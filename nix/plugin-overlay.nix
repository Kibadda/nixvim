{ inputs }: final: prev: let
  mkNvimPlugin = src: pname:
    prev.pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };
in {
  nvimPlugins = {
    nvim-web-devicons = mkNvimPlugin inputs.nvim-web-devicons "nvim-web-devicons";
    vim-pasta = mkNvimPlugin inputs.vim-pasta "vim-pasta";
    nvim-surround = (mkNvimPlugin inputs.nvim-surround "nvim-surround").overrideAttrs {
      nvimSkipModule = [
        "nvim-surround.queries"
      ];
    };
    nvim-autopairs = (mkNvimPlugin inputs.nvim-autopairs "nvim-autopairs").overrideAttrs {
      nvimSkipModule = [
        "nvim-autopairs.completion.cmp"
        "nvim-autopairs.completion.compe"
      ];
    };
    conform-nvim = mkNvimPlugin inputs.conform-nvim "conform.nvim";
    mini-ai = mkNvimPlugin inputs.mini-ai "mini.ai";
    mini-diff = mkNvimPlugin inputs.mini-diff "mini.diff";
    mini-hipatterns = mkNvimPlugin inputs.mini-hipatterns "mini.hipatterns";
    mini-pick = mkNvimPlugin inputs.mini-pick "mini.pick";
    nvim-recorder = mkNvimPlugin inputs.nvim-recorder "nvim-recorder";
    nvim-treesitter = (mkNvimPlugin inputs.nvim-treesitter "nvim-treesitter").overrideAttrs {
      nvimSkipModule = [
        "nvim-treesitter.install"
        "nvim-treesitter.async"
        "nvim-treesitter._meta.parsers"
      ];
    };
    treesj = mkNvimPlugin inputs.treesj "treesj";
  };
}
