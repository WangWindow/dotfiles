-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- ~/.config/nvim/lua/config/options.lua
local opt = vim.opt

-- 全局缩进设置（对大多数语言生效）
opt.tabstop = 4 -- Tab 显示为 4 个空格宽
opt.shiftwidth = 4 -- 缩进/反缩进时移动 4 列
opt.expandtab = true -- 将 Tab 自动转为空格（关键！）
opt.softtabstop = 4 -- 在编辑时按 Backspace 可一次删除 4 空格（模拟 Tab 行为）
opt.autoindent = true -- 自动继承上一行缩进
opt.smartindent = true -- 智能缩进（可选，某些语言可能冲突，LSP 更推荐）
