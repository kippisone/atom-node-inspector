NodeInspector = require 'node-inspector'
exec = require('child_process').exec
spawn = require('child_process').spawn
path = require 'path'

module.exports = NodeInspector =
  start: ->
    return new Promise (resolve, reject) ->
      NodeInspector.status()
      .then (status) ->
        return resolve('already runing') if status

        console.log 'Start Inspector', status

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
          resolve('with pid ' + data)

        inspector.stderr.on 'data', (err) ->
          console.log 'ERR', err
          reject err

        inspector.on 'close', (code) ->
          console.log 'Process stoped', code

      .catch (err) ->
        console.error err
        reject err
  status: ->
    return new Promise (resolve, reject) ->
      exec 'pgrep -fa node-inspector', (err, stdout, stderr) ->
        return reject err if err
        return reject stderr if stderr

        processes = stdout.split('\n')
        console.log 'PGREP: PIDS ' + processes
        return resolve true if stdout.length < 1
        resolve false
