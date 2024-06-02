# include .env
# export

# LOCAL_BIN:=$(CURDIR)/bin
# PATH:=$(LOCAL_BIN):$(PATH)

migrate-create:  ### create new migration
	migrate create -ext sql -dir migrations 'migrate_name'
.PHONY: migrate-create

migrate-up: ### migration up
	migrate -path migrations -database 'postgres://mgwdb:mgwdb@localhost:5436/postgres?sslmode=disable' up
.PHONY: migrate-up

migrate-down: ### migration down
	migrate -path migrations -database 'postgres://mgwdb:mgwdb@localhost:5436/postgres?sslmode=disable' down
.PHONY: migrate-down

build-container: ## build container
	docker build -t "golang-backend" .
.PHONY: build-container

# run-container: ## run container
# 	docker run -d -p 8181:8181 --name $(APP_NAME) $(APP_NAME)
# .PHONY: run-container

build-db: ## build db
	docker run --name=mgwdb -e POSTGRES_USER='mgwdb' -e POSTGRES_PASSWORD='mgwdb' -p 5436:5432 -d --rm postgres:14.1-alpine
.PHONY: build-db