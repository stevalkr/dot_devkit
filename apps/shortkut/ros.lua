local M = {}

local fs = require('utils').fs
local sh = require('utils').sh
local confirm_command = require('utils').confirm_command

M.ros = function(cwd, subcommands, options, rest_args, extra_args)
  local name    = options['name'] or fs.split_path(cwd).name:lower()
  local store   = fs.join(options['store'] or '~/.devkit')
  local path    = fs.join(options['path'] or fs.join(store, 'builds', 'catkin_' .. name))
  local command = [[conda activate ros]]

  local source  = fs.join(path, 'devel/setup.zsh')
  if fs.exists(source) then
    print('Sourcing: ' .. source)
    command = command .. [[ && ]] ..
        [[source ]] .. source
  end

  return confirm_command(
    [[zsh -c "source ~/.zshrc && ]] ..
    [[export CONDA_BUILD=1 && ]] ..
    command .. [[ && ]] ..
    [[export PATH=$CONDA_PREFIX/bin:$PATH && ]] ..
    [[export ROS_PACKAGE_PATH=$CONDA_PREFIX/share:$ROS_PACKAGE_PATH && ]] ..
    [[exec fish"]]
  )
end

M.catkin = function(cwd, subcommands, options, rest_args, extra_args)
  local name   = options['name'] or fs.split_path(cwd).name:lower()
  local store  = fs.join(options['store'] or '~/.devkit')
  local path   = fs.join(options['path'] or fs.join(store, 'builds', 'catkin_' .. name))
  local select = options['select'] or [[""]]

  io.write([[Building "]] .. name .. '" under\n  ' .. path .. '\n\n')

  local cmd = ''
  local commands = {
    build = function()
      if not fs.exists(path) then
        cmd = [[zsh -c "mkdir -p ]] .. path .. [[ && ]] ..
            [[ln -s ]] .. cwd .. [[ ]] .. fs.join(path, 'src') .. [["]]
      else
        cmd = cmd .. [[catkin_make -C ]] .. path ..
            [[ -DCMAKE_EXPORT_COMPILE_COMMANDS=ON]] ..
            [[ -DCATKIN_WHITELIST_PACKAGES=]] .. select .. [[ ]]
      end
      return cmd
    end,

    clean = function()
      return 'rm -rf "' .. path .. '"'
    end
  }

  local command = commands[subcommands[1]]() .. ' ' .. table.concat(extra_args, ' ')

  return confirm_command(command)
end

M.ros2 = function(cwd, subcommands, options, rest_args, extra_args)
  local name    = options['name'] or fs.split_path(cwd).name:lower()
  local store   = fs.join(options['store'] or '~/.devkit')
  local path    = fs.join(options['path'] or fs.join(store, 'builds', 'colcon_' .. name))
  local command = [[conda activate ros2]]

  local source  = fs.join(path, 'install/setup.zsh')
  if fs.exists(source) then
    print('Sourcing: ' .. source)
    command = command .. ' && source ' .. source
  end

  local export_env =
      [[export CONDA_BUILD=1 && ]] ..
      [[export LDFLAGS_LD=\"$LDFLAGS_LD -L/opt/homebrew/Caskroom/miniconda/base/envs/ros2/lib]] ..
      [[ -rpath /opt/homebrew/Caskroom/miniconda/base/envs/ros2/lib\" && ]] ..
      [[export LDFLAGS=\"$LDFLAGS -L/opt/homebrew/Caskroom/miniconda/base/envs/ros2/lib]] ..
      [[ -Wl,-rpath,/opt/homebrew/Caskroom/miniconda/base/envs/ros2/lib\"]]

  return confirm_command(
    [[zsh -c "source ~/.zshrc && ]] ..
    export_env .. [[ && ]] ..
    command .. [[ && ]] ..
    [[exec fish"]]
  )
end

M.colcon = function(cwd, subcommands, options, rest_args, extra_args)
  local name   = options['name'] or fs.split_path(cwd).name:lower()
  local store  = fs.join(options['store'] or '~/.devkit')
  local path   = fs.join(options['path'] or fs.join(store, 'builds', 'colcon_' .. name))
  local select = options['select'] or nil

  io.write([[Building "]] .. name .. '" under\n  ' .. path .. '\n\n')

  local cmd = ''
  local commands = {
    build = function()
      cmd = [[colcon --log-base "]] .. fs.join(path, 'log') .. [[" ]] ..
          [[build --symlink-install --build-base "]] .. fs.join(path, 'build') .. [[" ]] ..
          [[--install-base "]] .. fs.join(path, 'install') .. [[" ]] ..
          [[--cmake-args '-DPython_EXECUTABLE=$CONDA_PREFIX/bin/python ]] ..
          [[-DPython3_EXECUTABLE=$CONDA_PREFIX/bin/python ]] ..
          [[-DPYTHON_EXECUTABLE=$CONDA_PREFIX/bin/python ]] ..
          [[-DPython3_FIND_STRATEGY=LOCATION ]] ..
          [[-DPython_FIND_STRATEGY=LOCATION ]] ..
          [[-DCMAKE_EXPORT_COMPILE_COMMANDS=ON']]
      if select ~= nil then
        cmd = cmd .. ' --packages-select ' .. select
      end
      return cmd
    end,

    clean = function()
      return [[rm -rf "]] .. path .. [["]]
    end
  }

  local command = commands[subcommands[1]]() .. ' ' .. table.concat(extra_args, ' ')

  return confirm_command(command)
end

return M
