PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj
LIB_NAME = $(PREFIX)/chdb_nif.so
ARCHIVE_NAME = $(PREFIX)/chdb_nif.a

SRC = c_src/chdb_nif.c
CFLAGS = -I"$(ERTS_INCLUDE_DIR)" -I.
LDFLAGS += -L$(PREFIX) -lchdb -Wl,-rpath,$(PREFIX)

ifneq ($(DEBUG),)
    CFLAGS += -g
else
    CFLAGS += -DNDEBUG=1 -O2
endif

KERNEL_NAME := $(shell uname)
ARCH := $(shell uname -m)

OBJ = $(SRC:c_src/%.c=$(BUILD)/%.o)

ifeq ($(KERNEL_NAME), Linux)
    ifeq ($(ARCH), aarch64)
		ARCHIVE = linux-aarch64-libchdb.tar.gz
    else ifeq ($(ARCH), x86_64)
		ARCHIVE = linux-x86_64-libchdb.tar.gz
    endif
	CFLAGS += -fPIC -fvisibility=hidden
	LDFLAGS += -fPIC -shared
endif
ifeq ($(KERNEL_NAME), Darwin)
    ifeq ($(ARCH), arm64)
		ARCHIVE = macos-arm64-libchdb.tar.gz
    else ifeq ($(ARCH), x86_64)
		ARCHIVE = macos-x86_64-libchdb.tar.gz
    endif
	CFLAGS += -fPIC
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
endif
ifeq ($(KERNEL_NAME), $(filter $(KERNEL_NAME),OpenBSD FreeBSD NetBSD))
	CFLAGS += -fPIC
	LDFLAGS += -fPIC -shared
endif

ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)

ifneq ($(STATIC_ERLANG_NIF),)
	CFLAGS += -DSTATIC_ERLANG_NIF=1
endif

DOWNLOAD_URL = https://github.com/chdb-io/chdb/releases/download/v1.3.0/$(ARCHIVE)

$(PREFIX)/libchdb.so: $(PREFIX)/$(ARCHIVE)
	tar -xvzf $(PREFIX)/$(ARCHIVE) -C $(PREFIX)
	touch $(PREFIX)/libchdb.so

$(PREFIX)/$(ARCHIVE):
	mkdir -p $(PREFIX)
	curl -L $(DOWNLOAD_URL) -o $(PREFIX)/$(ARCHIVE)

prepare_lib: $(PREFIX)/libchdb.so

ifeq ($(STATIC_ERLANG_NIF),)
all: prepare_lib $(PREFIX) $(BUILD) $(LIB_NAME)
else
all: prepare_lib $(PREFIX) $(BUILD) $(ARCHIVE_NAME)
endif

$(BUILD)/%.o: c_src/%.c
	@echo " CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(LIB_NAME): $(OBJ)
	@echo " LD $(notdir $@)"
	$(CC) -o $@ $^ $(LDFLAGS)

$(ARCHIVE_NAME): $(OBJ)
	@echo " AR $(notdir $@)"
	$(AR) -rv $@ $^

$(PREFIX) $(BUILD):
	mkdir -p $@

clean:
	$(RM) $(LIB_NAME) $(ARCHIVE_NAME) $(OBJ) $(PREFIX)/$(ARCHIVE) $(PREFIX)/libchdb.so $(PREFIX)/chdb.h

.PHONY: all clean prepare_lib

# Don't echo commands unless the caller exports "V=1"
${V}.SILENT:
