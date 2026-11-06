NAME = PEDROCE
DESCRIPTION = "Pedro Fu CE adaptation"
COMPRESSED = YES
ARCHIVED = YES
CFLAGS = -Wall -Wextra -Oz -std=c11
FAST_RENDER ?= NO
ifeq ($(FAST_RENDER),YES)
LTO = NO
endif
CEDEV_TOOLCHAIN = ../../local-tools/cedev/CEdev
include ../../local-tools/cedev/CEdev/meta/makefile.mk

ifeq ($(FAST_RENDER),YES)
# Keep gameplay/menu code compact while compiling pixel loops for speed.
$(OBJDIR)/src/render.c.s $(OBJDIR)/src/render_cache.c.s: override CFLAGS += -O2
endif
