FROM alpine:latest

LABEL maintainer="my_nginx"

RUN apk update && \
    apk upgrade && \
    apk add --update nginx

COPY nginx.conf /etc/nginx/nginx.conf

COPY common.conf /etc/nginx/common.conf

COPY index.html /usr/share/nginx/html

EXPOSE 443 80

CMD ["nginx", "-g", "daemon off;"]
