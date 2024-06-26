--[[

  =====================================================================
  ==================== READ THIS BEFORE CONTINUING ====================
  =====================================================================

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a template for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you should start exploring, configuring and tinkering to
    explore Neovim!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example:
    - https://learnxinyminutes.com/docs/lua/


    And then you can explore or search through `:help lua-guide`
    - https://neovim.io/doc/user/lua-guide.html
  Kickstart Guide:

  I have left several `:help X` comments throughout the init.lua
  You should run that command and read that help section for more information.

  In addition, I have some `NOTE:` items throughout the file.
  These are for you, the reader to help understand what is happening. Feel free to delete
  them once you know what you're doing, but they should serve as a guide for when you
  are first encountering a few different constructs in your nvim config.

  I hope you enjoy your Neovim journey,
  - TJ

  P.S. You can delete this when you're done too. It's your config now :)
  --]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({

    {
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            require("nvim-navic").setup()
        end,
    },
    {
        'stevearc/dressing.nvim',
        opts = {},
    },
    -- { "xarthurx/taskwarrior.vim" },
    -- { "github/copilot.vim" },
    -- NOTE: First, some plugins that don't require any configuration
    { "rottencandy/vimkubectl" },
    --
    -- Git related plugins
    'tpope/vim-fugitive',
    -- 'tpope/vim-rhubarb',

    {
        "ThePrimeagen/git-worktree.nvim",
        config = function()
            require 'git-worktree'.setup()
            require("telescope").load_extension("git_worktree")
        end
    },

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    {
        "mfussenegger/nvim-lint",
        config = function()
            require('lint').linters_by_ft = {
                python = {
                    -- "pylint",
                    "mypy",
                    "ruff"
                }
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    require('lint').try_lint()
                end,
            })
        end
    },

    -- 'dense-analysis/ale',

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        opts = { inlay_hints = { enabled = true } },
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            { 'williamboman/mason.nvim', config = true },
            'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
            "mfussenegger/nvim-lint",
            'mhartington/formatter.nvim'

        },
    },
    {
        'tamago324/nlsp-settings.nvim',
        dependencies = {
            { 'williamboman/nvim-lsp-installer' },
        },
        config = function()
            local lsp_installer = require('nvim-lsp-installer')
            local lspconfig = require("lspconfig")
            local nlspsettings = require("nlspsettings")

            nlspsettings.setup({
                config_home = vim.fn.stdpath('config') .. '/nlsp-settings',
                local_settings_dir = ".nlsp-settings",
                local_settings_root_markers_fallback = { '.git' },
                append_default_schemas = true,
                loader = 'json'
            })

            function on_attach(client, bufnr)
                local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
                buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- disable helm diagnostic because its full of errors
                if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
                    vim.diagnostic.disable()
                end

                -- if client.server_capabilities.documentSymbolProvider then
                require("nvim-navic").attach(client, bufnr)
                -- end
            end

            local global_capabilities = vim.lsp.protocol.make_client_capabilities()
            global_capabilities.textDocument.completion.completionItem.snippetSupport = true

            lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
                capabilities = global_capabilities,
            })

            lsp_installer.on_server_ready(function(server)
                server:setup({
                    on_attach = on_attach
                })
            end)
        end
    },
    -- {
    --     "nvim-neorg/neorg",
    --     build = ":Neorg sync-parsers",
    --     dependencies = { "nvim-lua/plenary.nvim" },
    --     config = function()
    --         require("neorg").setup {
    --             load = {
    --                 ["core.defaults"] = {},  -- Loads default behaviour
    --                 ["core.concealer"] = {}, -- Adds pretty icons to your documents
    --                 ["core.dirman"] = {      -- Manages Neorg workspaces
    --                     config = {
    --                         workspaces = {
    --                             notes = "~/notes",
    --                         },
    --                     },
    --                 },
    --             },
    --         }
    --     end,
    -- },
    -- {
    --   "mhartington/formatter.nvim",
    --   config = function()
    --     require 'formatter'.setup()
    --   end
    -- },
    { 'rcarriga/nvim-notify' },
    { 'mg979/vim-visual-multi', branch = 'master' },
    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',

            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
        },
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = {},
        config = function(_, opts) require 'lsp_signature'.setup(opts) end
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,
    },
    { "tpope/vim-surround" },
    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim', opts = {} },
    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            on_attach = function(bufnr)
                vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
                    { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
                vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk,
                    { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
                vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk,
                    { buffer = bufnr, desc = '[P]review [H]unk' })
            end,
        },
    },
    {
        'stevearc/aerial.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
    },
    {
        'weirongxu/plantuml-previewer.vim',
        dependencies = {
            "tyru/open-browser.vim",
            "aklt/plantuml-syntax",
        }
    },
    { "vim-test/vim-test" },
    { "folke/neodev.nvim", opts = {} },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/neotest-python",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-neotest/nvim-nio"
        }
    },
    { "mbbill/undotree" },
    { "towolf/vim-helm" },
    { "mattn/emmet-vim" },
    { "glench/vim-jinja2-syntax" },
    { "vifm/vifm.vim" },

    -- colorschemes
    {
        "ronisbr/nano-theme.nvim",
        -- init = function()
        --     vim.o.background = "light" -- or "dark".
        -- end
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },

    { "ellisonleao/gruvbox.nvim" },

    { "projekt0n/github-nvim-theme" },
    { "sainnhe/everforest" },
    { "zootedb0t/citruszest.nvim" },
    { "nyngwang/nvimgelion" },
    { "miikanissi/modus-themes.nvim" },
    {
        'maxmx03/solarized.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            -- vim.o.background = 'dark' -- or 'light'
            -- vim.cmd.colorscheme 'solarized'
        end,
    },

    { "metalelf0/jellybeans-nvim" },
    { "marko-cerovac/material.nvim" },
    { "agude/vim-eldar" },
    { "vim/colorschemes" },
    { "NLKNguyen/papercolor-theme" },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        opts = {
            term_colors = true,
            transparent_background = false,
            styles = {
                comments = {},
                conditionals = {},
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
            },
            color_overrides = {
                mocha = {
                    base = "#000000",
                    mantle = "#000000",
                    crust = "#000000",
                },
            },
        },
    },
    { "Mofiqul/dracula.nvim" },
    { 'techtuner/aura-neovim' },
    { 'jordst/colorscheme' },
    -- { 'RRethy/nvim-base16' },
    -- { 'olivercederborg/poimandres.nvim' },
    -- { 'LunarVim/horizon.nvim' },
    { 'techygrrrl/techygrrrl-cmyk-colourrrs-neovim' },
    { 'jascha030/nitepal.nvim' },
    { 'maxmx03/fluoromachine.nvim' },
    { 'loctvl842/monokai-pro.nvim' },
    { 'hgoose/temple.vim' },
    { 'RaphaeleL/my_vivid' },
    { 'alek3y/spacegray.vim' },
    { 'cseelus/nvim-colors-tone' },
    { 'AndrewLockVI/dark_ocean.vim' },
    { 'seandewar/paragon.vim' },
    { "rose-pine/neovim",                           name = "rose-pine" },
    { "kwsp/halcyon-neovim" },
    { "bluz71/vim-moonfly-colors" },
    {
        "chrsm/paramount-ng.nvim",
        dependencies = { "rktjmp/lush.nvim" }
    },
    { url = "https://gitlab.com/madyanov/gruber.vim", name = "madyanov-gruber-vim" },

    { "ribru17/bamboo.nvim" },
    { "rebelot/kanagawa.nvim" },
    { "navarasu/onedark.nvim" },
    { "nyoom-engineering/oxocarbon.nvim" },
    { "bluz71/vim-moonfly-colors" },
    { "AlexvZyl/nordic.nvim" },
    { "mcchrish/zenbones.nvim" },
    { "shaunsingh/moonlight.nvim" },
    { "cpea2506/one_monokai.nvim" },

    { "ntk148v/komau.vim" },
    { "dgox16/oldworld.nvim" },
    {
        -- Theme inspired by Atom
        -- 'nyoom-engineering/oxocarbon.nvim',
        'jaredgorski/SpaceCamp',
        -- 'navarasu/onedark.nvim',
        priority = 1000
    },


    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                icons_enabled = false,
                -- theme = 'onedark',
                theme = 'auto',
                component_separators = '|',
                section_separators = '',
            },
        },
        winbar = {
            lualine_c = {
                {
                    "navic",
                    color_correction = nil,
                    navic_opts = nil
                }
            }
        }
    },
    {
        "leoluz/nvim-dap-go",
        config = function()
            require("dap-go").setup()
        end
    },
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            require "dap-python".setup("python")
        end
    },

    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        main = "ibl",
        opts = {},
        config = function()
            require 'ibl'.setup {
                indent = { char = "┊" }
            }
        end
    },

    {
        's1n7ax/nvim-window-picker',
        name = 'window-picker',
        event = 'VeryLazy',
        version = '2.*',
        config = function()
            require 'window-picker'.setup()
        end,
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim',        opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            'nvim-telescope/telescope-symbols.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
        config = function()
            require 'telescope'.setup {
                defaults = {
                    theme = "ivy"
                },
                extensions = {
                    file_browser = {
                        -- use the "ivy" theme if you want
                        theme = "ivy",
                    }
                }
            }
        end,
        -- config = function ()
        --   require'telescope'.setup {
        --     defaults = {
        --       file_ignore_patterns = { "\\.venv" }
        --     }
        --   }
        -- end
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },
    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        build = ':TSUpdate',
        config = function()
            vim.o.foldmethod = "expr"
            vim.o.foldexpr = "nvim_treesitter#foldexpr()"
            vim.o.foldenable = false
        end
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require 'neo-tree'.setup {
                filesystem = {
                    hijack_netrw_behavior = "disabled"
                }
            }
        end
    },
    { 'ThePrimeagen/refactoring.nvim' },
    {
        'stevearc/oil.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require 'oil'.setup {
                default_file_explorer = false
            }
        end
    },
    { "Mofiqul/vscode.nvim" },
    { "kdheepak/lazygit.nvim" },

    { "fatih/vim-go" },
    { "mattn/emmet-vim" },
    {
        "folke/todo-comments.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require("todo-comments").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end
    },
    {
        "nvim-pack/nvim-spectre",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require("spectre").setup {
            }
        end
    },
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    },
    {
        "simrat39/symbols-outline.nvim",
        config = function()
            require('symbols-outline').setup()
        end
    },
    -- {
    --     "ahmedkhalf/project.nvim",
    --     config = function()
    --         require("project_nvim").setup({
    --             patterns = { ".nvim-project" },
    --         })
    --         require('telescope').load_extension('projects')
    --     end
    -- },

    -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
    --       These are some example plugins that I've included in the kickstart repository.
    --       Uncomment any of the lines below to enable them.
    -- require 'kickstart.plugins.autoformat',
    -- require 'kickstart.plugins.debug',

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
    --    up-to-date with whatever is in the kickstart repo.
    --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --
    --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
    -- { import = 'custom.plugins' },
    { import = 'kickstart.plugins' }
    --
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set({ 'n' }, '<C-k>', function()
    require('lsp_signature').toggle_float_win()
end, { silent = true, noremap = true, desc = 'toggle signature' })

vim.keymap.set({ 'n' }, '<Leader>k', function()
    vim.lsp.buf.signature_help()
end, { silent = true, noremap = true, desc = 'toggle signature' })
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
    pickers = {
        colorscheme = {
            enable_preview = true
        }
    },
    defaults = {
        theme = "ivy",
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Enable telescope file-browser
pcall(require('telescope').load_extension, 'file_browser')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>ld', require('telescope.builtin').lsp_document_symbols,
    { desc = '[L]sp [D]ocument Symbols' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim', 'ocaml',
        'yaml',
        'json' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
                ['ab'] = '@block.outer',
                ['ib'] = '@block.inner',
                ['al'] = '@loop.outer',
                ['il'] = '@loop.inner',
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader>A'] = '@parameter.inner',
            },
        },
    },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
        vim.diagnostic.disable()
    end
    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
    -- clangd = {},
    gopls = {},
    pyright = {
        settings = {
            python = {
                formatting = {
                    provider = "black"
                }
            }
        }
    },
    -- rust_analyzer = {},
    -- tsserver = {},
    html = { filetypes = { 'html', 'twig', 'hbs' } },
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}

-- Setup neovim lua configuration
require("neodev").setup({
    library = { plugins = { "neotest" }, types = true },
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        }
    end
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'

require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        -- ['<Tab>'] = cmp.mapping(function(fallback)
        --     if cmp.visible() then
        --         cmp.select_next_item()
        --     elseif luasnip.expand_or_locally_jumpable() then
        --         luasnip.expand_or_jump()
        --     else
        --         fallback()
        --     end
        -- end, { 'i', 's' }),
        -- ['<S-Tab>'] = cmp.mapping(function(fallback)
        --     if cmp.visible() then
        --         cmp.select_prev_item()
        --     elseif luasnip.locally_jumpable(-1) then
        --         luasnip.jump(-1)
        --     else
        --         fallback()
        --     end
        -- end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}

require('refactoring').setup({
    prompt_func_return_type = {
        go = true,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
    },
    prompt_func_param_type = {
        go = true,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
    },
    printf_statements = {},
    print_var_statements = {},
})
--
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>')

vim.keymap.set('n', '<leader>tn', ':TestNearest<CR>')
vim.keymap.set('n', '<leader>tf', ':TestFile<CR>')
vim.keymap.set('n', '<leader>ts', ':TestSuite<CR>')
vim.keymap.set('n', '<leader>tv', ':TestVisit<CR>')
vim.keymap.set('n', '<leader>tl', ':TestLast<CR>')

vim.keymap.set('n', '<leader>j', ':Telescope jumplist<CR>')

require("neotest").setup({
    adapters = {
        require("neotest-python")({
            dap = { justMyCode = false },
        }),
        -- require("neotest-plenary"),
        -- require("neotest-vim-test")({
        --   ignore_file_types = { "python", "vim", "lua" },
        -- }),
    },
})


vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
        require("lint").try_lint()
    end,
})
-- vim.cmd('autocmd ColorScheme * hi Normal ctermbg=None')

vim.o.linebreak = true
vim.o.swapfile = false

-- vim.g.copilog_no_tab_mapped = true
vim.g.copilot_assume_mapped = true

-- vim.cmd.colorscheme 'PaperColor'
--- vim.cmd.colorscheme 'base64-irblack'
-- vim.cmd.colorscheme 'monokai-pro'
vim.g.material_style = "darker"
-- vim.cmd.colorscheme 'rose-pine'
-- vim.cmd.colorscheme 'material'
-- vim.cmd.colorscheme 'modus'
-- vim.cmd.colorscheme 'aura'
-- vim.cmd.colorscheme 'bamboo'
-- vim.cmd.colorscheme 'gruvbox'
-- vim.cmd.colorscheme 'monokai-pro-default'
vim.cmd.colorscheme 'catppuccin'

-- vim.cmd.colorscheme "oxocarbon"
--vim.cmd.highlight "Normal guibg=black guifg=white"

if vim.g.neovide then
    -- vim.o.guifont = "mononoki NFM:h14" -- text below applies for VimScript
    -- vim.o.guifont = "Lilex NFM:h14" -- text below applies for VimScript
    -- vim.o.guifont = "BigBlue_Terminal_437TT NF:h14"
    -- vim.o.guifont = "OxProto NF:h12"
    -- vim.o.guifont = "iMWritingMonoS NF:h14"
    -- vim.o.guifont = "MartianMono Nerd Font:h12"
    -- vim.o.guifont = "IosevkaTermSlab Nerd Font:h14"
    -- vim.o.guifont = "ComicShannsMono Nerd Font Mono:h13"
    vim.o.guifont = "Inconsolata Nerd Font Mono:h16"
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "plantuml",
    callback = function()
        -- Führe den externen Befehl aus und speichere die Ausgabe
        local handle = io.popen("cat `which plantuml` | grep plantuml.jar")
        local result = handle:read("*a")
        handle:close()

        -- Extrahiere den Pfad zur plantuml.jar aus der Ausgabe
        local jar_path = result:match('.*%s[\'"]?(%S+plantuml%.jar).*')

        print(jar_path)

        -- Setze die globale Variable, wenn ein Pfad gefunden wurde
        if jar_path then
            vim.g["plantuml_previewer#plantuml_jar_path"] = jar_path
        end
    end
})

vim.g.navic_silence = false
