// server.js

// express module
const express = require("express");
const app = express();
app.use(express.static("public"));
// app.use(express.static("public"), { dotfiles: "allow" });
app.use(express.json());

// modules
const parseArgs = require("node:util").parseArgs;

// local modules
const data = require("./data.js");
const indexRoute = require("./routes/index.js");
const apiRoute = require("./routes/api.js");
const apiController = require("./controllers/api.js");
const helper = require("./helper");

// parse command line arguments
const args = parseArgs({
  options: {
    port: { type: "string" },
    logdir: { type: "string" },
    cachedir: { type: "string" },
    file: { type: "string" },
    "open-browser": { type: "boolean" },
  },
});

// console.log(args);

// handle command line arguments
if (helper.isValidPort(parseInt(args.values.port))) {
  data.config.server.port = parseInt(args.values.port);
}
if (helper.isValidDirectory(args.values.logdir)) {
  data.config.logdir = args.values.logdir;
}
if (helper.isValidDirectory(args.values.cachedir)) {
  data.config.cachedir = args.values.cachedir + "/nvim-asciidoc-preview/";
}
if (helper.isValidFile(args.values.file, data.config.asciidoc.extensions)) {
  data.preview.filepath = args.values.file;
}
if (args.values["open-browser"]) {
  data.config.openBrowser = true;
}
console.log(data.config);

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
