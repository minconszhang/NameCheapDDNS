#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"

# 加载 .env
if [ -f .env ]; then
  set -o allexport; source .env; set +o allexport
else
  echo "❌ .env 文件未找到" >&2
  exit 1
fi

PREV_IP_FILE=".prev_ip"

# 读取上次的 IP
if [[ -f "$PREV_IP_FILE" ]]; then
  PREV_IP=$(cat "$PREV_IP_FILE")
else
  PREV_IP=""
fi

# 获取公网 IP
IP=$(curl -4 --connect-timeout 5 --max-time 15 -s https://api.ipify.org)
if [[ -z "$IP" ]]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S')  ❌ 获取真实 IP 失败" >&2
  exit 1
fi

# 如果 IP 未变，则直接退出
if [[ "$IP" == "$PREV_IP" ]]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S')  [INFO] IP 未变 -> ${IP}"
  exit 0
fi

echo "$(date '+%Y-%m-%d %H:%M:%S')  [INFO] IP 变更: ${PREV_IP:-无} -> ${IP}"

CF_API="https://api.cloudflare.com/client/v4"

# 把 HOSTS 变量拆成数组
read -r -a HOST_ARRAY <<< "$HOSTS"

for HOST in "${HOST_ARRAY[@]}"; do
  # 构建完整域名：@ 代表根域名
  if [[ "$HOST" == "@" ]]; then
    RECORD_NAME="$DOMAIN"
  else
    RECORD_NAME="${HOST}.${DOMAIN}"
  fi

  # 查询 DNS 记录 ID
  RESPONSE=$(curl -s --connect-timeout 5 --max-time 15 \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    "${CF_API}/zones/${CF_ZONE_ID}/dns_records?type=A&name=${RECORD_NAME}")

  RECORD_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -n1 | cut -d'"' -f4)

  if [[ -z "$RECORD_ID" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S')  [ERROR] 未找到记录 ${RECORD_NAME}" >&2
    continue
  fi

  # 更新 DNS 记录
  UPDATE=$(curl -s --connect-timeout 5 --max-time 15 -X PUT \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"${RECORD_NAME}\",\"content\":\"${IP}\",\"ttl\":1,\"proxied\":false}" \
    "${CF_API}/zones/${CF_ZONE_ID}/dns_records/${RECORD_ID}")

  if echo "$UPDATE" | grep -q '"success":true'; then
    echo "$(date '+%Y-%m-%d %H:%M:%S')  [INFO] 更新 ${RECORD_NAME} -> ${IP}"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S')  [ERROR] 更新 ${RECORD_NAME} 失败" >&2
  fi
done

# 保存当前 IP
echo "$IP" > "$PREV_IP_FILE"
