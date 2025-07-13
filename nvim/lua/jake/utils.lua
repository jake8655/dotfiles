return {
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
