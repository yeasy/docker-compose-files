# LNMP+Wordpress

Deploy nginx, mysql, php + wordpress.

## Usage

1. Start the db container.

```bash
docker-compose --env-file ./.env up -d db
```

2. Start the nginx and wordpress container.

```bash
docker-compose --env-file ./.env up -d wordpress nginx
```

3. Access `https://localhost`

## Data path

* `wordpress_data`: data for wordpress.
* `wordpress_config`: config for wordpress.
* `db_data`: config for wordpress.


## Generate ssl certs

```bash
openssl req -x509 -outform pem -out server.pem -keyout privkey.pem \
  -newkey rsa:4096 -nodes -sha256 -days 3650 \
  -subj '/CN=localhost' -extensions EXT -config <( \
   printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```

## Common wordpress configs

* permanent link;
* theme: astra;
* plugins: Contact Form 7, Updraft, Sucuri; 