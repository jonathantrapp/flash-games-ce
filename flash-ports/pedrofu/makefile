NAME = PEDROCE
DESCRIPTION = "Pedro Fu CE adaptation"
COMPRESSED = YES
ARCHIVED = YES
HAS_PRINTF = NO
CFLAGS = -Wall -Wextra -Oz -std=c11
EXTRA_LDFLAGS += -T ram_guard.ld
FAST_RENDER ?= NO
HWDIAG ?= NO
SKY_FLASH ?= YES
ifeq ($(SKY_FLASH),YES)
CFLAGS += -DSKY_FLASH_ROWS
endif
ifeq ($(HWDIAG),YES)
CFLAGS += -DPEDRO_HWDIAG
NAME = PEDRODG
DESCRIPTION = "Pedro CE hardware diagnostic"
endif
ifeq ($(FAST_RENDER),YES)
LTO = NO
endif
CEDEV_TOOLCHAIN = ../../local-tools/cedev/CEdev
include ../../local-tools/cedev/CEdev/meta/makefile.mk
$(BINDIR)/$(TARGETOBJ): ram_guard.ld

ifeq ($(FAST_RENDER),YES)
# Keep gameplay/menu code compact while compiling pixel loops for speed.
$(OBJDIR)/src/render.c.s $(OBJDIR)/src/render_cache.c.s: override CFLAGS += -O2
endif
