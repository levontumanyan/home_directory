alias k="kubectl"
alias kcd="kubectl config set-context --current --namespace"

alias python="python3"
alias pip="pip3"

sudo() {
    if command -v doas >/dev/null 2>&1; then
        doas "$@"
    else
        command sudo "$@"
    fi
}
