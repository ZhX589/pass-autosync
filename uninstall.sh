#!/usr/bin/bash

echo "🗑️ 卸载 pass-autosync..."

sudo systemctl stop pass-autosync.timer
sudo systemctl disable pass-autosync.timer
sudo rm -f /etc/systemd/system/pass-autosync@.service
sudo rm -f /etc/systemd/system/pass-autosync.timer
sudo rm -f /usr/local/bin/pass-autosync
sudo rm -f /usr/local/bin/pass-sync-helper

sudo systemctl daemon-reload

read -p "是否删除配置文件 (~/.config/pass-autosync) 和日志 (~/.local/log/pass-autosync.log)? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/pass-autosync"
    rm -f "$HOME/.local/log/pass-autosync.log"
fi

echo "✅ 卸载完成"
