FROM ntxcode/ruby-base:2.2.1

EXPOSE 80

RUN cd /tmp \
    && curl -O http://nginx.org/download/nginx-1.8.0.tar.gz \
    && tar xzf nginx-1.8.0.tar.gz \
    && gem install rack --version 1.5.5 \
    && gem install passenger --version 5.0.30 \
    && passenger-install-nginx-module --auto --nginx-source-dir=/tmp/nginx-1.8.0 --extra-configure-flags=none --languages=ruby

RUN bundle config --global frozen 1 && \
    mkdir -p /usr/src/app

RUN chown -R www-data. /usr/src/app

WORKDIR /usr/src/app

COPY Gemfile      /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without development --deployment -j`getconf _NPROCESSORS_ONLN`

COPY . /usr/src/app

COPY nginx.conf /etc/nginx/nginx.conf

RUN sed -ri "s@PASSENGER_ROOT@`passenger-config --root`@" /etc/nginx/nginx.conf \
    && ln -s /opt/nginx/sbin/nginx /usr/sbin/nginx \
    && mkdir -p /var/log/nginx

RUN mkdir -p /usr/src/app/public

COPY boot.sh /boot.sh
RUN chmod +x /boot.sh

WORKDIR /usr/src/app

RUN apt-get purge -y --auto-remove git-core && \
    rm -rf /var/lib/apt/lists/* && \
    truncate -s 0 /var/log/*log && \
    cd / && rm -rf /tmp/* || true

CMD ["/boot.sh"]
