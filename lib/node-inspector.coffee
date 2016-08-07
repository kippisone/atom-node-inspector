NodeInspector = require 'node-inspector'
exec = require('child_process').exec
spawn = require('child_process').spawn
path = require 'path'
fs = require 'fs'
co = require 'co'

module.exports = NodeInspector =
  start: ->
    return co ->
      if !NodeInspector.isInstalled()
        installState = yield NodeInspector.install()
        console.log installState

      status = yield NodeInspector.status()
      return 'already runing' if status
      console.log 'Start Inspector', status

      yield new Promise (resolve, reject) ->
        cmd =
          path.join __dirname, '../node_modules/node-inspector/bin/inspector.js'

        args = [
          '--web-port',
          '8082'
        ]

        opts =
          detach: true
          cwd: process.cwd()
          env: process.env

        inspector = spawn cmd, args, opts
        inspector.stdout.on 'data', (data) ->
          console.log 'NEW' + data

        inspector.stderr.on 'data', (err) ->
          console.log 'ERR', err.toString()

        inspector.on 'close', (code) ->
          console.log 'Process stoped', code
          resolve 'Success' if !code
          reject 'Failed! ' + code

  status: ->
    return new Promise (resolve, reject) ->
      exec 'pgrep -fa node-inspector', (err, stdout, stderr) ->
        return reject err if err
        return reject stderr if stderr

        processes = stdout.split('\n')
        console.log 'PGREP: PIDS ' + processes
        return resolve true if stdout.length < 1
        resolve false

  install: ->
    return new Promise (resolve, reject) ->
      opts =
        cwd: path.join(__dirname, '../')
      cp = spawn 'npm install node-inspector', opts
      cp.stdout.on 'data', (data) ->
        console.log data
      cp.stderr.on 'data', (data) ->
        console.error data
      cp.on 'close', (code) ->
        resolve 'Installed!' if !code
        reject 'Installation failed!'
  isInstalled: ->
    try
      fs.accessSync path.join(__dirname, '../node_modules/node-inspector/package.json')
      return true
    catch err
      return false
