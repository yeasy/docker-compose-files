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

3. Access [https://127.0.0.1/wp-admin](https://127.0.0.1/wp-admin).

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

## Apply ssl certs from Let's Encrypt

Set `/etc/nginx/conf.d/default.conf` as the following:

```bash
server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files
        include /etc/nginx/default.d/*.conf;

        # Let's Encrypt authentication
        location ~ /.well-known {
            root /usr/share/nginx;
            allow all;
        }
    }
```

Restart nginx.

```bash
nginx -s reload
service nginx restart
```

Apply ssl cert and key pair with certbot.

```bash
certbot certonly --webroot --agree-tos -v -t --email xxx@xxx.com -w /usr/share/nginx/ -d xxx.com
```

The new cert will be saved under `/etc/letsencrypt/live/`.

Renew cert when it's expired.

```bash
certbot renew --pre-hook "service nginx stop" --post-hook "service nginx start"
```

## Common wordpress configs

* permanent link: use article title only;
* theme: astra;
* plugins: 
  * Akismet: anti spam posts;
  * AMP: improve page experience;
  * Contact Form 7 + Flamingo: contact information form;
  * Insert Headers and Footers: insert header/footer to every page;
  * elementor website builder
  * Limit Login Attempts Reloaded: limit login attempts;
  * ModuloBox: show figure in large view;
  * Pinyin Slugs: convert Chinese article title to pinyin in permlink;
  * Post Views Counter: count page view number;
  * Sucuri: security protection and audit; 
  * Super Cache: cache support;
  * Updraft: backup wordpress data; 
  * WP User Profile Avatar: User avatar
