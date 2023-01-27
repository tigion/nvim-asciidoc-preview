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
    'clients': data.clients.length,
  })
}

// send file
exports.getFile = (req, res) => {
  console.log('API: Sending json file')
  res.json({
    'file': { 
      'path': data.file.path,
      'position': data.file.position,
    }
  })
}

// receive file
exports.setFile = (req, res) => {
  // get received data
  const newFileName = req.body.file.path
  const newFilePos = req.body.file.position
  console.log('DEBUG: ' + newFileName + ' - ' + newFilePos)

  // handle received file
  if (helper.isValidFile(newFileName, data.asciidoc.extensions)) {
    console.log(`API: Receiving valid file '${newFileName}'`)

    // set update or create state
    if (data.file.path) {
      res.status(204) // No Content (200, 204)
    } else {
      res.status(201) // Created (201)
    }

    // set only if it is a new file or position
    if (newFileName != data.file.path || newFilePos != data.file.position) {
      data.file.path = newFileName
      data.file.position = newFilePos
      exports.notifyClientsToUpdate()
    }

    //res.send('Valid file')
    res.end();
  } else {
    console.log(`API: Receiving not valid file '${newFileName}'`)
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
  data.file.path = 'stop'
  exports.notifyClientsToClose()
  res.status(204) // No Content
  res.end()
  helper.waitToClose(data.server)
}

// send update notify to all clients
exports.notifyClientsToUpdate = () => {
  console.log('Server: Notify all clients to update')
  data.clients.forEach(client => client.response.write(`data: ${data.file.position}\n\n`))
}

// send close notify to all clients
exports.notifyClientsToClose = () => {
  console.log('Server: Notify all clients to close')
  data.clients.forEach(client => client.response.end('data: close\n\n'))
}
