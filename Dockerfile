FROM mysql:5

LABEL version="5"

ENV TZ Europe/Stockholm

RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y apt-utils && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

COPY ./bin /usr/bin
RUN chmod 755 /usr/bin/healthcheck

COPY ./mysqld.cnf /etc/mysql/mysql.conf.d

VOLUME /var/lib/mysql

HEALTHCHECK --interval=30s --timeout=5s CMD healthcheck

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld"]