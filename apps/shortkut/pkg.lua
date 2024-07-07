local M = {}

local fs = require('utils').fs
local sh = require('utils').sh
local snake = require('utils').snake
local confirm_command = require('utils').confirm_command

M.pkg = function(cwd, subcommands, options, rest_args, extra_args)
  local name  = options['name']
  local type  = options['type'] or 'meson'
  local store = fs.join(options['store'] or '~/.devkit')

  if name == nil then
    return {
      search_path = 'true',
      use_shell = 'true',
      command = 'echo --name is required. && return 1'
    }
  end

  local commands = {
    meson = function()
      return [[mkdir -p ]] .. name .. [[ && ]] ..
             [[cd ]] .. name .. [[ && ]] ..
             [[cp ]] .. fs.join(store, 'templates', 'clang-format') .. [[ ./.clang-format && ]] ..
             [[cp -r ]] .. fs.join(store, 'templates', 'meson', '*') .. [[ ./ && ]] ..
             [[sed -i '' "s/{{ project_name }}/]] .. snake(name) .. [[/g" meson.build]]
    end,

    cmake = function()
      return [[mkdir -p ]] .. name .. [[ && ]] ..
             [[cd ]] .. name .. [[ && ]] ..
             [[cp ]] .. fs.join(store, 'templates', 'clang-format') .. [[ ./.clang-format && ]] ..
             [[cp -r ]] .. fs.join(store, 'templates', 'cmake', '*') .. [[ ./ && ]] ..
             [[sed -i '' "s/{{ project_name }}/]] .. snake(name) .. [[/g" CMakeLists.txt]]
    end,

    catkin = function()
      return [[echo Not implemented yet. Develop with catkin flake and run with conda ros env. && return 1]]
    end,

    colcon = function()
      return [[echo Not implemented yet. Develop and run with conda ros2 env. && return 1]]
    end,
  }

  local command = commands[type]()
  return confirm_command(command)
end

return M
