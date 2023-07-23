FROM nginx:stable AS nginx

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  nginx-extras \
  && apt-get clean \
  && rm -rf /etc/nginx/conf.d/* /etc/nginx/sites-enabled/* /var/lib/apt/lists/*

COPY ./YetiForceCRM/tests/setup/nginx/yetiforce.conf /etc/nginx/yetiforce.conf
COPY ./nginx/docker.conf /etc/nginx/conf.d/default.conf
