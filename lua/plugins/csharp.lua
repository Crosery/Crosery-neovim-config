return {
  -- 1. 配置 Mason，加入 roslyn 仓库
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.registries = opts.registries or {}
      table.insert(opts.registries, "github:mason-org/mason-registry")
      table.insert(opts.registries, "github:Crashdummyy/mason-registry")
    end,
  },

  -- 2. 确保在 nvim-lspconfig 中禁用其他的 C# LSP (防止冲突)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = { enabled = false },
        csharp_ls = { enabled = false },
      },
    },
  },

  -- 3. 配置 Roslyn.nvim (微软官方 C# LSP)
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = {
      filewatching = true,
    },
    init = function()
      -- 获取 capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      vim.lsp.config("roslyn", {
        capabilities = capabilities,
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
        },
        on_attach = function(client, bufnr)
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end,
      })
    end,
  },
}
