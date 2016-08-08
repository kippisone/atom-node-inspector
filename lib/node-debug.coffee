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

  config:
    nodePath:
      type: 'string'
      default: 'node'

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

      mainFile = NodeDebug.getMainFile(curDir)

      args = [
        '--debug-brk'
        mainFile.file
      ]

      opts =
        'env': process.env
        'cwd': mainFile.dir

      cmd = atom.config.get('node-debug.nodePath')

      if process.platform == 'win32'
        args = ['/c', cmd].concat(args)
        cmd = 'cmd.exe'

      console.log 'CMD:', cmd
      console.log 'ARGS:', args
      console.log 'OPTS:', opts

      ndbg = spawn(cmd, args, opts)
      ndbg.stderr.on 'data', (err) ->
        console.error err.toString()

      ndbg.stdout.on 'data', (data) ->
        console.log data.toString()

      ndbg.on 'close', (state) ->
        console.log 'FIN', state

      browserOpts =
        preferredBrowsers : ['chromium', 'chrome', 'opera']

      browser 'http://localhost:8082', browserOpts, (err, ok, instance) ->
        instance.on 'stop', ->
          console.log 'Browser stoped, kill debug session'
          # ndbg.kill()

    .catch (err) ->
      console.error(err)

  getMainFile: (curDir) ->
    projectDirs = atom.project.getPaths(curDir)
    projectDir = project for project in projectDirs when curDir.startsWith project
    console.log projectDirs, projectDir, curDir

    pkg = require path.join projectDir || projectDirs[0], 'package.json'

    project =
      dir: projectDir
      file: pkg.debug || pkg.main

    console.log('MAIN', project)
    return project
