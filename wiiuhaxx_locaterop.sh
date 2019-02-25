coreinitpath=$1
gx2path=$2
coreinit_textaddr=$3
gx2_textaddr=$4
extension=$5

reloc_coreinit=$((0x02000000-$coreinit_textaddr))
reloc_gx2=$((0x02000000-$gx2_textaddr))


getcoreinit_symboladdr()
{
	val=`powerpc-eabi-readelf -a "$PWD/$coreinitpath.elf" | grep "$1" | head -n 1 | cut -d: -f2 | cut "-d " -f2`
	printf "$2 = 0x%X;\n" $((0x$val-$reloc_coreinit))
}

getgx2_symboladdr()
{
	val=`powerpc-eabi-readelf -a "$PWD/$gx2path.elf" | grep "$1" | head -n 1 | cut -d: -f2 | cut "-d " -f2`
	printf "$2 = 0x%X;\n" $((0x$val-$reloc_gx2))
}

echo "<?php" 
./bin/ropgadget_patternfinder$extension $coreinitpath.elf --baseaddr=$coreinit_textaddr "--plainsuffix=;" --script=wiiuhaxx_locaterop_script_ci #?1EFE3500?
./bin/ropgadget_patternfinder$extension $gx2path.elf --baseaddr=$gx2_textaddr "--plainsuffix=;" --script=wiiuhaxx_locaterop_script_gx2 #?1EFE3500?
echo ""
getcoreinit_symboladdr "memcpy" "\$ROP_memcpy"
getcoreinit_symboladdr "DCFlushRange" "\$ROP_DCFlushRange"
getcoreinit_symboladdr "ICInvalidateRange" "\$ROP_ICInvalidateRange"
getcoreinit_symboladdr "OSSwitchSecCodeGenMode" "\$ROP_OSSwitchSecCodeGenMode"
getcoreinit_symboladdr "OSCodegenCopy" "\$ROP_OSCodegenCopy"
getcoreinit_symboladdr "OSGetCodegenVirtAddrRange" "\$ROP_OSGetCodegenVirtAddrRange"
getcoreinit_symboladdr "OSGetCoreId" "\$ROP_OSGetCoreId"
getcoreinit_symboladdr "OSGetCurrentThread" "\$ROP_OSGetCurrentThread"
getcoreinit_symboladdr "OSSetThreadAffinity" "\$ROP_OSSetThreadAffinity"
getcoreinit_symboladdr "OSYieldThread" "\$ROP_OSYieldThread"
getcoreinit_symboladdr "OSFatal" "\$ROP_OSFatal"
getcoreinit_symboladdr "_Exit" "\$ROP_Exit"
getcoreinit_symboladdr "OSScreenFlipBuffersEx" "\$ROP_OSScreenFlipBuffersEx"
getcoreinit_symboladdr "OSScreenClearBufferEx" "\$ROP_OSScreenClearBufferEx"
getcoreinit_symboladdr "OSDynLoad_Acquire" "\$ROP_OSDynLoad_Acquire"
getcoreinit_symboladdr "OSDynLoad_FindExport" "\$ROP_OSDynLoad_FindExport"
getcoreinit_symboladdr "__os_snprintf" "\$ROP_os_snprintf"
getgx2_symboladdr "GX2Init" "\$ROP_GX2Init"
getgx2_symboladdr "GX2Flush" "\$ROP_GX2Flush"
getgx2_symboladdr "GX2DirectCallDisplayList" "\$ROP_GX2DirectCallDisplayList"
echo "?>"