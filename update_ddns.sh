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

# 把 HOSTS 变量拆成数组
read -r -a HOST_ARRAY <<< "$HOSTS"

for HOST in "${HOST_ARRAY[@]}"; do
  echo "$(date '+%Y-%m-%d %H:%M:%S')  [INFO] 更新 ${HOST}.${DOMAIN}" >> "$LOG"
  RESPONSE=$(curl -s \
    "https://dynamicdns.park-your-domain.com/update?host=${HOST}&domain=${DOMAIN}&password=${PASSWORD}&ip=${IP}" 2>&1)
  echo "$(date '+%Y-%m-%d %H:%M:%S')  [RESPONSE] Host=${HOST}  $RESPONSE" >> "$LOG"
done
