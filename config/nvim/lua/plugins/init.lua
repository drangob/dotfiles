return {
  -- Colorscheme
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('gruvbox')
    end,
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      vim.g.elixir_lsp_failed = false

      local function elixir_lsp_startup_status()
        if not vim.tbl_contains({ 'elixir', 'eelixir', 'heex', 'surface' }, vim.bo.filetype) then
          return ''
        end

        if vim.g.elixir_lsp_failed then
          return 'ElixirLS failed'
        end

        if vim.g.elixir_lsp_status then
          return vim.g.elixir_lsp_status
        end

        if vim.lsp.is_enabled('elixirls') then
          return 'ElixirLS starting...'
        end

        return ''
      end

      require('lualine').setup({
        options = { theme = 'gruvbox' },
        sections = {
          lualine_x = {
            elixir_lsp_startup_status,
            {
              'lsp_status',
              icon = 'LSP:',
              symbols = {
                spinner = { '|', '/', '-', '\\' },
                done = 'ready',
                separator = ' ',
              },
              show_name = true,
            },
            'encoding',
            'fileformat',
            'filetype',
          },
        },
      })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'LspAttach', 'LspDetach' }, {
        group = vim.api.nvim_create_augroup('lualine-lsp-status', { clear = true }),
        callback = function()
          require('lualine').refresh()
        end,
      })
    end,
  },

  -- Git signs + hunk/blame/diff keymaps
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      local gs = require('gitsigns')
      gs.setup({
        on_attach = function(bufnr)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'Git: ' .. desc })
          end

          -- Hunk navigation (falls back to vim's diff motions in a diff view)
          map('n', ']c', function()
            if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gs.nav_hunk('next') end
          end, 'Next Hunk')
          map('n', '[c', function()
            if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gs.nav_hunk('prev') end
          end, 'Previous Hunk')

          -- Stage / reset
          map('n', '<leader>gs', gs.stage_hunk, 'Stage Hunk')
          map('n', '<leader>gr', gs.reset_hunk, 'Reset Hunk')
          map('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage Hunk')
          map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset Hunk')
          map('n', '<leader>gS', gs.stage_buffer, 'Stage Buffer')
          map('n', '<leader>gR', gs.reset_buffer, 'Reset Buffer')

          -- Inspect
          map('n', '<leader>gp', gs.preview_hunk, 'Preview Hunk')
          map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame Line')
          map('n', '<leader>gB', gs.toggle_current_line_blame, 'Toggle Inline Blame')
          map('n', '<leader>gd', gs.diffthis, 'Diff This')
          map('n', '<leader>gD', function() gs.diffthis('~') end, 'Diff Against Last Commit')
        end,
      })
    end,
  },

  -- Python venv selector (auto-detects and switches venvs)
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-telescope/telescope.nvim',
      'mfussenegger/nvim-dap-python',
    },
    ft = 'python',
    config = function()
      require('venv-selector').setup({
        settings = {
          search = {
            -- Search for venvs in project and common locations
            project_venvs = {
              command = "fd 'python$' . --type x --hidden --exclude .git",
              type = 'project',
            },
          },
        },
      })
      vim.keymap.set('n', '<leader>vs', '<cmd>VenvSelect<cr>', { desc = 'Select Python Venv' })
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install({
        'lua', 'vim', 'vimdoc',
        'javascript', 'typescript', 'tsx',
        'python',
        'elixir', 'heex', 'eex',
        'json', 'yaml', 'html', 'css', 'markdown', 'markdown_inline',
      })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- Mason: LSP/DAP/Linter/Formatter installer
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },

  -- Auto-install formatters used by conform (mason adds these to nvim's PATH)
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-tool-installer').setup({
        ensure_installed = {
          'stylua',     -- Lua (this config)
          'prettierd',  -- JS/TS/JSON/YAML/Markdown
          'ruff',       -- Python (fallback when no project venv ruff)
        },
      })
    end,
  },

  -- Mason-lspconfig for auto-installing servers
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'ts_ls',           -- TypeScript/JavaScript
          'pyright',         -- Python
          'elixirls',        -- Elixir
          'lua_ls',          -- Lua (for neovim config)
        },
        -- We enable servers explicitly via vim.lsp.enable() in the cmp-nvim-lsp
        -- config, so suppress mason-lspconfig's own auto-enable to avoid both
        -- paths racing to enable the same server.
        automatic_enable = false,
      })
    end,
  },

  -- LSP configuration using native vim.lsp.config (Neovim 0.11+)
  {
    'hrsh7th/cmp-nvim-lsp',
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local elixir_filetypes = { 'elixir', 'eelixir', 'heex', 'surface' }

      local function set_elixir_lsp_status(status)
        vim.g.elixir_lsp_status = status
        vim.schedule(function()
          if package.loaded['lualine'] then
            require('lualine').refresh()
          end
        end)
      end

      -- ElixirLS initializes its LSP connection before it has compiled and indexed the project.
      -- Its log messages are the only progress signal it exposes to Neovim.
      if not vim.g.elixir_lsp_log_handler_installed then
        local original_log_message = vim.lsp.handlers['window/logMessage']
        vim.lsp.handlers['window/logMessage'] = function(err, result, ctx, config)
          local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)
          local message = result and result.message or ''

          if client and client.name == 'elixirls' then
            local file_count = message:match('Compiling (%d+) files?')

            if message:find('Starting build', 1, true) then
              set_elixir_lsp_status('ElixirLS building...')
            elseif file_count then
              set_elixir_lsp_status('ElixirLS compiling ' .. file_count .. ' files...')
            elseif message:find('WorkspaceSymbols] Indexing', 1, true) then
              set_elixir_lsp_status('ElixirLS indexing...')
            elseif message:find('Module discovery complete', 1, true) or message:find('symbols added to index', 1, true) then
              set_elixir_lsp_status('ElixirLS ready')
            elseif message:find('Build failed', 1, true)
                or message:find('Compilation failed', 1, true)
                or message:find("Can't continue due to errors on dependencies", 1, true)
                or message:find('Mix.Error', 1, true) then
              vim.g.elixir_lsp_failed = true
              set_elixir_lsp_status('ElixirLS failed')
            end
          end

          if original_log_message then
            return original_log_message(err, result, ctx, config)
          end
        end

        vim.g.elixir_lsp_log_handler_installed = true
      end

      local function elixir_lsp_is_ready()
        return vim.g.elixir_lsp_status == 'ElixirLS ready'
      end

      local function lsp_action(method, action, label)
        return function()
          local supporting_clients = vim.lsp.get_clients({ bufnr = 0, method = method })
          local elixir_buffer = vim.tbl_contains(elixir_filetypes, vim.bo.filetype)

          if elixir_buffer and vim.lsp.is_enabled('elixirls') and not elixir_lsp_is_ready() then
            local status = vim.g.elixir_lsp_status or 'ElixirLS starting...'
            local level = vim.g.elixir_lsp_failed and vim.log.levels.ERROR or vim.log.levels.INFO
            local message = status .. ' ' .. label .. ' is unavailable until the project index is ready.'
            if vim.g.elixir_lsp_failed then
              message = status .. ' ' .. label .. ' is unavailable. Check :messages or :LspLog.'
            end
            vim.notify(message, level, {
              title = 'ElixirLS',
            })
            return
          end

          if #supporting_clients == 0 then
            vim.notify('No attached LSP server supports ' .. label .. ' for this buffer.', vim.log.levels.WARN, {
              title = label,
            })

            return
          end

          action()
        end
      end

      local function set_lsp_keymaps(bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        map('gd', lsp_action('textDocument/definition', vim.lsp.buf.definition, 'go-to-definition'), 'Go to Definition')
        map('gr', lsp_action('textDocument/references', vim.lsp.buf.references, 'references'), 'Go to References')
        map('gI', lsp_action('textDocument/implementation', vim.lsp.buf.implementation, 'implementation'), 'Go to Implementation')
        map('gy', lsp_action('textDocument/typeDefinition', vim.lsp.buf.type_definition, 'type definition'), 'Go to Type Definition')
        map('K', lsp_action('textDocument/hover', vim.lsp.buf.hover, 'hover documentation'), 'Hover Documentation')
        map('<leader>ca', lsp_action('textDocument/codeAction', vim.lsp.buf.code_action, 'code actions'), 'Code Action')
        map('<leader>rn', lsp_action('textDocument/rename', vim.lsp.buf.rename, 'rename'), 'Rename')
        map('<leader>D', lsp_action('textDocument/typeDefinition', vim.lsp.buf.type_definition, 'type definition'), 'Type Definition')
        map('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous Diagnostic')
        map(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next Diagnostic')
        map('<leader>cd', vim.diagnostic.open_float, 'Show Diagnostic')
        map('<leader>q', vim.diagnostic.setloclist, 'Diagnostic List')
      end

      local lsp_filetypes = {
        'elixir', 'eelixir', 'heex', 'surface',
        'javascript', 'javascriptreact', 'typescript', 'typescriptreact',
        'python', 'lua',
      }

      local function maybe_set_lsp_keymaps(bufnr)
        if vim.tbl_contains(lsp_filetypes, vim.bo[bufnr].filetype) then
          set_lsp_keymaps(bufnr)
        end
      end

      vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType', 'LspAttach' }, {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          maybe_set_lsp_keymaps(event.buf)
        end,
      })

      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          maybe_set_lsp_keymaps(bufnr)
        end
      end

      -- Configure LSP servers using native vim.lsp.config (Neovim 0.11+)
      local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'

      -- TypeScript/JavaScript (auto-uses local node_modules typescript)
      vim.lsp.config('ts_ls', {
        capabilities = capabilities,
        cmd = { mason_bin .. '/typescript-language-server', '--stdio' },
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
        init_options = {
          preferences = {
            importModuleSpecifierPreference = 'relative',
          },
        },
      })

      -- Python (venv-selector handles this, but fallback detection included)
      local function get_python_path(root_dir)
        -- Check for active venv from environment
        if vim.env.VIRTUAL_ENV then
          return vim.env.VIRTUAL_ENV .. '/bin/python'
        end
        -- Check common venv locations in project root
        root_dir = root_dir or vim.fn.getcwd()
        local venv_dirs = { '.venv', 'venv', '.conda', 'env' }
        for _, dir in ipairs(venv_dirs) do
          local path = root_dir .. '/' .. dir .. '/bin/python'
          if vim.fn.executable(path) == 1 then
            return path
          end
        end
        return 'python3'
      end

      vim.lsp.config('pyright', {
        capabilities = capabilities,
        cmd = { mason_bin .. '/pyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'pyrightconfig.json', '.git' },
        before_init = function(_, config)
          local python_path = get_python_path(config.root_dir)
          config.settings = config.settings or {}
          config.settings.python = config.settings.python or {}
          config.settings.python.pythonPath = python_path
        end,
      })

      -- Elixir (elixirls has built-in asdf support)
      vim.lsp.config('elixirls', {
        capabilities = capabilities,
        cmd = { mason_bin .. '/elixir-ls' },
        filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
        root_markers = { 'mix.exs', '.tool-versions', '.git' },
        settings = {
          elixirLS = {
            dialyzerEnabled = false,
          },
        },
        on_init = function()
          vim.g.elixir_lsp_failed = false
          set_elixir_lsp_status('ElixirLS starting...')
        end,
        on_exit = function(code)
          if code ~= 0 then
            vim.g.elixir_lsp_failed = true
            set_elixir_lsp_status('ElixirLS failed')
            vim.schedule(function()
              vim.notify(
                'ElixirLS stopped before becoming ready. Check :messages and :LspLog.',
                vim.log.levels.ERROR,
                { title = 'ElixirLS' }
              )
              require('lualine').refresh()
            end)
          end
        end,
      })

      -- Lua (for neovim config editing)
      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        cmd = { mason_bin .. '/lua-language-server' },
        filetypes = { 'lua' },
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Enable all configured servers
      vim.lsp.enable({ 'ts_ls', 'pyright', 'elixirls', 'lua_ls' })
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- Telescope (fuzzy finder)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({ extensions = { fzf = {} } })
      telescope.load_extension('fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help Tags' })
      vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document Symbols' })

      -- Git pickers
      vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git Commits' })
      vim.keymap.set('n', '<leader>gC', builtin.git_bcommits, { desc = 'Git Commits (buffer)' })
      vim.keymap.set('n', '<leader>gt', builtin.git_status, { desc = 'Git Status' })
      vim.keymap.set('n', '<leader>gw', builtin.git_branches, { desc = 'Git Branches' })
    end,
  },

  -- Which-key (shows keybindings)
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>?', function() require('which-key').show({ global = false }) end, desc = 'Buffer-local Keymaps' },
    },
    config = function()
      local wk = require('which-key')
      wk.setup()
      wk.add({
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git' },
        { '<leader>c', group = 'code' },
      })
    end,
  },

  -- File explorer sidebar (rooted at the git repo via the auto-root autocmd)
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle File Explorer' },
    },
    config = function()
      require('neo-tree').setup({
        close_if_last_window = true,
        filesystem = {
          bind_to_cwd = true,
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
          },
        },
      })
    end,
  },

  -- GitHub permalinks for the current line/selection
  {
    'linrongbin16/gitlinker.nvim',
    cmd = 'GitLink',
    opts = {},
    keys = {
      { '<leader>gy', '<cmd>GitLink<cr>', mode = { 'n', 'v' }, desc = 'Yank Permalink' },
      { '<leader>go', '<cmd>GitLink!<cr>', mode = { 'n', 'v' }, desc = 'Open Permalink in Browser' },
    },
  },

  -- lazygit in a floating window
  {
    'kdheepak/lazygit.nvim',
    cmd = { 'LazyGit', 'LazyGitCurrentFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },

  -- Formatter (format-on-save + manual <leader>cf)
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      { '<leader>cf', function() require('conform').format({ async = true, lsp_format = 'fallback' }) end, mode = { 'n', 'v' }, desc = 'Format Buffer' },
    },
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          elixir = { 'mix' },
          lua = { 'stylua' },
          python = { 'ruff_organize_imports', 'ruff_format' },
          javascript = { 'prettierd', 'prettier', stop_after_first = true },
          javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
          typescript = { 'prettierd', 'prettier', stop_after_first = true },
          typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
          json = { 'prettierd', 'prettier', stop_after_first = true },
          yaml = { 'prettierd', 'prettier', stop_after_first = true },
          markdown = { 'prettierd', 'prettier', stop_after_first = true },
        },
        format_on_save = function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 5000, lsp_format = 'fallback' }
        end,
      })

      -- :FormatDisable[!] toggles autoformat (global, or buffer-local with bang)
      vim.api.nvim_create_user_command('FormatDisable', function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { bang = true, desc = 'Disable format-on-save' })
      vim.api.nvim_create_user_command('FormatEnable', function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = 'Re-enable format-on-save' })
    end,
  },
}
