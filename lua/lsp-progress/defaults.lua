--- @alias Configs table<any, any>
--- @type Configs
local Defaults = {
    -- Spinning icons.
    --
    --- @type string[]
    spinner = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },

    -- Spinning update time in milliseconds.
    --
    --- @type integer
    spin_update_time = 200,

    -- Last message cached decay time in milliseconds.
    --
    -- Message could be really fast(appear and disappear in an
    -- instant) that user cannot even see it, thus we cache the last message
    -- for a while for user view.
    --
    --- @type integer
    decay = 700,

    -- User event name.
    --
    --- @type string
    event = "LspProgressStatusUpdated",

    -- Event update time limit in milliseconds.
    --
    -- Sometimes progress handler could emit many events in an instant, while
    -- refreshing statusline cause too heavy synchronized IO, so we limit the
    -- event rate to reduce this cost.
    --
    --- @type integer
    event_update_time_limit = 100,

    -- Max progress string length, by default -1 is unlimit.
    --
    --- @type integer
    max_size = -1,

    -- Regular internal update time.
    --
    -- Emit user event to update the lsp progress status, even there's no new
    -- message.
    --
    --- @type integer
    regular_internal_update_time = 500,

    -- Disable emitting events on specific mode/filetype.
    -- User events would interrupt insert mode, thus break which-key like plugins behaviour.
    -- See:
    --  * https://github.com/linrongbin16/lsp-progress.nvim/issues/50
    --  * https://neovim.io/doc/user/builtin.html#mode()
    --
    --- @type table[]
    disable_events_opts = {
        {
            mode = "i",
            filetype = "TelescopePrompt",
        },
    },

    -- Format series message.
    --
    -- By default it looks like: `formatting isort (100%) - done`.
    --
    --- @param title string|nil
    ---     Message title.
    --- @param message string|nil
    ---     Message body.
    --- @param percentage number|nil
    ---     Progress in percentage numbers: 0-100.
    --- @param done boolean
    ---     Indicate whether this series is the last one in progress.
    --- @return SeriesFormatResult messages
    ---     The returned value will be passed to function `client_format` as
    ---     one of the `series_messages` array, or ignored if return nil.
    series_format = function(title, message, percentage, done)
        local builder = {}
        local has_title = false
        local has_message = false
        if title and title ~= "" then
            table.insert(builder, title)
            has_title = true
        end
        if message and message ~= "" then
            table.insert(builder, message)
            has_message = true
        end
        if percentage and (has_title or has_message) then
            table.insert(builder, string.format("(%.0f%%%%)", percentage))
        end
        if done and (has_title or has_message) then
            table.insert(builder, "- done")
        end
        return table.concat(builder, " ")
    end,

    -- Format client message.
    --
    -- By default it looks like:
    -- `[null-ls] ⣷ formatting isort (100%) - done, formatting black (50%)`.
    --
    --- @param client_name string
    ---     Client name.
    --- @param spinner string
    ---     Spinner icon.
    --- @param series_messages string[]|table[]
    ---     Messages array.
    --- @return ClientFormatResult messages
    ---     The returned value will be passed to function `format` as one of the
    ---     `client_messages` array, or ignored if return nil.
    client_format = function(client_name, spinner, series_messages)
        return #series_messages > 0
                and ("[" .. client_name .. "] " .. spinner .. " " .. table.concat(
                    series_messages,
                    ", "
                ))
            or nil
    end,

    -- Format (final) message.
    --
    -- By default it looks like:
    -- ` LSP [null-ls] ⣷ formatting isort (100%) - done, formatting black (50%)`
    --
    --- @param client_messages string[]|table[]
    ---     Client messages array.
    --- @return string
    ---     The returned value will be returned from `progress` API.
    format = function(client_messages)
        local sign = " LSP" -- nf-fa-gear \uf013
        if #client_messages > 0 then
            return sign .. " " .. table.concat(client_messages, " ")
        end
        if #vim.lsp.get_active_clients() > 0 then
            return sign
        end
        return ""
    end,

    -- Enable debug.
    --
    --- @type boolean
    debug = false,

    -- Print log to console(command line).
    --
    --- @type boolean
    console_log = true,

    -- Print log to file.
    --
    --- @type boolean
    file_log = false,

    -- Log file to write, work with `file_log=true`.
    --
    -- For Windows: `$env:USERPROFILE\AppData\Local\nvim-data\lsp-progress.log`.
    -- For *NIX: `~/.local/share/nvim/lsp-progress.log`.
    --
    --- @type string
    file_log_name = "lsp-progress.log",
}

--- @param option table<string, any>
--- @return nil
local function setup(option)
    local config =
        vim.tbl_deep_extend("force", vim.deepcopy(Defaults), option or {})
    return config
end

--- @type table<string, any>
local M = {
    setup = setup,
}

return M
