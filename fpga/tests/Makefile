# Simple Makefile to build a bare-metal "hello_world.elf" for CVA6 FPGA bring-up.
# Usage (from repo root):
#   RISCV=/opt/ariane/riscv CROSS=riscv-none-elf make -C fpga/tests hello_world

RISCV ?= /opt/ariane/riscv
# Toolchain prefix: use riscv-none-elf or riscv64-unknown-elf, etc.
CROSS ?= riscv-none-elf

CC      := $(RISCV)/bin/$(CROSS)-gcc
OBJDUMP := $(RISCV)/bin/$(CROSS)-objdump
READELF := $(RISCV)/bin/$(CROSS)-readelf

OUT_DIR := out

# Paths are relative to fpga/tests/
HELLO       := ../../verif/tests/custom/hello_world/hello_world.c
HELLO_UART  := hello_world_uart/hello_world_uart.c
CRT         := ../../verif/tests/custom/common/crt.S
SYSCALLS    := ../../verif/tests/custom/common/syscalls.c
LINKER      := ../../config/gen_from_riscv_config/linker/link.ld

# For CVA6 64-bit SoC (cv64a6_imafdc_sv39)
CFLAGS := -static -mcmodel=medany -fvisibility=hidden \
          -nostdlib -nostartfiles -g \
          -I../../verif/tests/custom/env -I../../verif/tests/custom/common \
          -march=rv64imafdc -mabi=lp64d

LDFLAGS := -T $(LINKER) -lgcc

ELF      := $(OUT_DIR)/hello_world.elf
ELF_UART := $(OUT_DIR)/hello_world_uart.elf

.PHONY: all hello_world hello_world_uart dump clean

all: hello_world

hello_world: $(ELF)

hello_world_uart: $(ELF_UART)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(ELF): $(OUT_DIR) $(HELLO) $(CRT) $(SYSCALLS) $(LINKER)
	$(CC) $(CFLAGS) $(HELLO) $(SYSCALLS) $(CRT) $(LDFLAGS) -o $@

$(ELF_UART): $(OUT_DIR) $(HELLO_UART) $(CRT) $(LINKER)
	$(CC) $(CFLAGS) $(HELLO_UART) $(CRT) $(LDFLAGS) -o $@

dump: $(ELF)
	$(OBJDUMP) -d $(ELF) | head -n 80
	$(READELF) -l $(ELF) | grep LOAD || true

clean:
	rm -rf $(OUT_DIR)
