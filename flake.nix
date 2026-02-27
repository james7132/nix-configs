{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs-unstable, ... }@inputs:
    {
      # Main Personal Desktop
      nixosConfigurations.amaterasu = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./amaterasu.nix ];
      };
    };
}
