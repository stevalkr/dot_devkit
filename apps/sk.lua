local M = {}
require('utils')

M.help = function(command)
  if command == 'build' then
    return [[
    Usage: sk build [options] [--] <rest arguments>

    Options:
      --store <dir>                        Store directory, default to ~/.devkit
      -n <name>, --name <name>             Project name, default to cwd (lower case)
      -p <build dir>, --path <build dir>   Build directory, default to <store>/builds/<name> ]]
  end

  if command == 'flake' then
    return [[
    Usage: sk flake [options] [--] <rest arguments>

    Options:
      --store <dir>                        Store directory, default to ~/.devkit
      -n <name>, --name <name>             Project name, default to cwd (lower case)
      -p <build dir>, --path <build dir>   Flake directory, default to <store>/flakes/<name>
      -s, --save                           Save profile to <store>/nix-profiles/<name> ]]
  end

  return [[
  Usage: sk help [build | flake] ]]
end

M.notify = require('shortkut.sys').notify
M.source = require('shortkut.sys').source

M.pkg = require('shortkut.pkg').pkg

M.test = require('shortkut.builder').test
M.build = require('shortkut.builder').build
M.install = require('shortkut.builder').install
M.clean = require('shortkut.builder').clean

M.dev = require('shortkut.nix').dev
M.flake = require('shortkut.nix').flake
M.livebook = require('shortkut.nix').livebook

M.ros = require('shortkut.ros').ros
M.ros2 = require('shortkut.ros').ros2
M.catkin = require('shortkut.ros').catkin
M.colcon = require('shortkut.ros').colcon

return M
