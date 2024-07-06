local M = {}

local fs = require('utils').fs
local sh = require('utils').sh
local merge_tables = require('utils').merge_tables
local confirm_command = require('utils').confirm_command

M.notify = function(cwd, subcommands, options, rest_args, extra_args)
  local args = merge_tables(subcommands, rest_args, extra_args)

  local params = {
    ApiKey = sh.get_env('NOTIFY_API_KEY'),
    PushTitle = 'devkit notify',
    PushText = ' '
  }

  for i, v in ipairs(args) do
    if i == 1 then
      params.PushTitle = v
    else
      if #params.PushText > 1 then
        params.PushText = params.PushText .. ' '
      end
      params.PushText = v
    end
  end

  local param_str = ''
  for k, v in pairs(params) do
    if #param_str > 0 then
      param_str = param_str .. '&'
    end
    param_str = param_str .. k .. '=' .. v
  end

  local command = [[curl -X POST -d "]] .. param_str .. [[" https://www.notifymydevice.com/push]]
  return confirm_command(command)
end

M.source = function(cwd, subcommands, options, rest_args, extra_args)
  local file = table.concat(require('utils').merge_tables(subcommands, rest_args, extra_args), ' ')
  return confirm_command(
    [[exec zsh -c "source ~/.zshrc && ]] ..
    [[source ]] .. file .. [[ && ]] ..
    [[exec fish"]]
  )
end

return M
