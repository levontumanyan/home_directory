#!/usr/bin/env zsh
# setup usually once

# install kubernetes function
install_kubectl() {
	# determine whether we are on arm or x86_64
	arch=$(uname -m)
	if [[ "$arch" == "x86_64" ]]; then
		curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	elif [[ "$arch" == "arm64" || "$arch" == "aarch64" ]]; then
		curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
	else
		echo "Unsupported architecture: $arch, can't install kubectl..."
	fi

	# add checksum check
	chmod +x kubectl
	mkdir -p ~/bin
	mv ./kubectl ~/bin/kubectl

	source <(kubectl completion zsh)
}

# setup fuzzy finder
command -v fzf >/dev/null 2>&1 || {
	echo "fzf not found, installing..."
	git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
	"$HOME/.fzf/install" --all
}

# install kubectl if wanted
command -v kubectl >/dev/null 2>&1 || {
	echo "Kubectl is not installed, would you like to install it: y/N]: "
	read -r kubectl_reply
	if [[ "$kubectl_reply" == [yY] ]]; then
		install_kubectl
	fi
}
