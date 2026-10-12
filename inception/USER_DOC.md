# User guide

## Services

The stack provides an HTTPS NGINX gateway, a WordPress site using PHP-FPM, and
a MariaDB database. Only NGINX is published to the host, on TCP port 443.

## Start and stop

From the repository root, ensure Docker and the Compose plugin are installed,
then run:

```bash
make
make status
```

Stop containers without deleting persistent data with `make stop` and start
them again with `make start`. `make down` removes the containers (data is
kept); bring them back with `make`. `make fclean` removes images,
containers, volumes, and `/home/nmaltsev/data/`; use it only for a full reset.

## Website and administration

Add `127.0.0.1 nmaltsev.42.fr` to `/etc/hosts`, then visit:

- Website: `https://nmaltsev.42.fr/`
- Administration: `https://nmaltsev.42.fr/wp-admin/`

The certificate is self-signed, so a browser warning is expected on a local
machine. HTTP on port 80 is intentionally not configured. The HTTPS port can be
changed with `NGINX_PORT` in `srcs/.env` followed by `make`.

## Credentials

Non-sensitive settings such as the domain, database name, and WordPress user
names are in `srcs/.env`. Passwords are local Docker secret files:

- `secrets/wp_admin_password.txt` for the WordPress administrator
- `secrets/wp_user_password.txt` for the regular WordPress user
- `secrets/db_password.txt` for the WordPress database user
- `secrets/db_root_password.txt` for the MariaDB root account

Do not commit or publish these files.

## Basic checks

Run `make status` to inspect containers, volumes, and networks. For detailed
diagnostics use:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
docker compose --env-file srcs/.env -f srcs/docker-compose.yml logs --tail=100 nginx wordpress mariadb
curl -kI --resolve nmaltsev.42.fr:443:127.0.0.1 https://nmaltsev.42.fr/
```
