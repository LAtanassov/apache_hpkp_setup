# Setup HTTP Public Key Pinning Extension HPKP for Apache
[on GitHub](https://github.com/LAtanassov/apache_hpkp_setup.git)

## Requirements
- Ubuntu 14.04 64 Bit
- Docker 1.12.6
- Apache 2.4
- OpenSSL 1.0.1f

## Simple HTML Project
Create a HTML file ./public-html/index.html with the following content 

```html
<html>
  <body>Hello there.</body>
</html>
```

## Certificates and the SPKI Fingerprints
Create three certificates
- two will be used to pin the browser (one certificate which is used by the Apache Web Server the other one as backup)
- the third one will be used to show that the browser will not accept other certificates

### Create Certificate 
Create three self signed Certificate with the following shell command and different names
```sh
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certificate/server.key -out ./certificate/server.crt
```
Two SPKI Fingerprints of two different Certificates have to be specified in the Header Property. One of them have to match the Certificate which is used by Apache and the other one is a backup. 

### SPKI Fingerprints
Create SPKI Fingerprints of the private key with the following command
```sh
$ openssl rsa -in ./certificate/server.key -outform der -pubout | openssl dgst -sha256 -binary | openssl enc -base64
ygh+CY5Mdl+E45kK48GuXDiWZ9bEX4hMy2sN7LYnki4=
```

## Setup Apache 2.4 as Dockerfile
Based on the Docker Image httpd:2.4, which contains an Apache 2.4 setup we will copy
- Project Folder
- Certificates and
- Configurations
into the Docker Images and build it.

### Adapt default httpd.conf file
Based on the httpd.conf from the Docker Image uncomment the following lines
```txt
Include conf/extra/httpd-ssl.conf
LoadModule ssl_module modules/mod_ssl.so
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
LoadModule headers_module modules/mod_headers.so
```
Add the SPKI Fingerprints
```txt
Header set Public-Key-Pins "pin-sha256=\"ygh+CY5Mdl+E45kK48GuXDiWZ9bEX4hMy2sN7LYnki4=\"; pin-sha256=\"+dh24vsE9RbAU81Urr8IhzypH2hTdoqKwSfFqY6bYh8=\"; max-age=2592000; includeSubDomains"
```

### Configure Dockerfile
Create a Dockerfile with the following content 
```txt
FROM httpd:2.4
COPY ./public-html/ /usr/local/apache2/htdocs/

COPY ./certificate/server.crt /usr/local/apache2/conf/
COPY ./certificate/server.key /usr/local/apache2/conf/
COPY ./config/httpd.conf /usr/local/apache2/conf/httpd.conf
```

## Build & Run Docker Image
```sh
$ docker build -t hello-hpkp .
$ docker run -dit -p 80:80 -p 443:443 hello-hpkp
```

## Test
At first start the docker images as configured and open on https://localhost the index.html site. Your browser will probably show you now a warning caused by the self-signed certificate depending on your browser. Skip this warning by adding an exception (for test reasons). Now you should see the simple 'hello there.' website we created. The HTTP response was delivered with an additional header entry, which you probably can see when you open the developer tool of your browser.

Public-Key-Pins:pin-sha256="hDnBlosknv16wA4K3dDTUgPsIV7IXgmo5qYW4bEITsk="; pin-sha256="6X0iNAQtPIjXKEVcqZBwyMcRwq1yW60549axatu3oDE="; max-age=2592000;

## Validation
Usually the browser should pin your Certificates and should not allow other Certificates, but unfortunately it is not that easy. According to [RFC 7469](https://www.rfc-editor.org/rfc/pdfrfc/rfc7469.txt.pdf) (at the moment Proposed Standard) self-signed certificates may be pinned. [Mutton P., 2016](https://news.netcraft.com/archives/2016/03/30/http-public-key-pinning-youre-doing-it-wrong.html) wrote in his blog about typical mistakes made by HPKP setups. Some older blog from [Lover R., 2006](http://blog.rlove.org/2015/01/public-key-pinning-hpkp.html) mentioned the validation problem. Nevertheless to check if the browser pinned your Certificates simply change the certificate on your Apache Server by modifying the Dockerfile
```txt
COPY ./certificate/badone.crt /usr/local/apache2/conf/server.crt
COPY ./certificate/badone.key /usr/local/apache2/conf/server.key
```
rebuild and start the docker images.

Chrome 56.0.2924.46 (64-bit) seems not to pin the self-signed Certificates and shows only the self-signed warning. After an Exception was added the website can be visited as normal. There can be several reasons why Chrome does not pin Certificates. In our case I assume it is because of the self-signed certificate.

## References
[Apache Docker Installation and Configuration](https://hub.docker.com/_/httpd/) accessed on 29.01.2017

[HTTP Public Key Pinning Extension HPKP for Apache, NGINX and Lighttpd](https://raymii.org/s/articles/HTTP_Public_Key_Pinning_Extension_HPKP.html) accessed on 29.01.2017

[RFC 7469](https://www.rfc-editor.org/rfc/pdfrfc/rfc7469.txt.pdf)

[Mutton P., 2016](https://news.netcraft.com/archives/2016/03/30/http-public-key-pinning-youre-doing-it-wrong.html) accessed on 29.01.2017

[Lover R., 2006](http://blog.rlove.org/2015/01/public-key-pinning-hpkp.html) accessed on 29.01.2017