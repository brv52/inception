NAME = inception
COMPOSE_FILE = ./srcs/docker-compose.yml
LOGIN = <login>
DATA_DIR = /home/$(LOGIN)/data

all: up

up: build
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) up -d

build:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build

down:
	docker compose -f $(COMPOSE_FILE) down

stop:
	docker compose -f $(COMPOSE_FILE) stop

start:
	docker compose -f $(COMPOSE_FILE) start

status:
	docker compose -f $(COMPOSE_FILE) ps
	docker volume ls
	docker network ls

clean: down
	docker system prune -a --volumes -f

fclean: down
	docker compose -f $(COMPOSE_FILE) down -v --rmi all
	docker system prune -a --volumes -f
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all up build down stop start status clean fclean re