local M = {}

local fs = require('utils').fs
local sh = require('utils').sh
local confirm_command = require('utils').confirm_command

M.dev = function(cwd, subcommands, options, rest_args, extra_args)
  return M.flake(cwd, {}, { name = 'dev', store = options['store'], save = options['save'] }, {}, {})
end

M.flake = function(cwd, subcommands, options, rest_args, extra_args)
  local name  = options['name'] or fs.split_path(cwd).name:lower()
  local store = fs.join(options['store'] or '~/.devkit')
  local path  = fs.join(options['path'] or fs.join(store, 'flakes', name))
  local git   = options['git'] == 'true' or false

  local save  = ''
  if options['save'] == 'true' then
    save = '--profile "' .. fs.join(store, 'nix-profiles', name) .. '"'
  end

  local check_flake = function(p)
    if fs.exists(p) then
      for _, file in ipairs(fs.ls_dir(p)['files']) do
        if file == 'flake.nix' then
          return true
        end
      end
    end
    return false
  end

  if not check_flake(path) then
    path = fs.join(cwd, 'flake')
  end

  if not check_flake(path) then
    return {
      search_path = 'true',
      use_shell = 'true',
      command = 'echo flake not found. && exit 1'
    }
  end

  if not git then
    path = 'path:' .. path
  end

  io.write('Using flake "' .. name .. '" under\n  ' .. path .. '\n\n')

  local command = 'nix develop "' .. path .. '" ' .. save .. ' ' .. table.concat(extra_args, ' ') .. ' --command fish'
  return confirm_command(command, function() sh.set_env('DK_ENV', name, 1) end)
end

return M
