#!/bin/bash

CONFIG_FILE="cfg.txt"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检测是否存在 cfg.txt 文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo "未找到 $CONFIG_FILE 文件，将自动创建并配置参数。"

    # 创建 cfg.txt 文件并交互式输入配置参数
    echo -n "Cloudflare 邮箱: "
    read EMAIL

    echo -n "Cloudflare API 密钥: "
    read API_KEY

    echo -n "Cloudflare 区域 ID: "
    read ZONE_ID

    echo -n "域名: "
    read DOMAIN

    echo -n "延迟测速线程数 (默认 200): "
    read DELAY_THREADS
    DELAY_THREADS=${DELAY_THREADS:-200}

    echo -n "延迟测速次数 (默认 4): "
    read DELAY_TIMES
    DELAY_TIMES=${DELAY_TIMES:-4}

    echo -n "下载测速数量 (默认 10): "
    read DOWNLOAD_COUNT
    DOWNLOAD_COUNT=${DOWNLOAD_COUNT:-10}

    echo -n "下载测速时间 (默认 10): "
    read DOWNLOAD_TIME
    DOWNLOAD_TIME=${DOWNLOAD_TIME:-10}

    echo -n "测速端口 (默认 443): "
    read TEST_PORT
    TEST_PORT=${TEST_PORT:-443}

    # 是否使用自定义测速地址的标志
    USE_CUSTOM_URL=""

    # 询问用户是否使用自定义测速地址
    read -p "是否使用自定义测速地址？(y/n): " use_custom_url
    case "$use_custom_url" in
        [yY])
            echo -n "请输入自定义测速地址: "
            read TEST_URL
            USE_CUSTOM_URL=true
            ;;
        *)
            USE_CUSTOM_URL=false
            ;;
    esac

    echo -n "显示结果数量 (默认 10): "
    read SHOW_RESULTS
    SHOW_RESULTS=${SHOW_RESULTS:-10}

    echo -n "IP 段数据文件 (默认 ip.txt): "
    read IP_FILE
    IP_FILE=${IP_FILE:-"ip.txt"}

    echo -n "写入结果文件 (默认 result.csv): "
    read OUTPUT_FILE
    OUTPUT_FILE=${OUTPUT_FILE:-"result.csv"}

    echo -n "下载速度下限 (默认 10): "
    read DOWNLOAD_SPEED_LIMIT
    DOWNLOAD_SPEED_LIMIT=${DOWNLOAD_SPEED_LIMIT:-10}

    # 将配置参数写入 cfg.txt 文件
    cat <<EOL >"$CONFIG_FILE"
# cfg.txt 文件

# Cloudflare API 凭据
EMAIL="$EMAIL"
API_KEY="$API_KEY"

# Cloudflare 区域 ID 和域名
ZONE_ID="$ZONE_ID"
DOMAIN="$DOMAIN"

# 其他参数
DELAY_THREADS=$DELAY_THREADS          # 延迟测速线程
DELAY_TIMES=$DELAY_TIMES              # 延迟测速次数
DOWNLOAD_COUNT=$DOWNLOAD_COUNT       # 下载测速数量
DOWNLOAD_TIME=$DOWNLOAD_TIME         # 下载测速时间
TEST_PORT=$TEST_PORT                  # 测速端口
USE_CUSTOM_URL=$USE_CUSTOM_URL        # 是否使用自定义测速地址
SHOW_RESULTS=$SHOW_RESULTS            # 显示结果数量
IP_FILE="$IP_FILE"                    # IP 段数据文件
OUTPUT_FILE="$OUTPUT_FILE"            # 写入结果文件
DOWNLOAD_SPEED_LIMIT=$DOWNLOAD_SPEED_LIMIT  # 下载速度下限
EOL

    echo "配置文件已创建: $CONFIG_FILE"
fi

# 读取配置参数
source "$CONFIG_FILE"

# CloudflareST 结果文件路径
CLOUDFLAREST_RESULT_FILE="result.csv"

# CloudflareST 命令
CLOUDFLAREST_COMMAND="$SCRIPT_DIR/CloudflareST"

# 检测系统架构
ARCHITECTURE=$(uname -m)

# 根据系统架构选择 CloudflareST
case $ARCHITECTURE in
    x86_64)
        CLOUDFLAREST_URL="https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.5/CloudflareST_linux_amd64.tar.gz"
        ;;
    i386|i686)
        CLOUDFLAREST_URL="https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.5/CloudflareST_linux_386.tar.gz"
        ;;
    arm64|aarch64)
        CLOUDFLAREST_URL="https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.5/CloudflareST_linux_arm64.tar.gz"
        ;;
    *)
        echo "未支持的系统架构: $ARCHITECTURE"
        exit 1
        ;;
esac

# 检测是否存在 CloudflareST
if ! command -v "$CLOUDFLAREST_COMMAND" &> /dev/null
then
    echo "$CLOUDFLAREST_COMMAND 未找到，正在下载并安装..."

    # 下载 CloudflareST
    curl -LO "$CLOUDFLAREST_URL"

    # 解压 CloudflareST 到当前脚本目录并加入可执行权限
    tar -xzf $(basename "$CLOUDFLAREST_URL") -C "$SCRIPT_DIR"
    chmod +x "$CLOUDFLAREST_COMMAND"

    echo "安装完成."
fi

# CloudflareST 获取最佳 IP 的函数
run_cloudflarest() {
    if [ "$USE_CUSTOM_URL" = true ]; then
        "$CLOUDFLAREST_COMMAND" -n $DELAY_THREADS -t $DELAY_TIMES -dn $DOWNLOAD_COUNT -dt $DOWNLOAD_TIME \
            -tp $TEST_PORT -url $TEST_URL -sl $DOWNLOAD_SPEED_LIMIT -p $SHOW_RESULTS -f $IP_FILE -o $OUTPUT_FILE
    else
        "$CLOUDFLAREST_COMMAND" -n $DELAY_THREADS -t $DELAY_TIMES -dn $DOWNLOAD_COUNT -dt $DOWNLOAD_TIME \
            -tp $TEST_PORT -sl $DOWNLOAD_SPEED_LIMIT -p $SHOW_RESULTS -f $IP_FILE -o $OUTPUT_FILE
    fi
}

# 从 CloudflareST 结果中获取最佳 IP 的函数
get_best_ip() {
    best_ip=$(tail -n +2 "$CLOUDFLAREST_RESULT_FILE" | sort -t, -k5,5n | head -n 1 | cut -d',' -f1)

    echo $best_ip
}

# 删除指定域名下的所有 DNS 记录
del_dns() {
    local domain="$1"

    # 获取所有 DNS 记录的 IDs
    local record_ids=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$DOMAIN" \
        -H "X-Auth-Email: $EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json" | jq -r '.result[].id')

    # 删除所有 DNS 记录
    for id in $record_ids; do
        curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$id" \
            -H "X-Auth-Email: $EMAIL" \
            -H "X-Auth-Key: $API_KEY" \
            -H "Content-Type: application/json"
    done
}

# 更新 Cloudflare DNS 记录的函数
update_dns() {
    local ip="$1"

    # 注释掉删除指定域名下的所有 DNS 记录的部分
    # del_dns "$DOMAIN"

    # 添加新的 A 类型 DNS 记录
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "X-Auth-Email: $EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}"
}




# 主脚本
run_cloudflarest

# 等待 CloudflareST 完成并获取最佳 IP
while [ ! -f "$CLOUDFLAREST_RESULT_FILE" ]; do
    sleep 1
done
#删除DNS记录
    del_dns
# 循环读取 result.csv 文件中的记录，并逐个增加到 Cloudflare
  tail -n +2 "$CLOUDFLAREST_RESULT_FILE" | while IFS=',' read -r ip _ _ _ _; do
    # 在这里你可以进行一些处理，如果需要的话

    # 增加 Cloudflare DNS 记录
    update_dns "$ip"
    echo "IP $ip 已成功更新."
done

best_ip=$(get_best_ip)
echo "Best IP: $best_ip"

if [ -n "$best_ip" ]; then
    update_dns $best_ip
    echo "DNS 记录已成功更新."
else
    echo "无法更新 DNS 记录. 未找到有效的 IP."
fi

