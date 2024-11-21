local group = vim.api.nvim_create_augroup("LspServers", { clear = true })

---@class me.lsp.ServerConfig
---@field filetypes string[]
---@field root_markers string[]
---@field config vim.lsp.ClientConfig

---@param server me.lsp.ServerConfig
local function register(server)
  server.config.name = server.config.name or server.config.cmd[1]

  server.config.capabilities =
    vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), server.config.capabilities or {})

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = server.filetypes,
    callback = function(args)
      vim.lsp.start(vim.tbl_deep_extend("keep", {
        root_dir = vim.fs.root(args.buf, server.root_markers),
      }, server.config))
    end,
  })
end

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

        -- for own external plugins
        if params.rootPath:find ".nvim" then
          table.insert(config.settings.Lua.workspace.library, vim.env.VIMRUNTIME .. "/lua")
        end

        if vim.fn.isdirectory(params.rootPath .. "/lua") == 1 then
          table.insert(config.settings.Lua.workspace.library, params.rootPath .. "/lua")
        end
      end,
      settings = {
        Lua = {
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
      capabilities = {
        textDocument = {
          formatting = {
            dynamicRegistration = false,
          },
        },
      },
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
    filetypes = { "rust" },
    root_markers = { "Cargo.toml" },
    config = {
      cmd = { "rust-analyzer" },
    },
  },
}

for _, server in ipairs(servers) do
  register(server)
end
