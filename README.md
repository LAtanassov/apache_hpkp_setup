# Setup HTTP Public Key Pinning Extension HPKP for Apache (incl. docker file)

## Requirements
- Ubuntu 14.04 64 Bit
- Docker 1.12.6
- Apache 2.4
- OpenSSL 1.0.1f

## Simple HTML Projekt
Create a HTML file ./public-html/index.html with the following content 
```html
<html>
  <body>Hello there.</body>
</html>
```

## Certificates and the SPKI Fingerprints
Create two certificates
- one will be used to pin the browser to a specific certificate
- the other one will be used to show that the browser will not accept other certificates

### Create Certificate 
Create two self signed Certificate with the following shell command and different names
```sh
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certificate/server.key -out ./certificate/server.crt
```

## Setup Apache 2.4 as docker file
Create a Dockerfile with the content 
```txt
FROM httpd:2.4
COPY ./public-html/ /usr/local/apache2/htdocs

COPY ./certificate/server.crt /usr/local/apache2/conf/
COPY ./certificate/server.key /usr/local/apache2/conf/
```

Create an own Apache Configration file based on the default in ./config/httpd.conf 
- uncomment the following line
```txt
# Secure (SSL/TLS) connections
Include @rel_sysconfdir@/extra/httpd-ssl.conf
```



## References
[Apache Docker Installation and Configuration]: https://hub.docker.com/_/httpd/

