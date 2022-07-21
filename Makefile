SUBDIRS := debian ubuntu archlinux fedora

DOCKER := docker

VERSION := 1.0.0

.PHONY: all clean test $(SUBDIRS)

clean: $(SUBDIRS)
	$(MAKE) -C $@ clean

$(SUBDIRS):
	$(MAKE) -C $@ test VERSION="$(VERSION)"

test: $(SUBDIRS)
	$(MAKE) -C $@ all.test

.SECONDEXPANSION:
$(addsuffix .test,$(SUBDIRS)): $$(basename $$@)
	$(MAKE) -C $(basename $@) $(basename $@).test

push: $(SUBDIRS)
	$(MAKE) -C $@ push
