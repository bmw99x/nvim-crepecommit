local config = {
  command = "opencode-git-commit-msg",
  bypass_hooks = false,
}

local function gen_commit_msg(bypass_hooks)
  local src_win = vim.api.nvim_get_current_win()
  local src_buf = vim.api.nvim_get_current_buf()
  local src_ft  = vim.bo[src_buf].filetype

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(80, vim.o.columns - 6)
  local height = 12
  local win = vim.api.nvim_open_win(buf, true, {
    relative   = "editor",
    row        = math.floor((vim.o.lines   - height) / 2),
    col        = math.floor((vim.o.columns - width)  / 2),
    width      = width,
    height     = height,
    style      = "minimal",
    border     = "rounded",
    title      = bypass_hooks and "  Commit (skip hooks) " or "  Commit Message ",
    title_pos  = "center",
    footer     = " <CR> confirm · q cancel ",
    footer_pos = "center",
  })

  local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local spinner_idx = 1

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { spinner[1] .. "  Generating…" })
  vim.bo[buf].modifiable = false

  local uv = vim.uv or vim.loop
  local timer = uv.new_timer()
  timer:start(80, 80, vim.schedule_wrap(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      timer:stop()
      return
    end
    spinner_idx = (spinner_idx % #spinner) + 1
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { spinner[spinner_idx] .. "  Generating…" })
    vim.bo[buf].modifiable = false
  end))

  local cmd = config.command
  if bypass_hooks then
    cmd = cmd .. " --no-verify"
  end

  local stdout, stderr = {}, {}
  local job_id = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    stdin = "null",
    on_stdout = function(_, data) vim.list_extend(stdout, data) end,
    on_stderr = function(_, data) vim.list_extend(stderr, data) end,
    on_exit = function(_, code)
      timer:stop()
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then return end
        vim.bo[buf].modifiable = true
        if code ~= 0 then
          local msg = #stderr > 0 and stderr or stdout
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "error: " .. table.concat(msg, " ") })
          vim.bo[buf].modifiable = false
          return
        end
        local clean = {}
        for _, line in ipairs(stdout) do
          line = line:gsub("\27%[[%d;]*[A-Za-z]", "")
          if line ~= "" and not line:match("^>%s") then
            table.insert(clean, line)
          end
        end
        while #clean > 0 and clean[#clean] == "" do
          table.remove(clean)
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, clean)
        vim.bo[buf].filetype = "gitcommit"
        if #clean > 0 then
          vim.api.nvim_win_set_cursor(win, { 1, #clean[1] })
        end
      end)
    end,
  })
  if job_id <= 0 then
    timer:stop()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "error: command not found: " .. cmd })
    vim.bo[buf].modifiable = false
  end

  local function confirm()
    if not vim.api.nvim_win_is_valid(win) then return end
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    while #lines > 0 and lines[#lines] == "" do
      table.remove(lines)
    end
    vim.api.nvim_win_close(win, true)
    if src_ft == "gitcommit" then
      vim.api.nvim_buf_set_lines(src_buf, 0, 0, false, lines)
      vim.api.nvim_set_current_win(src_win)
    else
      vim.fn.setreg("+", table.concat(lines, "\n"))
      vim.notify("Commit message copied", vim.log.levels.INFO)
    end
  end

  local opts = { buffer = buf, nowait = true }
  vim.keymap.set("n", "<CR>",  confirm,                                              opts)
  vim.keymap.set("n", "q",     function() vim.api.nvim_win_close(win, true) end,     opts)
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end,     opts)
end

return {
  setup = function(opts)
    if opts then
      config = vim.tbl_deep_extend("force", config, opts)
    end
  end,

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      signs_staged = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
      },
      signs_staged_enable = true,
      attach_to_untracked = true,
      current_line_blame  = true,
      current_line_blame_opts = {
        delay        = 500,
        virt_text_pos = "eol",
      },
    },
    keys = {
      { "<leader>gbl", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame line (full)" },
      { "<leader>gB",  function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle inline blame" },
      { "[g",          function() require("gitsigns").nav_hunk("prev") end,            desc = "Prev hunk" },
      { "]g",          function() require("gitsigns").nav_hunk("next") end,            desc = "Next hunk" },
      { "<leader>gp",  function() require("gitsigns").preview_hunk() end,              desc = "Preview hunk" },
      { "<leader>gr",  function() require("gitsigns").reset_hunk() end,                desc = "Reset hunk" },
      { "<leader>gS",  function() require("gitsigns").stage_hunk() end,                desc = "Stage hunk" },
      { "<leader>gU",  function() require("gitsigns").undo_stage_hunk() end,           desc = "Undo stage hunk" },
      { "<leader>gd",  function() require("gitsigns").diffthis() end,                  desc = "Diff this file" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    keys = {
      { "<leader>gC", function() gen_commit_msg(false) end, desc = "Generate commit message" },
      { "<leader>gW", function() gen_commit_msg(true) end, desc = "Generate commit message (skip hooks)" },
    },
  },
}