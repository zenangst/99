local Request = require("99.request")
local make_clean_up = require("99.ops.clean-up")
local make_prompt = require("99.ops.make-prompt")

--- @class _99.Tutorial.Result

--- @param context _99.RequestContext
---@param opts _99.ops.Opts
local function tutorial(context, opts)
  opts = opts or {}

  local logger = context.logger:set_area("tutorial")
  logger:debug("starting", "with opts", opts)

  local request = Request.new(context)

  local clean_up = make_clean_up(context, "Search", function()
    request:cancel()
  end)

  local prompt, rules =
    make_prompt(context, context._99.prompts.prompts.tutorial(), opts)
  context:add_agent_rules(rules)
  request:add_prompt_content(prompt)

  request:start({
    on_complete = function(status, response)
      vim.schedule(clean_up)
      if status == "cancelled" then
        logger:debug("cancelled")
      elseif status == "failed" then
        logger:error(
          "failed",
          "error response",
          response or "no response provided"
        )
      elseif status == "success" then
        error("what the hell")
      end
    end,
    on_stdout = function(line)
      --- TODO: i need to figure out how to surface this information
      _ = line
    end,
    on_stderr = function(line)
      logger:debug("on_stderr", "line", line)
    end,
  })
end
return tutorial
