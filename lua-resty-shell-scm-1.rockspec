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
  type          = "command",
  build_command = [[
       git submodule init \
    && cd sockproc \
    && git checkout master \
    && git pull \
    && make
  ]],
  install = {
    lua = {
      ["resty.shell"] = "lib/resty/shell.lua",
    },
    bin = {
      ["sockproc"] = "sockproc/sockproc",
    }
  },
}
