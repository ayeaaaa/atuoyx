#!/bin/bash

# 定义ANSI颜色码
GREEN='\e[32m'
RESET='\e[0m'

# 安装 ZeroTier
echo -e "${GREEN}安装 ZeroTier...${RESET}"
curl -s https://install.zerotier.com | sudo bash

# 进入 ZeroTier 目录
echo -e "${GREEN}切换到 ZeroTier 目录...${RESET}"
cd /var/lib/zerotier-one

# 删除旧的 planet 文件夹
echo -e "${GREEN}删除旧的 'planet' 文件夹...${RESET}"
rm -rf planet

# 下载新的 planet 文件
echo -e "${GREEN}下载新的 'planet' 文件...${RESET}"
wget http://blog.nomao.top/planet -O planet

# 重启 ZeroTier 服务
echo -e "${GREEN}重启 ZeroTier 服务...${RESET}"
service zerotier-one restart

# 加入指定的 ZeroTier 网络
echo -e "${GREEN}加入指定的 ZeroTier 网络...${RESET}"
# 延时 5 秒
echo -e "${GREEN}等待 1 秒...${RESET}"
sleep 1
sudo zerotier-cli join 93caa675b035c9d7

# 设置允许全局流量
echo -e "${GREEN}设置 allowGlobal=true...${RESET}"
# 延时 5 秒
echo -e "${GREEN}等待 1 秒...${RESET}"
sleep 1
sudo zerotier-cli set 93caa675b035c9d7 allowGlobal=true

# 设置默认路由
echo -e "${GREEN}设置 allowDefault=1...${RESET}"
# 延时 5 秒
echo -e "${GREEN}等待 1 秒...${RESET}"
sleep 1
sudo zerotier-cli set 93caa675b035c9d7 allowDefault=1

# 运行成功
echo -e "${GREEN}运行成功，等待5秒显示IPV6地址倒计时：${RESET}"

for ((i=5; i>=1; i--)); do
    echo -e "${GREEN}倒计时：${i}${RESET}"
    sleep 1
done

# 获取指定网络接口（zt4z5jhpdh）并以2开头的IPv6地址
ipv6_address=$(ip -6 addr show dev zt4z5jhpdh | awk '/inet6/ && $2 ~ /^2/ {print $2}')

# 判断是否成功获取到IPv6地址
if [ -n "$ipv6_address" ]; then
    echo -e "${GREEN}成功获取到IPv6地址: ${ipv6_address}${RESET}"
else
    echo -e "${GREEN}未能获取到满足条件的IPv6地址${RESET}"
fi

# 运行成功
echo -e "${GREEN}运行结束${RESET}"
