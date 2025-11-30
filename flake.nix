{
  description = "NixOS configuration for MacBook Air 2011";

  inputs = {
    # NixOS official package source, pinned to the nixos-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs,... }@inputs: {
    # Define a NixOS system configuration
    # host name set to castor
    nixosConfigurations.castor = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Specify the system architecture
      specialArgs = { inherit inputs; }; # Pass the 'inputs' attribute set to modules
      modules = [
        # Import your existing configuration files
       ./configuration.nix
      ];
    };
  };
}
