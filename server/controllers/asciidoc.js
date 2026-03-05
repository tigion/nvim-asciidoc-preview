// controller/asciidoc.js

// load required modules
const fs = require("fs");
const path = require("path");

// set reload script
const reloadScript = '<script src="script.js"></script>';

// Collect .asciidoctorconfig content by walking up from the file's directory.
// Configs are collected root-first so that closer configs override parent ones
// (Asciidoctor's last-attribute-wins behavior).
function loadAsciidoctorConfigHeaders(file) {
  const configs = [];
  let dir = path.dirname(path.resolve(file));
  const root = path.parse(dir).root;

  while (dir !== root) {
    for (const name of [".asciidoctorconfig", ".asciidoctorconfig.adoc"]) {
      const configPath = path.join(dir, name);
      if (!fs.existsSync(configPath)) continue;

      const content = fs.readFileSync(configPath, "utf-8");
      configs.push(`:asciidoctorconfigdir: ${dir}\n${content}`);
    }
    dir = path.dirname(dir);
  }

  return configs.reverse().join("\n");
}

// convert with Asciidoctor.js
function convertWithAsciidoctorJs(file, useAsciidoctorConfigs) {
  // needed Asciidoctor modules
  const Asciidoctor = require("asciidoctor");
  const asciidoctor = Asciidoctor();
  const kroki = require("asciidoctor-kroki");
  kroki.register(asciidoctor.Extensions);
  const registry = asciidoctor.Extensions.create();

  // add script for client registration and refresh event
  registry.docinfoProcessor(function () {
    const self = this;
    self.atLocation("head");
    self.process(function () {
      return reloadScript;
    });
  });

  // read file content and prepend config headers (if present and enabled)
  let content = fs.readFileSync(file, "utf-8");
  if (useAsciidoctorConfigs) {
    const configHeaders = loadAsciidoctorConfigHeaders(file);
    content = configHeaders + "\n" + content;
  }

  // convert with Asciidoctor.js to html
  return asciidoctor.convert(content, {
    to_file: false,
    standalone: true,
    safe: "unsafe", // unsafe: access files outside of the parent directory
    base_dir: path.dirname(path.resolve(file)),
    attributes: {
      webfonts: "", // use webfonts
      "data-uri": "", // embed images (base64)
    },
    extension_registry: registry,
  });
}

// convert with local installed Asciidoctor tools
function convertWithAsciidoctorCmd(file, cacheDir) {
  // -a ... set document attributes (overwrites source attributes)
  //        - webfonts ... use webfonts
  //        - toc=auto ... theme of content
  //        - data-uri ... embed images as base64
  // -e ... for embedded documents
  // -o ... output target (`-` stdout)
  const attributes = "-a toc=auto -a data-uri";
  const resources = "-r asciidoctor-diagram";
  let cmd = "asciidoctor";
  cmd = `${cmd} ${resources} ${attributes} -o - "${file}"`;

  // set command to run asciidoctor in cache directory
  cmd = `mkdir -p "${cacheDir}" && cd "${cacheDir}" && ${cmd}`;
  // console.log("DEBUG: " + cmd);

  // FIX: Handle build artefacts?!
  //      - Remove all generated files (content of build folder)
  //      - Generate on source file path
  //      - Generate on ~/.local/state/nvim/asciidoctor-preview
  //
  // convert mit Asciidoctor command
  const childProcess = require("child_process");
  const maxBuffer = 1024 * 1024 * 100;
  // const maxBuffer = undefined;
  let stdout;
  try {
    stdout = childProcess.execSync(cmd, { maxBuffer: maxBuffer });
  } catch (error) {
    console.log("ERROR: " + error);
    return "<p>An error occurred while creating the preview.</p>";
  }

  // check if stdout is null
  if (stdout == null) {
    console.log("ERROR: stdout is null");
    return "<p>Error: Nothing to preview!</p>";
  }

  // add script for client registration and refresh event
  // (not perfect, but it works)
  return stdout.toString() + reloadScript;
}

// convert AsciiDoc to HTML
function convertAsciidocToHtml(
  processor,
  file,
  cacheDir,
  useAsciidoctorConfigs,
) {
  switch (processor) {
    case "js":
      return convertWithAsciidoctorJs(file, useAsciidoctorConfigs);
    case "cmd":
      return convertWithAsciidoctorCmd(file, cacheDir);
    default:
      return "<p>Error: Invalid converter!</p>";
  }
}

// module exports
module.exports = {
  convertAsciidocToHtml,
};
