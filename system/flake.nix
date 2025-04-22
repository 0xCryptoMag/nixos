{
	description = "NixOS flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
	};

	outputs = {
		self,
		nixpkgs,
		...
	} @ inputs: let
		inherit (self) outputs;
		system = "x86_64-linux";
	in {
		# Accessible through 'nix build', 'nix shell', etc
		packages = import ./pkgs nixpkgs.legacyPackages.${system};

		# Formatter for your nix files, available through 'nix fmt'
		formatter = nixpkgs.legacyPackages.${system}.nixfmt;

		# Custom packages and modifications, exported as overlays
		overlays = import ./overlays {inherit inputs;};

		# Reusable Nixos modules
		nixosModules = import ./modules;

		# NixOS configuration entrypoint
		# Availabe through 'nixos-rebuild --flake .#your-hostname'
		nixosConfigurations = {
			# Hostname set
			nixMag = nixpkgs.lib.nixosSystem {
				specialArgs = { inherit inputs outputs; };
				modules = [ ./nixos/configuration.nix ];
			};
		};
	};
}
