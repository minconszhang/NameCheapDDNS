#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"

# 加载 .env
if [ -f .env ]; then
  set -o allexport; source .env; set +o allexport
else
  echo "❌ .env 文件未找到" >&2
  exit 1
fi

LOG="ddns.log"
MAX_LINES=256

log() {
  echo "$1" >> "$LOG"
  tail -n "$MAX_LINES" "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
}

# 读取上次的 Latest IP
if [[ -f "$LOG" ]]; then
  last_line=$(grep '\[INFO\] Latest IP ->' "$LOG" | tail -n1)
  PREV_IP=$(echo "$last_line" | awk -F' -> ' '{print $2}')
else
  PREV_IP=""
fi

# Change to your real network interface name, e.g., en0, en1, etc.
IP=$(curl -4 --connect-timeout 5 --max-time 15 -s https://api.ipify.org)
if [[ -z "$IP" ]]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S')  ❌ 获取真实 IP 失败" >> "$LOG"
  exit 1
fi

# 如果 IP 未变，则直接退出
if [[ "$IP" == "$PREV_IP" ]]; then
  exit 0
fi

# 把 HOSTS 变量拆成数组
read -r -a HOST_ARRAY <<< "$HOSTS"

for HOST in "${HOST_ARRAY[@]}"; do
  if curl -s \
      "https://dynamicdns.park-your-domain.com/update?host=${HOST}&domain=${DOMAIN}&password=${PASSWORD}&ip=${IP}" \
      >/dev/null 2>&1; then
    log "$(date '+%Y-%m-%d %H:%M:%S')  [INFO] 更新 ${HOST}.${DOMAIN} -> ${IP}"
  else
    log "$(date '+%Y-%m-%d %H:%M:%S')  [ERROR] 更新 ${HOST}.${DOMAIN} 失败"
  fi
done

# 最后一行写入最新 IP
log "$(date '+%Y-%m-%d %H:%M:%S')  [INFO] Latest IP -> ${IP}"
