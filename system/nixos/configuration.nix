{
	inputs,
	outputs,
	config,
	pkgs,
	lib,
	...
}: {
	imports = [
		./hardware-configuration.nix
	];

	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
	};

	system.autoUpgrade = {
		enable = true;
		allowReboot = true;
	};

	nixpkgs = {
		overlays = [
			outputs.overlays.additions
			outputs.overlays.modifications
			outputs.overlays.unstable-packages
		];
		config.allowUnfree = true;
	};

	nix = let
		flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
	in {
		settings = {
			experimental-features = "nix-command flakes";
			flake-registry = "";
		};

		registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
		nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
	};

	networking = {
		hostName = "nixMag";
		networkmanager.enable = true;
		firewall = {
			allowedTCPPorts = [];
			allowedUDPPorts = [];
		};
	};

	environment = {
		systemPackages = with pkgs; [
			gvfs						# For trash support
			wl-clipboard				# For clipboard functionality
			wget						# Downloader
		];
		sessionVariables = {
			WLR_NO_HARDWARE_CURSORS = "1";
			LIBVA_DRIVER_NAME = "nvidia";
			GBM_BACKEND = "nvidia-drm";
			__GLX_VENDOR_LIBRARY_NAME = "nvidia";
			NVD_BACKEND = "direct";
		};
	};

	users.users = {
		zxcm = {
			description = "zxcm";
			isNormalUser = true;
			shell = pkgs.zsh;
			openssh.authorizedKeys.keys = [];
			extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
		};
	};

	services = {
		printing.enable = true;			# Printing with CUPS
		gvfs.enable = true;				# Trash service
		openssh = {						# SSH server
			enable = true;
			settings = {
				PermitRootLogin = "no";
				PasswordAuthentication = false;
			};
		};
		pipewire = {					# Audio server
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
			jack.enable = true;
		};
		xserver.videoDrivers = [		# Obtain drivers only
			"nvidia-open"
		];
	};

	programs = {
		zsh = {						# Shell
			enable = true;
			enableCompletion = true;
			autosuggestions.enable = true;
			syntaxHighlighting.enable = true;
		};
		mtr.enable = true;				# Network troubleshooter
		gnupg.agent = {					# SSH key manager
			enable = true;
			enableSSHSupport = true;
		};
	};

	hardware = {
		bluetooth.enable = true;
		nvidia = {
			modesetting.enable = true;
			powerManagement.enable = true;
			package = config.boot.kernelPackages.nvidiaPackages.stable;
			nvidiaSettings = true;
			open = true;
		};
		graphics = {
			enable = true;
			enable32Bit = true;
		};
	};

	security.rtkit.enable = true;

	time.timeZone = "America/New_York";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "en_US.UTF-8";
		LC_IDENTIFICATION = "en_US.UTF-8";
		LC_MEASUREMENT = "en_US.UTF-8";
		LC_MONETARY = "en_US.UTF-8";
		LC_NAME = "en_US.UTF-8";
		LC_NUMERIC = "en_US.UTF-8";
		LC_PAPER = "en_US.UTF-8";
		LC_TELEPHONE = "en_US.UTF-8";
		LC_TIME = "en_US.UTF-8";
	};


	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "24.11"; # Did you read the comment?
}
