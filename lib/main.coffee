module.exports = GoOutline =
  config:
    path:
      title: 'go-outline path'
      description: 'Set this if the go-outline executable is not found within your PATH'
      type: 'string'
      default: 'go-outline'
  activate: ->
    view = new (require './go-outline-view')
