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

COREINIT_PATH	:= tmp/$(FIRMWARE)/000500101000400A/code/coreinit.rpl
COREINIT_PATH_ELF	:= $(COREINIT_PATH).elf

GX2_PATH	:= tmp/$(FIRMWARE)/000500101000400A/code/gx2.rpl
GX2_PATH_ELF	:= $(GX2_PATH).elf

ifeq ($(OS),Windows_NT) 
    exe_ext := .exe
else
    exe_ext := 
endif

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
	make locatespecific FIRMWARE=532 OS_VERSION=11464 TEXTADDRESS_COREINIT=0x0101c400 TEXTADDRESS_GX2=0x0101c400
    
locate550:
	make locatespecific FIRMWARE=550 OS_VERSION=15702 TEXTADDRESS_COREINIT=0x0101c400 TEXTADDRESS_GX2=0x0114EC40

convertrpl: $(COREINIT_PATH_ELF) $(GX2_PATH_ELF)

$(COREINIT_PATH_ELF): $(COREINIT_PATH)
	./bin/rpl2elf$(exe_ext) $(COREINIT_PATH) $(COREINIT_PATH_ELF) > /dev/null
    
$(GX2_PATH_ELF): $(GX2_PATH)
	./bin/rpl2elf$(exe_ext) $(GX2_PATH) $(GX2_PATH_ELF) > /dev/null

$(COREINIT_PATH):
	java -jar bin/FileDownloader.jar -titleID 000500101000400A -file '.*coreinit.rpl' -version $(OS_VERSION) -out tmp/$(FIRMWARE)
    
$(GX2_PATH):
	java -jar bin/FileDownloader.jar -titleID 000500101000400A -file '.*gx2.rpl' -version $(OS_VERSION) -out tmp/$(FIRMWARE)

locatespecific:	convertrpl
	sh ./wiiuhaxx_locaterop.sh $(COREINIT_PATH) $(GX2_PATH) $(TEXTADDRESS_COREINIT) $(TEXTADDRESS_GX2) $(exe_ext) > wiiuhaxx_rop_sysver_$(FIRMWARE).php

clean:
	rm -rf wiiuhaxx_loader.elf wiiuhaxx_loader.bin wiiuhaxx_searcher.elf wiiuhaxx_searcher.bin wiiuhaxx_rop_sysver_* tmp

