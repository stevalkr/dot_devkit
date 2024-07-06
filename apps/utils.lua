local M = {}
Confirmed = Confirmed or false

M.fs = fs or {
  ls_dir = function(...) end,
  exists = function(...) end,
  join = function(...) return '' end,
  split_path = function(...) return {} end
}

M.sh = sh or {
  set_env = function(...) end,
  get_env = function(...) end,
}

M.load_env_file = function(path)
  local f = io.open(path, 'r')
  if f == nil then
    return
  end
  for line in f:lines() do
    local key, value = line:match('([^=]+)=(.*)')
    if key ~= nil and value ~= nil then
      M.sh.set_env(key, value)
    end
  end
  f:close()
end

M.merge_tables = function(...)
  local result = {}
  for _, t in ipairs({ ... }) do
    for _, v in ipairs(t) do
      table.insert(result, v)
    end
  end
  return result
end

M.confirm = function()
  if Confirmed then
    return true
  end
  io.write('Confirm [y]/n: ')
  local c = io.read()
  if c ~= '' and c ~= 'y' and c ~= 'Y' then
    return false
  end
  return true
end

M.confirm_command = function(command, fn)
  io.write('Running command:\n  ' .. command .. '\n\n')

  if M.confirm() then
    if fn ~= nil then
      fn()
    end
    return {
      search_path = 'true',
      use_shell = 'true',
      command = command,
    }
  end
  return {
    search_path = 'true',
    use_shell = 'true',
    command = 'echo Canceled. && exit 1'
  }
end

return M
