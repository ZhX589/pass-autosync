#!/usr/bin/bash
# 为 pass 密码仓库配置 git sync 别名

PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-${HOME}/.password-store}"

configure_sync_alias() {
    if [ ! -d "$PASSWORD_STORE_DIR" ]; then
        echo "错误: 密码仓库不存在: $PASSWORD_STORE_DIR"
        return 1
    fi
    
    cd "$PASSWORD_STORE_DIR" || return 1
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "错误: 密码仓库尚未初始化 Git"
        echo "请先运行: pass git init"
        return 1
    fi
    
    if git config --local --get alias.sync > /dev/null 2>&1; then
        echo "sync 别名已存在:"
        git config --local --get alias.sync
        read -p "是否覆盖? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "取消配置"
            return 0
        fi
    fi
    
    git config --local alias.sync '!git pull --rebase --autostash && git push'
    echo "✅ git sync 别名配置成功"
    echo "使用: pass git sync"
}

configure_sync_alias
