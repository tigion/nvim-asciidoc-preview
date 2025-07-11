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
  - Updating the preview while typing is currently not supported.
    A workaround is in the [FAQ](#faq-live-preview).
- When exiting Neovim, no open Asciidoc files exists or using the
  `:AsciiDocPreviewStop` command, the preview server is terminated in the
  background.
- The generation of the HTML preview is done either with:
  - [Asciidoctor.js](https://docs.asciidoctor.org/asciidoctor.js/latest/)
    (default, no local installed Asciidoctor needed)
  - Or the locally installed [Asciidoctor](https://docs.asciidoctor.org/asciidoctor/latest/)
    tools (`asciidoctor` and `asciidoctor-diagram`).

## Requirements

- Neovim >= 0.10
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
  build = 'cd server && npm install --omit=dev',
  ---@module 'asciidoc-preview'
  ---@type asciidoc-preview.Config
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
  run = 'cd server && npm install --omit=dev',
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

### <a name="faq-live-preview"></a>Is there a way to update the preview as I edit the AsciiDoc document?

[auto-save.nvim]: https://github.com/okuuva/auto-save.nvim
[autosave.nvim]: https://github.com/brianhuster/autosave.nvim

The plugin itself does currently not support this. However, you can use an
extra plugin for automatic saving like [auto-save.nvim] or [autosave.nvim] to
automatically save the AsciiDoc document after every change. Thanks to
[brianhuster](https://github.com/tigion/nvim-asciidoc-preview/issues/6#issuecomment-2370163011)
for the idea.

With [auto-save.nvim] you can use the following
[Condition](https://github.com/okuuva/auto-save.nvim#condition) to only
automatically save AsciiDoc files:

```lua
-- Configuration part of the plugin auto-save.nvim
opts = {
  -- Activate automatic saving only for specified file types.
  condition = function(buf)
    local filetype = vim.fn.getbufvar(buf, "&filetype")
    local filetypes = { 'asciidoc', 'asciidoctor' } -- List of allowed file types.
    return vim.list_contains(filetypes, filetype)
  end,
  -- I think a delay between 1000 and 3000 ms is okay.
  -- To low delays might cause performance issues with
  -- the rendering of the AsciiDoc preview!
  debounce_delay = 2000,
}
```

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
> from the current/last session. These are, for example, the (user) name of
> your **home directory** and the file names of the **AsciiDoc files** used.
>
> If you **don't** want to share this information with others,
> remove or anonymize the relevant parts.
