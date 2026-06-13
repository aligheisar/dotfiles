require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = { "tsserver", "biome" },
})

-- TypeScript / Next.js
vim.lsp.config("tsserver", {
  on_attach = function(client)
    -- disable formatting, Biome handles it
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

-- Biome LSP
vim.lsp.config("biome", {
  cmd = { "biome", "lsp-proxy" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
  },
  root_markers = { "biome.json" },
})

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

vim.keymap.set("n", "<leader>ci", vim.lsp.buf.incoming_calls)
vim.keymap.set("n", "<leader>co", vim.lsp.buf.outgoing_calls)
