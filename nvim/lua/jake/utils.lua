local M = {
  ESLINT_CONFIG = {
    '.eslintrc',
    '.eslintrc.json',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.mjs',
    'eslint.config.js',
    'eslint.config.cjs',
    'eslint.config.mjs',
    'eslint.config.ts',
  },

  PRETTIER_CONFIG = {
    '.prettierrc',
    '.prettierrc.json',
    '.prettierrc.js',
    '.prettierrc.cjs',
    '.prettierrc.mjs',
    'prettier.config.js',
    'prettier.config.cjs',
    'prettier.config.mjs',
    'prettier.config.ts',
  },

  BIOME_CONFIG = {
    'biome.json',
    'biome.jsonc',
    '.biome.json',
    '.biome.jsonc',
  },

  OX_CONFIG = {
    '.oxlintrc.json',
    '.oxlintrc.jsonc',
    'oxlint.config.ts',
    '.oxfmtrc.json',
    '.oxfmtrc.jsonc',
    'oxfmt.config.ts',
  },

  ---@param fileNames table<integer, string>
  areFilesPresentInCWD = function(fileNames)
    for _, file in ipairs(fileNames) do
      if vim.fn.filereadable(file) == 1 then
        return true
      end
    end
    return false
  end,
}

local project_root_markers = {
  'package-lock.json',
  'yarn.lock',
  'pnpm-lock.yaml',
  'bun.lockb',
  'bun.lock',
  'deno.lock',
  '.git',
}

---@param bufnr integer
---@return string
local function buffer_directory(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(filename)
end

---@param directory string
---@param filenames string[]
---@return boolean
local function has_file(directory, filenames)
  for _, filename in ipairs(filenames) do
    if vim.fn.filereadable(vim.fs.joinpath(directory, filename)) == 1 then
      return true
    end
  end
  return false
end

---@param directory string
---@param dependencies table<string, boolean>
---@return string?
local function package_toolchain(directory, dependencies)
  local package_json = vim.fs.joinpath(directory, 'package.json')
  if vim.fn.filereadable(package_json) == 0 then
    return nil
  end

  local ok, package = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_json), '\n'))
  if not ok then
    return nil
  end

  for _, dependency_group in ipairs { 'dependencies', 'devDependencies', 'peerDependencies', 'optionalDependencies' } do
    for dependency in pairs(package[dependency_group] or {}) do
      if dependencies[dependency] then
        return dependency
      end
    end
  end
end

---@param bufnr? integer
---@return string
function M.webProjectRoot(bufnr)
  bufnr = bufnr or 0
  return vim.fs.root(bufnr, project_root_markers) or vim.fs.root(bufnr, { 'package.json', 'deno.json', 'deno.jsonc' }) or buffer_directory(bufnr)
end

---Select the JS formatter/linter toolchain for a buffer. Explicit configuration
---or dependencies win; projects without either intentionally use Biome.
---@param bufnr? integer
---@return 'biome'|'ox'
function M.webToolchain(bufnr)
  bufnr = bufnr or 0
  local directory = buffer_directory(bufnr)
  local root = M.webProjectRoot(bufnr)

  while directory do
    if has_file(directory, M.BIOME_CONFIG) or package_toolchain(directory, { ['@biomejs/biome'] = true }) then
      return 'biome'
    end

    if has_file(directory, M.OX_CONFIG) or package_toolchain(directory, { ['vite-plus'] = true, oxlint = true, oxfmt = true }) then
      return 'ox'
    end

    if directory == root then
      break
    end

    local parent = vim.fs.dirname(directory)
    if not parent or parent == directory then
      break
    end
    directory = parent
  end

  return 'biome'
end

return M
