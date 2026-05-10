#!/usr/bin/bash
# pass-autosync - 自动同步 pass 密码仓库到 Git 远程

set -euo pipefail

# 配置文件路径
CONFIG="${HOME}/.config/pass-autosync/config"
if [ -f "$CONFIG" ]; then
    source "$CONFIG"
fi

# 默认配置
PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-${HOME}/.password-store}"
LOG_FILE="${LOG_FILE:-${HOME}/.local/log/pass-autosync.log}"
MAX_RETRIES="${MAX_RETRIES:-3}"
RETRY_DELAY="${RETRY_DELAY:-5}"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 切换到密码仓库
if ! cd "$PASSWORD_STORE_DIR"; then
    log "ERROR: 无法进入密码仓库目录 $PASSWORD_STORE_DIR"
    exit 1
fi

# 检查是否是 Git 仓库
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log "ERROR: $PASSWORD_STORE_DIR 不是 Git 仓库"
    log "提示: 运行 'pass git init' 和 'pass git remote add origin <url>' 初始化"
    exit 1
fi

# 检查 sync 别名是否存在
ensure_sync_alias() {
    if ! git config --local --get alias.sync > /dev/null 2>&1; then
        log "INFO: 配置 git sync 别名"
        git config --local alias.sync '!git pull --rebase --autostash && git push'
    fi
}

# 重试函数
retry() {
    local n=1
    local max=$MAX_RETRIES
    local delay=$RETRY_DELAY
    while true; do
        if "$@"; then
            return 0
        else
            if [[ $n -lt $max ]]; then
                log "WARNING: 命令失败，${delay}秒后重试 ($n/$max)"
                sleep $delay
                ((n++))
            else
                log "ERROR: 命令在 $max 次尝试后仍然失败"
                return 1
            fi
        fi
    done
}

# 主同步逻辑
do_sync() {
    log "开始同步密码仓库..."
    
    # 确保 sync 别名存在
    ensure_sync_alias
    
    # 尝试同步
    if retry pass git sync; then
        log "✅ 同步成功"
        return 0
    else
        log "❌ 同步失败"
        return 1
    fi
}

# 执行同步
do_sync

# 返回状态码供 systemd 使用
exit $?
