FROM alpine:3.4

ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

RUN apk --update add nginx php5-fpm && \
    mkdir -p /var/log/nginx && \
    touch /var/log/nginx/access.log && \
    mkdir -p /run/nginx



RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir /usr/app
WORKDIR /usr/app
COPY Gemfile /usr/app/
#COPY Gemfile.lock /usr/app/
RUN bundle install

WORKDIR /

ADD www /www
ADD nginx.conf /etc/nginx/
ADD php-fpm.conf /etc/php5/php-fpm.conf

EXPOSE 80
CMD /www/in_s3_env /usr/bin/php-fpm -d variables_order='EGPCS' && (tail -F /var/log/nginx/access.log &) && exec nginx -g 'daemon off;'
