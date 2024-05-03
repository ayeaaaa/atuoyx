#!/bin/bash

# 固定的定时任务
cron_job="30 * * * * bash /root/tz1.sh"

# 将任务写入临时文件
echo "$cron_job" > /tmp/temp_cron

# 将临时文件添加到 crontab
crontab /tmp/temp_cron

# 清理临时文件
rm /tmp/temp_cron

echo "任务已成功添加到 crontab。"
