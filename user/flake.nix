{
	description = "User flake";

	inputs = {
		# Nixpkgs
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

		# Home-manager
		home-manager = {
			url = "github:nix-community/home-manager/release-24.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {
		self,
		nixpkgs,
		home-manager,
		...
	} @ inputs: let
		inherit (self) outputs;
		system = "x86_64-linux";
		pkgs = nixpkgs.legacyPackages.${system};
	in {
		# Custom packages and modifications, exported as overlays
		overlays = import ./overlays {inherit inputs;};

		# Standalone home-manager configuration entrypoint
		# Available through 'home-manager --flake .#your-username@your-hostname'
		homeConfigurations."zxcm" = home-manager.lib.homeManagerConfiguration {
			inherit pkgs;
			extraSpecialArgs = { inherit inputs outputs; };
			modules = [ ./home/home.nix ];
		};
	};
}
