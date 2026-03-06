FROM alpine:latest

RUN apk add --no-cache bash curl

COPY update_ddns.sh /app/update_ddns.sh
RUN chmod +x /app/update_ddns.sh

RUN echo "* * * * * cd /app && bash update_ddns.sh" | crontab -

CMD ["crond", "-f"]
