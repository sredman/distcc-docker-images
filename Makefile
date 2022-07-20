BASE_OS    := fedora
OS_VERSION := 33 34 35 36

AUTHOR := konradkleine

IMAGE_NAME := distcc

IMAGE := $(AUTHOR)/$(IMAGE_NAME)

DOCKERFILE := Dockerfile
DOCKER := docker

TAG := $(shell date '+%Y%m%d')-$(shell git rev-parse --short HEAD)
DATE := $(shell date -u +"%Y-%m-%d")
VERSION := 1.0.0

all: $(OS_VERSION)

all.test: $(addsuffix .test,$(OS_VERSION))

$(BASE_OS): all

$(OS_VERSION):
	$(DOCKER) build . -f $(DOCKERFILE) \
	-t $(IMAGE):$(BASE_OS)-$@-$(TAG) \
	-t $(IMAGE):$(BASE_OS)-$@ \
	--build-arg BUILD_DATE=$(DATE) --build-arg DOCKER_IMAGE=$(BASE_OS):$@ \
	--build-arg VERSION=$(VERSION)

push: all

clean:
	$(DOCKER) images --filter='reference=$(IMAGE)' --format='{{.Repository}}:{{.Tag}}' | xargs -r $(DOCKER) rmi -f

.SECONDEXPANSION:
$(addsuffix .test,$(OS_VERSION)): $$(basename $$@)
	export DISTCC_HOSTS="localhost:3632/1 localhost/1"
	docker run -d -p 3632:3632 -p 3633:3633 --name testdistcc-$(basename $@) $(IMAGE):$(BASE_OS)-$(basename $@)-$(TAG) --allow 0.0.0.0/0 --nice 5
	cmake -B build-$(basename $@) -S ./test -DCMAKE_BUILD_TYPE=Release -GNinja \
		-DCMAKE_C_COMPILER_LAUNCHER="ccache;distcc" \
		-DCMAKE_CXX_COMPILER_LAUNCHER="ccache;distcc" \
		&& cmake --build build-$(basename $@)
	docker stop testdistcc-$(basename $@)
	docker rm testdistcc-$(basename $@)
	rm -rf build-$(basename $@)


.PHONY: all push clean