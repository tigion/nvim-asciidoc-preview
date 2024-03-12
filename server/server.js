// server.js

// express module
const express = require("express");
const app = express();
app.use(express.static("public"));
app.use(express.json());

// modules

// local modules
const data = require("./data.js");
const indexRoute = require("./routes/index.js");
const apiRoute = require("./routes/api.js");
const apiController = require("./controllers/api.js");
const helper = require("./helper");

// handle command line arguments
console.log(process.argv);
for (let i = 2; i < process.argv.length; i++) {
  switch (process.argv[i]) {
    // set port
    case "--port": {
      i++;
      if (i == process.argv.length) continue;
      const port = process.argv[i];
      if (helper.isValidPort(port)) {
        data.config.server.port = port;
      }
      break;
    }
    // set Asciidoc file
    case "--file": {
      i++;
      if (i == process.argv.length) continue;
      const file = process.argv[i];
      if (helper.isValidFile(file, data.config.asciidoc.extensions)) {
        data.preview.filepath = file;
      }
      break;
    }
    // set config
    case "--open-browser":
      data.config.openBrowser = true;
      break;
  }
}

// route website: '/'
app.use("/", indexRoute);

// route api: '/api'
app.use("/api", apiRoute);

// route 404 (last route)
app.use((_req, res, _next) => {
  res.status(404);
  res.send("Server Error<br />404: Page Not Found");
});

// get server hostname and port from configuration
const hostname = data.config.server.hostname;
const port = data.config.server.port;

// set server url
const url = `http://${hostname}:${port}`;

// start `http.Server` server
data.server = app.listen(port, hostname, () => {
  console.log(`Server: Running at http://${hostname}:${port}/`);
});

data.server.on("listening", () => {
  //console.log('Server: Listening...')
  if (data.config.openBrowser) {
    const openCmd = helper.getOpenCmd();
    if (openCmd != "") {
      console.log("Server: Open browser");
      const { spawn } = require("child_process");
      const args = [url];
      spawn(openCmd, args, { detached: true });
      //exec(openCmd + ' ' + args[0], (error, stdout, stderr) => {});
    } else {
      console.log(
        "Server: Open browser on '" + process.platform + "' not yet supported",
      );
    }
  }
});

data.server.on("close", () => {
  console.log("Server: Stopping...");
  // TODO: kill after specific time?
});

process.on("SIGINT", () => {
  console.log("Server: Receiving SIGINT");
  apiController.notifyClientsToClose();
  helper.waitToClose(data.server);
});

process.on("uncaughtException", (err, origin) => {
  console.log(`Caught exception: ${err}\n` + `Exception origin: ${origin}`);
});
