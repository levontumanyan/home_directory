# Container Testing

Testing instructions for running dotfiles configuration in a clean containerized Linux environment using Apple's native container tool.

# Getting Started

To run these tests, ensure Apple's container system service is started:

```bash
container system start
```

# Building and Running the Test Environment

Build the container image using the [Containerfile](file:///Users/levontumanyan/repos/home_directory/.devcontainer/Containerfile):

```bash
container build -t localhost/dotfiles-test -f .devcontainer/Containerfile .devcontainer
```

## Running an Interactive Session

```bash
container run -it --rm -v "$(pwd):/workspace" localhost/dotfiles-test zsh
```

## Running the Automated Install Tests

To test the personal configuration profile:

```bash
container run -it --rm -v "$(pwd):/workspace" localhost/dotfiles-test zsh -c "cd /workspace && ./install.sh -m personal -t && zsh"
```

To test the work configuration profile:

```bash
container run -it --rm -v "$(pwd):/workspace" localhost/dotfiles-test zsh -c "cd /workspace && ./install.sh -m work -t && zsh"
```
