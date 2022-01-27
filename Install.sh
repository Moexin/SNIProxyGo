#!/bin/bash
echo '正在更新系统'
apt-get update -y > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1
echo '正在安装依赖'
apt-get install cron curl wget chrony vim-tiny -y > /dev/null 2>&1
echo '正在安装后端'
wget -P /usr/local/bin -T 15 -t 30 -c -q --show-progress --retry-connrefused https://raw.githubusercontent.com/Moexin/SNIProxyGo/main/SNIProxyGo
chmod +x /usr/local/bin/SNIProxyGo
wget -P /usr/local/etc -T 15 -t 30 -c -q --show-progress --retry-connrefused https://raw.githubusercontent.com/Moexin/SNIProxyGo/main/SNIProxyGo.yaml
cat > /usr/local/bin/SNIProxyGo.sh <<EOF
#!/bin/bash
systemctl stop SNIProxyGo
rm -f /usr/local/etc/SNIProxyGo.yaml
wget -P /usr/local/etc -T 15 -t 30 -c -q --show-progress --retry-connrefused https://raw.githubusercontent.com/Moexin/SNIProxyGo/main/SNIProxyGo.yaml
systemctl start SNIProxyGo
EOF
echo '配置进程守护'
cat > /etc/systemd/system/SNIProxyGo.service <<EOF
[Unit]
Description=SNIProxyGo Service
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/SNIProxyGo -c /usr/local/etc/SNIProxyGo.yaml
LimitNOFILE=51200
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF
echo '正在设置时区'
timedatectl set-timezone Asia/Shanghai
echo '启动自动校时'
/lib/systemd/systemd-sysv-install enable chrony
chronyc makestep > /dev/null 2>&1
echo '正在启动后端'
systemctl daemon-reload
systemctl enable --now SNIProxyGo > /dev/null 2>&1
echo '配置定时任务'
echo "30 4 * * * /bin/bash /usr/local/bin/SNIProxyGo.sh" >> /var/spool/cron/crontabs/root
export EDITOR="/usr/bin/vim.tiny > /dev/null 2>&1";
crontab -e > /dev/null 2>&1 <<EOF
:wq
EOF
echo '添加虚拟内存'
fallocate -l 2048M /swap
chmod 600 /swap
mkswap /swap > /dev/null 2>&1
swapon /swap
echo '/swap none swap defaults 0 0' >> /etc/fstab
echo '优化系统配置'
wget -T 15 -t 30 -c -q --show-progress --retry-connrefused https://xrayr.onrender.com/Optimize.sh
source Optimize.sh
install_bbr > /dev/null 2>&1
rm -f Optimize.sh
echo '重启系统生效'
reboot
