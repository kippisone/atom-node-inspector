# node-debug

Node.js debugging interface for Atom using node-inspector.  
[node-inspector](https://github.com/node-inspector/node-inspector) uses the Blink Developer Tools as debugging interface.

![node-debug screenshot](https://cloud.githubusercontent.com/assets/3463165/14064391/02f19412-f402-11e5-8f21-5bd3a59ed488.jpg)

Install
-------

The node-debug app installs `node-inspector` on its first start. This may take a few seconds. Press `ctrl`+`alt`+`i` to open the Atom console in order to see what's happened. The debugger should start after a successful installation.

Run the debugger
----------------

You can run the dubugger by using `node-debug:run` command or pressing `ctrl`+`i`. The debugger reads the main file from package.json of the current project. It looks for a `debug` flag or reads from the `main` property.
