local M = {}
local h = {}
require('utils')


--
-- sys
--
M.notify = require('shortkut.sys').notify
h['notify'] = [[
Usage:
  sk notify                              Send notification to device
]]

M.source = require('shortkut.sys').source
h['source'] = [[
Usage:
  sk source                              Source file using zsh
]]


--
-- pkg
--
M.pkg = require('shortkut.pkg').pkg
h['pkg'] = [[
Usage:
  sk pkg --name <name> [options]         Create a new project

Options:
  -n, --name <name>                      Project name, required
  -t, --type <type>                      Project type, default to meson. Available types: meson, cmake, catkin, colcon
]]


--
-- builder
--
M.build = require('shortkut.builder').build
h['build'] = [[
Usage:
  sk build [subcommands] [options] [--] <extra arguments>

Subcommands:
  [none]                                 Build project
  test                                   Run tests
  install                                Install to system
  find_path                              Print build path

Options:
  -n, --name <name>                      Project name, default to cwd (lower case)
  -p, --path <build dir>                 Build directory, default to <store>/builds/<name> or cwd/build or cwd/_build
  -l, --local                            Use local build directory cwd/_build
  -t, --type <type>                      Project type, default order: meson > cmake > make
  -d, --debug                            Debug build, default to false
]]

M.test = require('shortkut.builder').test
h['test'] = h['build']

M.install = require('shortkut.builder').install
h['install'] = h['build']

M.clean = require('shortkut.builder').clean
h['clean'] = [[
Usage:
  sk clean [options]                     Clean build directory

Options:
  -n, --name <name>                      Project name, default to cwd (lower case)
  -p, --path <build dir>                 Build directory, default to <store>/builds/<name> or cwd/build or cwd/_build
]]


--
-- nix
--
M.dev = require('shortkut.nix').dev
h['dev'] = [[
Usage:
  sk dev [options]                       Start dev environment

Options:
  -s, --save                             Save profile to <store>/nix-profiles/<name>
]]

M.flake = require('shortkut.nix').flake
h['flake'] = [[
Usage:
  sk flake [options] [--] <extra arguments>

Options:
  -n, --name <name>                      Project name, default to cwd (lower case)
  -p, --path <build dir>                 Flake directory, default to <store>/flakes/<name> or cwd/flake
  -s, --save                             Save profile to <store>/nix-profiles/<name>
  --git                                  Use git path, default to false
]]


--
-- ros
--
M.ros = require('shortkut.ros').ros
M.ros2 = require('shortkut.ros').ros2
M.catkin = require('shortkut.ros').catkin
M.colcon = require('shortkut.ros').colcon


--
-- help
--
h['help'] = [[
Usage:
  sk <command> [subcommands] [options] [--] <extra arguments>

Commands:
  notify                              Send notification to device
  source                              Source file using zsh
  pkg                                 Create a new project
  build                               Build project
  test                                Run tests
  install                             Install to system
  clean                               Clean build directory
  dev                                 Start dev environment
  flake                               Start flake environment
  ros                                 Start ros environment
  ros2                                Start ros2 environment
  catkin                              Build with catkin
  colcon                              Build with colcon
  help                                Print help message
]]
M.help = function(command)
  local general_options = [[

General Options:
  -h, --help                           Print help message
  -y, --confirm                        Confirm all prompts
  --store <dir>                        Store directory, default to ~/.devkit ]]

  if #command == 0 then
    command = 'help'
  end

  return (h[command] or '') .. general_options
end

return M
