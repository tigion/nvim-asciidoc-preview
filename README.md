# nvim-asciidoc-preview

A simple AsciiDoc preview while editing AsciiDoc documents in Neovim.

> [!WARNING]
> The plugin is ~~in an early stage~~ not fully tested.
> Use at your own risk.
>
> Works on: ✅ Linux, ✅ macOS and ✅ Windows with WSL2

<img width="1000" alt="Screenshot 2024-10-30" src="https://github.com/user-attachments/assets/ac63f6df-292b-4d6d-8680-829083d0dc16">

The plugin started as a playground for learning Neovim plugin programming
with Lua and a server component with Node.js.
Therefore, many things are not solved optimally and partly implemented
twice (plugin and server). Helpful tips are welcome.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [FAQ](#faq)

## Features

- Once started with `:AsciiDocPreview`, a preview of the current AsciiDoc
  file is shown in the web browser.
- The preview is updated every time the AsciiDoc file is saved or a new
  AsciiDoc file is opened.
- When exiting Neovim, no open Asciidoc files exists or using the
  `:AsciiDocPreviewStop` command, the preview server is terminated in the
  background.
- The generation of the HTML preview is done either with:
  - [Asciidoctor.js](https://docs.asciidoctor.org/asciidoctor.js/latest/)
    (default, no local installed Asciidoctor needed)
  - Or the locally installed [Asciidoctor](https://docs.asciidoctor.org/asciidoctor/latest/)
    tools (`asciidoctor` and `asciidoctor-diagram`).

## Requirements

- Neovim >= 0.8
- Node.js with `node` and `npm` command
- `curl` command

The plugin allows optionally using the local installed Asciidoctor tools.

- This requires the `asciidoctor` command with the `asciidoctor-diagram` extension.
  - [Install instruction (de)]

[Install instruction (de)]: https://www.informatik.htw-dresden.de/~zirkelba/praktika/se/arbeiten-mit-git-und-asciidoc/installation-und-konfiguration/index.html#_variante_2_asciidoctor_lokal_installiert

## Installation

### [lazy.nvim]

[lazy.nvim]: https://github.com/folke/lazy.nvim

```lua
{
  'tigion/nvim-asciidoc-preview',
  ft = { 'asciidoc' },
  build = 'cd server && npm install',
  opts = {
    -- Add user configuration here
  },
}
```

### [packer.nvim]

[packer.nvim]: https://github.com/wbthomason/packer.nvim

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
  server = {
    -- Determines how the AsciiDoc file is converted to HTML for the preview.
    -- `js`  - asciidoctor.js (no local installation needed)
    -- `cmd` - asciidoctor command (local installation needed)
    converter = 'js',

    -- Determines the local port of the preview website.
    -- Must be between 10000 and 65535.
    port = 11235,
  },
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
| `:AsciiDocPreviewStop`   | (if needed) Stops the AsciiDoc preview server.                                                                    |
| `:AsciiDocPreviewOpen`   | (if needed) (Re)Opens the current AsciiDoc file in the standard web browser.                                      |
| `:AsciiDocPreviewNotify` | (if needed) Notifies the server to display the current AsciiDoc file in the preview.                              |

A keymap suggestion:

```lua
vim.keymap.set('n', '<Leader>cp', ':AsciiDocPreview<CR>', { desc = 'Preview AsciiDoc document' })
```

- To use the same keymap for different file types and plugins (e.g. [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)),
  place the following in `after/ftplugin/asciidoc.lua`:

  ```lua
  local opts = { buffer = true, silent = true }
  opts.desc = 'Preview AsciiDoc document'
  vim.keymap.set('n', '<Leader>cp', ':AsciiDocPreview<CR>', opts)
  ```

  This way the keymap is only set for AsciiDoc files.

## FAQ

### How do I report an issue?

1. Open an AsciiDoc document in Neovim.
2. Run the `:checkhealth asciidoc-preview` command.
3. Open a new [Issue](https://github.com/tigion/nvim-asciidoc-preview/issues/new).
4. Describe your problem and include:
   - the `checkhealth` output
   - the [Installation/Configuration](#installation) with the used package manager
   - the content of the `~/.local/state/nvim/nvim-asciidoc-preview-server.log` file

> [!WARNING]
> The `nvim-asciidoc-preview-server.log` file contains **private information**
> from the current/last session. These are, for example, the name of your
> **home directory** and the names of the **AsciiDoc files** used.
>
> Do **not** share this information with others.
> So please remove or anonymize this information before.
