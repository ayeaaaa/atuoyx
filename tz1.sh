#!/bin/bash

# 设置系统时区为东八区
echo "设置时区为东八区"
sudo timedatectl set-timezone Asia/Shanghai

# 配置文件路径
CONFIG_FILE="tg.cfg"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "配置文件 $CONFIG_FILE 不存在，现在创建..."

    # 交互创建配置文件
    read -p "请输入通知的周几 (如: 周二): " weekday
    read -p "请输入主机位置 (如: US4-02): " CUSTOM_ID
    read -p "请输入TGID (如: 692474): " CUSTOM_CODE1
    read -p "请输入电话号码 (如: 15633): " CUSTOM_CODE2

    # 写入配置文件
    echo "weekday=\"$weekday\"" > "$CONFIG_FILE"
    echo "CUSTOM_ID=\"$CUSTOM_ID\"" >> "$CONFIG_FILE"
    echo "CUSTOM_CODE1=\"$CUSTOM_CODE1\"" >> "$CONFIG_FILE"
    echo "CUSTOM_CODE2=\"$CUSTOM_CODE2\"" >> "$CONFIG_FILE"

    echo "配置文件 $CONFIG_FILE 创建成功。"
fi
	
# 读取配置文件
source tg.cfg

# 设置变量，指定余数的目标值
declare -A day_to_number=( ["周一"]=1 ["周二"]=2 ["周三"]=3 ["周四"]=4 ["周五"]=5 ["周六"]=6 ["周日"]=7 )

# 获取对应的 target_number
target_number=${day_to_number[$weekday]}

# 电报 Bot API 相关信息
TELEGRAM_BOT_TOKEN="6892727060:AAFlx9jX71mYoYQ_B3fQNfN6tZiaVMC-Hdw"
TELEGRAM_CHAT_ID="2124103257"

# 推送到 PushPlus 相关信息
PUSHPLUS_TOKEN="759f32f022cb42a3960cc77bb21b4c44"
PUSHPLUS_TITLE="${CUSTOM_ID}-${CUSTOM_CODE1},${CUSTOM_CODE2}该续期了"
PUSHPLUS_CONTENT="${CUSTOM_ID}-${CUSTOM_CODE1},${CUSTOM_CODE2}该续期了,每周${weekday}"
	
# 发送通知到电报
send_telegram_notification() {
    curl -s -X POST \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage \
        -d text="$1" \
        -d chat_id=$TELEGRAM_CHAT_ID > /dev/null
}
	
# 发送通知到 PushPlus
send_pushplus_notification() {
    curl -d "token=${PUSHPLUS_TOKEN}&title=${PUSHPLUS_TITLE}&content=${PUSHPLUS_CONTENT}" -X POST http://www.pushplus.plus/send
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

# 获取当前的星期几（1-7，1代表周一，7代表周日）
current_weekday=$(date +%u)

# 输出当前星期几
echo "当前是星期：$current_weekday"

# 如果当前的星期几与配置的星期几相同，则发送通知，否则退出脚本
if [ $current_weekday -eq $target_number ]; then
    send_notification "$PUSHPLUS_CONTENT"
    exit 0
else    
    echo "今天不是 $weekday，退出脚本。"
    exit 0
fi
