FROM alpine:latest

RUN apk add --no-cache bash curl

COPY update_ddns.sh /app/update_ddns.sh
RUN chmod +x /app/update_ddns.sh

CMD ["bash", "-c", "while true; do bash /app/update_ddns.sh; sleep 60; done"]
