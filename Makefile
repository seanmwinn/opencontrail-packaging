WORKDIR = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SRCDIR = $(shell dirname $(WORKDIR))
OUTPUT := $(WORKDIR)/output
PKG_OUT := /var/workspace/pkg/build/packages

DOCKER_IMAGE ?= contrail-packaging

TARGET ?= all
MAKEFILE ?= /var/workspace/pkg/packages.make


docker-all: docker-clean docker-run


docker-build:
	@echo "--> Building docker build image"
	#Do some stuff to add a github ssh key and host key
	docker build -t $(DOCKER_IMAGE) -f "$(WORKDIR)/Dockerfile" $(WORKDIR)


docker-clean:
	@echo "--> Removing docker build image"
	docker rmi $(DOCKER_IMAGE) || true



docker-run: docker-build
	@echo "--> Run the build image container"
	docker run --rm -v $(OUTPUT):$(PKG_OUT) -v /lib/modules:/lib/modules -v \
	/usr/src:/usr/src -t $(DOCKER_IMAGE) $(MAKEFILE) $(TARGET)

.PHONY: docker-all docker-build docker-clean docker-run
