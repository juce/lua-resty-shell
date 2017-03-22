package = "lua-resty-shell"
version = "scm-1"
source  = {
  url = "git+https://github.com/juce/lua-resty-shell.git",
}
description = {
  summary  = "Tiny subprocess/shell library to use with OpenResty application server.",
  detailed = "",
  homepage = "https://github.com/juce/lua-resty-shell",
  license  = "MIT",
}
dependencies = {
  "lua >= 5.1",
}

build = {
  type    = "builtin",
  modules = {
    ["resty.shell"] = "lib/resty/shell.lua",
  },
}
