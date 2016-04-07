WORKDIR = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SRCDIR = $(shell dirname $(WORKDIR))
OUTPUT := $(WORKDIR)/output
PKG_OUT := /var/workspace/pkg/build/packages

DOCKER_IMAGE ?= contrail-packaging

MAKE_TARGET ?= all
MAKE_ARGS ?= /var/workspace/pkg/packages.make

clean:
	@echo "--> Removing build artifacts"
	rm -rf $(WORKDIR)/output


docker-all: docker-clean docker-build


docker-build:
	@echo "--> Building docker build image"
	docker build -t $(DOCKER_IMAGE) -f "$(WORKDIR)/Dockerfile" $(WORKDIR)


docker-clean:
	@echo "--> Removing docker build image"
	docker rmi $(DOCKER_IMAGE) || true


docker-run: clean
	@echo "--> Run the build image container"
	mkdir -p $(WORKDIR)/output
	docker run --rm -v $(OUTPUT):$(PKG_OUT) -v /lib/modules:/lib/modules -v \
	/usr/src:/usr/src -t $(DOCKER_IMAGE) $(MAKE_ARGS) $(MAKE_TARGET)


.PHONY: clean docker-all docker-build docker-clean docker-run
