-- persistant undo
vim.o.undodir = vim.fn.stdpath("data") .. "/nvim/undo"
vim.o.undofile = true
vim.o.swapfile = false

-- clipboard works with desktop environment
vim.o.clipboard = "unnamedplus"

-- formatting
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        local cursor_position = vim.fn.getpos('.')
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", cursor_position)
    end
})

-- positioning
vim.o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
vim.o.scrolloff = 999
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorcolumn = true

-- spelling
-- vim.o.spell = true
-- vim.keymap.set("n", "<leader>s", "<cmd>Telescope spell_suggest<cr>")

-- window bar
vim.o.winbar = "%{gitbranch#name()}%=%m %f"

-- status line
vim.cmd[[
function! Mode()
    let letter = mode()
    if letter == 'n'
        return "normal"
    elseif letter == 'i'
        return "insert"
    elseif letter == 'v'
        return "visual"
    elseif letter == 'V'
        return "v-line"
    else
        return "v-block"
    endif
endfunction
]]
vim.o.statusline = "%{Mode()}%=%l:%c"
vim.o.laststatus = 3

-- command line
vim.o.cmdheight = 0
vim.o.showmode = false

-- auto mkdir
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        local dir = vim.fn.expand("<afile>:p:h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end
})

-- leader key
vim.g.mapleader = ' '

-- keymaps
vim.keymap.set('n', "<leader>q", function()
	vim.cmd("wa")
	vim.cmd("qa")
end)
vim.keymap.set('n', "<leader>x", "<cmd>wq<cr>")
vim.keymap.set('n', "<leader>h", "<cmd>vsplit<cr>")
vim.keymap.set('n', "<leader>v", "<cmd>split<cr>")

local plugins = vim.fn.stdpath("data") .. "/nvim/plugins"
if not vim.loop.fs_stat(plugins) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    plugins,
  })
end
vim.opt.rtp:prepend(plugins)

require("lazy").setup({
	-- movement
	{
		"phaazon/hop.nvim",
		opts = {
			quit_key = "<SPC>",
		},
		keys = {
			{ "<leader>jw", "<cmd>HopWord<cr>" },
			{ "<leader>jl", "<cmd>HopLineStart<cr>" },
			{ "<leader>ja", "<cmd>HopAnywhere<cr>" },
		},
	},
	{
		"j-morano/buffer_manager.nvim",
		keys = {
			{ "<leader>jb", "<cmd>lua require('buffer_manager.ui').toggle_quick_menu()<cr>" },
		},
	},
	{
		"gaborvecsei/memento.nvim",
		keys = {
			{ "<leader>jp", "<cmd>lua require('memento').toggle()<cr>" },
		},
	},
    -- selection
    "gcmt/wildfire.vim",
    {
        "numToStr/Comment.nvim",
        config = function()
            require('Comment').setup()
        end,
    },
	-- ui
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.cmd("colorscheme gruvbox-material")
        end,
    },
    "sainnhe/sonokai",
    "bluz71/vim-moonfly-colors",
	"tpope/vim-vividchalk",
	"lukas-reineke/indent-blankline.nvim",
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "saadparwaiz1/cmp_luasnip",
            "petertriho/cmp-git",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },

                window = {
                  -- completion = cmp.config.window.bordered(),
                  -- documentation = cmp.config.window.bordered(),
                },

                mapping = cmp.mapping.preset.insert({
                  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                  ['<C-f>'] = cmp.mapping.scroll_docs(4),
                  ['<C-Space>'] = cmp.mapping.complete(),
                  ['<C-e>'] = cmp.mapping.abort(),
                  ['<CR>'] = cmp.mapping.confirm({ select = false }),
                }),

                sources = cmp.config.sources({
                  { name = 'nvim_lsp' },
                  { name = 'luasnip' },
                }, {
                  { name = 'buffer' },
                })
            })

            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'git' },
                }, {
                    { name = 'buffer' },
                })
            })

            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end,
        lazy = false,
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
    },
    {
        "saadparwaiz1/cmp_luasnip",
        dependencies = {
            "L3MON4D3/LuaSnip",
        },
    },
    {
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			require("telescope").load_extension("ui-select")
		end,
		keys = {
            { "<leader>fs", "<cmd>Telescope live_grep<cr>" },
            { "<leader>ff", "<cmd>Telescope find_files<cr>" },
		},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
        config = function()
            require("todo-comments").setup()
        end,
        lazy = false,
		keys = {
			{ "<leader>ft", "<cmd>TodoTelescope<cr>" },
		},
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add          = { text = '+' },
                change       = { text = '~' },
                delete       = { text = '-' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '?' },
            }
        }
	},
    "nvim-treesitter/nvim-treesitter-context",
	{
		"sindrets/winshift.nvim",
		keys = {
			{ "<leader>m", "<cmd>WinShift<cr>" },
		},
	},
	{
		"anuvyklack/windows.nvim",
		dependencies = {
			"anuvyklack/middleclass"
		},
        config = function()
            require("windows").setup()
        end,
        lazy = false,
		keys = {
			{ "<leader>f", "<cmd>WindowsMaximize<cr>" },
			{ "<leader>=", "<cmd>WindowsEqualize<cr>" },
		},
	},
	{
		"junegunn/goyo.vim",
		keys = {
			{ "<leader>z", "<cmd>Goyo<cr>" },
		},
	},
	-- languages
	{
		"nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter.configs").setup({
                auto_install = true,
            })
        end,
        lazy = false,
	},
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
        lazy = false,
    },
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
		},
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            require("mason-lspconfig").setup({
                handlers = {
                    function(name)
                        require("lspconfig")[name].setup({
                            capabilities = capabilities
                        })
                    end,
                },
            })
        end,
        lazy = false,
		keys = {
			{ "<leader>i", "<cmd>lua vim.lsp.buf.hover()<cr>" },
			{ "<leader>d", "<cmd>lua vim.lsp.buf.definition()<cr>" },
			{ "<leader>r", "<cmd>lua vim.lsp.buf.rename()<cr>" },
			{ "<leader>u", "<cmd>lua vim.lsp.buf.code_action()<cr>" },
			{ "<leader>e", "<cmd>Telescope diagnostics<cr>" },
			{ "<leader>s", "<cmd>Telescope lsp_workspace_symbols<cr>" },
		},
	},
    {
        "ziglang/zig.vim",
        ft = "zig",
    },
	-- git
    "itchyny/vim-gitbranch",
	{
		"ThePrimeagen/git-worktree.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("telescope").load_extension("git_worktree")
		end,
		keys = {
			{ "<leader>gc", "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>" },
			{ "<leader>gw", "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>" },
		},
	},
    -- other
    "tpope/vim-sensible",
    {
        "christoomey/vim-tmux-navigator",
        config = function()
            vim.g.tmux_navigator_no_mappings = 1
        end,
        keys = {
            { "<A-Up>", "<cmd>TmuxNavigateUp<cr>" },
            { "<A-Down>", "<cmd>TmuxNavigateDown<cr>" },
            { "<A-Left>", "<cmd>TmuxNavigateLeft<cr>" },
            { "<A-Right>", "<cmd>TmuxNavigateRight<cr>" },
        },
    },
    "wakatime/vim-wakatime",
    "nvim-lua/plenary.nvim",
})