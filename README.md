# Setup HTTP Public Key Pinning Extension HPKP for Apache (incl. docker file)

## Requirements
- Ubuntu 14.04 64 Bit
- Docker 1.12.6
- Apache 2.4
- OpenSSL 1.0.1f

## Simple HTML Projekt
Create an index.html file with the following content into a folder named ./public-html
```html
<html>
  <body>Hello there.</body>
</html>
```

## Certificates and the SPKI Fingerprints
Create two certificates in the folder ./certificates
- one will be used to pin the browser to a specific certificate
- the other one will be used to show that the browser will not accept other certificates

### Create Certificate 
Create two self signed Certificate with the following shell command and different names
```sh
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout trustme.key -out trustme.crt
```

### Setup SSL on Apache  


## Setup Apache 2.4 as docker file
Create a Dockerfile with the content 
```txt
FROM httpd:2.4
COPY ./public-html/ /usr/local/apache2/htdocs/
```

## References
[Apache Docker Installation and Configuration]: https://hub.docker.com/_/httpd/

