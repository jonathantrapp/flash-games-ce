NAME = SCOUTCE
DESCRIPTION = "Scouts vs Aliens CE"
COMPRESSED = YES
ARCHIVED = YES
HAS_PRINTF = NO
CFLAGS = -Wall -Wextra -Oz -std=c11
EXTRA_LDFLAGS += -T ram_guard.ld
CEDEV_MAKEFILE ?= ../../local-tools/cedev/CEdev/meta/makefile.mk
CEDEV_TOOLCHAIN ?= ../../local-tools/cedev/CEdev
include $(CEDEV_MAKEFILE)
$(BINDIR)/$(TARGETOBJ): ram_guard.ld
