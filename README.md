# nvim-asciidoc-preview

A simple AsciiDoc preview while editing AsciiDoc documents in Neovim.

> [!WARNING]
> The plugin is ~~in an early stage~~ not fully tested.
> Use at your own risk. Linux/macOS ✅ and Windows ❓.

<img width="1000" alt="Screenshot" src="https://user-images.githubusercontent.com/31811/214418871-14477f16-fe26-4b08-b864-77113997d321.png">

The plugin started as a playground for learning Neovim plugin programming
with Lua and a server component with Node.js.
Therefore, many things are not solved optimally and partly implemented
twice (plugin and server). Helpful tips are welcome.

More instructions and information will follow soon.

## Features

- once started with `:AsciiDocPreview`, a preview of the current AsciiDoc
  file is shown in the web browser
- the preview is updated every time the AsciiDoc file is saved
- when exiting Neovim or using the `:AsciiDocPreviewStop` command,
  the preview server is terminated in the background
- the generation of the HTML preview is done either with:
  - [Asciidoctor.js](https://docs.asciidoctor.org/asciidoctor.js/latest/)
    (default, no local installed Asciidoctor needed)
  - or the locally installed [Asciidoctor](https://docs.asciidoctor.org/asciidoctor/latest/)
    tools

## Requirements

- Neovim >= 0.8
- Node.js with `node` and `npm` command
- `curl` command
- (optional) Asciidoctor
  - `asciidoctor` command with `asciidoctor-diagram`

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'tigion/nvim-asciidoc-preview',
  cmd = { 'AsciiDocPreview' },
  ft = { 'asciidoc' },
  opts = {},
}
```

_plugins/asciidoc-preview.lua_:

```lua
return {
  'tigion/nvim-asciidoc-preview',
  cmd = { 'AsciiDocPreview' },
  ft = { 'asciidoc' },
  opts = {},
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'tigion/nvim-asciidoc-preview'
```

## Configuration

⏳ ... follows soon

## Usage

| Command                  | Description                                                                                                      |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| `:AsciiDocPreview`       | Starts the AsciiDoc preview server in background and opens the current AsciiDoc file in the standard web browser |
| `:AsciiDocPreviewStop`   | Stops the AsciiDoc preview server                                                                                |
| `:AsciiDocPreviewOpen`   | (if needed) Opens the current AsciiDoc file in the standard web browser                                          |
| `:AsciiDocPreviewNotify` | (if needed) Notifies server about an update on the last saved AsciiDoc file                                      |
