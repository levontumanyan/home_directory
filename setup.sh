#!/usr/bin/env zsh
# setup usually once
set -euo xtrace
setopt pipefail

# create user bin
mkdir -p ~/bin

# install kubernetes function
install_kubectl() {
	# determine whether we are on arm or x86_64
	arch=$(uname -m)
	if [[ "$arch" == "x86_64" ]]; then
		url="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	elif [[ "$arch" == "arm64" || "$arch" == "aarch64" ]]; then
		url="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
	else
		echo "Unsupported architecture: $arch, can't install kubectl..."
	fi
	
	echo "Downloading kubectl from: $url"
	curl -LO "$url"

	# add checksum check
	chmod 744 kubectl
	mv ./kubectl ~/bin/kubectl
}

# download and install fuzzy finder
command -v fzf >/dev/null 2>&1 || {
	echo "fzf not found, installing..."
	git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
	"$HOME/.fzf/install" --all --no-update-rc --no-fish

	# remove unnecessary stuff and move things to $HOME/bin
	mv "$HOME/.fzf/bin/fzf" "$HOME/bin/"
	# mv "$HOME/.fzf/shell/key-bindings.zsh" "$HOME/bin/fzf/"
	# mv "$HOME/.fzf/shell/completion.zsh" "$HOME/bin/fzf/"

	rm -rf "$HOME/.fzf"
	rm -f "$HOME/.fzf.bash" "$HOME/.fzf.zsh"
}

# install kubectl if wanted
command -v kubectl >/dev/null 2>&1 || {
	echo "Kubectl is not installed, would you like to install it: y/N]: "
	read -r kubectl_reply
	if [[ "$kubectl_reply" == [yY] ]]; then
		install_kubectl
	fi
}
