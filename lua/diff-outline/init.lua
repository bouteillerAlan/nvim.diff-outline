local M = {}

local CURRENT_MARKER = { "^<<<<<<<$", "^<<<<<<<%s.*$" }
local SEPARATOR_MARKER = "^=======%s*$"
local INCOMING_MARKER = { "^>>>>>>>$", "^>>>>>>>%s.*$" }
local BODY_NAMESPACE = vim.api.nvim_create_namespace("MergeConflictBody")

local function set_conflict_highlights()
  vim.api.nvim_set_hl(0, "MergeConflictCurrent", { fg = "#C4F5CA", bg = "#254D32" })
  vim.api.nvim_set_hl(0, "MergeConflictSeparator", { fg = "#FFE99B", bg = "#544414" })
  vim.api.nvim_set_hl(0, "MergeConflictIncoming", { fg = "#FFC4C4", bg = "#592B2B" })
  local light = vim.o.background == "light"
  vim.api.nvim_set_hl(0, "MergeConflictCurrentBody", { bg = light and "#CDE4C8" or "#203B2B" })
  vim.api.nvim_set_hl(0, "MergeConflictIncomingBody", { bg = light and "#F0CECA" or "#43262C" })
end

local function highlight_conflict_bodies(buf)
  if vim.bo[buf].buftype ~= "" then return end

  vim.api.nvim_buf_clear_namespace(buf, BODY_NAMESPACE, 0, -1)
  local start_line, base_line, separator_line
  for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if line:match(CURRENT_MARKER[1]) or line:match(CURRENT_MARKER[2]) then
      start_line, base_line, separator_line = row, nil, nil
    elseif start_line and not separator_line and (line == "|||||||" or line:match("^|||||||%s")) then
      base_line = row
    elseif start_line and not separator_line and line:match(SEPARATOR_MARKER) then
      separator_line = row
    elseif line:match(INCOMING_MARKER[1]) or line:match(INCOMING_MARKER[2]) then
      if start_line and separator_line then
        for body_row = start_line, (base_line or separator_line) - 2 do
          vim.api.nvim_buf_set_extmark(buf, BODY_NAMESPACE, body_row, 0, {
            line_hl_group = "MergeConflictCurrentBody",
          })
        end
        for body_row = separator_line, row - 2 do
          vim.api.nvim_buf_set_extmark(buf, BODY_NAMESPACE, body_row, 0, {
            line_hl_group = "MergeConflictIncomingBody",
          })
        end
      end
      start_line, base_line, separator_line = nil, nil, nil
    end
  end
end

--- Enable conflict highlighting and pass optional settings to mini.hipatterns
---@param hipatterns_opts? table Additional mini.hipatterns configuration
function M.setup(hipatterns_opts)
  set_conflict_highlights()
  local group = vim.api.nvim_create_augroup("DiffOutline", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_conflict_highlights })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "TextChanged", "TextChangedI", "TextChangedP" }, {
    group = group,
    callback = function(event) highlight_conflict_bodies(event.buf) end,
  })
  highlight_conflict_bodies(vim.api.nvim_get_current_buf())

  local conflict_opts = {
    highlighters = {
      -- mini.hipatterns normalizes pattern lists in place.
      conflict_current = {
        pattern = vim.deepcopy(CURRENT_MARKER),
        group = "MergeConflictCurrent",
        extmark_opts = { line_hl_group = "MergeConflictCurrent" },
      },
      conflict_separator = {
        pattern = SEPARATOR_MARKER,
        group = "MergeConflictSeparator",
        extmark_opts = { line_hl_group = "MergeConflictSeparator" },
      },
      conflict_incoming = {
        pattern = vim.deepcopy(INCOMING_MARKER),
        group = "MergeConflictIncoming",
        extmark_opts = { line_hl_group = "MergeConflictIncoming" },
      },
    },
  }
  require("mini.hipatterns").setup(vim.tbl_deep_extend("force", conflict_opts, hipatterns_opts or {}))
end

return M
