# node-debug

Node.js debugging interface for Atom using node-inspector.  
[node-inspector](https://github.com/node-inspector/node-inspector) uses the Blink Developer Tools as debugging interface.

![node-debug screenshot](https://cloud.githubusercontent.com/assets/3463165/14064391/02f19412-f402-11e5-8f21-5bd3a59ed488.jpg)

Install
-------

The node-debug app installs `node-inspector` by its first start. This may takes a few seconds. Press `ctrl`+`alt`+`i` to open the atom console to see whats happend. The debugger should start after a successfully installation.

Run the debugger
----------------

The debugger will be start by the command `node-debug:run` or by pressing `ctrl`+`i`. The debugger reads the main file from package.json of the current project. It looks for a `debug` flag or reads from the `main` propertie.
