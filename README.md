This project has been created as part of the 42 curriculum by nmaltsev.

Inception

Description

Inception is a System Administration project within the 42 curriculum designed to broaden knowledge of containerization, infrastructure orchestration, and service isolation using Docker and Docker Compose.

The primary goal is to establish a secure, multi-container infrastructure hosted entirely inside a virtual machine. Each component runs in a dedicated container built from custom Dockerfiles based on Debian Bullseye (penultimate stable version), orchestrated over a custom internal bridge network without relying on pre-built images from DockerHub or unsafe operational hacks.

Docker Usage and Included Sources

The infrastructure is organized under the srcs/ directory and consists of the following isolated services:

NGINX: Acts as the sole public gateway to the infrastructure. It listens strictly on port 443 using TLSv1.2/TLSv1.3 with a dedicated SSL certificate, routing incoming FastCGI requests directly to WordPress.

WordPress + PHP-FPM: Executes WordPress using PHP-FPM (FastCGI process manager) listening internally on port 9000. It is configured and initialized automatically at startup via WP-CLI without including NGINX inside the container.

MariaDB: Operates the relational database engine on internal port 3306. It initializes the database schema, administrative credentials, and regular users without exposing its port outside the private bridge network.

Architectural Choices & Technical Comparisons

Virtual Machines vs Docker

Virtual Machines (VMs) virtualize physical hardware down to the CPU, memory, and storage controllers. Each VM requires its own complete guest operating system, kernel, and system services, resulting in significant resource overhead, longer boot times, and duplicated kernel scheduling.

Docker Containers utilize operating-system-level virtualization. Containers share the host Linux kernel while using kernel namespaces (pid, net, ipc, mnt, uts) for process isolation and control groups (cgroups) for strict resource limitation. Docker provides instantaneous startup times, minimal memory consumption, and predictable runtime behavior compared to hypervisors.

Secrets vs Environment Variables

Environment Variables are stored in process memory tables and configuration metadata. They can be exposed through command inspections (docker inspect), process trees (/proc/<pid>/environ), or log outputs, making them unsuitable for confidential data.

Docker Secrets mount sensitive information (such as root database passwords and application credentials) as transient in-memory files at /run/secrets/. They are never written to container filesystem layers or exposed in image configuration metadata, drastically reducing the attack surface.

Docker Network vs Host Network

Host Network (network: host) removes network isolation between the container and the underlying host. The container attaches directly to the host's network interfaces, leading to potential port collisions and severe security vulnerabilities if a container is compromised.

Docker Network (docker-network) creates an isolated software bridge. Containers communicate strictly within their own private subnet using Docker's built-in DNS service discovery by container name. External access is strictly controlled, exposing only port 443 on NGINX while database and FastCGI ports remain entirely unreachable from outside networks.

Docker Volumes vs Bind Mounts

Bind Mounts directly map an existing host directory or file into a container. While easy to set up, they tightly couple the container runtime to the host's directory structure, creating permission conflicts and portability issues across different host systems.

Docker Volumes are managed directly by the Docker engine API, abstracting storage drivers and isolating container data storage from the host filesystem lifecycle. In this project, named Docker volumes are configured with local bind options pointing to /home/nmaltsev/data/ on the host to fulfill strict persistence inspection standards while retaining Docker volume management semantics.

Instructions

Prerequisites

Operating System: Linux (Debian or Ubuntu environment recommended).

Installed tools: make, docker (v20.10+), and docker compose (v2+).

Sudo access (required for volume storage creation in /home/nmaltsev/data).

Host Resolution Setup

Map the local IP address to your login domain in /etc/hosts:

sudo sed -i "s/localhost/localhost nmaltsev.42.fr/" /etc/hosts
# Or manually append:
# 127.0.0.1 nmaltsev.42.fr


Configuration & Secrets

Configure non-sensitive environment variables in srcs/.env:

DOMAIN_NAME=nmaltsev.42.fr
LOGIN=nmaltsev
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_TITLE=Inception
WP_ADMIN_USER=site_commander
WP_ADMIN_EMAIL=commander@nmaltsev.42.fr
WP_USER=contributor_user
WP_USER_EMAIL=contributor@nmaltsev.42.fr


Populate credentials in the secrets/ directory (these must remain untracked in Git):

secrets/db_root_password.txt

secrets/db_password.txt

secrets/wp_admin_password.txt

secrets/wp_user_password.txt

Build and Execution Commands

All actions are handled via the root Makefile:

Build and start containers in background:

make


Stop containers without removing volume data:

make down


Inspect current status of containers, volumes, and networks:

make status


Perform complete cleanup of all containers, images, volumes, and data:

make fclean


Rebuild and restart the entire stack from scratch:

make re


Accessing the Services

Public Site: Navigate to https://nmaltsev.42.fr in your browser. Accept the self-signed SSL/TLS warning.

WordPress Administration Panel: Navigate to https://nmaltsev.42.fr/wp-login.php using the administrative credentials configured in srcs/.env and secrets/wp_admin_password.txt.

Resources

References

Docker Documentation

Docker Compose Specification

NGINX Documentation & FastCGI Configuration

MariaDB Server Official Knowledge Base

WP-CLI Command Reference

OpenSSL Certificate Management

Artificial Intelligence Usage

In compliance with 42 curriculum guidelines, Artificial Intelligence (Large Language Model) was utilized as an architectural advisor and code reviewer throughout this project:

Architecture Validation: AI was consulted to review container lifecycle management, verifying that all entrypoint scripts hand execution over to foreground processes via exec "$@" as PID 1, avoiding prohibited commands (such as tail -f, sleep infinity, or infinite loops).

Configuration Design: AI assisted in designing compliant named volume configurations utilizing Docker's local driver with bind options to satisfy the requirement of hosting files under /home/nmaltsev/data/ while maintaining Docker named volume management.

Documentation & Standard Verification: AI was used to cross-reference the repository structure and required documentation sections against version 5.3 of the subject and evaluation criteria to guarantee full compliance.