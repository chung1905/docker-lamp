# LAMP Stack in Docker
###### multiple PHP (5.6/7.x/8.x) + Apache2 + MariaDB/Mysql + ... in Docker
This docker setup has been tested with Magento 2, WordPress and Symfony 2 -> Symfony 4

## How to set up:
1. Install `docker` and `docker compose` properly
2. Clone project and `cd` into the that
3. Configure PHP versions and services (first time only, interactive):
```shell
make config
```
This creates `dclamp.env` (PHP versions + services) and `.env` (docker env vars).
The `docker-compose.yml` file is **generated** from these — you never edit it by hand.
4. Generate wildcard self-signed certificates for `*.*.localhost` (optional)
```shell
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout ./httpd/certs/x.x.localhost.key \
-out ./httpd/certs/x.x.localhost.crt \
-subj "/C=XX/ST=State/L=City/O=Company/OU=CompanySectionName/CN=*.*.localhost"
```
5. Create and run containers:
```shell
make up
```
`make up` regenerates `docker-compose.yml` automatically whenever `dclamp.env` or
`compose-declaration.yml` change, so you no longer have to run `dclamp` by hand
before `docker compose up`. Run `make help` to see all targets (`up`, `down`,
`logs`, `build`, ...).

> Prefer the raw commands? `./dclamp generate` followed by `docker compose up -d`
> still works exactly as before — `make` is just a thin wrapper around them.

## PHP web application:
- Write your code at public_html directory
- Browse to URL: `localhost/info.php` to check if it's running properly
- Your MariaDB database credentials: `root:1@localhost:3306` or `root:1@mariadb:3306`

### Default VirtualHost
- Default PHP version(s): latest PHP 8.x
- Assume your `index.php` is located at `./public_html/project-dir/public-dir/index.php`,
please browse to: 
  - `http://public-dir.project-dir73.localhost` to run your application with PHP 7.3,
  - `http://public-dir.project-dir74.localhost` (PHP 7.4)
- You don't have to add entry to `/etc/hosts/` because by default, all .localhost sites will be redirected to 127.0.0.1:
  - If it's not the case, you can use dnsmasq instead of /etc/hosts, example:
```
# Redirect all localhost sites to 127.0.0.1
address=/localhost/127.0.0.1
```

### Custom VirtualHost
- Add your VirtualHost config files to `./httpd/conf/vhosts/`
- Restart Apache container: `docker restart httpd`

## Use PHP CLI:
- Shell into a PHP container (replace `73` with your version):
```shell
docker compose exec php73 /bin/bash
```
- Run you PHP application with command `php ...`
- To debug PHP CLI application: replace `php` by `xdebug`
  - Example: `php bin/console` to `xdebug bin/console`

### Enable/Disable PHP xdebug:
- After ```docker compose exec...``` into container, run
```shell
toggle-php-mod xdebug
```
or shortcut
```shell
toggle-php-mod xd
```

### Enable/Disable PHP Opcache:
- After ```docker compose exec...``` into container, run
```shell
toggle-php-mod opcache
```
or shortcut
```shell
toggle-php-mod op
```
