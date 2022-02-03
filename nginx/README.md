# Nginx samples

## Nginx auth
Nginx serves as a proxy, and requires simple password to auth to access backend.

## Nginx https
Nginx serves as a proxy, and terminates the ssl from client.

Nginx1 (ssl terminate) --> app


## Nginx https 2
Nginx1 serves as a proxy, uses mutual tls to connect with nginx2, then nginx2 terminates the ssl from HTTP client.

Nginx1 (mutual tls) --> Nginx2 (ssl terminate) --> app

## Nginx gRPC 2
Nginx1 serves as a proxy, uses mutual tls to connect with nginx2, then nginx2 terminates the ssl from a gRPC client.

Nginx1 (mutual tls) --> Nginx2 (ssl terminate) --> app
