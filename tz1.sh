#!/bin/bash
	
# 电报 Bot API 相关信息
TELEGRAM_BOT_TOKEN="6892727060:AAFlx9jX71mYoYQ_B3fQNfN6tZiaVMC-Hdw"
TELEGRAM_CHAT_ID="2124103257"
	
# 推送到 PushPlus 相关信息
PUSHPLUS_TOKEN="759f32f022cb42a3960cc77bb21b4c44"
PUSHPLUS_TITLE="7185180233-EU4该续期了"
PUSHPLUS_CONTENT="7185180233-EU4该续期了—Next 05-04到期,eq 5"
	
# 发送通知到电报
send_telegram_notification() {
    curl -s -X POST \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage \
        -d text="$1" \
        -d chat_id=$TELEGRAM_CHAT_ID > /dev/null
}
	
# 发送通知到 PushPlus
send_pushplus_notification() {
    curl -s -X POST \
        https://www.pushplus.plus/send \
        -H 'Content-Type: application/json' \
        -d '{
            "token":"'$PUSHPLUS_TOKEN'",
            "title":"'$PUSHPLUS_TITLE'",
            "content":"'$1'"
        }' > /dev/null
}
	
# 发送通知
send_notification() {
    send_telegram_notification "$1"
    send_pushplus_notification "$1"
}

#=====================超时设置=======================
# 设置超时时间
timeout_duration=10

# 定义超时退出函数
timeout_exit() {
    echo "脚本执行超时，退出。"
    exit 1
}

# 设置超时退出时的捕获信号
trap timeout_exit SIGALRM

# 启动超时计时器
( sleep $timeout_duration; kill -ALRM $$ ) &

#=====================

#=====================计时器=======================

# 获取当前时间的小时数
current_hour=$(date +%H)

# 计算当前时间的分钟数
current_timestamp=$(date +%s)
minutes=$((current_timestamp / 60))

# 计算当前时间的小时数
hours=$((minutes / 60))

# 计算当前时间的天数
days=$((hours / 24))

# 计算当前时间的商和余数
weeks=$((days / 7))
remainder=$((days % 7))
echo "当前时间的天数为：$days"
echo "当前时间的天数除以7的商为：$weeks，余数为：$remainder"

# 如果余数为0，则发送通知，否则退出脚本
if [ $remainder -eq 5 ]; then
    send_notification "$PUSHPLUS_CONTENT"
    exit 0
else    
    echo "余数不为0，退出脚本。"
    exit 0
fi
