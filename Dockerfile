FROM httpd:2.4
COPY ./public-html/ /usr/local/apache2/htdocs/

COPY ./certificate/badone.crt /usr/local/apache2/conf/server.crt
COPY ./certificate/badone.key /usr/local/apache2/conf/server.key
COPY ./config/httpd.conf /usr/local/apache2/conf/httpd.conf