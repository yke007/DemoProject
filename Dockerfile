FROM centos:7

COPY mysql-5.7.22.tar.gz /srv
COPY boost_1_59_0.tar.gz /srv
COPY setup.sh /root
COPY my.cnf /srv
COPY grant.sql /srv

RUN set -x \
    && useradd mysql -s /sbin/nologin \
    && cd /srv ; tar -xvf mysql-5.7.22.tar.gz ; tar -xvf boost_1_59_0.tar.gz \
    && cd /srv/mysql-5.7.22 \
    && yum -y install cmake bison ncurses-devel gcc gcc-c++ make \
    && cd /srv/mysql-5.7.22 \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \  
       -DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock \
       -DDEFAULT_CHARSET=utf8  \
       -DDEFAULT_COLLATION=utf8_general_ci \
       -DWITH_INNOBASE_STORAGE_ENGINE=1   \
       -DWITH_ARCHIVE_STORAGE_ENGINE=1  \
       -DWITH_BLACKHOLE_STORAGE_ENGINE=1  \
       -DMYSQL_DATADIR=/usr/local/mysql/data  \
       -DMYSQL_TCP_PORT=3306  \
       -DMYSQL_USER=mysql  \
       -DENABLE_DOWNLOADS=1  \
       -DWITH_BOOST=/srv/boost_1_59_0  \
    && cd /srv/mysql-5.7.22 \
    && make -j 2 \
    && make install \
    && rm -rf /srv/*.gz \
    && rm -rf /srv/mysql-* 

RUN set -x \
    && cd /usr/local/mysql \
    && chmod +x /root/setup.sh \
    && ./bin/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data \
    && mv /srv/my.cnf /usr/local/mysql \
    && chown -R mysql.mysql /usr/local/mysql 

EXPOSE 3306

ENV PATH /usr/local/mysql/bin:$PATH

WORKDIR /usr/local/mysql

CMD ["/root/setup.sh"]
