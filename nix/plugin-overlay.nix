{ inputs }: final: prev: let
  mkNvimPlugin = src: pname:
    (prev.pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    }).overrideAttrs {
      # TODO: this is just a quick fix so I can update nixpkgs input
      # new nixpkgs introduced automatic require check for all lua files in plugin
      # but this check uses nvim version 0.10.3
      # I could not find out how this check can use the nvim binary from the neovim-nighlty-overlay
      doCheck = false;
    };
in {
  nvimPlugins = {
    nvim-web-devicons = mkNvimPlugin inputs.nvim-web-devicons "nvim-web-devicons";
    plenary = mkNvimPlugin inputs.plenary "plenary.nvim";
    nui-nvim = mkNvimPlugin inputs.nui-nvim "nui.nvim";
    vim-pasta = mkNvimPlugin inputs.vim-pasta "vim-pasta";
    nvim-surround = mkNvimPlugin inputs.nvim-surround "nvim-surround";
    nvim-autopairs = mkNvimPlugin inputs.nvim-autopairs "nvim-autopairs";
    conform-nvim = mkNvimPlugin inputs.conform-nvim "conform.nvim";
    git-nvim = mkNvimPlugin inputs.git-nvim "git.nvim";
    mini-ai = mkNvimPlugin inputs.mini-ai "mini.ai";
    mini-diff = mkNvimPlugin inputs.mini-diff "mini.diff";
    mini-hipatterns = mkNvimPlugin inputs.mini-hipatterns "mini.hipatterns";
    mini-pick = mkNvimPlugin inputs.mini-pick "mini.pick";
    nvim-recorder = mkNvimPlugin inputs.nvim-recorder "nvim-recorder";
    session-nvim = mkNvimPlugin inputs.session-nvim "session.nvim";
    kanban-nvim = mkNvimPlugin inputs.kanban-nvim "kanban.nvim";
    starter-nvim = mkNvimPlugin inputs.starter-nvim "starter.nvim";
    fake-nvim = mkNvimPlugin inputs.fake-nvim "fake.nvim";
    nvim-treesitter = mkNvimPlugin inputs.nvim-treesitter "nvim-treesitter";
    treesj = mkNvimPlugin inputs.treesj "treesj";
  };
}
