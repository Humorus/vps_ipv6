#!/usr/bin/env bash 
set -euo pipefail

#
#**************************************************
# Author:         AGou-ops                        *
# E-mail:         agou-ops@foxmail.com            *
# Date:           2021-12-02                      *
# Description:                              *
# Copyright 2021 by AGou-ops.All Rights Reserved  *
#**************************************************

# ----------------
echoColor(){
  echo -e "\033[36m$1 \033[0m"
}

# 启用ipv6

tee /etc/sysctl.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
EOF

sysctl -p
echoColor "====== 启用ipv6 ======\n"

# 将下面的重定向内容替换为上面示例的配置片段内容
tee /etc/network/interfaces <<EOF

auto he-ipv6
iface he-ipv6 inet6 v4tunnel
        address 2001:470:1f14:4ad::2
        netmask 64
        endpoint 216.66.84.46
        local 23.94.101.153
        ttl 255
        gateway 2001:470:1f14:4ad::1
EOF

echoColor "====== 修改网络配置文件成功 ======\n"

apt update -y 2>&1 > /dev/null
apt install ifupdown dnsutils -y 2>&1 > /dev/null

echoColor "====== 安装必要包完成，图个方便，不为啥 ======\n"

sleep 1
# 启动ipv6网络接口，如果没生效可以尝试重启网络
ifup he-ipv6
echoColor "====== 接口内容信息如下 ======\n"
ip a show dev he-ipv6

echoColor "========================\n"
# 备份原来的dns
cp -a /etc/resolv.conf{,.bak}

tee /etc/resolv.conf <EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

echoColor "====== 修改dns完成 ======\n"

# 这里用ping查看ipv6地址也可以，这里我图方便使用dig好了
google_ipv6=$(dig www.google.com AAAA | grep -E "^www" | awk '{print $5}')

echo "$google_ipv6 www.google.com" > /etc/hosts

echoColor "====== 修改hosts文件完成 ======\n"

# 默认访问时会使用IPv6线路进行访问，考虑到速度问题，建议优先使用IPv4
sed -i 's@#precedence ::ffff:0:0/96  100@precedence ::ffff:0:0/96  100@g' /etc/gai.conf

echoColor "====== 配置优先IPv4完成 ======\n"

echoColor "\n\nDone."