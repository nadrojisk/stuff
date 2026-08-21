return {
    'glacambre/firenvim',
    lazy = not vim.g.started_by_firenvim, -- only load if started by Firenvim
    build = ":call firenvim#install(0)",
    config = function()
        -- Firenvim takeover config
        vim.g.firenvim_config = {
            localSettings = {
                [".*"] = {
                    takeover = "never" -- disable takeover everywhere by default
                },
                ["https://thehive.pnl.gov/cases"] = {
                    takeover = "always", -- only enable for this site
                    priority = 1
                },
                ["https://thehive.pnl.gov/cases/.*/observables"] = {
                    takeover = "never", -- only enable for this site
                    priority = 1
                }

            }
        }

        vim.api.nvim_create_autocmd({'BufEnter'}, {
            pattern = "thehive.pnl.gov_*.txt",
            command = "set filetype=markdown"
        })
    end
}
