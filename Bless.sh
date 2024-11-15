#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Bless.sh"

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 安装和配置 Blessnode 函数
function setup_blessnode() {
    # 检查 Bless 目录是否存在，如果存在则删除
    if [ -d "Bless node" ]; then
        echo "检测到 Bless 目录已存在，正在删除..."
        rm -rf "Bless node" || { echo "删除 Bless node 目录失败"; exit 1; }
        echo "Bless node 目录已删除。"
    fi

    # 检查并终止已存在的 Bless tmux 会话
    if tmux has-session -t Bless 2>/dev/null; then
        echo "检测到正在运行的 Bless 会话，正在终止..."
        tmux kill-session -t Bless || { echo "终止 Bless 会话失败"; exit 1; }
        echo "已终止现有的 Bless 会话。"
    fi
    
    # 安装 npm 环境
    sudo apt update
    sudo apt install -y nodejs npm tmux node-cacache node-gyp node-mkdirp node-nopt node-tar node-which

    # 检查 Node.js 版本
    node_version=$(node -v 2>/dev/null)
    if [[ $? -ne 0 || "$node_version" != v16* ]]; then
        echo "当前 Node.js 版本为 $node_version，正在安装 Node.js 16..."
        # 安装 Node.js 16
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt install -y nodejs || { echo "安装 Node.js 失败"; exit 1; }
    else
        echo "Node.js 版本符合要求：$node_version"
    fi

    echo "正在从 GitHub 克隆 Bless 仓库..."
    git clone https://github.com/sdohuajia/Bless-node.git "Bless node" || { echo "克隆失败，请检查网络连接或仓库地址。"; exit 1; }

    cd "Bless node" || { echo "无法进入 Bless node 目录"; exit 1; }

    # 提示用户输入 B7S_AUTH_TOKEN
    read -p "请输入 B7S_AUTH_TOKEN: " B7S_AUTH_TOKEN
    echo "$B7S_AUTH_TOKEN" > user.txt
    echo "B7S_AUTH_TOKEN 已保存到 user.txt 文件中。"

    # 提示用户输入 nodeid 和 hardwareid
    read -p "请输入 nodeid (公钥): " nodeid
    read -p "请输入 hardwareid: " hardwareid

    # 将 nodeid 和 hardwareid 保存到 id.txt 文件中
    echo "$nodeid:$hardwareid" > id.txt
    echo "nodeid 和 hardwareid 已保存到 id.txt 文件中。"

    # 使用 tmux 自动运行 npm start
    tmux new-session -d -s Bless  # 创建新的 tmux 会话，名称为 Bless
    tmux send-keys -t Bless "cd 'Bless node'" C-m  # 切换到 Bless node 目录
    tmux send-keys -t Bless "npm start" C-m # 启动 npm start
    echo "npm 已在 tmux 会话中启动。"
    echo "使用 'tmux attach -t Bless' 命令来查看日志。"
    echo "要退出 tmux 会话，请按 Ctrl+B 然后按 D。"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装部署 Bless节点"
        echo "2. 退出"

        read -p "请输入您的选择 (1,2): " choice
        case $choice in
            1)
                setup_blessnode  # 调用安装和配置函数
                ;;
            2)
                echo "退出脚本..."
                exit 0
                ;;
            *)
                echo "无效的选择，请重试."
                read -n 1 -s -r -p "按任意键继续..."
                ;;
        esac
    done
}

# 进入主菜单
main_menu
