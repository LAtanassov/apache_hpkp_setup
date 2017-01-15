# Setup HTTP Public Key Pinning Extension HPKP for Apache
[on GitHub](https://github.com/LAtanassov/apache_hpkp_setup.git)

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
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout ./certificate/server.key -out ./certificate/server.crt
$ openssl rsa -in ./certificate/server.key -text > ./certificate/private.pem
$ openssl x509 -inform PEM -in ./certificate/server.crt > ./certificate/public.pem
```
### SPKI Fingerprints
Create SPKI Fingerprints of the public key with the following command
```sh
$ openssl x509 -noout -in ./certificate/public.pem -pubkey | \
$ openssl asn1parse -noout -inform pem -out public.key;
$openssl dgst -sha256 -binary public.key | openssl enc -base64
hDnBlosknv16wA4K3dDTUgPsIV7IXgmo5qYW4bEITsk=
$
```


## Setup Apache 2.4 as docker file
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
Header set Public-Key-Pins "pin-sha256=\"hDnBlosknv16wA4K3dDTUgPsIV7IXgmo5qYW4bEITsk=\"; max-age=600; includeSubDomains"
```

### Configure Dockerfile
Create a Dockerfile with the content 
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
At first start the docker images as configured and open on https://localhost the index.html site. Your browser now pinned this certificates and will not allow other ones for the time define in the max-age property (in our case 600 seconds).

Shutdown the docker container and change in the Dockerfile the certificates to
```txt
COPY ./certificate/badone.crt /usr/local/apache2/conf/server.crt
COPY ./certificate/badone.key /usr/local/apache2/conf/server.key
```
Rebuild and start the docker images.
The next time you try to open the https://localhost the browser should warn you that something is wrong and someone maybe tries to fool you.

## References
- [Apache Docker Installation and Configuration](https://hub.docker.com/_/httpd/)
- [HTTP Public Key Pinning Extension HPKP for Apache, NGINX and Lighttpd](https://raymii.org/s/articles/HTTP_Public_Key_Pinning_Extension_HPKP.html)
