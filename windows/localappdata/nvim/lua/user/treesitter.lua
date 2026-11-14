---@type rainbow_delimiters.config
vim.g.rainbow_delimiters = {
  strategy = {
    [""] = "rainbow-delimiters.strategy.global",
    vim = "rainbow-delimiters.strategy.local",
  },
  query = {
    [""] = "rainbow-delimiters",
    lua = "rainbow-blocks",
  },
  -- NOTE: We intentionally lower semantic token priority in user/lsp.lua.
  -- rainbow-delimiters defaults to a midpoint between semantic_tokens and
  -- treesitter, which would fall below treesitter and become visually hidden.
  -- Keep rainbow highlights above treesitter explicitly.
  priority = {
    [""] = vim.hl.priorities.treesitter + 10,
  },
  highlight = {
    "RainbowDelimiterRed",
    "RainbowDelimiterYellow",
    "RainbowDelimiterBlue",
    "RainbowDelimiterOrange",
    "RainbowDelimiterGreen",
    "RainbowDelimiterViolet",
    "RainbowDelimiterCyan",
  },
}
vim.api.nvim_create_autocmd("User", {
  pattern = "FileOpened",
  callback = function()
    require("nvim-treesitter.install").compilers = { "clang", "gcc" }
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "mysql",
  callback = function(args)
    vim.treesitter.start(args.buf, "sql")
    -- vim.bo[args.buf].syntax = 'on' -- only if additional legacy syntax is needed
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql" },
  once = true,
  callback = function()
    local ft = require "Comment.ft"
    ft.set("mysql", "-- %s")
  end,
})
