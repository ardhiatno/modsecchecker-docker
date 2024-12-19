.PHONY: clean build run stop inspect

IMAGE_NAME = modsecchecker:latest
CONTAINER_NAME = modsecchecker

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run --rm --name $(CONTAINER_NAME) $(IMAGE_NAME)