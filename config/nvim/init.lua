-- Core settings
vim.opt.clipboard = 'unnamedplus'
vim.wo.number = true
vim.opt.showcmd = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400  -- snappier multi-key sequences (e.g. which-key)

-- Leader key (set before lazy)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Auto-cd to the git repo root of whatever file you open, so the file tree
-- and fuzzy-finder always treat the enclosing repo as the project root.
-- Files outside any repo are left at the current directory.
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('auto-root', { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= '' then return end
    if vim.api.nvim_buf_get_name(args.buf) == '' then return end
    local root = vim.fs.root(args.buf, '.git')
    if root and root ~= vim.fn.getcwd() then
      vim.cmd.cd(vim.fn.fnameescape(root))
    end
  end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require('lazy').setup('plugins')
