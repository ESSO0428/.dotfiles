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
      local ok_bufferline, bufferline = pcall(require, "bufferline")
      if not ok_bufferline then
        return
      end

      local builtin_bufferline = vim.deepcopy(Nvim.builtin.bufferline or {})

      local bufferline_options = vim.deepcopy(builtin_bufferline.options or {})

      -- 加入預設 ungrouped group。
      local ok_groups, groups = pcall(require, "bufferline.groups")

      if ok_groups and bufferline_options.groups and vim.islist(bufferline_options.groups.items) then
        local has_ungrouped = vim.iter(bufferline_options.groups.items):any(function(item)
          return item.name == "ungrouped"
        end)

        if not has_ungrouped then
          local ungrouped = groups.builtin.ungrouped:with {
            name = "ungrouped",
            separator = {
              style = groups.separator.pill,
            },
          }

          table.insert(bufferline_options.groups.items, ungrouped)
        end
      end

      local function install_bufferline_render_cache()
        local original = _G.nvim_bufferline

        if type(original) ~= "function" then
          vim.notify("[bufferline] nvim_bufferline is unavailable", vim.log.levels.ERROR)
          return nil
        end

        -- 每個 generation / tabpage / active buffer
        -- 各保存一份完整 bufferline render 字串。
        local render_cache = {}
        local generation = 0

        -- resize 期間沿用最後一份成功 render。
        local resizing = false
        local resize_generation = 0
        local frozen_cache = nil

        -- 處理 bufferline 在 session 載入途中才 lazy-load 的情況。
        local session_loading = vim.g.session_loading == true

        local cache_group = vim.api.nvim_create_augroup("BufferlineRenderCache", { clear = true })

        local function make_cache_key()
          return table.concat({
            generation,
            vim.api.nvim_get_current_tabpage(),
            vim.api.nvim_get_current_buf(),
          }, ":")
        end

        local function redraw_tabline()
          vim.schedule(function()
            vim.cmd "redrawtabline"
          end)
        end

        local function invalidate_all(redraw)
          -- Session restore 期間會連續新增、刪除與切換 buffers。
          -- 此時不清 cache，也不喚醒昂貴的 bufferline renderer。
          if session_loading then
            return
          end

          generation = generation + 1
          render_cache = {}
          frozen_cache = nil

          if redraw then
            redraw_tabline()
          end
        end

        -- 這些事件會使所有 active-buffer 版本的 render 過期。
        --
        -- 不要加入 BufEnter：
        -- active buffer 已包含在 cache key 中，切換時應查找另一份 cache。
        vim.api.nvim_create_autocmd({
          "BufAdd",
          "BufDelete",
          "BufWipeout",
          "BufFilePost",
          "FileType",
          "ColorScheme",
          "TabNew",
          "TabClosed",
        }, {
          group = cache_group,
          callback = function()
            invalidate_all(false)
          end,
        })

        -- modified 狀態 false/true 切換時立即更新。
        vim.api.nvim_create_autocmd("BufModifiedSet", {
          group = cache_group,
          callback = function()
            invalidate_all(true)
          end,
        })

        -- 只有啟用 bufferline diagnostics 時才監聽。
        if bufferline_options.diagnostics then
          vim.api.nvim_create_autocmd("DiagnosticChanged", {
            group = cache_group,
            callback = function()
              invalidate_all(true)
            end,
          })
        end

        -- Bufferline hover 狀態會影響最終 render。
        vim.api.nvim_create_autocmd("User", {
          group = cache_group,
          pattern = {
            "BufferLineHoverOver",
            "BufferLineHoverOut",
          },
          callback = function()
            invalidate_all(true)
          end,
        })

        -- resize 過程中不針對每個寬度重算。
        -- 停止 resize 120ms 後才清空並正式 render 一次。
        vim.api.nvim_create_autocmd({
          "VimResized",
          "WinResized",
        }, {
          group = cache_group,
          callback = function()
            resizing = true
            resize_generation = resize_generation + 1

            local current_generation = resize_generation

            vim.defer_fn(function()
              if current_generation ~= resize_generation then
                return
              end

              resizing = false
              invalidate_all(true)
            end, 120)
          end,
        })

        -- Session manager 自訂載入事件。
        vim.api.nvim_create_autocmd("User", {
          group = cache_group,
          pattern = "SessionManagerLoadPre",
          callback = function()
            session_loading = true
          end,
        })

        vim.api.nvim_create_autocmd("User", {
          group = cache_group,
          pattern = "SessionManagerLoadPost",
          callback = function()
            session_loading = false
            invalidate_all(true)
          end,
        })

        _G.nvim_bufferline = function()
          -- Session 載入中完全不呼叫原始 renderer。
          if session_loading then
            return frozen_cache or ""
          end

          -- resize 期間沿用最近一次正確結果。
          if resizing and frozen_cache ~= nil then
            return frozen_cache
          end

          local key = make_cache_key()
          local cached = render_cache[key]

          if cached ~= nil then
            frozen_cache = cached
            return cached
          end

          local rendered = original()

          render_cache[key] = rendered
          frozen_cache = rendered

          return rendered
        end

        vim.api.nvim_create_user_command("BufferlineCacheInvalidate", function()
          invalidate_all(true)
        end, {
          desc = "Invalidate and redraw bufferline render cache",
          force = true,
        })

        -- 讓外層可以在 bufferline 內部狀態操作前清除 cache。
        return invalidate_all
      end

      -- 避免 bufferline 載入前先閃出預設 tabline。
      vim.opt.showtabline = 2

      bufferline.setup {
        highlights = vim.deepcopy(builtin_bufferline.highlights or {}),

        options = bufferline_options,

        -- 只交給 bufferline.setup 執行一次。
        on_config_done = builtin_bufferline.on_config_done,
      }

      -- 必須在 bufferline.setup 後載入；
      -- 此模組可能修改 bufferline/tabline 狀態。
      local ok_integrated, integrated_err = pcall(require, "user.integrated.bufferline.nvimTabline")

      if not ok_integrated then
        vim.notify(("Failed to load bufferline integration: %s"):format(integrated_err), vim.log.levels.WARN)
      end

      local ok_tabline, tabline = pcall(require, "tabline")

      if ok_tabline then
        local ok_session, session_err = pcall(tabline.on_session_load_post)

        if not ok_session then
          vim.notify(("Failed to initialize tabline session state: %s"):format(session_err), vim.log.levels.WARN)
        end

        vim.o.tabline = "%!v:lua.nvim_bufferline()" .. " .. v:lua.require'tabline'.tabline_tabs()"
      else
        vim.o.tabline = "%!v:lua.nvim_bufferline()"
      end

      -- 必須在所有可能修改 _G.nvim_bufferline 的初始化之後安裝。
      local invalidate_bufferline_cache = install_bufferline_render_cache()

      if type(invalidate_bufferline_cache) ~= "function" then
        return
      end

      -- BufferLineMovePrev / BufferLineMoveNext
      --
      -- 必須先失效，再呼叫原始操作：
      -- 原始 move() 內部會自行 refresh。
      if type(bufferline.move) == "function" then
        local original_move = bufferline.move

        bufferline.move = function(direction)
          invalidate_bufferline_cache(false)
          return original_move(direction)
        end
      end

      -- BufferLineSortByExtension
      -- BufferLineSortByDirectory
      -- BufferLineSortByRelativeDirectory
      -- BufferLineSortByTabs
      if type(bufferline.sort_by) == "function" then
        local original_sort_by = bufferline.sort_by

        bufferline.sort_by = function(sort_by)
          invalidate_bufferline_cache(false)
          return original_sort_by(sort_by)
        end
      end

      -- BufferLineTogglePin 與 group 操作。
      --
      -- 不同 bufferline 版本可能不直接暴露 bufferline.groups，
      -- 所以同時嘗試使用先前 require 的 groups module。
      local groups_module

      if type(bufferline.groups) == "table" then
        groups_module = bufferline.groups
      elseif ok_groups and type(groups) == "table" then
        groups_module = groups
      end

      if groups_module then
        if type(groups_module.toggle_pin) == "function" then
          local original_toggle_pin = groups_module.toggle_pin

          groups_module.toggle_pin = function(...)
            invalidate_bufferline_cache(false)
            return original_toggle_pin(...)
          end
        end

        if type(groups_module.action) == "function" then
          local original_group_action = groups_module.action

          groups_module.action = function(...)
            invalidate_bufferline_cache(false)
            return original_group_action(...)
          end
        end
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
