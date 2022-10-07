# SSH with GitHub keys.
ssh -i ~/.ssh/cypkeypair cyprien@...

# Clone repo and install.
cd ~
git clone git@github.com:c2mda/dotfiles.git
./install.sh
