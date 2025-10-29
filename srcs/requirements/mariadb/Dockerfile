FROM alpine:3.21

RUN apk add --no-cache mariadb mariadb-client tzdata bash

# Folders and ownership for mysql daemon
RUN mkdir -p /var/lib/mysql /run/mysqld \
 && chown -R mysql:mysql /var/lib/mysql /run/mysqld

COPY conf/mariadb.cnf /etc/my.cnf.d/mariadb.cnf
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

VOLUME ["/var/lib/mysql"]
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_db.sh"]