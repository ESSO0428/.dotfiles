-- LSP
Nvim.keys.normal_mode["<leader>gD"] = { vim.lsp.buf.declaration, desc = "LSP: [G]oto [D]eclaration" }
Nvim.keys.normal_mode["gh"] = { vim.lsp.buf.hover, desc = "LSP: documentation hover" }

-- Nvim.keys.normal_mode["gm"] = { vim.lsp.buf.signature_help, desc = "LSP: signature help" }

Nvim.keys.normal_mode["gm"] =
  { "<cmd>lua require('lsp_signature').toggle_float_win()<cr>", desc = "LSP: signature help" }
Nvim.keys.normal_mode["g;"] = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", desc = "LSP: Goto type definition" }
Nvim.keys.normal_mode["gp"] = {
  "<cmd>lua require('goto-preview').goto_preview_type_definition()<cr>",
  desc = "LSP: Goto type definition (preview)",
}
Nvim.keys.normal_mode["<leader><a-o>"] =
  { "<cmd>lua require('goto-preview').goto_preview_definition()<cr>", desc = "LSP: [G]oto [D]efinition (preview)" }
Nvim.keys.normal_mode["<leader>ua"] =
  { "<cmd>lua require('actions-preview').code_actions()<cr>", desc = "LSP: Code Action" }
Nvim.keys.normal_mode["gl"] = {
  function()
    local float = vim.diagnostic.config().float

    if float then
      local config = type(float) == "table" and float or {}
      config.scope = "line"

      vim.diagnostic.open_float(config)
    end
  end,
  desc = "LSP: Show line diagnostics",
}

-- Diagnostics
Nvim.keys.normal_mode["<"] = { vim.diagnostic.goto_prev, desc = "goto prev diagnostic", silent = true, nowait = true }
Nvim.keys.normal_mode[">"] = { vim.diagnostic.goto_next, desc = "goto next diagnostic", silent = true, nowait = true }

Nvim.keys.normal_mode["<leader>="] = { vim.lsp.buf.format, desc = "Lsp Buffer Format", silent = true, nowait = true }
