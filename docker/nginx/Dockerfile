FROM debian:bookworm

RUN apt-get update -y && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=PACA/L=Nice/O=42/OU=42/CN=kkraft.42.fr/UID=kkraft"

COPY conf/nginx.conf /etc/nginx/conf.d/inception.conf

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]