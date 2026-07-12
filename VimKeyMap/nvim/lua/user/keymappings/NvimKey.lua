-- import the integrated WindowsTerminal module
local windows_terminal = require "user.integrated.WindowsTerminal"

-- Windows Terminal / config
Nvim.keys.normal_mode["<leader>rw"] = {
  windows_terminal.find_and_edit_terminal_settings,
  desc = "Edit Windows Terminal settings",
}
Nvim.keys.normal_mode["<leader>rc"] =
  { "<cmd>e $HOME/AppData/Local/nvim/lua/config.lua<cr>", desc = "Edit Neovim config" }

-- Comment
Nvim.keys.visual_mode["<leader>/"] =
  { "<Plug>(comment_toggle_linewise_visual)", desc = "Comment toggle linewise (visual)" }
Nvim.keys.normal_mode["<leader>/"] = { "<Plug>(comment_toggle_linewise_current)", desc = "Comment toggle current line" }

-- Bufferline
Nvim.keys.normal_mode["<c-j>"] = { "<cmd>BufferLineCyclePrev<cr>", desc = "Bufferline Prev Buffer" }
Nvim.keys.normal_mode["<c-l>"] = { "<cmd>BufferLineCycleNext<cr>", desc = "Bufferline Next Buffer" }
Nvim.keys.normal_mode["<a-j>"] = { "<cmd>BufferLineMovePrev<cr>", desc = "Bufferline Move Buffer to Prev" }
Nvim.keys.normal_mode["<a-l>"] = { "<cmd>BufferLineMoveNext<cr>", desc = "Bufferline Move Buffer to Next" }
Nvim.keys.normal_mode["<a-g>"] = { ":BufferLineGroupToggle ", { silent = false } }
Nvim.keys.normal_mode["<leader><a-g>"] = { ":BufferLineGroupClose ", { silent = false } }
Nvim.keys.normal_mode["<leader><a-i>"] = "<cmd>BufferLineTogglePin<cr>"

-- Nvim.keys.normal_mode["<c-w>"]         = { "<cmd>BufferKill<cr>", { nowait = true }}
-- Nvim.keys.normal_mode["<c-w>"]         = { "<cmd>BufferLineCyclePrev<cr><cmd>confirm bd#<cr>", { nowait = true }}
Nvim.keys.normal_mode["<c-w>"] = { "<cmd>BufferLineKill<cr>", { nowait = true } }

Nvim.keys.normal_mode["<leader><c-w>"] = "<cmd>ForceBufferLineKill<cr>"
-- NOTE: 直接使用 bd! 強制關閉緩衝區
Nvim.keys.normal_mode["<leader>d<c-w>"] = "<cmd>bd!<cr>"

Nvim.keys.normal_mode["<a-1>"] = "<cmd>BufferLineGoToBuffer 1<cr>"
Nvim.keys.normal_mode["<a-2>"] = "<cmd>BufferLineGoToBuffer 2<cr>"
Nvim.keys.normal_mode["<a-3>"] = "<cmd>BufferLineGoToBuffer 3<cr>"
Nvim.keys.normal_mode["<a-4>"] = "<cmd>BufferLineGoToBuffer 4<cr>"
Nvim.keys.normal_mode["<a-5>"] = "<cmd>BufferLineGoTOBuffer 5<cr>"
Nvim.keys.normal_mode["<a-6>"] = "<cmd>BufferLineGoToBuffer 6<cr>"
Nvim.keys.normal_mode["<a-7>"] = "<cmd>BufferLineGoToBuffer 7<cr>"
Nvim.keys.normal_mode["<a-8>"] = "<cmd>BufferLineGoToBuffer 8<cr>"
Nvim.keys.normal_mode["<a-9>"] = "<cmd>BufferLineGoToBuffer 9<cr>"
Nvim.keys.normal_mode["<a-0>"] = "<cmd>BufferLineGoToBuffer -1<cr>"
Nvim.keys.normal_mode["<a-`>"] = "<cmd>b#<cr>"

-- Session Manager
Nvim.keys.normal_mode["<leader>S"] =
  { ":SessionManager save_current_session<cr>", desc = "save_current_session", silent = false }
Nvim.keys.normal_mode["<leader>se"] = { "<cmd>SessionManager load_session<cr>", desc = "load_session" }

-- Toggle Term
Nvim.keys.normal_mode["<leader><a-1>"] =
  { "<cmd>exe v:count1 . 'ToggleTerm direction=horizontal'<cr>", desc = "Horizontal Terminal" }
