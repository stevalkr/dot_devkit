local M = {}

local fs = require('utils').fs
local sh = require('utils').sh
local confirm_command = require('utils').confirm_command

M.clean = function(cwd, subcommands, options, rest_args, extra_args)
  local name  = options['name'] or fs.split_path(cwd).name:lower()
  local store = fs.join(options['store'] or '~/.devkit')
  local path  = fs.join(options['path'] or fs.join(store, 'builds', name))

  if not fs.exists(path) then
    if fs.exists(fs.join(cwd, 'build')) then
      path = fs.join(cwd, 'build')
    end
    if fs.exists(fs.join(cwd, '_build')) then
      path = fs.join(cwd, '_build')
    end
  end

  io.write('Cleaning "' .. name .. '" under\n  ' .. path .. '\n\n')

  return confirm_command('rm -rf "' .. path .. '"')
end

M.test = function(cwd, subcommands, options, rest_args, extra_args)
  return M.build(cwd, { 'test' }, options, rest_args, extra_args)
end

M.install = function(cwd, subcommands, options, rest_args, extra_args)
  return M.build(cwd, { 'install' }, options, rest_args, extra_args)
end

M.build = function(cwd, subcommands, options, rest_args, extra_args)
  local name  = options['name'] or fs.split_path(cwd).name:lower()
  local store = fs.join(options['store'] or '~/.devkit')
  local path  = fs.join(options['path'] or fs.join(store, 'builds', name))

  if not fs.exists(path) then
    if fs.exists(fs.join(cwd, 'build')) then
      path = fs.join(cwd, 'build')
    end
    if fs.exists(fs.join(cwd, '_build')) then
      path = fs.join(cwd, '_build')
    end
  end

  local debug = options['debug'] or 'false'

  io.write('Building "' .. name .. '" under\n  ' .. path .. '\n\n')

  local proj_type = 'unknown'
  if fs.exists('meson.build') then
    proj_type = 'meson'
  elseif fs.exists('CMakeLists.txt') then
    proj_type = 'cmake'
  elseif fs.exists('Makefile') then
    proj_type = 'make'
  end

  local count = 0
  if fs.exists(path) then
    count = #fs.ls_dir(path)['files'] + #fs.ls_dir(path)['dirs']
  end
  local commands = {
    meson = function()
      if count > 0 then
        if #subcommands == 0 then
          -- meson compile
          return 'meson compile -C "' .. path .. '"'
        end
        -- meson test
        if subcommands[1] == 'test' then
          return 'meson test -C "' .. path .. '"'
        end
        -- meson install
        if subcommands[1] == 'install' then
          return 'meson install -C "' .. path .. '"'
        end
      else
        -- meson setup --buildtype=debug
        if debug == 'true' then
          return 'meson setup "' .. path .. '" --buildtype=debug'
        end

        -- meson setup
        return 'meson setup "' .. path .. '"'
      end
    end,

    cmake = function()
      if count > 0 then
        if #subcommands == 0 then
          -- cmake --build
          return 'cmake --build "' .. path .. '" -- '
        end
        -- ctest
        if subcommands[1] == 'test' then
          return 'ctest --test-dir "' .. path .. '"'
        end
      else
        -- cmake -B -DCMAKE_BUILD_TYPE=DEBUG
        if debug == 'true' then
          return 'cmake -B "' ..
              path .. '" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_BUILD_TYPE=DEBUG'
        end
        -- cmake -B
        return 'cmake -B "' .. path .. '" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_COLOR_DIAGNOSTICS=ON'
      end
    end,

    make = function()
      if #subcommands == 0 then
        -- make
        return 'make'
      end
      -- make test
      if subcommands[1] == 'test' then
        return 'make test'
      end
      -- make install
      if subcommands[1] == 'install' then
        return 'make install'
      end
    end
  }

  local command = commands[proj_type]() .. ' ' .. table.concat(extra_args, ' ')
  return confirm_command(command)
end

return M
