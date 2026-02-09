local _99 = require("99")

local M = {}

--- @param provider _99.Providers.BaseProvider?
function M.select_model(provider)
  provider = provider or _99.get_provider()

  provider.fetch_models(function(models, err)
    if err then
      vim.notify("99: " .. err, vim.log.levels.ERROR)
      return
    end
    if not models or #models == 0 then
      vim.notify("99: No models available", vim.log.levels.WARN)
      return
    end

    local ok, pickers = pcall(require, "telescope.pickers")
    if not ok then
      vim.notify(
        "99: telescope.nvim is required for this extension",
        vim.log.levels.ERROR
      )
      return
    end

    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- position the telescope cursor at the currently selected model
    local current = _99.get_model()
    local default_idx = 1
    for i, m in ipairs(models) do
      if m == current then
        default_idx = i
        break
      end
    end

    pickers
      .new({}, {
        prompt_title = "99: Select Model (current: " .. current .. ")",
        default_selection_index = default_idx,
        finder = finders.new_table({ results = models }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if not selection then
              return
            end
            _99.set_model(selection[1])
            vim.notify("99: Model set to " .. selection[1])
          end)
          return true
        end,
      })
      :find()
  end)
end

return M
