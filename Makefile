WORKDIR = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SRCDIR = $(shell dirname $(WORKDIR))
OUTPUT ?= $(WORKDIR)/output
BUILD_DIR ?= /var/workspace/pkg/build
PKG_OUT ?= $(BUILD_DIR)/packages

DOCKER_IMAGE ?= contrail-packaging
DOCKER_TAG ?= master
CONTAINER_NAME ?= $(DOCKER_IMAGE)

MAKE_TARGET ?= package-contrail
MAKE_ARGS ?= /var/workspace/pkg/packages.make

clean:
	@echo "--> Removing build artifacts"
	rm -rf $(OUTPUT)


docker-all: docker-clean docker-build


docker-build:
	@echo "--> Building docker build image"
	docker build --rm -t $(DOCKER_IMAGE):$(DOCKER_TAG) -f \
	"$(WORKDIR)/Dockerfile" $(WORKDIR)


docker-clean:
	@echo "--> Removing docker build image"
	docker rmi $(DOCKER_IMAGE):$(DOCKER_TAG) || true


docker-run:
	@echo "--> Run the build image container"
	mkdir -p $(OUTPUT)
	docker run --name $(CONTAINER_NAME) --rm -v $(OUTPUT):$(PKG_OUT) \
        -v /lib/modules:/lib/modules -v /usr/src:/usr/src \
        $(DOCKER_IMAGE):$(DOCKER_TAG) $(MAKE_ARGS) $(MAKE_TARGET)


.PHONY: clean docker-all docker-build docker-clean docker-run
