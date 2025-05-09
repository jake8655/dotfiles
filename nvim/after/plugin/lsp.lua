vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

-- Rounded corners for popups
vim.diagnostic.config {
  virtual_text = true,
  signs = true,
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    format = function(diagnostic)
      if diagnostic.source == 'eslint' then
        return string.format('%s (%s) [%s]', diagnostic.message, diagnostic.source, diagnostic.user_data.lsp.code)
      end
      return string.format('%s [%s]', diagnostic.message, diagnostic.source)
    end,
  },
}
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>s', require('telescope.builtin').lsp_document_symbols, 'Document [S]ymbols')
  nmap('<leader>y', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace S[y]mbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  -- Create a command `:Format` local to the LSP buffer
  -- vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
  --     vim.lsp.buf.format()
  -- end, { desc = 'Format current buffer with LSP' })
  -- nmap('<leader>h', vim.lsp.buf.format, 'Format current buffer with LSP')
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.

---@param fileNames table<integer, string>
local function areFilesPresentInCWD(fileNames)
  for _, file in ipairs(fileNames) do
    if vim.fn.filereadable(file) == 1 then
      return true
    end
  end
  return false
end

local BIOME_CONFIG = { 'biome.json', 'biome.jsonc' }
local ESLINT_CONFIG = {
  '.eslintrc',
  '.eslintrc.json',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.mjs',
  'eslint.config.js',
  'eslint.config.cjs',
  'eslint.config.mjs',
  'eslint.config.ts',
}

local function isBiomeLinterEnabled()
  for _, file in ipairs(BIOME_CONFIG) do
    if vim.fn.filereadable(file) == 1 then
      ---@type table<string>
      local content = vim.fn.readfile(file)
      ---@type table<string, unknown>
      ---@diagnostic disable-next-line: assign-type-mismatch
      local parsed = vim.fn.json_decode(content)

      if parsed.linter and parsed.linter.enabled == true then
        return true
      end
    end
  end

  return false
end

---@param table1 table
---@param table2 table
local function spread(table1, table2)
  local result = {}
  for k, v in pairs(table1) do
    result[k] = v
  end
  for k, v in pairs(table2) do
    result[k] = v
  end
  return result
end

local js_linter = {}
if isBiomeLinterEnabled() then
  js_linter.biome = {}
end
if areFilesPresentInCWD(ESLINT_CONFIG) then
  js_linter.eslint = {}
end

local servers = spread({
  -- Ensure installed
  astro = {},
  bashls = {},
  cssls = {},
  dockerls = {},
  jsonls = {},
  pyright = {},
  tailwindcss = {},
  yamlls = {},
  ts_ls = {
    update_in_insert = false,
  },

  rust_analyzer = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = 'clippy',
      },
      diagnostics = {
        enable = true,
        experimental = { enable = true },
      },
      cargo = {
        allFeatures = true,
      },
    },
  },

  lua_ls = {
    Lua = {
      format = {
        enable = false,
      },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}, js_linter)

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

---@diagnostic disable-next-line: missing-fields
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  ---@param server_name string
  function(server_name)
    if server_name == 'eslint' and not areFilesPresentInCWD(ESLINT_CONFIG) then
      return
    end
    if server_name == 'biome' and not isBiomeLinterEnabled() then
      return
    end

    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

---@diagnostic disable-next-line: missing-fields
require('mason').setup {
  ui = {
    border = 'rounded',
  },
}
if areFilesPresentInCWD(ESLINT_CONFIG) then
  require('lspconfig').eslint.setup {
    on_attach = function(client, bufnr)
      -- Disable hover and similar features for eslint-lsp
      client.server_capabilities.documentHighlight = false
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.signatureHelp = false
      client.server_capabilities.renameProvider = false
      client.server_capabilities.completion = false
      client.server_capabilities.codeAction = true
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormatting = false
      client.server_capabilities.documentSymbol = false
      client.server_capabilities.workspaceSymbol = false
      client.server_capabilities.codeLens = false
      client.server_capabilities.declaration = false
      client.server_capabilities.definition = false
      client.server_capabilities.typeDefinition = false
      client.server_capabilities.implementation = false
      client.server_capabilities.references = false
      client.server_capabilities.documentHighlight = false
      -- require('lspconfig').on_attach(client, bufnr)

      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        command = 'EslintFixAll',
      })
    end,
  }
end

if isBiomeLinterEnabled() then
  require('lspconfig').biome.setup {
    on_attach = function(_, bufnr)
      local workspace_path = vim.lsp.buf.list_workspace_folders()[1]
      local file_path = vim.fn.expand('%:' .. workspace_path .. ':.')

      vim.api.nvim_create_autocmd('BufWritePost', {
        buffer = bufnr,
        command = 'silent! !biome check --apply-unsafe ' .. file_path .. ' & biome lint --apply-unsafe ' .. file_path,
      })
    end,
  }
end
vim.keymap.set('n', '<leader>m', vim.cmd.Mason)

-- Configure nvim-cmp
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

---@diagnostic disable-next-line: missing-fields
cmp.setup {
  behavior = cmp.SelectBehavior.Select,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- Setup cmp source for crates lazily
vim.api.nvim_create_autocmd('BufRead', {
  group = vim.api.nvim_create_augroup('CmpSourceCargo', { clear = true }),
  pattern = 'Cargo.toml',
  callback = function()
    cmp.setup.buffer { sources = { { name = 'crates' } } }
  end,
})

-- Support for hyprland config files
vim.filetype.add {
  pattern = { ['.*/hypr/.*%.conf'] = 'hyprlang' },
}
