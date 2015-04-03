{BufferedProcess} = require 'atom'
{ResizablePanel} = require 'atom-resizable-panel'
{TreeEntryView, TreeView} = require 'atom-tree-view'

module.exports =
class GoOutlineView extends TreeView
  initialize: ->
    super

    @panel = new ResizablePanel item: this, position: 'left'
    @panel.width 200

    @open '/usr/lib/go/src/pkg/'

  open: (@path)->
    @focus()

    exit = (code)=>
    stderr = (output)=>
      atom.notifications.addError output

    pe = null
    fe = null
    stdout = (output)=>
      # console.log output
      for decl in output.split '\n'
        continue if decl is ''
        if decl.startsWith 'pkg'
          pe = new TreeEntryView
            text: decl.substring 4
            icon: 'icon-file-directory'
          @addEntry pe
        else if decl.startsWith 'file'
          s = decl.split '/'
          fe = new TreeEntryView
            text: s[s.length-1]
            icon: 'icon-file-text'
          pe.addEntry fe
        else
          e = new TreeEntryView text: decl
          e.addClass switch
            when decl.startsWith 'var'   then 'text-info'
            when decl.startsWith 'func'  then 'text-success'
            when decl.startsWith 'type'  then 'text-warning'
            when decl.startsWith 'const' then 'text-error'
          fe.addEntry e



    # command = atom.config.get 'go-find-references.path'
    command = 'go-outline'
    args = ['-path', path, '-public']
    process = new BufferedProcess({command, args, stdout, stderr, exit})
