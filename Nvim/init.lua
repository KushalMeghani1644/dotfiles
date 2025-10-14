-- Neovim Configuration for Rust Development
--
-- Prerequisites:
-- 1. Install Neovim 0.12-dev
-- 2. Install rust-analyzer: rustup component add rust-analyzer
-- 3. Install ripgrep: cargo install ripgrep (or via package manager)
-- 4. Install fd: cargo install fd-find (or via package manager)
-- 5. Install a Nerd Font for icons

-- ================================
-- BASIC SETTINGS
-- ================================

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic editor settings
vim.opt.number = true         -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true     -- Highlight current line
vim.opt.wrap = false          -- Don't wrap lines
vim.opt.scrolloff = 8         -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8     -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 4        -- 4 spaces for tabs
vim.opt.softtabstop = 4    -- 4 spaces for tab in insert mode
vim.opt.shiftwidth = 4     -- 4 spaces for autoindent
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.autoindent = true  -- Auto indent new lines
vim.opt.smartindent = true -- Smart indent

-- Search settings
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true  -- Override ignorecase if uppercase used
vim.opt.hlsearch = true   -- Highlight search results
vim.opt.incsearch = true  -- Incremental search

-- Appearance
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes"   -- Always show sign column
vim.opt.colorcolumn = "100"  -- Show column at 100 characters

-- Splits
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right

-- Clipboard
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- File handling
vim.opt.backup = false      -- Don't create backup files
vim.opt.writebackup = false -- Don't create backup before overwrite
vim.opt.swapfile = false    -- Don't create swap files
vim.opt.undofile = true     -- Enable persistent undo

-- Performance
vim.opt.updatetime = 300 -- Faster completion
vim.opt.timeoutlen = 500 -- Faster key sequence completion

-- Additional settings to help with treesitter stability
vim.opt.redrawtime = 1500 -- Increase redraw timeout
vim.opt.regexpengine = 0  -- Use automatic regexp engine selection

-- ================================
-- PLUGIN MANAGER (lazy.nvim)
-- ================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    -- Check if git is available
    if vim.fn.executable("git") == 0 then
        print("ERROR: git is not installed or not in PATH!")
        print("Please install git first:")
        print("  Ubuntu/Debian: sudo apt install git")
        print("  CentOS/RHEL: sudo yum install git")
        print("  Arch: sudo pacman -S git")
        print("  macOS: brew install git")
        return
    end

    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require("lazy").setup({
    -- ================================
    -- COLORSCHEME
    -- ================================
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                terminal_colors = true,
                undercurl = true,
                underline = true,
                bold = true,
                italic = {
                    strings = true,
                    emphasis = true,
                    comments = true,
                    operators = false,
                    folds = true,
                },
                strikethrough = true,
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                invert_intend_guides = false,
                inverse = true,
                contrast = "", 
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                transparent_mode = false,
            })
            vim.cmd("colorscheme gruvbox")
        end,
    },

    -- ================================
    -- LSP CONFIGURATION
    -- ================================
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })
        end,
    },

    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = { "clangd", "clang-format", "zls" },
                auto_update = false,
                run_on_start = true,
            })
        end,
    },


    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            -- Setup completion capabilities
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Setup LSP handlers
            local on_attach = function(client, bufnr)
                local opts = { buffer = bufnr, silent = true }

                -- LSP mappings
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

                -- Format on save
                if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = bufnr })
                        end,
                    })
                end
            end

            -- Configure rust-analyzer using the new vim.lsp.config API
            vim.lsp.config("rust_analyzer", {
                cmd = { "rust-analyzer" },
                filetypes = { "rust" },
                root_markers = { "Cargo.toml", "rust-project.json" },
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            runBuildScripts = true,
                        },
                        checkOnSave = {
                            allFeatures = true,
                            command = "clippy",
                            extraArgs = { "--no-deps" },
                        },
                        procMacro = {
                            enable = true,
                        },
                        diagnostics = {
                            enable = true,
                        },
                    },
                },
            })

            -- Configure C/C++ LSP (clangd)
            local clangd_capabilities = vim.deepcopy(capabilities)
            clangd_capabilities.offsetEncoding = { "utf-16" }
            vim.lsp.config("clangd", {
                cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed", "--header-insertion=never" },
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
                root_markers = { "compile_commands.json", ".git" },
                capabilities = clangd_capabilities,
                on_attach = function(client, bufnr)

            -- Configure Zig LSP (zls)
            vim.lsp.config("zls", {
                cmd = { "zls" },
                filetypes = { "zig", "zir" },
                root_markers = { "zls.json", "build.zig", ".git" },
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {},
            })

                    client.server_capabilities.documentFormattingProvider = false
                    on_attach(client, bufnr)
                end,
                init_options = {
                    clangdFileStatus = true,
                    usePlaceholders = true,
                    completeUnimported = true,
                    semanticHighlighting = true,
                },
            })


            -- Configure Lua LSP using the new vim.lsp.config API
            vim.lsp.config("lua_ls", {
                cmd = { "lua-language-server" },
                filetypes = { "lua" },
                root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })
        end,
    },

    -- ================================
    -- COMPLETION
    -- ================================
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                }),
            })
        end,
    },

    -- ================================
    -- RUST SPECIFIC TOOLS
    -- ================================
    {
        "mrcjkb/rustaceanvim",
        version = "^5",
        lazy = false,
        ft = { "rust" },
        config = function()
            vim.g.rustaceanvim = {
                inlay_hints = {
                    highlight = "NonText",
                },
                tools = {
                    hover_actions = {
                        auto_focus = true,
                    },
                },
                server = {
                    on_attach = function(client, bufnr)
                        -- Custom keymaps for Rust
                        local opts = { buffer = bufnr }
                        vim.keymap.set("n", "<leader>ca", function()
                            vim.cmd.RustLsp('codeAction')
                        end, opts)
                        vim.keymap.set("n", "<leader>dr", function()
                            vim.cmd.RustLsp('debuggables')
                        end, opts)
                    end,
                },
            }
        end,
    },

    {
        "saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        config = function()
            require("crates").setup({
                popup = {
                    autofocus = true,
                },
            })
        end,
    },

    -- ================================
    -- FILE EXPLORER
    -- ================================
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            -- Disable netrw
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            require("nvim-tree").setup({
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = false,
                },
            })
        end,
    },

    -- ================================
    -- FUZZY FINDER
    -- ================================
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8", -- Updated to latest stable
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-h>"] = "which_key",
                        },
                    },
                },
                pickers = {
                    find_files = {
                        theme = "dropdown",
                    },
                },
            })
        end,
    },

    -- ================================
    -- SYNTAX HIGHLIGHTING
    -- ================================
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "rust", "toml", "lua", "vim", "vimdoc", "query", "c", "cpp", "zig" },
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                    -- Add safeguards for the highlighting issue
                    disable = function(lang, buf)
                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                        
                        -- Disable for very long lines that might cause issues
                        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                        for _, line in ipairs(lines) do
                            if #line > 10000 then
                                return true
                            end
                        end
                        return false
                    end,
                },
                indent = {
                    enable = true,
                    disable = {},
                },
                matchup = {
                    enable = true,
                },
            })
            
            -- Add error handling for treesitter highlighting
            local group = vim.api.nvim_create_augroup("TreesitterErrorHandler", { clear = true })
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
                group = group,
                callback = function(args)
                    local buf = args.buf
                    pcall(function()
                        if vim.treesitter.highlighter.active[buf] == nil then
                            vim.treesitter.start(buf)
                        end
                    end)
                end,
            })
        end,
    },

    -- Bracket matching enhancements
    {
        "andymass/vim-matchup",
        init = function()
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
        end,
    },

    -- Rainbow colored brackets/braces
    {
        "HiPhish/rainbow-delimiters.nvim",
    },

    -- Indent guides with current scope lines
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup({
                scope = { enabled = true, show_start = true, show_end = true },
            })
        end,
    },

    -- ================================
    -- STATUS LINE
    -- ================================
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "gruvbox",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                },
            })
        end,
    },

    -- ================================
    -- GIT INTEGRATION
    -- ================================
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    },


    {
        "folke/sidekick.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
        config = function()
            require("sidekick").setup({})
        end,
    },

    -- ================================
    -- FORMATTING
    -- ================================
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    rust = { "rustfmt" },
                    lua = { "stylua" },
                    c = { "clang-format" },
                    cpp = { "clang-format" },
                    zig = { "zigfmt" }, 

                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            })
        end,
    },

    -- ================================
    -- UTILITY PLUGINS
    -- ================================
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup()
        end,
    },

    {
        "numToStr/Comment.nvim",
        opts = {},
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
        end,
    },

    -- ERROR LENS
    {
        "chikko80/error-lens.nvim",
        ft = { "rust", "c", "cpp", "zig" },
        config = function()
            require("error-lens").setup({})
        end,
    },

})

-- ================================
-- KEY MAPPINGS
-- ================================

-- General mappings
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- File explorer
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help tags" })

-- Rust specific mappings
vim.keymap.set("n", "<leader>rc", ":!cargo check<CR>", { desc = "Cargo check" })
vim.keymap.set("n", "<leader>rr", ":!cargo run<CR>", { desc = "Cargo run" })
vim.keymap.set("n", "<leader>rt", ":!cargo test<CR>", { desc = "Cargo test" })
vim.keymap.set("n", "<leader>rb", ":!cargo build<CR>", { desc = "Cargo build" })

-- Format
vim.keymap.set("n", "<leader>f", function()
    require("conform").format({ lsp_fallback = true })
end, { desc = "Format file" })


-- Sidekick
vim.keymap.set("n", "<leader>aa", function() require("sidekick.cli").toggle() end, { desc = "Sidekick Toggle CLI" })
-- ================================
-- AUTO COMMANDS
-- ================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", {}),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Treesitter error mitigation
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("TreesitterFix", { clear = true }),
    callback = function()
        -- Add a small delay to let treesitter settle
        vim.defer_fn(function()
            pcall(vim.cmd, "TSBufEnable highlight")
        end, 100)
    end,
})

-- ================================
-- DIAGNOSTICS CONFIGURATION
-- ================================

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = false,
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})

-- Set diagnostic signs
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
