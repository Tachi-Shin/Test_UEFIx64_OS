GNUEFI_DIR = gnu-efi-3.0.18
ARCH = x86_64

CC = gcc
LD = ld
OBJCOPY = objcopy

CFLAGS = -I$(GNUEFI_DIR)/inc \
         -I$(GNUEFI_DIR)/inc/$(ARCH) \
         -I$(GNUEFI_DIR)/inc/protocol \
         -fpic -ffreestanding -fno-stack-protector \
         -fno-stack-check -fshort-wchar -mno-red-zone \
         -maccumulate-outgoing-args -Wall -Wextra

LDFLAGS = -nostdlib -znocombreloc \
          -T $(GNUEFI_DIR)/gnuefi/elf_$(ARCH)_efi.lds \
          -shared -Bsymbolic \
          -L $(GNUEFI_DIR)/$(ARCH)/lib \
          -L $(GNUEFI_DIR)/$(ARCH)/gnuefi

TARGET = BOOTX64.EFI
BUILD_DIR = build
SRC = src/main.c

all: $(BUILD_DIR)/$(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/main.o: $(SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/main.so: $(BUILD_DIR)/main.o
	$(LD) $(LDFLAGS) \
	    $(GNUEFI_DIR)/$(ARCH)/gnuefi/crt0-efi-$(ARCH).o \
	    $< -o $@ -lefi -lgnuefi

$(BUILD_DIR)/$(TARGET): $(BUILD_DIR)/main.so
	$(OBJCOPY) -j .text -j .sdata -j .data -j .rodata -j .dynamic \
    	-j .dynsym -j .rel -j .rela -j .reloc \
    	--target=efi-app-$(ARCH) $< $@

disk: $(BUILD_DIR)/$(TARGET)
	dd if=/dev/zero of=$(BUILD_DIR)/uefi.img bs=1M count=64
	mkfs.vfat -F 32 $(BUILD_DIR)/uefi.img
	mmd -i $(BUILD_DIR)/uefi.img ::/EFI
	mmd -i $(BUILD_DIR)/uefi.img ::/EFI/BOOT
	mcopy -i $(BUILD_DIR)/uefi.img $(BUILD_DIR)/$(TARGET) ::/EFI/BOOT/

run: disk
	qemu-system-x86_64 \
	    -bios /usr/share/ovmf/OVMF.fd \
	    -drive format=raw,file=$(BUILD_DIR)/uefi.img \
	    -m 256M

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all disk run clean
