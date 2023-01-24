# nvim-asciidoc-preview

A simple AsciiDoc preview while editing AsciiDoc documents in Neovim.

> **Warning**
> The plugin is in an early stage. Use at your own risk.

<img width="1000" alt="Screenshot" src="https://user-images.githubusercontent.com/31811/214418871-14477f16-fe26-4b08-b864-77113997d321.png">

The plugin started as a playground for learning Neovim plugin programming with Lua and a server component with Node.js.
Therefore, many things are not solved optimally and partly implemented twice (plugin and server). Helpful tips are welcome.

> **Note** More instructions and information will follow soon.

## Features

- once started with `:AsciiDocPreviewStart`, a preview of the current AsciiDoc file is shown in the web browser
- the preview is updated every time the AsciiDoc file is saved
- when exiting Neovim or using the `:AsciiDocPreviewStop` command, the preview server is terminated in the background
- the generation of the HTML preview is done either with:
  - [Asciidoctor.js](https://docs.asciidoctor.org/asciidoctor.js/latest/) (default, no local installed Asciidoctor needed)
  - or the locally installed [Asciidoctor](https://docs.asciidoctor.org/asciidoctor/latest/) tools

## Requirements

- Node.js
- Neovim >= 0.8
- (optional) Asciidoctor
  - asciidoctor command with asciidoctor-diagram

## Installation

⏳ ... follows soon

## Configuration

⏳ ... follows soon

## Usage

- `:AsciiDocPreviewStart` ... starts the AsciiDoc preview server in background and opens the current AsciiDoc file in the standard browser
- `:AsciiDocPreviewStop` ... stops the AsciiDoc preview server

- `:AsciiDocPreviewOpen` ... (if needed) opens the current AsciiDoc file in the standard browser
- `:AsciiDocPreviewNotify` ... (if needed) notifies server about an update on the current AsciiDoc file
