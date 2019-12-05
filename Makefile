CI_BUILDER_ABI := 2017.9.0

TAG_PARTS ?= $(subst -, ,$@)
BUILD_ARGS ?= --build-arg CI_BUILDER_ABI=$(CI_BUILDER_ABI) \
			  --build-arg CI_BUILDER_PARENT_TAG=$(firstword $(TAG_PARTS))

EXTRA_TAGS += $(foreach TAG,$(UBUNTU_TAGS),$(TAG)-$(CI_BUILDER_ABI)=$(TAG)) \
			  latest=bionic \
			  latest-$(CI_BUILDER_ABI)=bionic \
			  rolling=bionic \
			  rolling-$(CI_BUILDER_ABI)=bionic

include Makefile.docker

