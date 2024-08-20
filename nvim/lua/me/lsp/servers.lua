---@type me.lsp.ServerConfig[]
local servers = {
  {
    filetypes = { "lua" },
    root_markers = { ".luarc.json", "stylua.toml", ".stylua.toml" },
    config = {
      cmd = { "lua-language-server" },
      before_init = function(params, config)
        if not params.rootPath or type(params.rootPath) ~= "string" then
          return
        end

        config.settings.Lua.workspace.library = config.settings.Lua.workspace.library or {}

        ---@diagnostic disable-next-line:param-type-mismatch
        if params.rootPath:find(string.gsub(vim.fn.stdpath "config", "%-", "%%-")) then
          config.settings.Lua.runtime.version = "LuaJIT"

          table.insert(config.settings.Lua.workspace.library, vim.env.VIMRUNTIME .. "/lua")

          for _, plugin in ipairs(require("lazy").plugins()) do
            ---@diagnostic disable-next-line:param-type-mismatch
            for _, p in ipairs(vim.fn.expand(plugin.dir .. "/lua", false, true)) do
              table.insert(config.settings.Lua.workspace.library, p)
            end
          end
        end

        if params.rootPath:find ".nvim" then
          table.insert(config.settings.Lua.workspace.library, vim.env.VIMRUNTIME .. "/lua")
        end

        if vim.fn.isdirectory(params.rootPath .. "/lua") == 1 then
          table.insert(config.settings.Lua.workspace.library, params.rootPath .. "/lua")
        end
      end,
      settings = {
        Lua = {
          runtime = {
            pathStrict = true,
          },
          format = {
            enable = false,
          },
          workspace = {
            checkThirdParty = false,
          },
          hint = {
            enable = true,
            arrayIndex = "Disable",
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    },
  },

  {
    filetypes = { "php" },
    root_markers = { "composer.json", ".git" },
    config = {
      cmd = { "intelephense", "--stdio" },
      settings = {
        intelephense = {
          -- stylua: ignore
          stubs = {
            "apache", "apcu", "bcmath", "bz2", "calendar", "com_dotnet", "Core", "ctype", "curl",
            "date", "dba", "dom", "enchant", "exif", "FFI", "fileinfo", "filter", "fpm", "ftp",
            "gd", "gettext", "gmp", "hash", "iconv", "imap", "intl", "json", "ldap", "libxml",
            "mbstring", "meta", "mysqli", "oci8", "odbc", "openssl", "pcntl", "pcre", "PDO",
            "pdo_ibm", "pdo_mysql", "pdo_pgsql", "pdo_sqlite", "pgsql", "Phar", "posix", "pspell",
            "readline", "Reflection", "session", "shmop", "SimpleXML", "snmp", "soap", "sockets",
            "sodium", "SPL", "sqlite3", "standard", "superglobals", "sysvmsg", "sysvsem",
            "sysvshm", "tidy", "tokenizer", "xml", "xmlreader", "xmlrpc", "xmlwriter", "xsl",
            "Zend OPcache", "zip", "zlib", "wordpress", "phpunit",
          },
          format = {
            braces = "psr12",
          },
          phpdoc = {
            textFormat = "text",
            functionTemplate = {
              summary = "$1",
              tags = {
                "@param ${1:$SYMBOL_TYPE} $SYMBOL_NAME",
                "@return ${1:$SYMBOL_TYPE}",
                "@throws ${1:$SYMBOL_TYPE}",
              },
            },
          },
        },
      },
    },
  },

  {
    filetypes = { "javascript", "typescript" },
    root_markers = { "package.json" },
    config = {
      cmd = { "typescript-language-server", "--stdio" },
    },
  },

  {
    filetypes = { "nix" },
    root_markers = { "flake.nix" },
    config = {
      cmd = { "nil" },
    },
  },

  {
    filetypes = { "typst" },
    root_markers = { "main.typ", ".git" },
    config = {
      cmd = { "tinymist" },
    },
  },
}

return servers
