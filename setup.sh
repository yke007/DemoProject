#!/bin/sh

mysqld --user=mysql  &

sleep 5

mysqladmin -uroot -p"$(cat /root/.mysql_secret | tail -1)" password '初始化数据库密码'

mysql -uroot -p"初始化数据库密码" mysql < /srv/grant.sql

ps -wef | grep mysql | grep -v grep | awk '{print $2}' | xargs kill -9

sleep 5

mysqld --user=mysql 
