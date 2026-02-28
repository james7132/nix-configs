{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      ...
    }@inputs:
    {
      # Main Personal Desktop
      nixosConfigurations.amaterasu = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./amaterasu.nix ];
      };
      # Main Personal Laptop
      nixosConfigurations.tsukuyomi = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./tsukuyomi.nix
          nixos-hardware.nixosModules.microsoft-surface-laptop-amd
        ];
      };
      # Home Lab servers
      nixosConfigurations.loki = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./servers/loki.nix ];
      };
      # Remote VPS servers
      nixosConfigurations.hourai = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./servers/hourai.nix ];
      };
      nixosConfigurations.zeus = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./servers/zeus.nix ];
      };
      # Remotely Managed Servers
      nixosConfigurations.wukong = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./servers/wukong.nix ];
      };
    };
}
