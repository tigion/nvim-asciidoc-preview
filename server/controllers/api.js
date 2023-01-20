// controllers/api.js

// local modules
const data = require('../data.js')
const helper = require('../helper.js')

// send server infos
exports.getServer = (req, res) => {
  console.log('API: Sending json server')
  res.json({
    'version': `Node.js ${process.version}`,
    'uptime': Math.floor(process.uptime()),
    'pid': process.pid,
    'arch': process.arch,
    'file': data.asciidoc.file,
    'clients': data.clients.length,
  })
}

// send file
exports.getFile = (req, res) => {
  console.log('API: Sending json file')
  res.json({
    'file': data.asciidoc.file,
  })
}

// receive file
exports.setFile = (req, res) => {
  // get received data
  const newFile = req.body.file

  // handle received file
  if (helper.isValidFile(newFile, data.asciidoc.extensions)) {
    console.log(`API: Receiving valid file '${newFile}'`)

    // set update or create state
    if (data.asciidoc.file) {
      res.status(204) // No Content (200, 204)
    } else {
      res.status(201) // Created (201)
    }

    // set only if it is a new file
    if (newFile != data.asciidoc.file) {
      data.asciidoc.file = newFile
      exports.notifyClientsToUpdate()
    }

    //res.send('Valid file')
    res.end();
  } else {
    console.log(`API: Receiving not valid file '${newFile}'`)
    res.status(400) // Bad Request
    //res.send('No valid file')
    res.end();
  }
}

// send hi message
exports.hi = (req, res) => {
  res.status(200)
  res.json({
    'hi': 'Coffee please',
  })
}

// receive action: subscribe client
exports.subscribe = (req, res) => {
  console.log('API: Receiving subscribtion')

  // send header keep alive
  const headers = {
    'Content-Type': 'text/event-stream',
    'Connection': 'keep-alive',
    'Cache-Control': 'no-cache'
  };
  res.writeHead(200, headers);

  // store client response
  const clientId = Date.now();
  const newClient = { id: clientId, response: res, };
  data.clients.push(newClient);
  res.write('you are subscribed\n');
  console.log(`Server: Client '${clientId}' registered`);

  // listen for client 'close' requests
  req.on('close', () => {
    console.log(`Server: Client '${clientId}' connection closed`);
    data.clients = data.clients.filter(client => client.id !== clientId);
  });
}

// receive action: notify clients
exports.notify = (req, res) => {
  exports.notifyClientsToUpdate()
  res.status(204) // No Content
  res.end()
}

// receive action: stop server
exports.stop = (req, res) => {
  console.log('API: Receiving server stop')
  data.asciidoc.file = 'stop'
  exports.notifyClientsToClose()
  res.status(204) // No Content
  res.end()
  helper.waitToClose(data.server)
}

// send update notify to all clients
exports.notifyClientsToUpdate = () => {
  console.log('Server: Notify all clients to update')
  data.clients.forEach(client => client.response.write('data: update\n\n'))
}

// send close notify to all clients
exports.notifyClientsToClose = () => {
  console.log('Server: Notify all clients to close')
  data.clients.forEach(client => client.response.end('data: update\n\n'))
}
