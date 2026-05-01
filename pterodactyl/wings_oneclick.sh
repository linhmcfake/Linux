#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
    systemctl enable --now docker
else
    echo "Docker is already installed, skipping..."
    systemctl enable --now docker
fi

mkdir -p /etc/pterodactyl

arch=$(uname -m)

if [[ "$arch" == "x86_64" ]]; then
    wings_url="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"
elif [[ "$arch" == "aarch64" ]]; then
    wings_url="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_arm64"
else
    echo "Unsupported architecture: $arch"
    exit 1
fi

echo "Detected architecture: $arch"
echo "Downloading Wings: $wings_url"

curl -L -o /usr/local/bin/wings "$wings_url"
chmod +x /usr/local/bin/wings

cat <<EOF > /etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDir=/etc/pterodactyl
LimitNOFILE=4096
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

echo -e "\n=== SETUP COMPLETE! Paste your Wings token below (not Configuration File) ===\n"
