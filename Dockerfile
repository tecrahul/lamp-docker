FROM ubuntu:16.04
MAINTAINER Rahul Kumar (rahul@tecadmin.net)

# install dependencies
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		apache2 \
		ca-certificates openssl \
		curl \
		php7.0 \
		php7.0-curl \
		php7.0-gd \
		php7.0-json \
		php7.0-simplexml \
		php7.0-mbstring \
		php7.0-mysql \
		php7.0-zip \
		openssh-server \
		composer \
		php7.0-mcrypt \
		php7.0-intl \
                supervisor  \
		libapache2-mod-php7.0 \
	&& rm -r /var/lib/apt/lists/*
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite expires
RUN a2enmod ssl
RUN a2enmod headers

RUN mkdir /var/run/sshd
RUN echo 'root:pass123' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
## Mount ##
WORKDIR /var/www/html
VOLUME /var/www/html
# Default command	
#CMD ["apachectl", "-D", "FOREGROUND"] 
# Ports
EXPOSE 80
EXPOSE 443
EXPOSE 22
CMD ["/usr/bin/supervisord"]
