openssl genrsa -out nginx.key 2048
openssl req -new -x509 -days 3650 -key nginx.key -out nginx.crt
