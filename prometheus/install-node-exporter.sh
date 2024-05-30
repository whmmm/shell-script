#!/bin/bash

# 设置要安装的 Node Exporter 版本
NODE_EXPORTER_VERSION="1.8.1"

# 清华大学镜像站地址
#MIRROR_URL="https://mirrors.tuna.tsinghua.edu.cn/github-release/prometheus/node_exporter"
# 设置要安装的 Node Exporter 版本
NODE_EXPORTER_VERSION="1.3.1"

# 使用 Cloudflare 的 CDN 服务加速 GitHub 下载
CDN_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"

# 创建一个临时目录来下载 Node Exporter
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

echo $CDN_URL
# 下载 Node Exporter 压缩包
curl -LO $CDN_URL


# 解压 Node Exporter 压缩包
tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# 将 Node Exporter 二进制文件移动到 /usr/local/bin 目录
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/

# 创建一个用于 Node Exporter 的 systemd 服务文件
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=default.target
EOF

# 重新加载 systemd 服务
systemctl daemon-reload

# 启动并启用 Node Exporter 服务
systemctl start node_exporter
systemctl enable node_exporter

# 清理临时目录
rm -rf $TMP_DIR

echo "Node Exporter ${NODE_EXPORTER_VERSION} 已成功安装并作为系统服务运行。"
