#!/usr/bin/bash
# 安装 pass-autosync

set -e

echo "🚀 安装 pass-autosync..."

# 检查依赖
for cmd in pass git gpg; do
    if ! command -v $cmd > /dev/null; then
        echo "错误: 未找到 $cmd，请先安装"
        exit 1
    fi
done

# 创建目录
sudo mkdir -p /usr/local/bin
mkdir -p "$HOME/.config/pass-autosync"
mkdir -p "$HOME/.local/log"

# 安装主脚本
sudo cp src/pass-autosync.sh /usr/local/bin/pass-autosync
sudo chmod +x /usr/local/bin/pass-autosync

# 可选：安装辅助脚本
sudo cp src/pass-sync-helper.sh /usr/local/bin/pass-sync-helper
sudo chmod +x /usr/local/bin/pass-sync-helper

# 复制 systemd 文件
sed "s|%h|$HOME|g" systemd/pass-autosync.service > /tmp/pass-autosync@.service
sudo cp /tmp/pass-autosync@.service /etc/systemd/system/pass-autosync@.service
sudo cp systemd/pass-autosync.timer /etc/systemd/system/pass-autosync.timer

# 为用户配置 sync 别名（如果密码仓库存在）
if [ -d "$HOME/.password-store" ] && [ -d "$HOME/.password-store/.git" ]; then
    echo "🔧 配置 git sync 别名..."
    (cd "$HOME/.password-store" && git config --local alias.sync '!git pull --rebase --autostash && git push')
fi

# 创建默认配置文件
cat > "$HOME/.config/pass-autosync/config" << 'EOF'
PASSWORD_STORE_DIR="${HOME}/.password-store"
MAX_RETRIES=3
RETRY_DELAY=5
LOG_FILE="${HOME}/.local/log/pass-autosync.log"
EOF

# 启用并启动定时器
echo "⏰ 启用 systemd 定时器..."
sudo systemctl daemon-reload
sudo systemctl enable pass-autosync.timer
sudo systemctl start pass-autosync.timer

echo "✅ 安装完成！"
echo ""
echo "查看状态: systemctl status pass-autosync.timer"
echo "手动运行: pass-autosync"
echo "查看日志: journalctl -u pass-autosync@$USER -f"
echo "查看同步日志: tail -f ~/.local/log/pass-autosync.log"
