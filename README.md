# SSH with GitHub keys and forwarding - only for trusted servers!

    ssh -A -i ~/.ssh/cypkeypair cyprien@...
    ssh -A -i ~/.ssh/id_ed25519 cyprien@...

# Clone repo and install.

    cd ~
    git clone git@github.com:c2mda/dotfiles.git
    ./install.sh
