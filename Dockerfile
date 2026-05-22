# 阶段一：提取官方 sing-box 核心
FROM ghcr.io/sagernet/sing-box:latest AS sing-box

# 阶段二：提取官方 Cloudflared 核心
FROM cloudflare/cloudflared:latest AS cloudflared

# 阶段三：构建极简运行环境
FROM alpine:latest

# 安装必要依赖并设定时区为东八区
RUN apk update && apk add --no-cache bash tzdata ca-certificates && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 导入二进制核心，确保极高纯净度
COPY --from=sing-box /usr/local/bin/sing-box /usr/local/bin/sing-box
COPY --from=cloudflared /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# 设置工作目录
WORKDIR /app

# 复制配置文件和启动脚本
COPY config.json .
COPY start.sh .

# 赋予启动脚本执行权限
RUN chmod +x start.sh

# 启动入口
CMD ["./start.sh"]
