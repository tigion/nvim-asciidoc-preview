// server.js

// express module
const express = require('express')
const app = express()
app.use(express.json())

// modules

// local modules
const data = require('./data.js')
const indexRoute = require('./routes/index.js')
const apiRoute = require('./routes/api.js')
const apiController = require('./controllers/api.js')
const helper = require('./helper')

// handle command line arguments
for (let i = 2; i < process.argv.length; i++) {
  switch (process.argv[i]) {
    // set Asciidoc file
    case '--file':
      i++
      if (i == process.argv.length) continue
      const file = process.argv[i]
      if (helper.isValidFile(file, data.asciidoc.extensions)) {
        data.asciidoc.file = file
      }
      break
    // set config
    case '--open-browser':
      data.config.openBrowser = true
      break
  }
}

// route website: '/'
app.use('/', indexRoute)

// route api: '/api'
app.use('/api', apiRoute)

// route 404 (last route)
app.use((req, res, next) => {
  res.status(404)
  res.send('Server Error<br />404: Page Not Found')
})

// start server
data.server = app.listen(data.config.port, data.config.hostname, () => {
  console.log(`Server: Running at http://${data.config.hostname}:${data.config.port}/`)
})

data.server.on('listening', () => {
  //console.log('Server: Listening...')
  if (data.config.openBrowser) {
    var openCmd = helper.getOpenCmd()
    if (openCmd != '') {
      console.log('Server: Open browser')
      const { spawn, exec } = require("child_process");
      var args = ['http://localhost:11235/']
      spawn(openCmd, args, { detached: true, })
      //exec(openCmd + ' ' + args[0], (error, stdout, stderr) => {});
    } else {
      console.log('Server: Open browser on \'' + process.platform + '\' not yet supported')
    }
  }
})

data.server.on('close', () => {
  console.log('Server: Stopping...')
  // TODO: kill after specific time?
})

process.on('SIGINT', () => {
  console.log('Server: Receiving SIGINT')
  data.asciidoc.file = 'stop'
  apiController.notifyClientsToClose()
  helper.waitToClose(data.server)
})

process.on('uncaughtException', (err, origin) => {
 console.log(
    `Caught exception: ${err}\n` +
    `Exception origin: ${origin}`,
  );
});
