'use strict'

exec = require('child_process').exec
spawn = require('child_process').spawn
path = require 'path'
fs = require 'fs'
http = require 'http'
superchain = require 'superchain'

module.exports = NodeInspector =
  start: ->
    chain = superchain.chain()
    if !NodeInspector.isInstalled()
      console.log('Install node-inspector')
      chain.add () ->
        return NodeInspector.install()

    chain.add () ->
      return NodeInspector.status()
      .then (status) ->
        chain.end 'already runing' if status

    chain.add () ->
      console.log 'Start Inspector', status
      return new Promise (resolve, reject) ->
        cmd =
          path.join __dirname, '../node_modules/.bin/node-inspector'

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
          console.log data.toString()

        inspector.stderr.on 'data', (err) ->
          console.error err.toString()

        inspector.on 'close', (code) ->
          resolve 'Success' if !code
          reject 'Failed! ' + code
    return chain

  status: ->
    return new Promise (resolve, reject) ->
      req = http.get 'http://localhost:8082/', (res) ->
        console.log 'RES', res.statusCode
        resolve true
      req.on 'error', (err) ->
        console.error 'Request error', err
        resolve false
      req.end()
      # exec 'pgrep -fa node-inspector', (err, stdout, stderr) ->
      #   return reject err if err
      #   return reject stderr if stderr
      #
      #   processes = stdout.split('\n')
      #   console.log 'PGREP: PIDS ' + processes
      #   return resolve true if stdout.length < 1
      #   resolve false

  install: ->
    return new Promise (resolve, reject) ->
      opts =
        cwd: path.join(__dirname, '../')
        env: process.env
      console.log('Install opts', opts)

      cmd = atom.config.get('node-debug.nodePath').replace(/node$/, 'npm')
      cp = spawn cmd, ['install', 'node-inspector'], opts
      cp.stdout.on 'data', (data) ->
        console.log data.toString()
      cp.stderr.on 'data', (data) ->
        console.error data.toString()
      cp.on 'close', (code) ->
        resolve 'Installed!' if !code
        reject 'Installation failed!'
  isInstalled: ->
    try
      scriptPath =
        path.join __dirname, '../node_modules/node-inspector/package.json'
      fs.accessSync scriptPath
      return true
    catch err
      return false
