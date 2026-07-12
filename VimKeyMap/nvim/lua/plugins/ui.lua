return {
  {
    "akinsho/bufferline.nvim",
    -- event = "VeryLazy", -- ★ 新增
    event = "User FileOpened",
    dependencies = {
      "ESSO0428/tabline.nvim",
      dependencies = { "fgheng/winbar.nvim", "nvim-lualine/lualine.nvim", "nvim-tree/nvim-web-devicons" },
      config = function()
        require("tabline").setup {
          enable = false,
          options = {
            show_tabs_always = true,
          },
        }
        vim.cmd [[
        set guioptions-=e " Use showtabline in gui vim
        set sessionoptions+=tabpages,globals " store tabpages and globals in session
      ]]
      end,
    },
    config = function()
      local function is_ft(b, ft)
        return vim.bo[b].filetype == ft
      end

      local function custom_filter(buf, buf_nums)
        local logs = vim.tbl_filter(function(b)
          return is_ft(b, "log")
        end, buf_nums or {})
        if vim.tbl_isempty(logs) then
          return true
        end
        local tab_num = vim.fn.tabpagenr()
        local last_tab = vim.fn.tabpagenr "$"
        local is_log = is_ft(buf, "log")
        if last_tab == 1 then
          return true
        end
        -- only show log buffers in secondary tabs
        return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
      end

      local function diagnostics_indicator(num, _, diagnostics, _)
        local result = {}
        local symbols = {
          error = "",
          warning = "",
          info = "",
        }
        for name, count in pairs(diagnostics) do
          if symbols[name] and count > 0 then
            table.insert(result, symbols[name] .. " " .. count)
          end
        end
        result = table.concat(result, " ")
        return #result > 0 and result or ""
      end

      local ok_bufferline, bufferline = pcall(require, "bufferline")
      if not ok_bufferline then
        return
      end

      local status_ok, bufferline = pcall(require, "bufferline")
      if not status_ok then
        return
      end

      local builtin_bufferline = vim.deepcopy(Nvim.builtin.bufferline or {})
      local bufferline_options = vim.deepcopy(builtin_bufferline.options or {})

      local ok_groups, groups = pcall(require, "bufferline.groups")
      if ok_groups and bufferline_options.groups and vim.tbl_islist(bufferline_options.groups.items) then
        local has_ungrouped = vim.tbl_contains(bufferline_options.groups.items, groups.builtin.ungrouped)
        if not has_ungrouped then
          table.insert(bufferline_options.groups.items, groups.builtin.ungrouped)
        end
      end

      -- can't be set in settings.lua because default tabline would flash before bufferline is loaded
      vim.opt.showtabline = 2
      bufferline.setup {
        on_config_done = builtin_bufferline.on_config_done,
        highlights = vim.deepcopy(builtin_bufferline.highlights or {}),
        options = bufferline_options,
      }
      if builtin_bufferline.on_config_done then
        builtin_bufferline.on_config_done()
      end
      local ok_tabline, tabline = pcall(require, "tabline")
      if ok_tabline then
        tabline.on_session_load_post()
        vim.o.tabline = "%!v:lua.nvim_bufferline() .. v:lua.require'tabline'.tabline_tabs()"
      else
        vim.o.tabline = "%!v:lua.nvim_bufferline()"
      end
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    -- event = "BufWinEnter", -- 比 VeryLazy 再精準一點
    event = "User FileOpened",
    config = function()
      require("scrollbar").setup {
        show = true,
        handle = {
          text = " ",
          color = "#928374",
          hide_if_all_visible = true,
        },
        marks = {
          Search = { color = "yellow" },
          Misc = { color = "purple" },
        },
      }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    -- event = "VimEnter",
    event = "VeryLazy", -- 或 "UIEnter"
    config = function()
      vim.g.vim_pid = vim.fn.getpid()
      require("lualine").setup {
        sections = {
          lualine_c = {},
          lualine_x = {
            {
              function()
                return vim.fn.getcwd()
              end,
            },
            { "encoding" },
            { "fileformat" },
            { "filetype", icon_only = false },
            {
              "pid",
              fmt = function()
                return "pid:" .. vim.g.vim_pid
              end,
            },
          },
        },
      }
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
