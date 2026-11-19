local owned_dotdirs = { ".agents", ".config", ".github", ".buildkite", ".claude" }

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
          transform = function(item, _)
            local file = item.file
            if not file then
              return
            end
            for seg in string.gmatch(file, "[^/]+") do
              if seg:sub(1, 1) == "." and not vim.list_contains(owned_dotdirs, seg) then
                return false
              end
            end
          end,
        },
      },
    },
  },
}
