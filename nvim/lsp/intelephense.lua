vim.lsp.config.intelephense = {
  cmd = { "intelephense", "--stdio" },
  root_markers = { "composer.json", ".git" },
  filetypes = { "php" },
  capabilities = {
    textDocument = {
      formatting = {
        dynamicRegistration = false,
      },
    },
  },
  commands = {
    ["editor.action.triggerParameterHints"] = function()
      vim.lsp.buf.signature_help()
    end,
  },
  settings = {
    intelephense = {
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
      stubs = {
        "apache",
        "apcu",
        "bcmath",
        "bz2",
        "calendar",
        "com_dotnet",
        "Core",
        "ctype",
        "curl",
        "date",
        "dba",
        "dom",
        "enchant",
        "exif",
        "FFI",
        "fileinfo",
        "filter",
        "fpm",
        "ftp",
        "gd",
        "gettext",
        "gmp",
        "hash",
        "iconv",
        "imap",
        "intl",
        "json",
        "ldap",
        "libxml",
        "mbstring",
        "meta",
        "mysqli",
        "oci8",
        "odbc",
        "openssl",
        "pcntl",
        "pcre",
        "PDO",
        "pdo_ibm",
        "pdo_mysql",
        "pdo_pgsql",
        "pdo_sqlite",
        "pgsql",
        "Phar",
        "posix",
        "pspell",
        "readline",
        "Reflection",
        "session",
        "shmop",
        "SimpleXML",
        "snmp",
        "soap",
        "sockets",
        "sodium",
        "SPL",
        "sqlite3",
        "standard",
        "superglobals",
        "sysvmsg",
        "sysvsem",
        "sysvshm",
        "tidy",
        "tokenizer",
        "xml",
        "xmlreader",
        "xmlrpc",
        "xmlwriter",
        "xsl",
        "Zend OPcache",
        "zip",
        "zlib",
        "wordpress",
        "phpunit",
      },
    },
  },
}
