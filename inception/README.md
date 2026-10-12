*This project has been created as part of the 42 curriculum by nmaltsev.*

# Inception

## Description

Inception builds a small WordPress infrastructure inside a virtual machine with
Docker Compose. NGINX is the only public entry point and provides HTTPS on port
443. WordPress runs with PHP-FPM in its own container, while MariaDB provides
the database in a separate container. The services communicate through the
private `inception-net` bridge network.

Every service has its own custom Dockerfile based on Debian Bookworm, the
penultimate stable Debian release for this environment. WordPress uses PHP 8.2
with PHP-FPM. The two
named volumes persist the WordPress files and MariaDB data under
`/home/nmaltsev/data/` on the host. Credentials are supplied as Docker secrets
from the local `secrets/` directory and are not stored in the image or in
`srcs/.env`.

### Use of Docker and project sources

Docker Compose builds three images from the Dockerfiles in this repository
(nothing is pulled except the `debian:bookworm` base image) and runs one
container per service:

- `Makefile` - entry point: checks `.env`/secrets, creates the data
  directories, builds and starts the stack through Docker Compose.
- `srcs/docker-compose.yml` - services, the `inception-net` network, the two
  named volumes and the Docker secrets.
- `srcs/.env` (not tracked) - domain, login, port, database and user names.
- `secrets/*.txt` (not tracked) - all passwords.
- `srcs/requirements/nginx` - NGINX with a self-signed certificate generated
  at build time, TLSv1.2/TLSv1.3 only, forwarding PHP to `wordpress:9000`.
- `srcs/requirements/wordpress` - PHP-FPM 8.2 and WP-CLI; the entrypoint
  waits for MariaDB, downloads, configures and installs WordPress once, and
  creates the administrator and a second (author) user.
- `srcs/requirements/mariadb` - MariaDB server; the entrypoint initializes the
  data directory, sets the root password and creates the WordPress database
  and user on the first start.

Main design choices: Debian Bookworm (penultimate stable Debian) for every
image; one process per container started with `exec` as PID 1 in the
foreground (no `tail -f`, no infinite loops); `restart: always` so crashed
containers come back; passwords only through Docker secrets; NGINX as the only
published service, on port 443.

### Design comparisons

- **Virtual machines vs Docker:** a VM includes a complete guest kernel and
  operating system, so it uses more resources and starts more slowly. Docker
  containers share the host kernel while isolating processes, filesystems, and
  networks, making this small service stack lighter.
- **Secrets vs environment variables:** ordinary environment variables are
  useful for non-sensitive configuration, but can appear in process or inspect
  output. Docker secrets are mounted as files under `/run/secrets/` and are used
  here for passwords.
- **Docker network vs host network:** the bridge network gives the containers a
  private DNS-enabled network. Host networking would remove that isolation and
  expose container ports directly on the host network.
- **Docker volumes vs bind mounts:** named volumes are managed by Docker and
  have a stable lifecycle. This project uses named volumes with the local
  driver configured to store their data in the required host directories.

## Instructions

Install Docker Engine with the Compose plugin and GNU Make. Add the local domain
to `/etc/hosts` before starting the stack:

```text
127.0.0.1 nmaltsev.42.fr
```

Keep the four password files in `secrets/` and keep that directory untracked.
Check `srcs/.env` for non-sensitive settings. From this directory:

```bash
make
make status
```

Open `https://nmaltsev.42.fr/` and accept the self-signed certificate warning.
The administration panel is at `https://nmaltsev.42.fr/wp-admin/`. Stop the
stack with `make down`; persistent data remains in `/home/nmaltsev/data/`.
Use `make re` only when a complete rebuild and data removal are intended.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Compose file reference](https://docs.docker.com/reference/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB knowledge base](https://mariadb.com/kb/en/)
- [WP-CLI command reference](https://developer.wordpress.org/cli/commands/)
- [OpenSSL documentation](https://www.openssl.org/docs/)

### AI usage

AI was used as a review and documentation aid: to compare the repository with
the subject and evaluation sheet, identify configuration risks, suggest focused
Docker and Compose checks, and help organize the user and developer guides.
All suggested changes were inspected against the local files and should be
validated with the commands in `a.txt`.