NodeDebugView = require './node-debug-view'
NodeInspector = require './node-inspector'
spawn = require('child_process').spawn
path = require 'path'
browser = require 'biased-opener'

{ CompositeDisposable } = require 'atom'

console.log 'Project', process.cwd()
module.exports = NodeDebug =
  nodeDebugView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @nodeDebugView = new NodeDebugView(state.nodeDebugViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @nodeDebugView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'node-debug:run': => @run()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @nodeDebugView.destroy()

  serialize: ->
    nodeDebugViewState: @nodeDebugView.serialize()

  toggle: ->
    console.log 'NodeDebug was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  run: ->
    console.log 'Run node-debug'
    console.log('Starting node-inspector')
    NodeInspector.start()
    .then (state) ->
      console.log('..' + state)

      editor = atom.workspace.getActiveTextEditor()
      curDir = path.dirname(editor.getPath())
      curFile = path.basename(editor.getPath(curDir))

      args = [
        '--debug-brk'
        curFile
      ]
      opts =
        'env': process.env
        'cwd': curDir

      cmd = 'node'

      console.log 'CMD:', cmd
      console.log 'ARGS:', args
      console.log 'OPTS:', opts

      ndbg = spawn(cmd, args, opts)
      ndbg.stderr.on 'data', (err) ->
        console.error err

      ndbg.stdout.on 'data', (data) ->
        console.log data

      ndbg.on 'close', ->
        console.log 'FIN'

      browserOpts =
        preferredBrowsers : ['chromium', 'chrome', 'opera']

      browser 'http://localhost:8082', browserOpts, (err, ok, instance) ->
        instance.on 'stop', ->
          console.log 'Browser stoped, kill debug session'
          ndbg.kill()

    .catch (err) ->
      console.error(err)
