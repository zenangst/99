local Agents = require("99.extensions.agents")
local Completions = require("99.extensions.completions")

--- @param context _99.RequestContext
--- @param prompt string
--- @param opts _99.ops.Opts
--- @return string, _99.Agents.Rule[], _99.Completion
return function(context, prompt, opts)
  local user_prompt = opts.additional_prompt
  assert(
    user_prompt and type(user_prompt) == "string" and #user_prompt > 0,
    "you must add a prompt to you request"
  )

  local full_prompt = prompt
  full_prompt = context._99.prompts.prompts.prompt(user_prompt, full_prompt)

  local rules = Agents.find_rules(context._99.rules, user_prompt)

  local additional_rules = opts.additional_rules
  if additional_rules then
    for _, r in ipairs(additional_rules) do
      table.insert(rules, r)
    end
  end

  local refs = Completions.parse(user_prompt)

  return full_prompt, rules, refs
end
