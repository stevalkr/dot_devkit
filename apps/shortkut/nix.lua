local M = {}

local fs = require('utils').fs
local sh = require('utils').sh
local confirm_command = require('utils').confirm_command

M.dev = function(cwd, subcommands, options, rest_args, extra_args)
  return M.flake(
    cwd,
    {},
    { name = 'dev', store = options['store'], save = options['save'] },
    {},
    {}
  )
end

M.flake = function(cwd, subcommands, options, rest_args, extra_args)
  local name = options['name'] or fs.split_path(cwd).name:lower()
  local store = fs.join(options['store'])
  local path = fs.join(options['path'] or fs.join(store, 'flakes', name))
  local git = options['git'] == 'true' or false
  local cmd = options['command'] or 'fish'

  local save = ''
  if options['save'] == 'true' then
    save = '--profile "' .. fs.join(store, 'nix-profiles', name) .. '"'
  end

  local flake_path = nil
  local link_path = fs.join(store, 'flakes', name .. '.sym')
  local candidates = {
    (options['name'] or options['path']) and path or false,
    cwd,
    fs.join(cwd, 'flake'),
    path,
    link_path,
  }
  local check_flake = function(p)
    return p and fs.exists(p) and fs.exists(fs.join(p, 'flake.nix'))
  end
  for _, candidate in ipairs(candidates) do
    if check_flake(candidate) then
      flake_path = candidate
      break
    end
  end

  if not flake_path then
    return {
      search_path = 'true',
      use_shell = 'true',
      command = 'echo flake not found. && exit 1',
    }
  end

  local command = ''
  if
    flake_path ~= path
    and flake_path ~= link_path
    and not fs.exists(link_path)
  then
    command = 'ln -sn ' .. flake_path .. ' ' .. link_path .. ' ; '
  end

  if not git then
    flake_path = 'path:' .. flake_path
  end

  io.write('Using flake "' .. name .. '" under\n  ' .. flake_path .. '\n\n')

  command = command
    .. 'nix develop "'
    .. flake_path
    .. '" '
    .. save
    .. ' '
    .. table.concat(extra_args, ' ')
    .. ' --command '
    .. cmd
  return confirm_command(command, function()
    sh.set_env('DK_ENV', name, 1)
  end)
end

return M
