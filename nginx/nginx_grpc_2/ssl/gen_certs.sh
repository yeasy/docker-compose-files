openssl req \
	-x509 \
	-nodes \
	-days 3650 \
	-newkey rsa:2048 \
	-keyout /root/server2.key \
	-out /root/server2.crt

# Enter "*.net" (without quotes) as "Common Name"
