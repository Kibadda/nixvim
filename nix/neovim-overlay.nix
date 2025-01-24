{ inputs }:
final: prev:
let
  mkNeovim =
    {
      appName ? null,
      plugins ? [ ],
      devPlugins ? [ ],
    }:
    let
      neovimConfig = final.neovimUtils.makeNeovimConfig {
        withPython3 = false;
        withRuby = false;
        withNodeJs = false;
        viAlias = appName == null || appName == "nvim";
        vimAlias = appName == null || appName == "nvim";
        plugins = final.neovimUtils.normalizePlugins plugins;
      };

      extraPackages = with final; [
        lua-language-server
        nodePackages.intelephense
        typescript-language-server
        nil
        stylua
        tree-sitter
        gcc
        nixfmt-rfc-style
      ];

      nvimRtp = final.stdenv.mkDerivation {
        name = "nvim-rtp";
        src = ../nvim;

        buildPhase = ''
          mkdir -p $out/nvim
          mkdir -p $out/lib
          rm init.lua
        '';

        installPhase = ''
          cp -r after $out/after
          rm -r after
          cp -r lua $out/lib
          rm -r lua
          cp -r * $out/nvim
        '';
      };

      initLua =
        ''
          vim.loader.enable()
          vim.opt.rtp = {
            "${nvimRtp}/lib",
            vim.fn.stdpath("data") .. "/site",
            vim.env.VIMRUNTIME,
            vim.fn.fnamemodify(vim.v.progpath, ":p:h:h") .. "/lib/nvim"
          }
        ''
        + ""
        + (builtins.readFile ../nvim/init.lua)
        + ""
        + final.lib.optionalString (devPlugins != [ ]) (
          ''
            local dev_pack_path = vim.fn.stdpath('data') .. '/site/pack/dev'
            local dev_plugins_dir = dev_pack_path .. '/opt'
            local dev_plugin_path
          ''
          + final.lib.strings.concatMapStringsSep "\n" (plugin: ''
            dev_plugin_path = dev_plugins_dir .. '/${plugin.name}'
            if vim.fn.empty(vim.fn.glob(dev_plugin_path)) > 0 then
              vim.notify('Bootstrapping dev plugin ${plugin.name} ...', vim.log.levels.INFO)
              vim.cmd('!${final.git}/bin/git clone ${plugin.url} ' .. dev_plugin_path)
            end
            vim.cmd('packadd! ${plugin.name}')
          '') devPlugins
        )
        + ''
          vim.opt.rtp:append('${nvimRtp}/nvim')
          vim.opt.rtp:append('${nvimRtp}/after')
        '';

      extraMakeWrapperArgs = builtins.concatStringsSep " " (
        (final.lib.optional (
          appName != "nvim" && appName != null && appName != ""
        ) ''--set NVIM_APPNAME "${appName}"'')
        ++ (final.lib.optional (
          extraPackages != [ ]
        ) ''--prefix PATH : "${final.lib.makeBinPath extraPackages}"'')
      );

      excludeFiles = [
        "indent.vim"
        "menu.vim"
        "mswin.vim"
        "plugin/matchit.vim"
        "plugin/matchparen.vim"
        "plugin/rplugin.vim"
        "plugin/shada.vim"
        "plugin/tohtml.lua"
        "plugin/tutor.vim"
        "plugin/gzip.vim"
        "plugin/tarPlugin.vim"
        "plugin/zipPlugin.vim"
        "plugin/netrwPlugin.vim"
      ];

      postInstallCommands = map (target: "rm -f $out/share/nvim/runtime/${target}") excludeFiles;

      neovim-unwrapped = prev.neovim.overrideAttrs (oa: {
        postInstall = ''
          ${oa.postInstall or ""}
          ${final.lib.concatStringsSep "\n" postInstallCommands}
        '';
      });
    in
    final.wrapNeovimUnstable neovim-unwrapped (
      neovimConfig
      // {
        luaRcContent = initLua;
        wrapperArgs = final.lib.escapeShellArgs neovimConfig.wrapperArgs + " " + extraMakeWrapperArgs;
        wrapRc = true;
      }
    );

  base-plugins = with final.nvimPlugins; [
    nvim-web-devicons
    vim-pasta
    nvim-surround
    nvim-autopairs
    conform-nvim
    mini-ai
    mini-diff
    mini-hipatterns
    mini-pick
    nvim-recorder
    nvim-treesitter
    treesj
  ];

  all-plugins =
    base-plugins
    ++ (with final; [
      git-nvim
      session-nvim
      kanban-nvim
      starter-nvim
      fake-nvim
    ]);

  nvim-dev = mkNeovim {
    plugins = base-plugins;
    appName = "nvim-dev";
    devPlugins = [
      {
        name = "git.nvim";
        url = "git@github.com:Kibadda/git.nvim";
      }
      {
        name = "session.nvim";
        url = "git@github.com:Kibadda/session.nvim";
      }
      {
        name = "kanban.nvim";
        url = "git@github.com:Kibadda/kanban.nvim";
      }
      {
        name = "plenary.nvim";
        url = "git@github.com:nvim-lua/plenary.nvim";
      }
      {
        name = "starter.nvim";
        url = "git@github.com:Kibadda/starter.nvim";
      }
      {
        name = "fake.nvim";
        url = "git@github.com:Kibadda/fake.nvim";
      }
    ];
  };

  nvim-pkg = mkNeovim {
    plugins = all-plugins;
  };

  luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
    nvim = final.neovim;
  };
in
{
  inherit nvim-dev nvim-pkg luarc-json;
}
