-- Install the Mason packages for this machine's tier (configs/tools.lua),
-- wait for them, and print "FAILED: none" or the packages that failed.
-- Used by tests/test-install-container.sh.
local pkgs = require("configs.tools").mason
require("lazy").load({ plugins = { "mason.nvim" } })
local registry = require("mason-registry")
local refreshed = false
registry.refresh(function() refreshed = true end)
vim.wait(120000, function() return refreshed end, 500)

local pending, failed = 0, {}
for _, name in ipairs(pkgs) do
  local ok, pkg = pcall(registry.get_package, name)
  if not ok then
    table.insert(failed, name .. " (unknown package)")
  elseif not pkg:is_installed() then
    pending = pending + 1
    pkg:install():once("closed", function() pending = pending - 1 end)
  end
end
vim.wait(900000, function() return pending == 0 end, 1000)

for _, name in ipairs(pkgs) do
  local ok, pkg = pcall(registry.get_package, name)
  if ok and not pkg:is_installed() then table.insert(failed, name) end
end
print("FAILED: " .. (#failed > 0 and table.concat(failed, " ") or "none"))
