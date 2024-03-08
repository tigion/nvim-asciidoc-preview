# nvim-asciidoc-preview

A simple AsciiDoc preview while editing AsciiDoc documents in Neovim.

> [!WARNING]
> The plugin is ~~in an early stage~~ not fully tested.
> Use at your own risk.
>
> Works on: ✅ Linux, ✅ macOS, but not yet on ❌ Windows (WSL❓)

<img width="1000" alt="Screenshot" src="https://user-images.githubusercontent.com/31811/214418871-14477f16-fe26-4b08-b864-77113997d321.png">

The plugin started as a playground for learning Neovim plugin programming
with Lua and a server component with Node.js.
Therefore, many things are not solved optimally and partly implemented
twice (plugin and server). Helpful tips are welcome.

## Features

- Once started with `:AsciiDocPreview`, a preview of the current AsciiDoc
  file is shown in the web browser.
- The preview is updated every time the AsciiDoc file is saved.
- When exiting Neovim or using the `:AsciiDocPreviewStop` command,
  the preview server is terminated in the background.
- The generation of the HTML preview is done either with:
  - [Asciidoctor.js](https://docs.asciidoctor.org/asciidoctor.js/latest/)
    (default, no local installed Asciidoctor needed)
  - Or the locally installed [Asciidoctor](https://docs.asciidoctor.org/asciidoctor/latest/)
    tools (`asciidoctor` and `asciidoctor-diagram`).
    The `asciidoctor` command must be available. ([Install instruction (de)](https://www.informatik.htw-dresden.de/~zirkelba/praktika/se/arbeiten-mit-git-und-asciidoc/installation-und-konfiguration/index.html#_variante_2_asciidoctor_lokal_installiert))

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
  build = 'cd server && npm install',
  opts = {
    -- Add user configuration here
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

<details>
  <summary>Show instruction</summary>

```lua
use({
  'tigion/nvim-asciidoc-preview',
  run = 'cd server && npm install',
  config = function()
    require('asciidoc-preview').setup({
      -- Add user configuration here
    })
  end,
})
```

</details>

## Configuration

For [lazy.nvim](https://github.com/folke/lazy.nvim) use the `opts` or `config` property.

```lua
opts = {
  server = {
    converter = 'js'
  },
  preview = {
    position = 'current',
  },
}
```

<details>
  <summary>Variant with config</summary>

```lua
config = function()
  require('asciidoc-preview').setup({
    server = {
      converter = 'js'
    },
    preview = {
      position = 'current',
    },
  })
end,
```

</details>

For other plugin manager, call the setup function
`require('asciidoc-preview').setup({ ... })` directly.

### Default Options

Currently available settings for the user:

```lua
{
  -- Server options
  server = {
    -- Determines how the AsciiDoc file is converted to HTML for the preview.
    -- `js`  - Asciidoctor.js (no local installation needed)
    -- `cmd` - Asciidoctor command (local installation needed)
    converter = 'js',
  },
  -- Preview options
  preview = {
    -- Determines the scroll position of the preview website.
    -- `current` - Keep current scroll position
    -- `start`   - Start of the website
    -- `sync`    - (experimental) Same (similar) position as in Neovim
    --             => inaccurate, because very content dependent
    position = 'current',
  },
}
```

## Usage

| Command                  | Description                                                                                                       |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `:AsciiDocPreview`       | Starts the AsciiDoc preview server in background and opens the current AsciiDoc file in the standard web browser. |
| `:AsciiDocPreviewStop`   | Stops the AsciiDoc preview server.                                                                                |
| `:AsciiDocPreviewOpen`   | (if needed) (Re)Opens the current AsciiDoc file in the standard web browser.                                      |
| `:AsciiDocPreviewNotify` | (if needed) Notifies server about an update on the last saved AsciiDoc file.                                      |

A keymap suggestion:

```lua
vim.keymap.set('n', '<Leader>cp', ':AsciiDocPreview<CR>', { desc = 'Preview AsciiDoc document' })
```

To use the same keymap for different file types and plugins (e.g. [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)),
place it in `after/ftplugin/asciidoc.lua`.
This way the keymap is only set for AsciiDoc files.

```lua
local opts = { buffer = true, silent = true }
opts.desc = 'Preview AsciiDoc document'
vim.keymap.set('n', '<Leader>cp', ':AsciiDocPreview<CR>', opts)
```
