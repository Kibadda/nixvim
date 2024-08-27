{ inputs }: final: prev: let
  mkNvimPlugin = src: pname:
    prev.pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
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
    vim-kitty-navigator = mkNvimPlugin inputs.vim-kitty-navigator "vim-kitty-navigator";
    mini-ai = mkNvimPlugin inputs.mini-ai "mini.ai";
    mini-diff = mkNvimPlugin inputs.mini-diff "mini.diff";
    mini-hipatterns = mkNvimPlugin inputs.mini-hipatterns "mini.hipatterns";
    mini-pick = mkNvimPlugin inputs.mini-pick "mini.pick";
    mini-starter = mkNvimPlugin inputs.mini-starter "mini.starter";
    nvim-recorder = mkNvimPlugin inputs.nvim-recorder "nvim-recorder";
    # rustaceanvim
    session-nvim = mkNvimPlugin inputs.session-nvim "session.nvim";
    nvim-treesitter = mkNvimPlugin inputs.nvim-treesitter "nvim-treesitter";
    treesj = mkNvimPlugin inputs.treesj "treesj";
  };
}
