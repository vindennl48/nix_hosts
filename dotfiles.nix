{ pkgs, config, lib, username, ... }:

{
  environment.systemPackages = with pkgs; [
    git 
    neovim gcc nodejs yarn xclip
    tmux
    (nerdfonts.override { fonts = [ "IBMPlexMono" ]; })
  ];

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      # need to also set this in .zshrc
      # if [ -n "${commands[fzf-share]}" ]; then
      #   source "$(fzf-share)/key-bindings.zsh"
      #   source "$(fzf-share)/completion.zsh"
      # fi
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  system.activationScripts.dotfiles = let
    username     = "${username}";  # REPLACE WITH YOUR USERNAME
    homeDir      = "/home/${username}";
    dotfilesRepo = "dotfiles_lite";
    dotfilesDir  = "${homeDir}/${dotfilesRepo}";
    gitBin       = "${pkgs.git}/bin/git";  # Absolute path to Git binary
  in {
    # Give this script a dependency on users being created
    deps = [ "users" ];
    text = ''
      echo ""
      echo ""
      echo "========== Installing Dotfiles =========="
      # Clone dotfiles if missing
      if [ ! -d "${dotfilesDir}" ]; then
        echo "Cloning dotfiles repository..."
        ${gitBin} clone https://github.com/vindennl48/${dotfilesRepo} ${dotfilesDir}
      fi

      # Function to manage dotfiles with backups
      link_dotfile() {
        local repo_path="${dotfilesDir}/$1"
        local home_path="${homeDir}/$2"
        
        # Skip if symlink is already correct
        if [ -L "$home_path" ] && [ "$(readlink "$home_path")" = "$repo_path" ]; then
          echo "✓ Symlink '$home_path' already correct"
          return 0
        fi

        # Backup existing file/directory if not a symlink
        if [ -e "$home_path" ] && [ ! -L "$home_path" ]; then
          local backup_base="$home_path.bak"
          local backup_path="$backup_base"
          local timestamp=$(date +%Y%m%d%H%M%S)
          
          # Append timestamp if backup exists
          [ -e "$backup_base" ] && backup_path="$backup_base.$timestamp"
          
          echo "⚠ Backing up '$home_path' to '$backup_path'"
          mv -- "$home_path" "$backup_path"
        fi

        # Create parent directories if needed
        mkdir -p "$(dirname "$home_path")"

        # Create/update symlink
        echo "➔ Creating symlink: '$home_path' → '$repo_path'"
        ln -sfn "$repo_path" "$home_path"

      	# Make sure to set correct user permissions
        echo "➔ Setting Permission: $(dirname "$home_path")"
      	chown ${username}:users "$(dirname "$home_path")"

        echo "➔ Setting Permission: $home_path"
      	chown -h ${username}:users "$home_path"
      }

      # Dotfile mappings (repo_path:home_path)
      declare -A dotfiles=(
        ['zsh/zshrc']='.zshrc'
        ['git/gitconfig']='.gitconfig'
        ['nvim']='.config/nvim'
        ['tmux']='.config/tmux'
        # Add more mappings here
      )

      # Process all dotfiles
      for repo_path in "''${!dotfiles[@]}"; do
        link_dotfile "$repo_path" "''${dotfiles[''$repo_path]}"
      done

      echo "========== Done Installing Dotfiles =========="
      echo ""
      echo ""
    '';
  };
}

