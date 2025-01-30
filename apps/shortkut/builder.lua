local M = {}

local fs = require('utils').fs
local sh = require('utils').sh
local cmd = require('utils').cmd
local confirm_command = require('utils').confirm_command

local find_path = function(cwd, options)
  local name = options['name'] or fs.split_path(cwd).name:lower()

  local debug = options['debug'] or 'false'
  if debug == 'true' then
    name = name .. '_debug'
  end

  local store = fs.join(options['store'])

  local default_path = fs.join(store, 'builds', name)
  if options['local'] == 'true' then
    default_path = fs.join(cwd, '_build')
  end
  local path = fs.join(options['path'] or default_path)

  if not fs.exists(path) then
    if fs.exists(fs.join(cwd, 'build')) then
      path = fs.join(cwd, 'build')
    end
    if fs.exists(fs.join(cwd, '_build')) then
      path = fs.join(cwd, '_build')
    end
  end

  return name, path
end

M.clean = function(cwd, subcommands, options, rest_args, extra_args)
  local name, path = find_path(cwd, options)

  io.write('Cleaning "' .. name .. '" under\n  ' .. path .. '\n\n')

  return confirm_command('rm -rf "' .. path .. '"')
end

M.test = function(cwd, subcommands, options, rest_args, extra_args)
  return M.build(cwd, { 'test' }, options, rest_args, extra_args)
end

M.install = function(cwd, subcommands, options, rest_args, extra_args)
  return M.build(cwd, { 'install' }, options, rest_args, extra_args)
end

M.compile_commands = function(cwd, subcommands, options, rest_args, extra_args)
  local name, path = find_path(cwd, options)

  io.write('Linking compile_commands.json of "' .. name .. '" under\n  ' .. path .. '\n\n')

  return confirm_command('ln -sf "' ..
    fs.join(path, 'compile_commands.json') .. '" "' .. fs.join(cwd, 'compile_commands.json') .. '"')
end

M.build = function(cwd, subcommands, options, rest_args, extra_args)
  local debug = options['debug'] or 'false'
  local name, path = find_path(cwd, options)

  if #subcommands > 0 and subcommands[1] == 'find_path' then
    print(path)
    return {}
  end

  io.write('Building "' .. name .. '" under\n  ' .. path .. '\n\n')

  local proj_type = 'unknown'
  if fs.exists('meson.build') then
    proj_type = 'meson'
  elseif fs.exists('CMakeLists.txt') then
    proj_type = 'cmake'
  elseif fs.exists('Makefile') then
    proj_type = 'make'
  end
  proj_type = options['type'] or proj_type

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
        -- meson setup
        local setup = 'meson setup "' .. path .. '"'
        if debug == 'true' then
          -- meson setup --buildtype=debug
          setup = setup .. ' --buildtype=debug'
        end
        return setup
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
        -- cmake -B
        local setup = 'cmake -B "' .. path .. '" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_COLOR_DIAGNOSTICS=ON'
        if debug == 'true' then
          -- cmake -B -DCMAKE_BUILD_TYPE=DEBUG
          setup = setup .. ' -DCMAKE_BUILD_TYPE=DEBUG'
        end
        return setup
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
    end,

    unknown = function()
      return 'echo Unknown project type. && exit 1'
    end
  }

  local command = commands[proj_type]() .. ' ' .. table.concat(extra_args, ' ')
  return confirm_command(command)
end

return M
