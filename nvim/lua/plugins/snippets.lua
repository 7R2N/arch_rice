return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "lervag/vimtex" },
    config = function()
      local ls = require("luasnip")
      ls.config.setup({
        enable_autosnippets = true,
        update_events = "TextChanged,TextChangedI",
        store_selection_keys = "<Tab>",
      })


      vim.keymap.set({ "i", "s" }, "<Tab>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        else
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<Tab>", true, true, true),
"n", false
          )
        end
      end, { silent = true })

      vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
        if ls.jumpable(-1) then ls.jump(-1) end
      end, { silent = true })

      require("luasnip.loaders.from_lua").load({
        paths = { vim.fn.stdpath("config") .. "/luasnippets" }
      })
    end,
  },
}
