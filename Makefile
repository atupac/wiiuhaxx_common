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

ifeq ($(OS),Windows_NT) 
    exe_ext := .exe
else
    exe_ext := 
endif

all: loader locateall
	
loader:
	$(CC) -x assembler-with-cpp -nostartfiles -nostdlib $(DEFINES) -o wiiuhaxx_loader.elf wiiuhaxx_loader.s
	$(OBJCOPY) -O binary wiiuhaxx_loader.elf wiiuhaxx_loader.bin
    
	$(CC) -x assembler-with-cpp -nostartfiles -nostdlib $(DEFINES) -o wiiuhaxx_searcher.elf wiiuhaxx_searcher.s
	$(OBJCOPY) -O binary wiiuhaxx_searcher.elf wiiuhaxx_searcher.bin
	
locateall: locate532 locate550
	
locate532:
	java -jar bin/FileDownloader.jar -titleID 000500101000400A -file '.*coreinit.rpl' -version 11464 -out tmp/532
	make locatespecific FIRMWARE=532 TEXTADDRESS=0x0101c400
	
locate550:
	java -jar bin/FileDownloader.jar -titleID 000500101000400A -file '.*coreinit.rpl' -version 15702 -out tmp/550
	make locatespecific FIRMWARE=550 TEXTADDRESS=0x0101c400
	
locatespecific:	
	./bin/rpl2elf$(exe_ext) $(COREINIT_PATH) $(COREINIT_PATH_ELF) > /dev/null
	sh ./wiiuhaxx_locaterop.sh $(COREINIT_PATH) $(TEXTADDRESS) $(exe_ext) > wiiuhaxx_rop_sysver_$(FIRMWARE).php

clean:
	rm -rf wiiuhaxx_loader.elf wiiuhaxx_loader.bin wiiuhaxx_searcher.elf wiiuhaxx_searcher.bin wiiuhaxx_rop_sysver_* tmp

