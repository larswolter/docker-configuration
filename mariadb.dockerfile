FROM mariadb

COPY mariadb-setup.sql /docker-entrypoint-initdb.d/mariadb-setup.sql
