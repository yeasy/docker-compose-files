openssl req \
	-x509 \
	-nodes \
	-days 3650 \
	-newkey rsa:2048 \
	-keyout /root/server.key \
	-out /root/server.crt

# Enter "*.com" (without quotes) as "Common Name"
