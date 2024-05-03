#!/bin/bash

# 显示菜单
echo "请选择要执行的操作："
echo "1. 安装WARP"
echo "2. 安装NEZHA"
echo "3. 安装HY2"
echo "4. 添加IPv6"
echo "5. 融合怪测试"
echo "6. 添加计划任务通知"
echo "7. 退出"

# 读取用户输入
read -p "请输入选项的数字编号: " choice

# 根据用户选择执行相应的操作
case $choice in
    1)
        echo "你选择了安装WARP。"
        # 运行安装WARP的操作
        wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
        ;;
    2)
        echo "你选择了安装NEZHA。"
        curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh
        ;;
    3)
        echo "你选择了安装HY2。"
        wget -N --no-check-certificate https://raw.githubusercontent.com/Misaka-blog/hysteria-install/main/hy2/hysteria.sh && bash hysteria.sh
        ;;
    4)
        echo "你选择了安装3X-UI。"
        bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
        ;;
    4)
        echo "你选择了添加IPv6。"
        wget -N --no-check-certificate https://github.com/ayeaaaa/atuoyx/releases/download/autoip/adv6.sh && bash adv6.sh
        ;;
    5)
        echo "你选择了融合怪测试。"
        curl -L https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
        ;;
    6)
        echo "添加计划任务。"
        # 运行安装工通知脚本的操作
        # 在这里执行添加计划任务的操作
        ;;
    7)
        echo "退出脚本。"
        ;;
    *)
        echo "无效的选项。请选择 1、2、3、4、5、6 或 7。"
        ;;
esac
