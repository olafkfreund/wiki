---
description: LunarVim plugin configuration for Linux (~/config/lvim/config.lua) and Windows. Includes Copilot, ChatGPT, terminal plugins, and DevOps/LLM best practices for 2025.
---

# LunarVim Plugins (2025)

This page provides actionable plugin configurations for LunarVim on Linux, NixOS, WSL, and Windows. These plugins enhance DevOps workflows, LLM integration, and terminal productivity.

## Linux/NixOS/WSL Example (`~/.config/lvim/config.lua`)

```lua
lvim.plugins = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    }
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true
  },
  {
    's1n7ax/nvim-terminal',
    config = function()
      vim.o.hidden = true
      require('nvim-terminal').setup()
    end,
  },
}

local ok, copilot = pcall(require, "copilot")
if ok then
  copilot.setup {
    suggestion = {
      keymap = {
        accept = "<c-l>",
        next = "<c-j>",
        prev = "<c-k>",
        dismiss = "<c-h>",
      },
    },
  }
end
```

## Windows Example (`%APPDATA%/lvim/config.lua`)

```lua
lvim.plugins = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    }
  },
}

local ok, copilot = pcall(require, "copilot")
if ok then
  copilot.setup {
    suggestion = {
      keymap = {
        accept = "<c-l>",
        next = "<c-j>",
        prev = "<c-k>",
        dismiss = "<c-h>",
      },
    },
  }
end
```

---

## DevOps & LLM Best Practices (2025)
- Use Copilot and ChatGPT plugins for code, YAML, and IaC suggestions
- Use terminal plugins for running CLI tools (kubectl, terraform, ansible, etc.) inside LunarVim
- Keep plugins and LunarVim up to date for security and new features
- Validate LLM-generated code before deploying to production
- Store plugin configs in version control (dotfiles repo)

## Common Pitfalls
- Not restarting LunarVim after plugin changes
- Plugin conflicts (check plugin docs for compatibility)
- Missing dependencies (ensure all required tools are installed)

---

## References
- [LunarVim Plugins Guide](https://www.lunarvim.org/docs/configuration/plugins/)
- [Copilot.nvim](https://github.com/zbirenbaum/copilot.lua)
- [ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim)
- [ToggleTerm.nvim](https://github.com/akinsho/toggleterm.nvim)
- [nvim-terminal](https://github.com/s1n7ax/nvim-terminal)
