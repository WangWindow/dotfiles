return {
  "Mythos-404/xmake.nvim",
  version = "^3",
  lazy = true,
  event = "BufReadPost xmake.lua", -- 更精准：仅当打开 xmake.lua 时加载
  config = true,
}
