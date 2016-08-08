'use strict'

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
        args = [
          '--web-port',
          '8082'
        ]

        if process.platform == 'win32'
          args = [path.join __dirname, '../node_modules/node-inspector/bin/inspector.js'].concat(args)
          cmd = atom.config.get('node-debug.nodePath')
        else
          cmd =
            path.join __dirname, '../node_modules/.bin/node-inspector'

        console.log 'Spawn process'
        console.log 'CMD:', cmd
        console.log 'ARGS:', args

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

  install: ->
    return new Promise (resolve, reject) ->
      opts =
        cwd: path.join(__dirname, '../')
        env: process.env
      console.log('Install opts', opts)

      if process.platform == 'win32'
        cmd = atom.config.get('node-debug.nodePath').replace(/node(.exe)$/, 'npm.cmd')
        args = ['/c', cmd, 'install', 'node-inspector']
        cmd = 'cmd.exe'
      else
        cmd = atom.config.get('node-debug.nodePath').replace(/node$/, 'npm')
        args = ['install', 'node-inspector']
      cp = spawn cmd, args, opts
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
