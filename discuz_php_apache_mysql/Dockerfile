# discuz + php + apache
FROM php:8.1.0-apache
MAINTAINER yeasy@github

RUN docker-php-ext-install mysqli; \
    docker-php-ext-install pdo_mysql; \
    apt-get update && \
    apt-get install -y unzip
    
# Download discuz 3.5 and copy to /var/www/html
RUN curl -L -o /tmp/discuz.zip https://gitee.com/Discuz/DiscuzX/releases/download/v3.5-20230316/Discuz_X3.5_SC_UTF8_20230316.zip && \
#COPY ./Discuz_X3.5_SC_UTF8_20230316.zip /tmp/discuz.zip
	unzip /tmp/discuz.zip -d /tmp/discuz && \
	cp -r /tmp/discuz/upload/* $PWD && \
	rm -rf /tmp/*

# Backup and let config be moutable later
RUN cp -rf config config_default; \
    sed -i "s|./config/config_global_default.php|./config_default/config_global_default.php|g" install/index.php

RUN chmod a+w -R config data uc_server/data uc_client/data

# After install, need to remove the install/index.php