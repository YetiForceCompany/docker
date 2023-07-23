FROM alpine:3.17
COPY ./cron-runner.sh /usr/local/bin/cron-runner.sh
RUN apk add --no-cache bash \
  && chmod +x /usr/local/bin/cron-runner.sh

CMD ["/usr/local/bin/cron-runner.sh"]