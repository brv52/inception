NAME = inception
COMPOSE_FILE = ./srcs/docker-compose.yml
ENV_FILE = ./srcs/.env
SECRETS_DIR = ./secrets
SECRETS = db_root_password db_password wp_admin_password wp_user_password
LOGIN = nmaltsev
DATA_DIR = /home/$(LOGIN)/data
COMPOSE = docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

all: up

check:
	@test -f $(ENV_FILE) || { echo "Error: $(ENV_FILE) is missing (see DEV_DOC.md)"; exit 1; }
	@for s in $(SECRETS); do \
		test -s $(SECRETS_DIR)/$$s.txt || { echo "Error: $(SECRETS_DIR)/$$s.txt is missing (see DEV_DOC.md)"; exit 1; }; \
	done

up: build
	$(COMPOSE) up -d

build: check
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	$(COMPOSE) build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

status:
	$(COMPOSE) ps
	docker volume ls
	docker network ls

logs:
	$(COMPOSE) logs --tail=100

clean: down
	docker system prune -a --volumes -f

fclean: down
	$(COMPOSE) down -v --rmi all
	docker system prune -a --volumes -f
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all check up build down stop start status logs clean fclean re
