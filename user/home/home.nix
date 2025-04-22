{
	inputs,
	outputs,
	lib,
	config,
	pkgs,
	...
}: {
	imports = [];

	nixpkgs = {
		overlays = [
			outputs.overlays.additions
			outputs.overlays.modifications
			outputs.overlays.unstable-packages
		];
		config.allowUnfree = true;
	};

	home = {
		username = "zxcm";
		homeDirectory = "/home/zxcm";
		packages = with pkgs; [
			ghostty						# Terminal emulator
			neovim						# Text editor
			vscode						# Second text editor
			hyprland					# Window Manager
			hyprpanel					# Status bar
			wofi						# Application launcher
			yazi						# Terminal file manager
			xfce.thunar					# GUI file manager
			xfce.thunar-vcs-plugin		# Subversion and Git support
			xfce.thunar-archive-plugin	# Thunar archive plugin
			xfce.thunar-volman			# Thunar volman plugin
			xfce.tumbler				# For Thunar thumbnails
			ffmpegthumbnailer			# For video thumbnails
			brave						# Browser
			protonmail-desktop			# Mail client
			protonvpn-gui				# VPN client
			proton-pass					# Password manager
		];
		file = {};
		sessionVariables = {};
	};

	programs = {
		home-manager.enable = true;
		git.enable = true;
		hyprland = {					# Window Manager
			enable = true;
			xwayland.enable = true;
		};
		programs.thunar = {				# GUI file manager
			enable = true;
			plugins = with pkgs.xfce; [
				thunar-archive-plugin
				thunar-volman
			];
		};
	};

	systemd.user.startservices = "sd-switch";

	# This value determines the Home Manager release that your configuration is
	# compatible with. This helps avoid breakage when a new Home Manager release
	# introduces backwards incompatible changes.
	#
	# You should not change this value, even if you update Home Manager. If you do
	# want to update the value, then make sure to first check the Home Manager
	# release notes.
	home.stateVersion = "24.11"; # Please read the comment before changing.
}
