# Developer guide

## Prerequisites

Use a Linux virtual machine with Docker Engine, the Docker Compose plugin, GNU
Make, `sudo`, and permission to create `/home/nmaltsev/data/`. Add
`127.0.0.1 nmaltsev.42.fr` to `/etc/hosts` for local browser and curl tests.
Make sure nothing else on the VM listens on port 443 (or on 80, e.g. a host
Apache, which would make the "no HTTP" check confusing).

## Configuration

`srcs/.env` and `secrets/` are ignored by git, so after a fresh clone create
them by hand. Non-sensitive values go in `srcs/.env`:

```text
DOMAIN_NAME=nmaltsev.42.fr
LOGIN=nmaltsev
NGINX_PORT=443

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

WP_TITLE=Inception Infrastructure
WP_ADMIN_USER=root
WP_ADMIN_EMAIL=root@nmaltsev.42.fr
WP_USER=user
WP_USER_EMAIL=user@nmaltsev.42.fr
```

Passwords go in four one-line files in `secrets/`. Compose mounts them as
Docker secrets under `/run/secrets/` inside the containers:

```bash
mkdir -p secrets
printf '%s' 'choose-a-password' > secrets/db_root_password.txt
printf '%s' 'choose-a-password' > secrets/db_password.txt
printf '%s' 'choose-a-password' > secrets/wp_admin_password.txt
printf '%s' 'choose-a-password' > secrets/wp_user_password.txt
```

`make` refuses to build if any of these files is missing. The Makefile
explicitly passes `srcs/.env` to Compose, so commands are reproducible from the
repository root. `NGINX_PORT` is the HTTPS port published on the host; the
WordPress entrypoint updates the site URL to match it on every start.

## Build and lifecycle

```bash
make              # check config, create host directories, build, start
make build        # build custom images only
make status       # show services, volumes, and networks
make logs         # show the last log lines of every service
make stop         # stop containers, retaining them and their data
make start        # start existing stopped containers
make down         # remove containers and the Compose network
make fclean       # remove containers, images, volumes and host data (sudo)
make re           # full cleanup followed by a fresh build and start
```

Equivalent direct Compose commands are:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml build
docker compose --env-file srcs/.env -f srcs/docker-compose.yml up -d
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
docker compose --env-file srcs/.env -f srcs/docker-compose.yml logs -f wordpress
docker compose --env-file srcs/.env -f srcs/docker-compose.yml down
```

Open a shell or a database client inside a running container:

```bash
docker exec -it wordpress bash
docker exec -it mariadb mariadb -u wpuser -p wordpress
```

## Project structure

`srcs/docker-compose.yml` defines NGINX, WordPress/PHP-FPM, MariaDB, the
bridge network, named volumes, and secrets. Each service directory contains a
custom Dockerfile and its configuration. Entrypoint scripts initialize the
database or WordPress and then use `exec` to run the foreground service as
PID 1. The images use Debian Bookworm; WordPress uses the matching PHP 8.2
FPM packages available in that release.

## Persistence

The named `mariadb_data` volume stores the database in
`/home/nmaltsev/data/mariadb/`. The named `wordpress_data` volume stores the
site in `/home/nmaltsev/data/wordpress/`. Both are named volumes using the
`local` driver with `driver_opts`, so Docker manages them while the data lives
in the required host directory. Verify this with:

```bash
docker volume ls
docker volume inspect mariadb_data wordpress_data
```

Never delete these directories or run `make fclean` when testing persistence.
After a VM reboot the containers are restarted by Docker (`restart: always`);
otherwise run `make`. Then verify the site, login, and previously created
content remain available.
