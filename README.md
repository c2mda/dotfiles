# Clone repo and install.

    cd ~
    git clone git@github.com:c2mda/dotfiles.git
    cd dotfiles
    ./install.sh

# User setup

    NEWUSER=cyprien
    PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBzKfjrkNf5SasXqdDmTwf8ioxBNu6Xt+8HLmckNOuj cyprien.de.masson@gmail.com"
    if [ ! -e "/home/$NEWUSER/.ssh/authorized_keys" ]; then
            echo "user $NEWUSER not found, adding"
            sudo useradd -m -d /home/$NEWUSER -s /bin/bash $NEWUSER
            sudo usermod -aG sudo $NEWUSER

            # SSH keys.
            sudo mkdir -p /home/$NEWUSER/.ssh
            echo "$PUBKEY" | sudo tee -a "/home/$NEWUSER/.ssh/authorized_keys"
            sudo chown -R $NEWUSER:$NEWUSER /home/$NEWUSER/.ssh
            sudo chmod 700 /home/$NEWUSER/.ssh
            sudo chmod 600 /home/$NEWUSER/.ssh/authorized_keys

            # No password for sudo.
            echo "$NEWUSER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$NEWUSER"
    else
            echo "user $NEWUSER already exists, skipping"
    fi
