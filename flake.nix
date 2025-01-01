# heavily inspired by https://github.com/mrcjkb/nvim
{
  description = "Neovim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

    git-nvim = {
      url = "github:Kibadda/git.nvim";
      flake = false;
    };
    session-nvim = {
      url = "github:Kibadda/session.nvim";
      flake = false;
    };
    kanban-nvim = {
      url = "github:Kibadda/kanban.nvim";
      flake = false;
    };
    starter-nvim = {
      url = "github:Kibadda/starter.nvim";
      flake = false;
    };
    fake-nvim = {
      url = "github:Kibadda/fake.nvim";
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
    conform-nvim = {
      url = "github:stevearc/conform.nvim";
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
    nvim-recorder = {
      url = "github:chrisgrieser/nvim-recorder";
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
          neovim-nightly.overlays.default
          gen-luarc.overlays.default
          plugin-overlay
          neovim-overlay
        ];
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
          "intelephense"
        ];
      };
      shell = pkgs.mkShell {
        name = "nvim-devShell";
        buildInputs = with pkgs; [
          lua-language-server
          nil
        ];
        shellHook = ''
          ln -fs ${pkgs.luarc-json} nvim/.luarc.json
        '';
      };
    in {
      packages = rec {
        default = nvim;
        nvim = pkgs.nvim-pkg;
        nvim-dev = pkgs.nvim-dev;
      };
      devShells = {
        default = shell;
      };
    })
    // {
      overlays.default = neovim-overlay;
    };
}
