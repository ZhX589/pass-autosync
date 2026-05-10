# pass-autosync

pass 密码仓库自动同步工具，基于 systemd 定时器实现。

---

## 功能

- 定时自动同步（默认每小时）
- 使用 rebase + autostash 策略处理冲突
- 失败自动重试（默认3次）
- systemd 服务单元，开机自启
- 日志记录，便于排查问题

---

## 系统要求

- Linux 发行版（使用 systemd）
- pass 密码管理器
- Git
- GPG

---

## 安装

从 GitHub 克隆并执行安装脚本：

```
git clone https://github.com/你的用户名/pass-autosync.git
cd pass-autosync
./install.sh
```

安装脚本会完成以下工作：

1. 复制主程序到 `/usr/local/bin/pass-autosync`
2. 安装 systemd 服务单元和定时器
3. 在密码仓库中配置 git sync 别名
4. 创建默认配置文件
5. 启用并启动定时器

---

## 配置

配置文件位于 `~/.config/pass-autosync/config`

```
# 密码仓库路径（默认为 ~/.password-store）
PASSWORD_STORE_DIR="${HOME}/.password-store"

# 失败重试次数
MAX_RETRIES=3

# 重试间隔（秒）
RETRY_DELAY=5

# 日志文件路径
LOG_FILE="${HOME}/.local/log/pass-autosync.log"
```

---

## 使用方法

查看定时器状态：

```
systemctl status pass-autosync.timer
```

手动执行一次同步：

```
pass-autosync
```

查看同步日志：

```
tail -f ~/.local/log/pass-autosync.log
```

查看 systemd 日志：

```
journalctl -u pass-autosync@$USER -f
```

停止自动同步：

```
sudo systemctl disable --now pass-autosync.timer
```

---

## 卸载

```
./uninstall.sh
```

卸载脚本会：

1. 停止并禁用 systemd 定时器
2. 删除服务单元文件
3. 删除主程序
4. 询问是否删除配置文件和日志

---

## 目录结构

```
~/.password-store/          # 密码仓库（Git 仓库）
~/.config/pass-autosync/    # 配置文件目录
~/.local/log/               # 日志目录
/etc/systemd/system/        # systemd 服务文件
```

---

## 故障排查

**定时器未触发**

检查定时器状态和执行时间：

```
systemctl list-timers --all | grep pass
```

**同步失败**

查看详细日志：

```
journalctl -u pass-autosync@$USER -n 50
```

**密码仓库未初始化 Git**

在密码仓库目录中执行：

```
pass git init
pass git remote add origin <你的远程仓库地址>
```

**git sync 别名不存在**

手动配置：

```
cd ~/.password-store
git config --local alias.sync '!git pull --rebase --autostash && git push'
```

---

## 许可证

MIT
