FROM mariadb:latest

COPY config/my.cnf /etc/mysql/

RUN apt-get update; apt-get install tzdata
RUN echo "Asia/Istanbul" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

RUN chmod o-w /etc/mysql/my.cnf
