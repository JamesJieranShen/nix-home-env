 {
  description = "A home flake";
  # original idea https://gist.github.com/suhr/4bb1f8434d0622588b23f9fe13e79973

  inputs = {
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }: 
    let
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    in {
    defaultPackage.x86_64-linux =  with import nixpkgs { system = "x86_64-linux"; overlays = [ overlay-unstable ]; config = { allowUnfree = true; }; }; buildEnv {
      name = "home-env";
      paths = [
        (rofi-wayland.override { 
             plugins = [
                (rofi-calc.override { rofi-unwrapped = rofi-wayland-unwrapped; })
             ]; 
           })
        swaynotificationcenter
        wlogout
        swappy
        slurp
        hyprpaper
        waybar
        grimblast

        (writeScriptBin "nix-rebuild" ''
          #!${stdenv.shell}
          cd ~/nix-home/ || exit 1
          nix flake update
          nix profile upgrade nix-home
        '')
      ];
    };
  };
}
