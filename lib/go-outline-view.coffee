{BufferedProcess} = require 'atom'
{ResizablePanel} = require 'atom-resizable-panel'
{TreeEntryView, TreeView} = require 'atom-tree-view'
path = require 'path'

module.exports =
class GoOutlineView extends TreeView
  initialize: ->
    super()

    @panel = new ResizablePanel item: this, position: 'right'
    @panel.width 200

    @entries = {'.': @}
    @open '/home/stargazer/dev/goroot/src/pkg/errors'

  recordEntry: (relpath, entry)->
    return if relpath is ''
    up = path.dirname relpath
    unless @entries[up]?
      @recordEntry up, new TreeEntryView
        text: up
        icon: 'icon-file-directory'
    @entries[up].addEntry entry
    @entries[up].collapse()
    @entries[relpath] = entry

  open: (@dirpath)->
    @focus()

    exit = (code)=>
    stderr = (output)=>
      atom.notifications.addError output

    cur_file = null
    stdout = (output)=>
      for decl in output.split '\n'
        entrypath = null
        entry = null
        switch
          when decl is ''
            continue
          when decl.startsWith 'pkg'
            p = decl.substring 4
            entrypath = path.relative @dirpath, p
            entry = new TreeEntryView
              text: path.basename p
              icon: 'icon-file-directory'
          when decl.startsWith 'file'
            p = decl.substring 5
            entrypath = path.relative @dirpath, p
            entry = new TreeEntryView
              text: path.basename p
              icon: 'icon-file-text'
            cur_file = entrypath
          else
            s = decl.split ':'
            entrypath = path.join cur_file, s[0]
            entry = new TreeEntryView text: s[0]
            entry.lineFrom = parseInt(s[1])-1
            entry.lineTo = parseInt(s[2])-1
            entry.confirm = -> atom.workspace.open file, initialLine: entry.lineFrom
            entry.addClass switch
              when decl.startsWith 'var'   then 'text-info'
              when decl.startsWith 'func'  then 'text-success'
              when decl.startsWith 'const' then 'text-warning'
              when decl.startsWith 'type'  then 'text-error'
        @recordEntry entrypath, entry

    command = atom.config.get 'go-outline.path'
    args = ['-path', dirpath, '-public']
    process = new BufferedProcess({command, args, stdout, stderr, exit})
