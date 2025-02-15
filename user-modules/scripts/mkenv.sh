setupEnv () {
    echo "Setting up .envrc"
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        insideGit;
    else
        outsideGit;
    fi;
}

insideGit () {
    echo "Inside of git environment"
    cd $(git rev-parse --show-toplevel)
    echo "Setting up inside $PWD"
    echo "git add -f --intent-to-add flake.nix
use flake ." > .envrc

    echo "Enabling environment"
    direnv allow

    setupFlake
}

outsideGit () {
    echo "Outside of git environment"
    echo "use flake . --impure" > .envrc

    echo "Enabling environment"
    direnv allow

    setupFlake
}

setupFlake () {
    if [ -e flake.nix ]; then
        echo "flake.nix already exists."
        return
    fi;

    echo "Setting up flake.nix"
    echo "{
  inputs.devenv.url = \"git+https://git.bulthuis.dev/Jan/dotfiles\";
  outputs = { devenv, ... }: devenv.lib.mkShell { };
}" > flake.nix
}

echo "Creating dev environment"

if [ -e .envrc ]; then
    echo ".envrc already exists."
    setupFlake
else
    setupEnv
fi;