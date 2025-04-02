local M = {}

local fs = require('utils').fs
local sh = require('utils').sh
local confirm_command = require('utils').confirm_command

M.pixi = function(cwd, subcommands, options, rest_args, extra_args)
  local name       = options['name'] or fs.split_path(cwd).name:lower()
  local store      = fs.join(options['store'])
  local path       = fs.join(options['path'] or fs.join(store, 'pixis', name))

  local pixi_path  = nil
  local link_path  = fs.join(store, 'pixis', name .. '.sym')
  local candidates = { (options['name'] or options['path']) and path or false, cwd, fs.join(cwd, 'pixi'), path, link_path }
  local check_pixi = function(p) return p and fs.exists(p) and fs.exists(fs.join(p, 'pixi.toml')) end
  for _, candidate in ipairs(candidates) do
    if check_pixi(candidate) then
      pixi_path = candidate
      break
    end
  end

  local clean = options['clean']
  local clean_all = options['clean-all']
  local clean_paths = {}
  if clean and pixi_path then
    table.insert(clean_paths, fs.join(pixi_path, '.pixi'))
  end
  if clean_all then
    table.insert(clean_paths, '~/.cache/rattler')
    table.insert(clean_paths, '~/Library/Caches/rattler/cache')
  end
  if #clean_paths > 0 then
    local command = ''
    for _, p in ipairs(clean_paths) do
      if fs.exists(p) then
        command = command .. 'rm -rf ' .. p .. ' ; '
      end
    end
    io.write('Cleaning caches\n')
    return confirm_command(command)
  end

  if not pixi_path then
    return {
      search_path = 'true',
      use_shell = 'true',
      command = 'echo pixi not found. && exit 1'
    }
  end

  local command = ''
  if pixi_path ~= path and pixi_path ~= pixi_path and not fs.exists(link_path) then
    command = 'ln -sn ' .. pixi_path .. ' ' .. link_path .. ' ; '
  end

  io.write('Using pixi "' .. name .. '" under\n' .. pixi_path .. '\n\n')

  command = command ..
      'pixi shell --manifest-path="' .. pixi_path .. '" ' .. table.concat(extra_args, ' ')
  return confirm_command(command, function() sh.set_env('DK_ENV', name, 1) end)
end

return M
