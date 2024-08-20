# heavily inspired by https://github.com/mrcjkb/nvim
{
  description = "Neovim config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";
    flake-utils.url = "github:numtide/flake-utils";

    # Plugins
    nvim-web-devicons = {
      url = "github:nvim-tree/nvim-web-devicons";
      flake = false;
    };
    plenary = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    nui-nvim = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };
    vim-pasta = {
      url = "github:ku1ik/vim-pasta";
      flake = false;
    };
    nvim-surround = {
      url = "github:kylechui/nvim-surround";
      flake = false;
    };
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    lspkind-nvim = {
      url = "github:onsails/lspkind-nvim";
      flake = false;
    };
    conform-nvim = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };
    git-nvim = {
      url = "github:Kibadda/git.nvim";
      flake = false;
    };
    vim-kitty-navigator = {
      url = "github:knubie/vim-kitty-navigator";
      flake = false;
    };
    mini-ai = {
      url = "github:echasnovski/mini.ai";
      flake = false;
    };
    mini-diff = {
      url = "github:echasnovski/mini.diff";
      flake = false;
    };
    mini-hipatterns = {
      url = "github:echasnovski/mini.hipatterns";
      flake = false;
    };
    mini-pick = {
      url = "github:echasnovski/mini.pick";
      flake = false;
    };
    mini-starter = {
      url = "github:echasnovski/mini.starter";
      flake = false;
    };
    nvim-recorder = {
      url = "github:chrisgrieser/nvim-recorder";
      flake = false;
    };
    # rustaceanvim
    session-nvim = {
      url = "github:Kibadda/session.nvim";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter/main";
      flake = false;
    };
    treesj = {
      url = "github:Wansmer/treesj";
      flake = false;
    };
    which-key-nvim = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    neovim-nightly,
    gen-luarc,
    flake-utils,
    ...
  }: let
    supportedSystems = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    plugin-overlay = import ./nix/plugin-overlay.nix {inherit inputs;};
    neovim-overlay = import ./nix/neovim-overlay.nix {inherit inputs;};
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            neovim-nightly = neovim-nightly.packages.${prev.system}.neovim;
          })
          gen-luarc.overlays.default
          plugin-overlay
          neovim-overlay
        ];
      };
      shell = pkgs.mkShell {
        name = "nvim-devShell";
        buildInputs = with pkgs; [
          lua-language-server
          nil
        ];
        shellHook = ''
          ln -fs ${pkgs.luarc-json} .luarc.json
        '';
      };
    in {
      packages = rec {
        default = nvim;
        nvim = pkgs.nvim-pkg;
        nvim-dev = pkgs.nvim-dev;
        nightly = pkgs.neovim-nightly;
      };
      devShells = {
        default = shell;
      };
    })
    // {
      overlays.default = neovim-overlay;
    };
}