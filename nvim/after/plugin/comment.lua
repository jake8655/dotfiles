require('ts_context_commentstring').setup {
  enable_autocmd = false,
}

local ts_pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()

require('Comment').setup {
  -- Fall back to the filetype's native commentstring when Treesitter can't
  -- resolve one (e.g. no parser installed for the language).
  pre_hook = function(ctx)
    return ts_pre_hook(ctx) or vim.bo.commentstring
  end,
}
