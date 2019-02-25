#---------------------------------------------------------------------------------
# Clear the implicit built in rules
#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITPPC)),)
$(error "Please set DEVKITPPC in your environment. export DEVKITPPC=<path to>devkitPPC")
endif
ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>devkitPRO")
endif

export PATH			:=	$(DEVKITPPC)/bin:$(PORTLIBS)/bin:$(PATH)

PREFIX	:=	powerpc-eabi-

export AS	:=	$(PREFIX)as
export CC	:=	$(PREFIX)gcc
export CXX	:=	$(PREFIX)g++
export AR	:=	$(PREFIX)ar
export READELF	:=	$(PREFIX)readelf
export OBJCOPY	:=	$(PREFIX)objcopy
DEFINES	:=	

COREINIT_CONFIG_PATH	:= coreinit.yml
GX2_CONFIG_PATH	:= gx2.yml
COREINIT_PATH	:= tmp/$(FIRMWARE)/coreinit.rpl
GX2_PATH	:= tmp/$(FIRMWARE)/gx2.rpl
TARGET_FILENAME := wiiuhaxx_rop_sysver_$(FIRMWARE).php
GADGET_FINDER_PATH := bin/rpxgadgetfinder.jar

all: loader locateall
	
loader: wiiuhaxx_loader.bin wiiuhaxx_searcher.bin

wiiuhaxx_loader.bin: wiiuhaxx_loader.s
	$(CC) -x assembler-with-cpp -nostartfiles -nostdlib $(DEFINES) -o wiiuhaxx_loader.elf wiiuhaxx_loader.s
	$(OBJCOPY) -O binary wiiuhaxx_loader.elf wiiuhaxx_loader.bin

wiiuhaxx_searcher.bin: wiiuhaxx_searcher.s
	$(CC) -x assembler-with-cpp -nostartfiles -nostdlib $(DEFINES) -o wiiuhaxx_searcher.elf wiiuhaxx_searcher.s
	$(OBJCOPY) -O binary wiiuhaxx_searcher.elf wiiuhaxx_searcher.bin
	
locateall: locate532 locate550

locate532:
	make locatespecific FIRMWARE=532 ADDRESS_OFFSET_COREINIT=$$((0x02000000-0x0101c400)) ADDRESS_OFFSET_GX2=$$((0x02000000-0x0114EC40))
    
locate550:
	make locatespecific FIRMWARE=550 ADDRESS_OFFSET_COREINIT=$$((0x02000000-0x0101c400)) ADDRESS_OFFSET_GX2=$$((0x02000000-0x0114EC40))
    
checkrpl: $(COREINIT_PATH) $(GX2_PATH)

$(COREINIT_PATH):
	if [ -a $(COREINIT_PATH) ]; then $(error missing $(COREINIT_PATH) for FW $(FIRMWARE)); fi;
    
$(GX2_PATH):
	if [ -a $(GX2_PATH) ]; then $(error missing $(GX2_PATH) for FW $(FIRMWARE)); fi; 
    
$(CONFIG_FILENAME):
	if [ -a $(CONFIG_FILENAME) ]; then $(error missing $(CONFIG_FILENAME)); fi;
    
$(GADGET_FINDER_PATH): 
	if [ -a $(GADGET_FINDER_PATH) ]; then $(error missing $(GADGET_FINDER_PATH)); fi;

locatespecific:	checkrpl $(GADGET_FINDER_PATH) $(CONFIG_FILENAME)
	@echo "Finding symbols for FW $(FIRMWARE)"
	@echo "<?php" > $(TARGET_FILENAME)
	@java -jar $(GADGET_FINDER_PATH) -cin $(COREINIT_CONFIG_PATH) -bin $(COREINIT_PATH) -aoff -$(ADDRESS_OFFSET_COREINIT) >> $(TARGET_FILENAME)
	@java -jar $(GADGET_FINDER_PATH) -cin $(GX2_CONFIG_PATH) -bin $(GX2_PATH) -aoff -$(ADDRESS_OFFSET_GX2) >> $(TARGET_FILENAME)
	@echo "?>" >> $(TARGET_FILENAME)

clean:
	rm -rf wiiuhaxx_loader.elf wiiuhaxx_loader.bin wiiuhaxx_searcher.elf wiiuhaxx_searcher.bin wiiuhaxx_rop_sysver_*

