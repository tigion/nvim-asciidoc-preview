// controller/asciidoc.js

// load required modules
const fs = require("fs");
const path = require("path");
const asciidoctor = require("asciidoctor");
const kroki = require("asciidoctor-kroki");

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
async function convertWithAsciidoctorJs(file, useAsciidoctorConfigs) {
  // Create a new extension registry.
  const registry = asciidoctor.Extensions.create();

  // Register the Kroki extension to handle diagrams.
  kroki.register(registry);

  // Add a docinfo processor to inject the reload script
  // into the head of the HTML.
  registry.docinfoProcessor(function () {
    this.atLocation("head");
    this.process(() => reloadScript);
  });

  // Read file content.
  let content = fs.readFileSync(file, "utf8");

  // Prepend config headers (if present and enabled).
  if (useAsciidoctorConfigs) {
    const configHeaders = loadAsciidoctorConfigHeaders(file);
    if (configHeaders) {
      content = configHeaders + "\n" + content;
    }
  }

  // Convert with Asciidoctor.js to HTML.
  const html = await asciidoctor.convert(content, {
    standalone: true,
    to_file: false,
    safe: "unsafe",
    base_dir: path.dirname(path.resolve(file)),
    attributes: {
      webfonts: "",
      "data-uri": "",
    },
    extension_registry: registry,
  });

  return html;
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
async function convertAsciidocToHtml(
  processor,
  file,
  cacheDir,
  useAsciidoctorConfigs,
) {
  switch (processor) {
    case "js":
      return await convertWithAsciidoctorJs(file, useAsciidoctorConfigs);
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
