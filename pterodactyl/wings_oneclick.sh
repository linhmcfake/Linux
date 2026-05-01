sudo -i <<'EOF'
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
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"
chmod +x /usr/local/bin/wings

cat <<UNIT > /etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
Partof=docker.service
[Service]
User=root
WorkingDir=/etc/pterodactyl
LimitNOFILE=4096
ExecStart=/usr/local/bin/wings
Restart=on-failure
[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
echo -e "\n\e[1;32m=== SETUP COMPLETE! PASTE YOUR CONFIG COMMAND BELOW ===\e[0m\n"
EOF
