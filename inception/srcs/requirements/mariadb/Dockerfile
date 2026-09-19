FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
	mariadb-server \
	mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysql \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& chmod 777 /ver/run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/endpoint.sh /usr/local/bin/endpoint.sh
RUN chmod +x /usr/local/bin/endpoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mariadb", "--user=mysql"]
