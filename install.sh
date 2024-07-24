#!/usr/bin/env bash

# Debian install script that should get everything that is needed there, written for Debian 12
# _really_ messy. First and foremost, makes the mistake of using apt in a script, getting worse from there.
# It is just the thing I used to install the config on all three machines when I was done,
# And, next the time I'll need to reinstall on all my machines, I'll update the script in a VM, and _then_ run again.

### Basic dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt-get install -y build-essential fakeroot devscripts ca-certificates \
    vim git ffmpeg ffmpeg-doc curl wget jq sqlite3 tar xz-utils libsensors5 \
    python3 python3-pip python3-venv python3-dev build-essential gdb lcov pkg-config libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev libncurses5-dev libreadline-dev libsqlite3-dev libssl-dev lzma lzma-dev tk-dev uuid-dev zlib1g-dev \
    gdb gcc clang cmake ninja-build \
    default-jdk default-jre \
    r-base r-base-dev \
    nodejs npm \
    texlive-full pandoc

# github cli
if ! type -p gh >/dev/null; then
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt update >/dev/null && sudo apt install gh -y
fi

# Go language
if ! type -p go >/dev/null; then
    sudo rm -rf /usr/local/go
    wget -P "$HOME/Downloads" https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf "$HOME/Downloads/go1.22.5.linux-amd64.tar.gz"
fi

# Rust
if ! type -p rustup >/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >$HOME/Downloads/rustupinst.sh
    bash "$HOME/Downloads/rustupinst.sh" -y
fi
"$HOME/.cargo/bin/cargo" install onefetch ripgrep stylua
"$HOME/.cargo/bin/rustup" component add rust-analyzer
"$HOME/.cargo/bin/rustup" component add rust-src

# Scala
if ! type -p cs >/dev/null; then
    curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d >$HOME/Downloads/cs
    chmod +x "$HOME/Downloads/cs"
    yes | "$HOME/Downloads/cs" setup
fi
sudo apt-get install openjdk-17-jdk openjdk-17-source -y

# Pyenv
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev
if ! type -p pyenv >/dev/null; then
    curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
fi

# Haskell
sudo apt-get install build-essential curl libffi-dev libgmp10 libncurses5 libtinfo5 libicu-dev libncurses-dev libgmp-dev zlib1g-dev -y
if ! type -p ghcup >/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org >"$HOME/Downloads/ghcupinst.sh"
    GHCUP_USE_XDG_DIRS=1 BOOTSTRAP_HASKELL_NONINTERACTIVE=1 bash "$HOME/Downloads/ghcupinst.sh"
    "$HOME/.local/bin/ghcup" install hls
fi
"$HOME/.local/bin/cabal" install ormolu

# Docker
if ! type -p docker >/dev/null; then
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo getent group docker || sudo groupadd docker && sudo usermod -aG docker $(whoami)
    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R
fi

# Flatpak
sudo apt-get install flatpak plasma-discover-backend-flatpak -y
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub com.github.tchx84.Flatseal flathub org.mozilla.firefox md.obsidian.Obsidian
# This line only works second time, after paths are updated. Doing this manually is hard, so script is ran twice.
xdg-settings set default-web-browser org.mozilla.firefox.desktop
sudo apt-get purge firefox-esr -y && sudo apt autoremove -y

### Dotfiles
# Many of these are repetetive, and could be done in a more generic way.
# However, that loses the power of being able to deviate from the pattern for individual things.

# This is likely already done by the time the script is run
mkdir -p "$HOME/Code"
if [ ! -d "$HOME/Code/dotfiles/" ]; then
    git clone https://github.com/JJWRoeloffs/dotfiles "$HOME/Code/dotfiles/"
fi

# There should always be _some_ nerdfont available.
if [ ! -d "$HOME/.local/share/fonts" ]; then
    wget -P "$HOME/.local/share/fonts" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/RobotoMono.zip
    cd "$HOME/.local/share/fonts"
    unzip RobotoMono.zip
    rm RobotoMono.zip

    cp -r "$HOME/Code/dotfiles/misc/fonts/" "$HOME/.local/share/fonts/"
    fc-cache -fv
fi

# alaritty
sudo apt-get install -y alacritty
if [ ! -d "$HOME/.config/alacritty" ]; then
    cp -r "$HOME/Code/dotfiles/config/alacritty" "$HOME/.config/alacritty"
fi

# zsh
sudo apt-get install -y zsh
sudo chsh -s /bin/zsh $(whoami)
if [ ! -f "$HOME/.zshrc" ]; then
    cp "$HOME/Code/dotfiles/.zshrc" "$HOME"
    cp "$HOME/Code/dotfiles/.p10k.zsh" "$HOME"
fi

# lf
sudo apt-get install -y lf
if [ ! -d "$HOME/.config/lf" ]; then
    cp -r "$HOME/Code/dotfiles/config/lf" "$HOME/.config/lf"
fi

# when
sudo apt-get install -y when
if [ ! -d "$HOME/.when" ]; then
    cp -r "$HOME/Code/dotfiles/.when" "$HOME/.when"
fi

# redshift
sudo apt-get install -y redshift
if [ ! -f "$HOME/.config/redshift.conf" ]; then
    cp -r "$HOME/Code/dotfiles/config/redshift.conf" "$HOME/.config/redshift.conf"
fi

# Installing nvim and its configuration
sudo apt-get build-dep neovim -y
sudo apt-get install wl-clipboard xclip -y
if [ ! -f "$HOME/.local/bin/nvim" ]; then
    wget -P "$HOME/.local/bin" https://github.com/neovim/neovim/releases/download/v0.10.0/nvim.appimage
    mv "$HOME/.local/bin/nvim.appimage" "$HOME/.local/bin/nvim"
    chmod u+x "$HOME/.local/bin/nvim"
fi
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/JJWRoeloffs/nvim-config "$HOME/.config/nvim"
fi

# Awesomewm
# We build from source, as I am using the git version of awesome.
sudo apt-get build-dep awesome -y
sudo apt-get install -y libxcb-xfixes0-dev feh compton asciidoctor luarocks
if ! type -p awesome >/dev/null; then
    if [ ! -d "$HOME/Code/awesome" ]; then
        git clone https://github.com/awesomeWM/awesome.git "$HOME/Code/awesome"
    fi
    (cd "$HOME/Code/awesome" && make && sudo make install)
    if [ ! -f /usr/share/xsessions/awesome.desktop ]; then
        sudo cp "$HOME/Code/dotfiles/misc/awesome.desktop" /usr/share/xsessions/
        sudo update-desktop-database
    fi
fi
if [ ! -d "$HOME/.config/awesome" ]; then
    cp -r "$HOME/Code/dotfiles/config/awesome/" "$HOME/.config/awesome/"
fi
if [ ! -f "$HOME/.Xresources" ]; then
    cp "$HOME/Code/dotfiles/.Xresources" "$HOME"
fi
cp -r "$HOME/Code/dotfiles/misc/bin/." "$HOME/.local/bin"
xrdb -merge "$HOME/Code/dotfiles/misc/colours/burned_purple"
feh --bg-fill "$HOME/Code/dotfiles/.assets/black-cat.jpg"

# Rofi
sudo apt-get install rofi -y
if [ ! -d "$HOME/.config/rofi" ]; then
    cp -r "$HOME/Code/dotfiles/config/rofi" "$HOME/.config/rofi"
fi

# htop
sudo apt-get install htop -y
if [ ! -d "$HOME/.config/htop" ]; then
    cp -r "$HOME/Code/dotfiles/config/htop" "$HOME/.config/htop"
fi
