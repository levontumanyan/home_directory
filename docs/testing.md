# container

```bash
podman machine init --cpus 1 --memory 1024 --disk-size 20 --rootful=false

# build the image
podman build -t localhost/dotfiles-test .devcontainer

# run the container and stay inside
podman run -it --rm -v "$(pwd):/workspace:Z" localhost/dotfiles-test zsh

# 2. Run the test (Personal)
podman run -it --rm -v "$(pwd):/workspace:Z" localhost/dotfiles-test zsh -c "cd /workspace && ./install.sh -m personal -t && zsh"

# 3. Run the test (Work)
podman run -it --rm -v "$(pwd):/workspace:Z" localhost/dotfiles-test zsh -c "cd /workspace && ./install.sh -m work -t && zsh"

```
