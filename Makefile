KERNEL_NAME := $(shell uname -s)
PRIV = $(MIX_APP_PATH)/priv
BUILD = $(MIX_APP_PATH)/obj
LIB = $(PRIV)/chdb_nif.so

CHDB_NIF_CFLAGS ?=
CHDB_NIF_LDFLAGS ?=

CFLAGS = -Ic_src -I"$(ERTS_INCLUDE_DIR)" -fPIC -pedantic -Wall -Wextra -Werror \
	-Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Wno-unused-but-set-variable \
	-Wno-unused-value -Wno-unused-label -Wno-unused-result -Wno-unused-local-typedefs

LDFLAGS = -lchdb

ifeq ($(MIX_ENV), dev)
	CFLAGS += -g
else ifeq ($(MIX_ENV), test)
	CFLAGS += -g
else
	CFLAGS += -O3 -DNDEBUG
endif

ifeq ($(KERNEL_NAME), Darwin)
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
else ifeq ($(KERNEL_NAME), Linux)
	LDFLAGS += -shared
else
	$(error Unsupported operating system $(KERNEL_NAME))
endif

all: $(PRIV) $(BUILD) $(LIB)

$(LIB): $(BUILD)/chdb_nif.o
	@echo " LD $(notdir $@)"
	$(CC) $(BUILD)/chdb_nif.o $(LDFLAGS) $(CHDB_NIF_LDFLAGS) -o $@

$(PRIV) $(BUILD):
	mkdir -p $@

$(BUILD)/chdb_nif.o: c_src/chdb_nif.c
	@echo " CC $(notdir $@)"
	$(CC) $(CFLAGS) $(CHDB_NIF_CFLAGS) -c c_src/chdb_nif.c -o $@

clean:
	$(RM) $(LIB) $(BUILD)/chdb_nif.o

.PHONY: all clean

# Don't echo commands unless the caller exports "V=1"
${V}.SILENT:
