{ inputs }: final: prev: with final.lib; let
  mkNeovim = { appName ? null, plugins ? [], devPlugins ? [] }: let
    defaultPlugin = {
      plugin = null;
      config = null;
      optional = false;
      runtime = {};
    };

    normalizedPlugins = map (x: defaultPlugin // (
      if x ? plugin
      then x
      else { plugin = x; }
    )) plugins;

    neovimConfig = final.neovimUtils.makeNeovimConfig {
      withPython3 = false;
      withRuby = false;
      withNodeJs = false;
      viAlias = appName == null || appName == "nvim";
      vimAlias = appName == null || appName == "nvim";
      plugins = normalizedPlugins;
    };

    extraPackages = with final; [
      lua-language-server
      nodePackages.intelephense
      typescript-language-server
      nil
      stylua
      tree-sitter
      gcc
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
      + optionalString (devPlugins != []) (
        ''
          local dev_pack_path = vim.fn.stdpath('data') .. '/site/pack/dev'
          local dev_plugins_dir = dev_pack_path .. '/opt'
          local dev_plugin_path
        ''
        + strings.concatMapStringsSep
        "\n"
        (plugin: ''
          dev_plugin_path = dev_plugins_dir .. '/${plugin.name}'
          if vim.fn.empty(vim.fn.glob(dev_plugin_path)) > 0 then
            vim.notify('Bootstrapping dev plugin ${plugin.name} ...', vim.log.levels.INFO)
            vim.cmd('!${final.git}/bin/git clone ${plugin.url} ' .. dev_plugin_path)
          end
          vim.cmd('packadd! ${plugin.name}')
        '')
        devPlugins
      )
      + ''
        vim.opt.rtp:append('${nvimRtp}/nvim')
        vim.opt.rtp:append('${nvimRtp}/after')
      '';

    extraMakeWrapperArgs = builtins.concatStringsSep " " (
      (optional (appName != "nvim" && appName != null && appName != "")
        ''--set NVIM_APPNAME "${appName}"'')
      ++ (optional (extraPackages != [])
        ''--prefix PATH : "${makeBinPath extraPackages}"'')
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

    nvim-unwrapped = prev.neovim.overrideAttrs (oa: {
      postInstall = ''
        ${oa.postInstall or ""}
        ${concatStringsSep "\n" postInstallCommands}
      '';
    });
  in
    final.wrapNeovimUnstable nvim-unwrapped (neovimConfig
      // {
        luaRcContent = initLua;
        wrapperArgs =
          escapeShellArgs neovimConfig.wrapperArgs
          + " "
          + extraMakeWrapperArgs;
        wrapRc = true;
      });

  base-plugins = with final.nvimPlugins; [
    nvim-web-devicons
    plenary
    nui-nvim
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

  all-plugins = base-plugins ++ (with final.nvimPlugins; [
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
in {
  inherit nvim-dev nvim-pkg luarc-json;
}
