{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      home-manager,
      home-manager-unstable,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        # Main Personal Desktop
        amaterasu = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./amaterasu.nix
            home-manager-unstable.nixosModules.home-manager
          ];
        };
        # Main Personal Laptop
        tsukuyomi = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./tsukuyomi.nix
            nixos-hardware.nixosModules.microsoft-surface-laptop-amd
            home-manager-unstable.nixosModules.home-manager
          ];
        };
        # Home Lab servers
        loki = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./servers/loki.nix
            home-manager-unstable.nixosModules.home-manager
          ];
        };
        # Remote VPS servers
        hourai = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./servers/hourai.nix
            home-manager.nixosModules.home-manager
          ];
        };
        zeus = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./servers/zeus.nix
            home-manager.nixosModules.home-manager
          ];
        };
        # Remotely Managed Servers
        wukong = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./servers/wukong.nix
            home-manager.nixosModules.home-manager
          ];
        };
      };
    };
}
