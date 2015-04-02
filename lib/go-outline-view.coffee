{BufferedProcess} = require 'atom'
{ResizablePanel} = require 'atom-resizable-panel'
{TreeEntryView, TreeView} = require 'atom-tree-view'

module.exports =
class GoOutlineView extends TreeView
  initialize: ->
    super

    @panel = new ResizablePanel item: this, position: 'left'
    @panel.width 200

    @open '/home/dev/go/go-outline/testpkg/'

  open: (@path)->
    @focus()

    exit = (code)=>
    stderr = (output)=>
      atom.notifications.addError output

    fileentry = null
    stdout = (output)=>
      for decl in output.split '\n'
        continue if decl is ""
        if decl.startsWith 'file'
          s = decl.split('/')
          fileentry = new TreeEntryView
            text: s[s.length-1]
            icon: 'icon-file-text'
          @addEntry fileentry
        else
          fileentry.addEntry new TreeEntryView
            text: decl

    # command = atom.config.get 'go-find-references.path'
    command = 'go-outline'
    args = ['-path', path]
    process = new BufferedProcess({command, args, stdout, stderr, exit})
