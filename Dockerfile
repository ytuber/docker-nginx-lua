FROM debian:wheezy

RUN echo "deb http://nginx.org/packages/ubuntu/ precise nginx" >> /etc/apt/sources.list.d/nginx.list
RUN echo "deb-src http://nginx.org/packages/ubuntu/ precise nginx" >> /etc/apt/sources.list.d/nginx.list
RUN apt-key adv --fetch-keys "http://nginx.org/keys/nginx_signing.key"
RUN apt-get -y update && apt-get upgrade -y
RUN apt-get -y build-dep nginx && apt-get -y install wget unzip ca-certificates

RUN apt-get install -y lua5.1 liblua5.1-0 liblua5.1-0-dev build-essential openssl git

RUN ln -s /usr/lib/x86_64-linux-gnu/liblua5.1.so /usr/lib/liblua.so

RUN git clone https://github.com/openresty/lua-nginx-module.git && \
    git clone https://github.com/simpl/ngx_devel_kit.git

RUN apt-get -y source nginx && \
    wget https://github.com/anomalizer/ngx_aws_auth/archive/master.zip && \
    unzip master.zip && \
    cd nginx-1.8.0 && \
    ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-http_spdy_module --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' --with-ipv6 --add-module=/ngx_aws_auth-master/ \
    --add-module=/lua-nginx-module --add-module=/ngx_devel_kit && \
    make && make install && \
    rm -rf /master.zip && \
    rm -rf /nginx*

RUN groupadd nginx && useradd -g nginx nginx && usermod -s /bin/false nginx && \
    mkdir -p /var/cache/nginx /var/lib/nginx /var/log/nginx && \
    chown nginx:nginx /var/cache/nginx /var/lib/nginx /var/log/nginx && \
    chmod 774 /var/cache/nginx /var/lib/nginx /var/log/nginx

ADD nginx.conf /etc/nginx/nginx.conf

CMD /usr/sbin/nginx -c /etc/nginx/nginx.conf
