#!/bin/bash
#
# Script (ssdtPRGen.sh) to create ssdt-pr.dsl for Apple Power Management Support.
#
# Version 0.9 - Copyright (c) 2012 by RevoGirl
# Version 9.8 - Copyright (c) 2014 by Pike <PikeRAlpha@yahoo.com>
#
# Updates:
#			- Added support for Ivy Bridge (Pike, January 2013)
#			- Filename error fixed (Pike, January 2013)
#			- Namespace error fixed in _printScopeStart (Pike, January 2013)
#			- Model and board-id checks added (Pike, January 2013)
#			- SMBIOS cpu-type check added (Pike, January 2013)
#			- Copy/paste error fixed (Pike, January 2013)
#			- Method ACST added to CPU scopes for IB CPUPM (Pike, January 2013)
#			- Method ACST corrected for latest version of iasl (Dave, January 2013)
#			- Changed path/filename to ~/Desktop/SSDT_PR.dsl (Dave, January 2013)
#			- P-States are now one-liners instead of blocks (Pike, January 2013)
#			- Support for flexible ProcessorNames added (Pike, Februari 2013)
#			- Better feedback and Debug() injection added (Pike, Februari 2013)
#			- Automatic processor type detection (Pike, Februari 2013)
#			- TDP and processor type are now optional arguments (Pike, Februari 2013)
#			- system-type check (used by X86PlatformPlugin) added (Pike, Februari 2013)
#			- ACST injection for all logical processors (Pike, Februari 2013)
#			- Introducing a stand-alone version of method _DSM (Pike, Februari 2013)
#			- Fix incorrect turbo range (Pike, Februari 2013)
#			- Restore IFS before return (Pike, Februari 2013)
#			- Better/more complete feedback added (Jeroen, Februari 2013)
#			- Processor data for desktop/mobile and server CPU's added (Jeroen, Februari 2013)
#			- Improved power calculation, matching Apple's new algorithm (Pike, Februari 2013)
#			- Fix iMac13,N latency and power values for C3 (Jeroen/Pike, Februari 2013)
#			- IASL failed to launch when path included spaces (Pike, Februari 2013)
#			- Typo in cpu-type check fixed (Jeroen, Februari 2013)
#			- Error in CPU data (i5-3317U) fixed (Pike, Februari 2013)
#			- Setting added for the target path/filename (Jeroen, Februari 2013)
#			- Initial implementation of auto-copy (Jeroen, Februari 2013)
#			- Additional checks added for cpu data/turbo modes (Jeroen, Februari 2013)
#			- Undo filename change done by Jeroen (Pike, Februari 2013)
#			- Improved/faster search algorithm to locate iasl (Jeroen, Februari 2013)
#			- Bug fix, automatic revision update and better feedback (Pike, Februari 2013)
#			- Turned auto copy on (Jeroen, Februari 2013)
#			- Download IASL if it isn't there where we expect it (Pike, Februari 2013)
#			- A sweet dreams update for Pike who wants better feedback (Jeroen, Februari 2013)
#			- First set of Haswell processors added (Pike/Jeroen, Februari 2013)
#			- More rigid testing for user errors (Pike/Jeroen, Februari 2013)
#			- Getting ready for new Haswell setups (Pike/Jeroen, Februari 2013)
#			- Typo and ssdtPRGen.command breakage fixed (Jeroen, Februari 2013)
#			- Target folder check added for _findIASL (Pike, Februari 2013)
#			- Set $baseFreqyency to $lfm when the latter isn't zero (Pike, Februari 2013)
#			- Check PlatformSupport.plist for supported model/board-id added (Jeroen, Februari 2013)
#			- New/expanded Sandy Bridge CPU lists, thanks to Francis (Jeroen, Februari 2013)
#			- More preparations for the official Haswell launch (Pike, Februari 2013)
#			- Fix for home directory with space characters (Pike, Februari 2013)
#			- Sandy Bridge CPU lists rearranged/extended, thanks to 'stinga11' (Jeroen, Februari 2013)
#			- Now supporting up to 16 logical cores (Jeroen, Februari 2013)
#			- Improved argument checking, now supporting a fourth argument (Jeroen/Pike, Februari 2013)
#			- Suppress override output when possible (Jeroen, Februari 2013)
#			- Get processor label from ioreg (Jeroen/Pike, Februari 2013)
#			- Create /usr/local/bin when missing (Jeroen, Februari 2013)
#			- Changed warnings to make them pop out in the on-screen log (Pike, March 2013)
#			- Now using the ACPI processor names of the running system (Pike, March 2013)
#			- Now supporting up to 256/0xff logical processors (Pike, March 2013)
#			- Command line argument for processor labels added (Pike, March 2013)
#			- Bug fix, overriding the cpu type displayed the wrong name (Jeroen, March 2013)
#			- Automatic detection of CPU scopes added (Pike, March 2013)
#			- Show warnings for Sandy Bridge systems as well (Jeroen, March 2013)
#			- New Intel Haswell processors added (Jeroen, April 2013)
#			- Improved Processor declaration detection (Jeroen/Pike, April 2013)
#			- New path for Clover revision 1277 (Jeroen, April 2013)
#			- Haswell's minimum core frequency is 800 MHz (Jeroen, April 2013)
#			- CPU signature output added (Jeroen/Pike, April 2013)
#			- Updating to v6.4 after Jeroen's accidental RM of my local RevoBoot directory (Pike, May 2013)
#			- Updating to v6.5 with bugs fixes and EFI partition checking for Clover compatibility (Pike, May 2013)
#			- Output of Clover ACPI directory detection fixed (Pike, June 2013)
#			- Haswell CPUs added (Jeroen, June 2013)
#			- board-id's for new MacBookAir6,[1/2] added (Pike, June 2013)
#			- board-id's for new iMac14,[1/2/3] added (Pike, October 2013)
#			- board-id's for new MacBookPro11,[1/2/3] added (Pike, October 2013)
#			- Cleanups and board-id for new MacPro6,1 added (Pike, October 2013)
#			– Frequency error in i7-4700MQ data fixed, thanks to RehabMan (Pike, November 2013)
#			- Intel i5-4200M added (Pike, December 2013)
#			- LFM fixed in the Intel i7-3930K data (Pike, December 2013)
#			- Intel E5-2695 V2 added (Pike, December 2013)
#			- Intel i3-3250 added (Pike, December 2013)
#			- Sed RegEx error fixed in _getCPUtype (Pike, January 2014)
#			- Fixed a typo 's/i7-2640M/i7-2674M/' (Pike, January 2014)
#			- Fixed a typo 's/gHaswellCPUList/gServerHaswellCPUList/' (Pike, January 2014)
#			- Intel E5-26nn v2 Xeon Processors added (Pike, January 2014)
#			- Show the CPU brandstring at all times (Pike, January 2014)
#			- Fixed cpu-type suggestion for MacPro6,1 (Pike, January 2014)
#			- Intel i7-4771 added (Pike, January 2014)
#			- A couple Intel Haswell/Crystal Well processor models added (Pike, January 2014)
#			- Moved a couple of Ivy Bridge desktop model processors to the right spot (Pike, January 2014)
#			- Experimental code added for Gringo Vermelho (Pike, January 2014)
#			- Fixed a typo so that checking gIvyWorkAround really works (Pike, January 2014)
#			- Added extra OS checks (as a test) to filter out possibly unwanted LFM P-States (Pike, January 2014)
#			- Let gIvyWorkAround control the additional LFM P-States (Pike, January 2014)
#			- Fixed a typo in processor data (i7-4960K should be i7-4960X) (Pike, January 2014)
#			- Missing Haswell i3 processor data added (Pike, Februari 2014)
#			- TDP can now also be a floating-point number (Pike, Februari 2014)
#			- New Brodwell processor preps (Pike, Februari 2014)
#			- Reformatted code layout (Pike, Februari 2014)
#			- Changed a bunch of misnamed (local) variables (Pike, Februari 2014)
#			- Fixed a couple of let/local mixups (Pike, Februari 2014)
#			- Destination path/filename no longer defauls to RevoBoot (Pike, Februari 2014)
#			- Support for RevoEFI added (Pike, Februari 2014)
#			- Changed SSDT.dsl open behaviour/ask for confirmation (Pike, Februari 2014)
#			- Additional processor scope check to get \_SB_ (Pike, Februari 2014)
#			- Set gIvyWorkAround=0 when XCPM is being used (Pike, Februari 2014)
#
# Contributors:
#			- Thanks to Dave, toleda and Francis for their help (bug fixes and other improvements).
#			- Thanks to 'stinga11' for Sandy Bridge (E5) data and processor list errors.
#			- Many thanks to Jeroen († 2013) for the CPU data, cleanups, renaming stuff and other improvements.
#			- Thanks to 'philip_petev' for his help with Snow Leopard/egrep incompatibility.
#			- Thanks to 'RehabMan' for his help with Snow Leopard/egrep incompatibility.
#			- Thanks to 'BigDonkey' for his help with LFM (800 MHz) for Sandy Bridge mobility models.
#			- Thanks to 'rtcl777' on Github issues for the tip about a typo in the iMac12 board-id's.
#			- Thanks to 'xpamamadeus' for the Clover boot.log tip.
#			- Thanks to 'rileyfreeman' for the Intel i7-3930K LFM value.
#			- Thanks to 'Klonkrieger2' aka Mark for the tip about the sed RegEx error in _getCPUtype.
#			- Thanks to 'dhnguyen92' on Github issues for the tip about a typo in the i7-2640M model data.
#			- Thanks to 'fabiosun' on Github issues for the tip about a typo in the cpu-type check.
#			- Thanks to 'Hackmodford ' on Github issues for testing/confirming that PM in Mavericks was changed.
#
# Bugs:
#			- Bug reports can be filed at https://github.com/Piker-Alpha/RevoBoot/issues
#			  Please provide clear steps to reproduce the bug, the output of the
#			  script and the resulting SSDT.dsl Thank you!
#
# Usage (v1.0 - v4.9):
#
#           - ./ssdtPRGen.sh [max turbo frequency] [TDP] [CPU type]
#
#           - ./ssdtPRGen.sh
#           - ./ssdtPRGen.sh 3600
#           - ./ssdtPRGen.sh 3600 70
#           - ./ssdtPRGen.sh 3600 70 1
#
# Usage (v5.0 and greater):
#
#           - ./ssdtPRGen.sh [processor number] [max turbo frequency] [TDP] [CPU type]
#
#           - ./ssdtPRGen.sh E5-1650
#
#           - ./ssdtPRGen.sh 'E3-1220 v2'
#           - ./ssdtPRGen.sh 'E3-1220 v2' 3600
#           - ./ssdtPRGen.sh 'E3-1220 v2' 3600 70
#           - ./ssdtPRGen.sh 'E3-1220 v2' 3600 70 1
#
# Usage (v5.5 and greater):
#
#           - ./ssdtPRGen.sh [processor number] [max turbo frequency] [TDP] [CPU type] [ACPI Processor Name]
#
#           - ./ssdtPRGen.sh E5-1650
#
#           - ./ssdtPRGen.sh 'E3-1220 v2'
#           - ./ssdtPRGen.sh 'E3-1220 v2' 3600
#           - ./ssdtPRGen.sh 'E3-1220 v2' 3600 70
#           - ./ssdtPRGen.sh 'E3-1220 v2' 3600 70 1
#           - ./ssdtPRGen.sh 'E3-1220 v2' 3600 70 1 CPU
#

# set -x # Used for tracing errors (can be used anywhere in the script).

#================================= GLOBAL VARS ==================================

#
# Script version info.
#
gScriptVersion=9.8

#
# Initial xcpm mode (default value is 0).
#
let gXcpm=0

#
# Change this to 1 when your CPU is stuck in Low Frequency Mode!
#
# 1 - Injects one extra Turbo P-State at he top with max-Turbo frequency + 1 MHz.
# 2 - Injects N extra Turbo P-States at the bottom.
# 3 - Injects both of them.
#
# Note: Will be changed to 0 in _checkForXCPM() when XCPM mode is being used.
#
let gIvyWorkAround=3

#
# Ask for confirmation before copying the new SSDT to the target location.
#
let gAutoCopy=1

#
# This is the target location that ssdt.aml will be copied to.
#
# Note: Do no change this - will be updated automatically for Clover/RevoBoot!
#
gDestinationPath="/Extra/"

#
# This is the filename used for the copy process
#
gDestinationFile="ssdt.aml"

#
# A value of 1 will make this script call iasl (compiles ssdt_pr.dsl)
#
# Note: Will be set to 0 when we failed to locate a copy of iasl!
#
let gCallIasl=1

#
# Open generated SSDT on request (default value is 2).
#
# 0 = don't open the generated SSDT.
# 1 = open the generated SSDT in the editor of your choice.
# 2 = ask for confirmation before opening the generated SSDT in the editor of your choice.
#
let gCallOpen=2

# 0 = no debug injection/debug statements executed.
# 1 = inject debug data.
# 3 = inject debug data and execute _debugPrint statements.
#
let gDebug=1

#
# Lowest possible idle frequency (user configurable). Also known as Low Frequency Mode.
#
let gBaseFrequency=1600

#
# This is the default processor label (verified by _setProcessorLabel).
#
gProcLabel="CPU"

#
# The Processor scope will be initialised by _getProcessorScope).
#
gScope=""

#
# Legacy RevoBoot status (default value is 0).
#
let gIsLegacyRevoBoot=0

#
# Other global variables.
#

gRevision='0x0000'${gScriptVersion:0:1}${gScriptVersion:2:1}'00'

#
# Path and filename setup.
#

gPath=~/Desktop
gSsdtID="ssdt"
gSsdtPR="${gPath}/${gSsdtID}.dsl"

let gDesktopCPU=1
let gMobileCPU=2
let gServerCPU=3

let gSystemType=0

let gACST_CPU0=13
let gACST_CPU1=7

gMacModelIdentifier=""

let BROADWELL=16
let HASWELL=8
let IVY_BRIDGE=4
let SANDY_BRIDGE=2

let gBridgeType=0

let gTypeCPU=0
gProcessorData="Unknown CPU"
gProcessorNumber=""
gBusFrequency=100
#
# Set to 1 after _setDestinationPath mounted the EFI partition.
#
let gUnmountEFIPartition=0

gProductName=$(sw_vers -productName)
gProductVersion="$(sw_vers -productVersion)"
gBuildVersion=$(sw_vers -buildVersion)
let gOSVersion=$(echo $gProductVersion | tr -d '.')

#
# Maximum Turbo Clock Speed (user configurable)
#
let gMaxOCFrequency=6300

let MAX_TURBO_FREQUENCY_ERROR=2
let MAX_TDP_ERROR=3
let TARGET_CPU_ERROR=4
let PROCESSOR_NUMBER_ERROR=5
let PROCESSOR_LABEL_LENGTH_ERROR=6
let PROCESSOR_NAMES_ERROR=7
let PROCESSOR_DECLARATION_ERROR=8

#
# First OS version number that no longer requires extra Low Frequency Mode P-States.
#
# Note: For future use (when we figured out what we need).
#
let LFM_REQUIRED_OS=1091

#
# Processor Number, Max TDP, Low Frequency Mode, Clock Speed, Max Turbo Frequency, Cores, Threads
#

gServerSandyBridgeCPUList=(
# E5-2600 Xeon Processor Series
E5-2687W,150,0,3100,3800,8,16
# E5-1600 Xeon Processor Series
E5-1660,130,0,3300,3900,6,12
E5-1650,130,0,3200,3800,6,12
E5-1620,130,0,3600,3800,4,8
# E3-1200 Xeon Processor Series
E3-1290,95,0,3600,4000,4,8
E3-1280,95,0,3500,3900,4,8
E3-1275,95,0,3400,3800,4,8
E3-1270,80,0,3400,3800,4,8
E3-1260L,45,0,2400,3300,4,8
E3-1245,95,0,3300,3700,4,8
E3-1240,80,0,3300,3700,4,8
E3-1235,95,0,3200,3600,4,8
E3-1230,80,0,3200,3600,4,8
E3-1225,95,0,3100,3400,4,4
E3-1220L,20,0,2200,3400,2,4
E3-1220,80,0,3100,3400,4,4
)

gDesktopSandyBridgeCPUList=(
i7-35355,120,1600,2666,2666,4,4
# i7 Desktop Extreme Series
i7-3970X,150,1200,3500,4000,6,12
i7-3960X,130,1200,3300,3900,6,12
i7-3930K,130,1200,3200,3800,6,12
i7-3820,130,1200,3600,3800,4,8
# i7 Desktop series
i7-2600S,65,1600,2800,3800,4,8
i7-2600,95,1600,3400,3800,4,8
i7-2600K,95,1600,3400,3800,4,8
i7-2700K,95,1600,3500,3900,4,8
# i5 Desktop Series
i5-2300,95,1600,2800,3100,4,4
i5-2310,95,1600,2900,3200,4,4
i5-2320,95,1600,3000,3300,4,4
i5-2380P,95,1600,3100,3400,4,4
i5-2390T,35,1600,2700,3500,2,4
i5-2400S,65,1600,2500,3300,4,4
i5-2405S,65,1600,2500,3300,4,4
i5-2400,95,1600,3100,3400,4,4
i5-2450P,95,1600,3200,3500,4,4
i5-2500T,45,1600,2300,3300,4,4
i5-2500S,65,1600,2700,3700,4,4
i5-2500,95,1600,3300,3700,4,4
i5-2500K,95,1600,3300,3700,4,4
i5-2550K,95,1600,3400,3800,4,4
# i3 1200 Desktop Series
i3-2130,65,1600,3400,0,2,4
i3-2125,65,1600,3300,0,2,4
i3-2120T,35,1600,2600,0,2,4
i3-2120,65,1600,3300,0,2,4
i3-2115C,25,1600,2000,0,2,4
i3-2105,65,1600,3100,0,2,4
i3-2102,65,1600,3100,0,2,4
i3-2100T,35,1600,2500,0,2,4
i3-2100,65,1600,3100,0,2,4
)

gMobileSandyBridgeCPUList=(
# i7 Mobile Extreme Series
i7-2960XM,55,800,2700,3700,4,8
i7-2920XM,55,800,2500,3500,4,8
# i7 Mobile Series
i7-2860QM,45,800,2500,3600,4,8
i7-2820QM,45,800,2300,3400,4,8
i7-2760QM,45,800,2400,3500,4,8
i7-2720QM,45,800,2200,3300,4,8
i7-2715QE,45,800,2100,3000,4,8
i7-2710QE,45,800,2100,3000,4,8
i7-2677M,17,800,1800,2900,2,4
i7-2675QM,45,800,2200,3100,4,8
i7-2670QM,45,800,2200,3100,4,8
i7-2675M,17,800,1600,2700,2,4
i7-2655LE,25,800,2200,2900,2,4
i7-2649M,25,800,2300,3200,2,4
i7-2640M,35,800,2800,3500,2,4
i7-2637M,17,800,1700,2800,2,4
i7-2635QM,45,800,2000,2900,4,8
i7-2630QM,45,800,2000,2900,4,8
i7-2629M,25,800,2100,3000,2,4
i7-2620M,35,800,2700,3400,2,4
i7-2617M,17,800,1500,2600,2,4
i7-2610UE,17,800,1500,2400,2,4
# i5 Mobile Series
i5-2467M,17,800,1600,2300,2,4
i5-2450M,35,800,2300,3100,2,4
i5-2435M,35,800,2400,3000,2,4
i5-2430M,35,800,2400,3000,2,4
i5-2410M,35,800,2300,2900,2,4
i5-2557M,17,800,1700,2700,2,4
i5-2540M,35,800,2600,3300,2,4
i5-2537M,17,800,1400,2300,2,4
i5-2520M,35,800,2500,3200,2,4
i5-2515E,35,800,2500,3100,2,4
i5-2510E,35,800,2500,3100,2,4
# i3 2300 Mobile Series
i3-2377M,17,800,1500,0,2,4
i3-2370M,35,800,2400,0,2,4
i3-2367M,17,800,1400,0,2,4
i3-2365M,17,800,1400,0,2,4
i3-2357M,17,800,1300,0,2,4
i3-2350M,35,800,2300,0,2,4
i3-2348M,35,800,2300,0,2,4
i3-2340UE,17,800,1300,0,2,4
i3-2330M,35,800,2200,0,2,4
i3-2330E,35,800,2200,0,2,4
i3-2328M,35,800,2200,0,2,4
i3-2312M,35,800,2100,0,2,4
i3-2310M,35,800,2100,0,2,4
i3-2310E,35,800,2100,0,2,4
)


#
# Processor Number, Max TDP, Low Frequency Mode, Clock Speed, Max Turbo Frequency, Cores, Threads
#

gServerIvyBridgeCPUList=(
# E3-1200 Xeon Processor Series
'E3-1290 v2',87,1200,3700,4100,4,8
'E3-1280 v2',69,1200,3600,4000,4,8
'E3-1275 v2',77,1200,3500,3900,4,8
'E3-1270 v2',69,1200,3500,3900,4,8
'E3-1265L v2',45,1200,2500,3500,4,8
'E3-1245 v2',77,1200,3400,3800,4,8
'E3-1240 v2',69,1200,3400,3800,4,8
'E3-1230 v2',69,1200,3300,3700,4,8
'E3-1225 v2',77,1200,3200,3600,4,4
'E3-1220 v2',69,1200,3100,3500,4,4
'E3-1220L v2',17,1200,2300,3500,2,4
# E5-2600 Xeon Processor Series
'E5-2687W v2',150,1200,3400,4000,8,16
'E5-2658 v2 ',95,1200,2400,3000,10,20
'E5-2648L v2',70,1200,1900,2500,10,20
'E5-2628L v2',70,1200,1900,2400,8,16
'E5-2603 v2',80,1200,1800,1800,4,4
'E5-2637 v2',130,1200,3500,3800,4,8
'E5-2630L v2',60,1200,2400,2800,6,12
'E5-2630 v2',80,1200,2600,3100,6,12
'E5-2620 v2',80,1200,2100,2600,6,12
'E5-2618L v2',50,1200,2000,2000,6,12
'E5-2609 v2',80,1200,2500,2500,4,4
'E5-2697 v2',130,1200,2700,3500,12,24
'E5-2695 v2',115,1200,2400,3200,12,24
'E5-2690 v2',130,1200,3000,3600,10,20
'E5-2680 v2',115,1200,2800,3600,10,20
'E5-2670 v2',115,1200,2500,3300,10,20
'E5-2667 v2',130,1200,3300,4000,6,16
'E5-2660 v2',95,1200,2200,3000,10,20
'E5-2650L v2',70,1200,1700,2100,10,20
'E5-2650 v2',95,1200,2600,3400,8,16
'E5-2643 v2',130,1200,3500,3800,6,12
'E5-2640 v2',95,1200,2000,2500,8,16
)

gDesktopIvyBridgeCPUList=(
# Socket 2011 (Premium Power)
i7-4960X,130,1200,3600,4000,6,12
i7-4930K,130,1200,3400,3900,6,12
i7-4820K,130,1200,3700,3900,4,8
# i7-3700 Desktop Processor Series
i7-3770T,45,1600,2500,3700,4,8
i7-3770S,65,1600,3100,3900,4,8
i7-3770K,77,1600,3500,3900,4,8
i7-3770,77,1600,3400,3900,4,8
# i5-3500 Desktop Processor Series
i5-3570T,45,1600,2300,3300,4,4
i5-3570K,77,1600,3400,3800,4,4
i5-3570S,65,1600,3100,3800,4,4
i5-3570,77,1600,3400,3800,4,4
i5-3550S,65,1600,3000,3700,4,4
i5-3550,77,1600,3300,3700,4,4
# i5-3400 Desktop Processor Series
i5-3475S,65,1600,2900,3600,4,4
i5-3470S,65,1600,2900,3600,4,4
i5-3470,77,1600,3200,3600,4,4
i5-3470T,35,1600,2900,3600,2,4
i5-3450S,65,1600,2800,3500,4,4
i5-3450,77,1600,3100,3500,4,4
# i5-3300 Desktop Processor Series
i5-3350P,69,1600,3100,3300,4,4
i5-3330S,65,1600,2700,3200,4,4
i5-3333S,65,1600,2700,3200,4,4
i5-3330S,65,1600,3700,3200,4,4
i5-3330,77,1600,3000,3200,4,4
# i3-3200 Desktop Processor Series
i3-3250,55,1600,3500,0,2,4
i3-3240,55,1600,3400,0,2,4
i3-3240T,35,1600,2900,0,2,4
i3-3225,55,1600,3300,0,2,4
i3-3220,55,1600,3300,0,2,4
i3-3220T,35,1600,2800,0,2,4
i3-3210,55,1600,3200,0,2,4
)

gMobileIvyBridgeCPUList=(
# i7-3800 Mobile Processor Series
i7-3840QM,45,1200,2800,3800,4,8
i7-3820QM,45,1200,2700,3700,4,8
# i7-3700 Mobile Processor Series
i7-3740QM,45,1200,2700,3700,4,8
i7-3720QM,45,1200,2600,3600,4,8
# i7-3600 Mobile Processor Series
i7-3689Y,13,0,1500,2600,2,4
i7-3687U,17,800,2100,3300,2,4
i7-3667U,17,800,2000,3200,2,4
i7-3635QM,45,0,2400,3400,4,8
i7-3620QM,35,0,2200,3200,4,8
i7-3632QM,35,0,2200,3200,4,8
i7-3630QM,45,0,2400,3400,4,8
i7-3615QM,45,0,2300,3300,4,8
i7-3615QE,45,0,2300,3300,4,8
i7-3612QM,35,0,2100,3100,4,8
i7-3612QE,35,0,2100,3100,4,8
i7-3610QM,45,0,2300,3300,4,8
i7-3610QE,45,0,2300,3300,4,8
# i7-3500 Mobile Processor Series
i7-3555LE,25,0,2500,3200,2,4
i7-3540M,35,1200,3000,3700,2,4
i7-3537U,17,800,2000,3100,2,4
i7-3520M,35,1200,2900,3600,2,4
i7-3517UE,17,0,1700,2800,2,4
i7-3517U,17,0,1900,3000,2,4
# i5-3600 Mobile Processor Series
i5-3610ME,35,0,2700,3300,2,4
# i5-3400 Mobile Processor Series
i5-3439Y,13,0,1500,2300,2,4
i5-3437U,17,800,1900,2900,2,4
i5-3427U,17,800,1800,2800,2,4
# i5-3300 Mobile Processor Series
i5-3380M,35,1200,2900,3600,2,4
i5-3360M,35,1200,2800,3500,2,4
i5-3340M,35,1200,2700,3400,2,4
i5-3339Y,13,0,1500,2000,2,4
i5-3337U,17,0,1800,2700,2,4
i5-3320M,35,1200,2600,3300,2,4
i5-3317U,17,0,1700,2600,2,4
# i5-3200 Mobile Processor Series
i5-3230M,35,1200,2600,3200,2,4
i5-3210M,35,1200,2500,3100,2,4
# i3-3200 Mobile Processor Series
i3-3239Y,13,0,1400,0,2,4
i3-3227U,17,800,1900,0,2,4
i3-3217UE,17,0,1600,0,2,4
i3-3217U,17,0,1800,0,2,4
# i3-3100 Mobile Processor Series
i3-3130M,35,1200,2600,0,2,4
i3-3120ME,35,0,2400,0,2,4
i3-3120M,35,0,2500,0,2,4
i3-3110M,35,0,2400,0,2,4
)

#
# Haswell processors (with HD-4600 graphics)
#
gServerHaswellCPUList=(
# E3-1200 v3 Xeon Processor Series
'E3-1285L v3',65,800,3100,3900,4,8
'E3-1285 v3',84,800,3600,4000,4,8
'E3-1280 v3',82,800,3600,4000,4,8
'E3-1275 v3',84,800,3500,3900,4,8
'E3-1270 v3',80,800,3500,3900,4,8
'E3-1268L v3',45,800,2300,3300,4,8
'E3-1265L v3',45,800,2500,3700,4,8
'E3-1245 v3',84,800,3400,3800,4,8
'E3-1240 v3',80,800,3400,3800,4,8
'E3-1230L v3',25,800,1800,2800,4,8
'E3-1230 v3',80,800,3300,3700,4,8
'E3-1225 v3',80,800,3200,3600,4,4
'E3-1220 v3',80,800,3100,3500,4,4
'E3-1220L v3',13,800,1100,1500,2,4
)

gDesktopHaswellCPUList=(
# Socket 1150 (Standard Power)
i7-4770K,84,800,3500,3900,4,8
i7-4771,84,800,3500,3900,4,8
i7-4770,84,800,3400,3900,4,8
i5-4670K,84,800,3400,3800,4,4
i5-4670,84,800,3400,3800,4,4
i5-4570,84,800,3200,3600,4,4
i5-4440,84,800,3100,3300,4,4
i5-4430,84,800,3000,3200,4,4
# Socket 1150 (Low Power)
i7-4770S,65,800,3100,3900,4,8
i7-4770T,45,800,2500,3700,4,8
i7-4765T,35,800,2000,3000,4,8
i5-4670S,65,800,3100,3800,4,4
i5-4670T,45,800,2300,3300,4,4
i5-4570S,65,800,2900,3600,4,4
i5-4570T,35,800,2900,3600,2,4
i5-4430S,65,800,2700,3200,4,4
# BGA
i7-4770R,65,800,3200,3900,4,8
i5-4670R,65,800,3000,3700,4,4
# Haswell ULT
i5-4288U,28,800,2600,3100,2,4
i5-4258U,28,800,2400,2900,2,4
i5-4250U,15,800,1300,2600,2,4
i5-4200Y,12,800,1400,1900,2,4
i5-4200U,15,800,1600,2600,2,4
#
i3-4130T,35,800,2900,2900,2,4
i3-4330T,35,800,3000,3000,2,4
i3-4130,54,800,3400,3400,2,4
i3-4330,54,800,3500,3500,2,4
i3-4340,54,800,3600,3600,2,4
)

gMobileHaswellCPUList=(
# Socket FCBGA1364
i7-4960HQ,47,800,2600,3800,4,8
i7-4950HQ,47,800,2400,3600,4,8
i7-4850HQ,47,800,2300,3500,4,8
i7-4750HQ,47,800,2000,3200,4,8
i7-4702HQ,37,800,2200,3200,4,8
i7-4700HQ,47,800,2400,3600,4,8
# Extreme Edition Series - socket FCPGA946
i7-4930MX,57,800,3000,3900,4,8
# Socket FCPGA946
i7-4900MQ,47,800,2800,3800,4,8
i7-4800MQ,47,800,2700,3700,4,8
i7-4702MQ,37,800,2200,3200,4,8
i7-4700MQ,47,800,2400,3400,4,8
i5-4200M,37,800,2500,3100,2,4
# Socket FCBGA1168
i7-4650U,15,800,1700,3300,2,4
i7-4650U,15,800,1700,3300,2,4
i7-4600U,15,800,2100,3300,2,4
i7-4558U,28,800,2800,3300,2,4
i7-4550U,15,800,1500,3000,2,4
i7-4500U,15,800,1800,3000,2,4
i5-4350U,15,800,1400,2900,2,4
i5-4288U,28,800,2600,3100,2,4
i5-4258U,28,800,2400,2900,2,4
i5-4250U,15,800,1300,2600,2,4
i5-4200U,15,800,1600,2600,2,4
i5-4200Y,12,800,1400,1900,2,4
# Socket FCPGA946
i3-4000M,37,800,2400,2400,2,4
i3-4100M,37,800,2500,2500,2,4
# Socket FCLGA1150
i3-4130,54,800,3400,3400,2,4
i3-4130T,35,800,3000,3000,2,4
i3-4330,54,800,3500,3500,2,4
i3-4330T,35,800,3000,3000,2,4
i3-4340,54,800,3600,3600,2,4
i3-4330TE,35,800,2400,2400,2,4
# Socket FCBGA1364
i3-4100E,37,800,2400,2400,2,4
i3-4102E,25,800,1600,1600,2,4
# Socket FCBGA1168
i3-4005U,15,800,1700,1700,2,4
i3-4010U,15,800,1700,1700,2,4
i3-4100U,15,800,1800,1800,2,4
i3-4010Y,12,800,1300,1300,2,4
i3-4158U,28,800,2000,2000,2,4
i3-4012Y,11.5,800,1500,1500,2,4
i3-4020Y,11.5,800,1500,1500,2,4
)

#
# New Broadwell processors.
#
gServerBroadwellCPUList=()
gDesktopBroadwellCPUList=()
gMobileBroadwellCPUList=()

#--------------------------------------------------------------------------------

function _printHeader()
{
    echo '/*'                                                                         >  $gSsdtPR
    echo ' * Intel ACPI Component Architecture'                                       >> $gSsdtPR
    echo ' * AML Disassembler version 20130210-00 [Feb 10 2013]'                      >> $gSsdtPR
    echo ' * Copyright (c) 2000 - 2014 Intel Corporation'                             >> $gSsdtPR
    echo ' * '                                                                        >> $gSsdtPR
    echo ' * Original Table Header:'                                                  >> $gSsdtPR
    echo ' *     Signature        "SSDT"'                                             >> $gSsdtPR
    echo ' *     Length           0x0000036A (874)'                                   >> $gSsdtPR
    echo ' *     Revision         0x01'                                               >> $gSsdtPR
    echo ' *     Checksum         0x00'                                               >> $gSsdtPR
    echo ' *     OEM ID           "APPLE "'                                           >> $gSsdtPR
    echo ' *     OEM Table ID     "CpuPm"'                                            >> $gSsdtPR
  printf ' *     OEM Revision     '$gRevision' (%d)\n' $gRevision                     >> $gSsdtPR
    echo ' *     Compiler ID      "INTL"'                                             >> $gSsdtPR
    echo ' *     Compiler Version 0x20130210 (538116624)'                             >> $gSsdtPR
    echo ' */'                                                                        >> $gSsdtPR
    echo ''                                                                           >> $gSsdtPR
    echo 'DefinitionBlock ("'$gSsdtID'.aml", "SSDT", 1, "APPLE ", "CpuPm", '$gRevision')' >> $gSsdtPR
    echo '{'                                                                          >> $gSsdtPR
}

#--------------------------------------------------------------------------------

function _printExternals()
{
  #
  # Local variable definition.
  #
  local currentCPU
  #
  # Local variable initialisation.
  #
  local let currentCPU=0

  while [ $currentCPU -lt $gLogicalCPUs ];
  do
    echo '    External ('${gScope}'.'${gProcessorNames[$currentCPU]}', DeviceObj)'    >> $gSsdtPR
    let currentCPU+=1
  done

  echo ''                                                                             >> $gSsdtPR
}

#--------------------------------------------------------------------------------

function _injectDebugInfo()
{
  #
  # Local variable definitions/initialisation.
  #
  local turboStates=$1
  local maxTurboFrequency=$2
  local packageLength=$3

  echo '        Method (_INI, 0, NotSerialized)'                                      >> $gSsdtPR
  echo '        {'                                                                    >> $gSsdtPR
  echo '            Store ("ssdtPRGen version: '$gScriptVersion' / '$gProductName' '$gProductVersion' ('$gBuildVersion')", Debug)'  >> $gSsdtPR
  echo '            Store ("target processor : '$gProcessorNumber'", Debug)'          >> $gSsdtPR
  echo '            Store ("running processor: '$gBrandString'", Debug)'              >> $gSsdtPR
  echo '            Store ("baseFrequency    : '$gBaseFrequency'", Debug)'            >> $gSsdtPR
  echo '            Store ("frequency        : '$frequency'", Debug)'                 >> $gSsdtPR
  echo '            Store ("busFrequency     : '$gBusFrequency'", Debug)'             >> $gSsdtPR
  echo '            Store ("logicalCPUs      : '$gLogicalCPUs'", Debug)'              >> $gSsdtPR
  echo '            Store ("max TDP          : '$gTdp'", Debug)'                      >> $gSsdtPR
  echo '            Store ("packageLength    : '$packageLength'", Debug)'             >> $gSsdtPR
  echo '            Store ("turboStates      : '$turboStates'", Debug)'               >> $gSsdtPR
  echo '            Store ("maxTurboFrequency: '$maxTurboFrequency'", Debug)'         >> $gSsdtPR
  echo '            Store ("gIvyWorkAround   : '$gIvyWorkAround'", Debug)'            >> $gSsdtPR
  echo '            Store ("machdep.xcpm.mode: '$gXcpm'", Debug)'                     >> $gSsdtPR
  echo '        }'                                                                    >> $gSsdtPR
  echo ''                                                                             >> $gSsdtPR
}

#--------------------------------------------------------------------------------

function _printProcessorDefinitions()
{
  let currentCPU=0;

  while [ $currentCPU -lt $1 ];
  do
    echo '    External ('${gScope}'.'${gProcessorNames[$currentCPU]}', DeviceObj)'    >> $gSsdtPR
    let currentCPU+=1
  done

  echo ''                                                                             >> $gSsdtPR
}

#--------------------------------------------------------------------------------

function _printScopeStart()
{
  #
  # Local variable definitions.
  #
  local turboStates
  local packageLength
  local maxTurboFrequency
  local lowFrequencyPStates
  local useWorkArounds
  local maxTDP
  local extraR
  local extraF
  #
  # Local variable initialisation.
  #
  let turboStates=$1
  let packageLength=$2
  let maxTurboFrequency=$3
  let useWorkArounds=0

  echo '    Scope ('${gScope}'.'${gProcessorNames[0]}')'                              >> $gSsdtPR
  echo '    {'                                                                        >> $gSsdtPR

  if (( $gDebug & 1 ));
    then
      _injectDebugInfo $turboStates $maxTurboFrequency $packageLength
  fi

  #
  # Do we need to create additional (Low Frequency) P-States?
  #
  if [ $gBridgeType -ne $SANDY_BRIDGE ];
    then
      let lowFrequencyPStates=0
      #
      # Do we need to add additional (Low Frequency) P-States for Ivy Bridge?
      #
      if (( $gBridgeType == $IVY_BRIDGE && $gIvyWorkAround & 2 ));
        then
          let lowFrequencyPStates=($gBaseFrequency/100)-8
      fi

      let packageLength=($2+$lowFrequencyPStates)

      if [[ lowFrequencyPStates -gt 0 ]];
        then
          printf "        Name (APLF, 0x%02x)\n" $lowFrequencyPStates                 >> $gSsdtPR
        else
          # Prevent optimization warning.
          echo "        Name (APLF, Zero)"                                            >> $gSsdtPR
      fi

      # TODO: Remove this when CPUPM for IB works properly!
      if (( $gBridgeType == $IVY_BRIDGE && $gIvyWorkAround & 1 ));
        then
          let useWorkArounds=1
      fi
  fi

  #
  # Check number of Turbo states (for IASL optimization).
  #
  if [ $turboStates -eq 0 ];
    then
      # TODO: Remove this when CPUPM for IB works properly!
      if (( $useWorkArounds ));
        then
          echo '        Name (APSN, One)'                                             >> $gSsdtPR
        else
          echo '        Name (APSN, Zero)'                                            >> $gSsdtPR
      fi
    else
      # TODO: Remove this when CPUPM for IB works properly!
      if (( $useWorkArounds ));
        then
          let turboStates+=1
      fi

      printf "        Name (APSN, 0x%02X)\n" $turboStates                             >> $gSsdtPR
  fi

  # TODO: Remove this when CPUPM for IB works properly!
  if (( $useWorkArounds ));
    then
      let packageLength+=1
  fi

  printf "        Name (APSS, Package (0x%02X)\n" $packageLength                      >> $gSsdtPR
  echo '        {'                                                                    >> $gSsdtPR

  # TODO: Remove this when CPUPM for IB works properly!
  if (( $useWorkArounds ));
    then
      let extraF=($maxTurboFrequency+1)
      #
      # Is the global TDP a floating-point number?
      #
      if [[ $gTdp =~ "." ]];
        then
          #
          # Yes, convert it and calculate maximum TDP.
          #
          let tdp=$(echo "$gTdp" | sed -e 's/\.//g')
          let maxTDP=($tdp*100)
        else
          #
          # No. Calculate maximum TDP.
          #
          let maxTDP=($gTdp*1000)
      fi

      let extraR=($maxTurboFrequency/100)+1
      echo "            /* Workaround for the Ivy Bridge PM 'bug' */"                 >> $gSsdtPR
      printf "            Package (0x06) { 0x%04X, 0x%06X, 0x0A, 0x0A, 0x%02X00, 0x%02X00 },\n" $extraF $maxTDP $extraR $extraR >> $gSsdtPR
  fi
}


#--------------------------------------------------------------------------------

function _printPackages()
{
  #
  # Local variable definitions/initialisation.
  #
  local maxNonTurboFrequency=$1
  local turboStates=$2
  local frequency=$3
  #
  # Local variable definitions.
  #
  local tdp
  local maxTDP
  local minRatio
  local p1Ratio
  local ratio
  local powerRatio
  #
  # Is the global TDP a floating-point number?
  #
  if [[ $gTdp =~ "." ]];
    then
      #
      # Yes, convert it and calculate maximum TDP.
      #
      let tdp=$(echo "$gTdp" | sed -e 's/\.//g')
      let maxTDP=($tdp*100)
    else
      #
      # No. Calculate maximum TDP.
      #
      let maxTDP=($gTdp*1000)
  fi
  #
  # Local variable initialisation.
  #
  let minRatio=($gBaseFrequency/$gBusFrequency)
  let p0Ratio=($maxNonTurboFrequency/$gBusFrequency)
  let ratio=($frequency/$gBusFrequency)
  let powerRatio=($p0Ratio-1)
  #
  # Do we need to add additional (Low Frequency) P-States for Ivy Bridge?
  #
  if (( $gBridgeType == $IVY_BRIDGE && $gIvyWorkAround & 2 ));
    then
      let minRatio=8
  fi

  if (( $turboStates ));
    then
      echo '            /* High Frequency Modes (turbo) */'                           >> $gSsdtPR
  fi

  while [ $ratio -ge $minRatio ];
  do
    if [ $frequency -eq $gBaseFrequency ];
      then
        echo '            /* Low Frequency Mode */'                                   >> $gSsdtPR
    fi

    if [ $frequency -eq $maxNonTurboFrequency ];
      then
        echo '            /* High Frequency Modes (non-turbo) */'                     >> $gSsdtPR
    fi

    printf "            Package (0x06) { 0x%04X, " $frequency                         >> $gSsdtPR

    if [ $frequency -lt $maxNonTurboFrequency ];
      then
        power=$(echo "scale=6;m=((1.1-(($p0Ratio-$powerRatio)*0.00625))/1.1);(($powerRatio/$p0Ratio)*(m*m)*$maxTDP);" | bc | sed -e 's/.[0-9A-F]*$//')
        let powerRatio-=1
      else
        power=$maxTDP
    fi

    if [ $frequency -ge $gBaseFrequency ];
      then
        printf "0x%06X, " $power                                                      >> $gSsdtPR
      else
        printf '    Zero, '                                                           >> $gSsdtPR
    fi

    printf "0x0A, 0x0A, 0x%02X00, 0x%02X00 }" $ratio $ratio                           >> $gSsdtPR

    let ratio-=1
    let frequency-=$gBusFrequency

    if [ $ratio -ge $minRatio ];
      then
        echo ','                                                                      >> $gSsdtPR
      else
        echo ''                                                                       >> $gSsdtPR
    fi

  done

  echo '        })'                                                                   >> $gSsdtPR
}


#--------------------------------------------------------------------------------

function _printMethodDSM()
{
  #
  # New stand-alone version of Method _DSM - Copyright (c) 2009 by Master Chief
  #
  echo ''                                                                             >> $gSsdtPR
  echo '        Method (_DSM, 4, NotSerialized)'                                      >> $gSsdtPR
  echo '        {'                                                                    >> $gSsdtPR

  if (( $gDebug ));
    then
      #
      # Note: This will be called twice!
      #
      echo '            Store ("Method '${gProcessorNames[0]}'._DSM Called", Debug)'  >> $gSsdtPR
      echo ''                                                                         >> $gSsdtPR
  fi

  echo '            If (LEqual (Arg2, Zero))'                                         >> $gSsdtPR
  echo '            {'                                                                >> $gSsdtPR
  echo '                Return (Buffer (One)'                                         >> $gSsdtPR
  echo '                {'                                                            >> $gSsdtPR
  echo '                    0x03'                                                     >> $gSsdtPR
  echo '                })'                                                           >> $gSsdtPR
  echo '            }'                                                                >> $gSsdtPR
  echo ''                                                                             >> $gSsdtPR
  #
  # This property is required to get X86Platform[Plugin/Shim].kext loaded.
  #
  echo '            Return (Package (0x02)'                                           >> $gSsdtPR
  echo '            {'                                                                >> $gSsdtPR
  echo '                "plugin-type",'                                               >> $gSsdtPR
  echo '                One'                                                          >> $gSsdtPR
  echo '            })'                                                               >> $gSsdtPR
  echo '        }'                                                                    >> $gSsdtPR
  echo '    }'                                                                        >> $gSsdtPR
}

#--------------------------------------------------------------------------------

function _debugPrint()
{
  if (( $gDebug & 2 ));
    then
      printf "$1"
  fi
}

#--------------------------------------------------------------------------------

function _printScopeACST()
{
  #
  # Local variable definition.
  #
  local C1 C2 C3 C6 C7

  local hintCode
  local pkgLength
  local targetCPU
  local numberOfCStates
  local targetCStates

  #
  # Intel values for Sandy / Ivy Bridge processors
  #
  # C-state : Power   : SB Latency : IB Latency
  #---------:---------:------------:------------
  #   C1    :  0x3e8  :    0x01    :    0x03
  #   C3    :  0x1f4  :    0x50    :    0xcd
  #   C6    :  0x15e  :    0x68    :    0xf5
  #   C7    :  0xc8   :    0x6d    :    0xf5
  #
  # Note: C-state latency in uS and C-state power in mW.
  #
  local latency_C1=Zero
  local latency_C2=0x43
  local latency_C3=0xCD
  local latency_C6=0xF5
  local latency_C7=0xF5
  #
  # Local variable initialisation.
  #
  let C1=0
  let C2=0
  let C3=0
  let C6=0
  let C7=0
  let pkgLength=2
  let numberOfCStates=0

  #
  # Are we injecting C-States for CPU1?
  #
  if [ $1 -eq 1 ];
    then
      let targetCPU=1
    else
      let targetCPU=0
  fi

  echo ''                                                                             >> $gSsdtPR
  echo '        Method (ACST, 0, NotSerialized)'                                      >> $gSsdtPR
  echo '        {'                                                                    >> $gSsdtPR

  if (( $gDebug ));
    then
      echo '            Store ("Method '${gProcessorNames[$targetCPU]}'.ACST Called", Debug)'  >> $gSsdtPR
  fi
  #
  # Are we injecting C-States for CPU1?
  #
  if [ $targetCPU -eq 1 ];
    then
      # Yes (also used by CPU2, CPU3 and greater).
      let targetCStates=$gACST_CPU1
      latency_C1=0x03E8
      latency_C2=0x94
      latency_C3=0xC6
    else
      #
      # C-States override for Mobile processors (CPU0 only)
      #
      if (($gTypeCPU == $gMobileCPU));
        then
          echo 'Adjusting C-States for detected (mobile) processor'
          let gACST_CPU0=29
      fi

      let targetCStates=$gACST_CPU0
      latency_C1=Zero
      latency_C2=0x43
      latency_C3=0xCD
      latency_C6=0xF5
      latency_C7=0xF5
  fi

  if (( $gDebug ));
    then
      echo '            Store ("'${gProcessorNames[$targetCPU]}' C-States    : '$targetCStates'", Debug)' >> $gSsdtPR
      echo ''                                                                         >> $gSsdtPR
  fi

  _debugPrint "targetCStates: $targetCStates\n"

  #
  # Checks to determine which C-State(s) we should inject.
  #
  if (($targetCStates & 1));
    then
      _debugPrint "Adding C1\n"
      let C1=1
      let numberOfCStates+=1
      let pkgLength+=1
  fi

  if (($targetCStates & 2));
    then
      _debugPrint "Adding C2\n"
      let C2=1
      let numberOfCStates+=1
      let pkgLength+=1
  fi

  if (($targetCStates & 4));
    then
      _debugPrint "Adding C3\n"
      let C3=1
      let numberOfCStates+=1
      let pkgLength+=1
  fi

  if (($targetCStates & 8));
    then
      _debugPrint "Adding C6\n"
      let C6=1
      let numberOfCStates+=1
      let pkgLength+=1
  fi

  if ((($targetCStates & 16) == 16));
    then
      _debugPrint "Adding C7\n"
      let C7=1
      let numberOfCStates+=1
      let pkgLength+=1
  fi

  let hintCode=0x00

    echo "            /* Low Power Modes for ${gProcessorNames[$1]} */"                 >> $gSsdtPR
  printf "            Return (Package (0x%02x)\n" $pkgLength                            >> $gSsdtPR
    echo '            {'                                                                >> $gSsdtPR
    echo '                One,'                                                         >> $gSsdtPR
  printf "                0x%02x,\n" $numberOfCStates                                   >> $gSsdtPR
    echo '                Package (0x04)'                                               >> $gSsdtPR
    echo '                {'                                                            >> $gSsdtPR
    echo '                    ResourceTemplate ()'                                      >> $gSsdtPR
    echo '                    {'                                                        >> $gSsdtPR
    echo '                        Register (FFixedHW,'                                  >> $gSsdtPR
    echo '                            0x01,               // Bit Width'                 >> $gSsdtPR
    echo '                            0x02,               // Bit Offset'                >> $gSsdtPR
  printf "                            0x%016x, // Address\n" $hintCode                  >> $gSsdtPR
    echo '                            0x01,               // Access Size'               >> $gSsdtPR
    echo '                            )'                                                >> $gSsdtPR
    echo '                    },'                                                       >> $gSsdtPR
    echo '                    One,'                                                     >> $gSsdtPR
    echo '                    '$latency_C1','                                           >> $gSsdtPR
    echo '                    0x03E8'                                                   >> $gSsdtPR

    if (($C2)); then
        let hintCode+=0x10
        echo '                },'                                                       >> $gSsdtPR
        echo ''                                                                         >> $gSsdtPR
        echo '                Package (0x04)'                                           >> $gSsdtPR
        echo '                {'                                                        >> $gSsdtPR
        echo '                    ResourceTemplate ()'                                  >> $gSsdtPR
        echo '                    {'                                                    >> $gSsdtPR
        echo '                        Register (FFixedHW,'                              >> $gSsdtPR
        echo '                            0x01,               // Bit Width'             >> $gSsdtPR
        echo '                            0x02,               // Bit Offset'            >> $gSsdtPR
      printf "                            0x%016x, // Address\n" $hintCode              >> $gSsdtPR
        echo '                            0x03,               // Access Size'           >> $gSsdtPR
        echo '                            )'                                            >> $gSsdtPR
        echo '                    },'                                                   >> $gSsdtPR
        echo '                    0x02,'                                                >> $gSsdtPR
        echo '                    '$latency_C2','                                       >> $gSsdtPR
        echo '                    0x01F4'                                               >> $gSsdtPR
    fi

    if (($C3)); then
        let hintCode+=0x10
        local power_C3=0x01F4
        #
        # Is this for CPU1?
        #
        if (($1)); then
            if [[ ${modelID:0:7} == "iMac13," ]];
                then
                    local power_C3=0x15E
                    latency_C3=0xA9
                else
                    local power_C3=0xC8
                    let hintCode+=0x10
            fi
        fi

        echo '                },'                                                       >> $gSsdtPR
        echo ''                                                                         >> $gSsdtPR
        echo '                Package (0x04)'                                           >> $gSsdtPR
        echo '                {'                                                        >> $gSsdtPR
        echo '                    ResourceTemplate ()'                                  >> $gSsdtPR
        echo '                    {'                                                    >> $gSsdtPR
        echo '                        Register (FFixedHW,'                              >> $gSsdtPR
        echo '                            0x01,               // Bit Width'             >> $gSsdtPR
        echo '                            0x02,               // Bit Offset'            >> $gSsdtPR
      printf "                            0x%016x, // Address\n" $hintCode              >> $gSsdtPR
        echo '                            0x03,               // Access Size'           >> $gSsdtPR
        echo '                            )'                                            >> $gSsdtPR
        echo '                    },'                                                   >> $gSsdtPR
        echo '                    0x03,'                                                >> $gSsdtPR
        echo '                    '$latency_C3','                                       >> $gSsdtPR
        echo '                    '$power_C3                                            >> $gSsdtPR
    fi

    if (($C6)); then
        let hintCode+=0x10
        echo '                },'                                                       >> $gSsdtPR
        echo ''                                                                         >> $gSsdtPR
        echo '                Package (0x04)'                                           >> $gSsdtPR
        echo '                {'                                                        >> $gSsdtPR
        echo '                    ResourceTemplate ()'                                  >> $gSsdtPR
        echo '                    {'                                                    >> $gSsdtPR
        echo '                        Register (FFixedHW,'                              >> $gSsdtPR
        echo '                            0x01,               // Bit Width'             >> $gSsdtPR
        echo '                            0x02,               // Bit Offset'            >> $gSsdtPR
      printf "                            0x%016x, // Address\n" $hintCode              >> $gSsdtPR
        echo '                            0x03,               // Access Size'           >> $gSsdtPR
        echo '                            )'                                            >> $gSsdtPR
        echo '                    },'                                                   >> $gSsdtPR
        echo '                    0x06,'                                                >> $gSsdtPR
        echo '                    '$latency_C6','                                       >> $gSsdtPR
        echo '                    0x015E'                                               >> $gSsdtPR
    fi

	if (($C7)); then
        #
        # If $hintCode is already 0x30 then use 0x31 otherwise 0x30
        #
        if [ $hintCode -eq 48 ];
            then
                let hintCode+=0x01
            else
                let hintCode+=0x10
        fi
        echo '                },'                                                       >> $gSsdtPR
        echo ''                                                                         >> $gSsdtPR
        echo '                Package (0x04)'                                           >> $gSsdtPR
        echo '                {'                                                        >> $gSsdtPR
        echo '                    ResourceTemplate ()'                                  >> $gSsdtPR
        echo '                    {'                                                    >> $gSsdtPR
        echo '                        Register (FFixedHW,'                              >> $gSsdtPR
        echo '                            0x01,               // Bit Width'             >> $gSsdtPR
        echo '                            0x02,               // Bit Offset'            >> $gSsdtPR
      printf "                            0x%016x, // Address\n" $hintCode              >> $gSsdtPR
        echo '                            0x03,               // Access Size'           >> $gSsdtPR
        echo '                            )'                                            >> $gSsdtPR
        echo '                    },'                                                   >> $gSsdtPR
        echo '                    0x07,'                                                >> $gSsdtPR
        echo '                    '$latency_C7','                                       >> $gSsdtPR
        echo '                    0xC8'                                                 >> $gSsdtPR
    fi

    echo '                }'                                                            >> $gSsdtPR
    echo '            })'                                                               >> $gSsdtPR
    echo '        }'                                                                    >> $gSsdtPR

  #
  # We don't need a closing bracket here when we add method _DSM for Ivy Bridge.
  #
  if [ $gBridgeType -eq $SANDY_BRIDGE ];
    then
      echo '    }'                                                                    >> $gSsdtPR
  fi
}


#--------------------------------------------------------------------------------

function _printScopeCPUn()
{
  #
  # Local variable definition.
  #
  local currentCPU
  #
  # Local variable initialisation.
  #
  let currentCPU=1;

  while [ $currentCPU -lt $gLogicalCPUs ];
  do
    echo ''                                                                         >> $gSsdtPR
    echo '    Scope ('${gScope}'.'${gProcessorNames[$currentCPU]}')'                >> $gSsdtPR
    echo '    {'                                                                    >> $gSsdtPR
    echo '        Method (APSS, 0, NotSerialized)'                                  >> $gSsdtPR
    echo '        {'                                                                >> $gSsdtPR

    if (( $gDebug ));
      then
        echo '            Store ("Method '${gProcessorNames[$currentCPU]}'.APSS Called", Debug)'  >> $gSsdtPR
        echo ''                                                                     >> $gSsdtPR
    fi

    echo '            Return ('${gScope}'.'${gProcessorNames[0]}'.APSS)'            >> $gSsdtPR
    echo '        }'                                                                >> $gSsdtPR
    #
    # IB CPUPM tries to parse/execute CPUn.ACST (see debug data) and thus we add
    # this method, conditionally, since SB CPUPM doesn't seem to care about it.
    #
    if [ $gBridgeType -ge $IVY_BRIDGE ];
      then
        if [ $currentCPU -eq 1 ];
          then
            _printScopeACST 1
          else
            echo ''                                                                 >> $gSsdtPR
            echo '        Method (ACST, 0, NotSerialized) { Return ('${gScope}'.'${gProcessorNames[1]}'.ACST ()) }' >> $gSsdtPR
        fi
    fi

    echo '    }'                                                                    >> $gSsdtPR

    let currentCPU+=1
  done

 echo '}'                                                                           >> $gSsdtPR
}

#--------------------------------------------------------------------------------

function _getModelName()
{
  #
  # Grab 'compatible' property from ioreg (stripped with sed / RegEX magic).
  #
  echo `ioreg -p IODeviceTree -d 2 -k compatible | grep compatible | sed -e 's/ *["=<>]//g' -e 's/compatible//'`
}

#--------------------------------------------------------------------------------

function _getBoardID()
{
  #
  # Grab 'board-id' property from ioreg (stripped with sed / RegEX magic).
  #
  boardID=$(ioreg -p IODeviceTree -d 2 -k board-id | grep board-id | sed -e 's/ *["=<>]//g' -e 's/board-id//')
}

#--------------------------------------------------------------------------------

function _getProcessorNames()
{
  #
  # Local variable definition/initialisation.
  #
  local acpiNames=$(ioreg -p IODeviceTree -c IOACPIPlatformDevice -k cpu-type | egrep name  | sed -e 's/ *[-|="<a-z>]//g')
  #
  # Global variable initialisation.
  #
  gProcessorNames=($acpiNames)
  #
  # Do we have two logical processor cores?
  #
  if [[ ${#gProcessorNames[@]} -lt 2 ]];
    then
      #
      # No. Bail out with error.
      #
      _exitWithError $PROCESSOR_NAMES_ERROR
  fi
}

#--------------------------------------------------------------------------------

function _updateProcessorNames()
{
  #
  # Local variable definition.
  #
  local currentCPU
  local numberOfLogicalCores
  #
  # Local variable initialisation.
  #
  let currentCPU=0
  let numberOfLogicalCores=$1
  #
  # Do we have less than/equal 15 logical processor cores?
  #
  if [[ $gLogicalCPUs -le 0x0f ]];
    then
      #
      # Yes. Use the first three characters 'CPU' of the processor label 'CPU0'.
      #
      local label=${gProcLabel:0:3}
    else
      #
      # No. Use the first two characters 'CP' of the processor label 'CP00'.
      #
      local label=${gProcLabel:0:2}
  fi
  #
  # Target processor with more logical cores than the running system?
  #
  if [[ $numberOfLogicalCores -gt ${#gProcessorNames[@]} ]];
    then
      echo -e "\nWarning: Target CPU has $gLogicalCPUs logical cores, the running system only ${#gProcessorNames[@]}"
      echo    "         Now using '$label' to extent the current range to $gLogicalCPUs..."
      echo -e "         Check/fix the generated $gSsdtID.dsl in case of a failure!\n"
  fi

  while [ $currentCPU -lt $numberOfLogicalCores ];
  do
    if [[ $numberOfLogicalCores -gt 0x0f && $currentCPU -le 0x0f ]];
      then
        local filler='0'
      else
        local filler=''
    fi
    #
    # Re-initialisation of a global variable.
    #
    gProcessorNames[$currentCPU]=${label}${filler}$(echo "obase=16; ${currentCPU}" | bc)
    #
    # Next.
    #
    let currentCPU+=1
  done
}

#--------------------------------------------------------------------------------

function _getACPIProcessorScope()
{
  #
  # Local variable definitions/initialisation.
  #
  local filename=$1
  local variableList=(10,6,4,40,2 12,8,6,42,4)
  local varList
  local checkGlobalProcessorScope
  local scopeLength
  local index
  #
  # Local variable initialisation.
  #
  let index=0

  #
  # Loop through all Name (_HID, ACPI0004) objects.
  #
  for varList in "${variableList[@]}"
  do
    #
    # Save default (0) delimiter.
    #
    local ifs=$IFS
    #
    # Change delimiter to a space character.
    #
    IFS=","
    #
    # Split vars.
    #
    local vars=(${varList})
    #
    # Up index of variableList.
    #
    let index+=1
    #
    # Restore the default delimiter.
    #
    IFS=$ifs
    #
    # Check for (a) Device(s) with a _HID object value of 'ACPI0004' in the DSDT.
    #
    local data=$(cat "$filename" | egrep -o '5b82[0-9a-f]{'${vars[0]}'}085f4849440d414350493030303400')
    #
    # Example:
    #          5b824d9553434b30085f4849440d414350493030303400 (N times)
    #          0123456789 123456789 123456789 123456789 12345
    #

    if [[ $data ]];
      then
        local hidObjectList=($data)
        local let objectCount=${#hidObjectList[@]}

        if [ $objectCount -gt 0 ];
          then
            printf "${objectCount} Name (_HID, \"ACPI0004\") object(s) found in the DSDT\n"
        fi
        #
        # Loop through all Name (_HID, ACPI0004) objects.
        #
        for hidObjectData in "${hidObjectList[@]}"
        do
          #
          # Get the name of the device.
          #
          local deviceName=$(echo ${hidObjectData:${vars[1]}:8} | xxd -r -p)
          # echo $deviceName
          #
          # Get the length of the device scope.
          #
          let scopeLength=("0x"${hidObjectData:${vars[2]}:2})
          # echo $scopeLength
          #
          # Convert number of bytes to number of characters.
          #
          let scopeLength*=2
          # echo $scopeLength
          #
          # Lower scopeLength with the number of bytes that we used for this match.
          #
          let scopeLength-=${vars[3]}
          # echo $scopeLength
          #
          # Initialise string.
          #
          local repetitionString=""
          #
          # Prevent "egrep: invalid repetition count(s)"
          #
          if [[ $scopeLength -gt 255 ]];
            then
              while [ $scopeLength -gt 255 ];
              do
                local repetitionString+="[0-9a-f]{255}"
                let scopeLength-=255
              done
          fi

          repetitionString+="[0-9a-f]{${scopeLength}}"
          # echo $repetitionString
          #
          # Extract the whole Device () {} scope.
          #
          local deviceObjectData=$(cat "$filename" | egrep -o "5b82[0-9a-f]{${vars[4]}}${hidObjectData:${vars[1]}:8}085f4849440d414350493030303400${repetitionString}" | tr -d '\n')
          # echo $deviceObjectData
          #
          # We should now have something like this (example):
          #
          #          Device (SCK0)
          #          {
          #              Name (_HID, "ACPI0004")
          #              Processor (C000, 0x00, 0x00000410, 0x06)
          #              {
          #                  Name (_HID, "ACPI0007")
          #              }
          #
          #          5b823053434b30085f4849440d4143504930303034005b831a43303030001004000006085f4849440d414350493030303700
          #          0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
          #
          # Check for Processor declarations.
          #
          let checkGlobalProcessorScope=0
          #
          # Convert (example) 'C000' to '43303030'
          #
          local processorNameBytes=$(echo -n ${gProcessorNames[0]} | xxd -ps)
          #
          # Search for the first Processor {} declaration.
          #
          # Example:
          #          5b831a4330303000 (C000)
          #          0123456789 12345
          #
          local processorObjectData=$(echo "$deviceObjectData" | egrep -o "5b83[0-9a-f]{2}${processorNameBytes}")
          #
          # Do we have a match for the first processor declaration?
          #
          if [[ $processorObjectData ]];
            then
              #
              # Yes. Print the result.
              #
              let checkGlobalProcessorScope=1
              printf "Processor declaration (${gProcessorNames[0]}) {0x${processorObjectData:4:2} bytes} found in Device (%s) (none ACPI 1.0 compliant)\n" $deviceName
            else
              #
              # No. Search for the first Processor {...} declaration with enclosed child objects.
              #
              # Example:
              #          5b834a044330303000 (C200)
              #          0123456789 1234567
              #
              processorObjectData=$(echo "$deviceObjectData" | egrep -o "5b83[0-9a-f]{4}${processorNameBytes}")

              if [[ $processorObjectData ]];
                then
                  let checkGlobalProcessorScope=1
                  printf "Processor declaration (${gProcessorNames[0]}) found in Device (%s) {...} (none ACPI 1.0 compliant)\n" $deviceName
              fi
          fi
          #
          # Free up some memory.
          #
          local processorObjectData=""
          #
          # Do we need to update the processor scope variable?
          #
          if [[ $checkGlobalProcessorScope -eq 1 ]];
            then
              #
              # Update the processor scope.
              #
              gScope="\_SB_.${deviceName}"
              #
              # Done.
              #
              return
          fi
        done
    fi
  done
}

#--------------------------------------------------------------------------------

function _getProcessorScope()
{
  local filename="/tmp/dsdt.txt"

  ioreg -c AppleACPIPlatformExpert -rd1 -w0 | egrep -o 'DSDT"=<[0-9a-f]+' > "$filename"
  #
  # Check for Device()s with enclosed Name (_HID, "ACPI0004") objects.
  #
  _getACPIProcessorScope $filename
  #
  # Did we find any with Processor declarations?
  #
  if [[ $gScope != "" ]];
    then
      #
      # Yes. We're done searching for the Processor scope.
      #
      return
    else
      printf "Name (_HID, \"ACPI0004\") NOT found in the DSDT\n"
  fi
  #
  # Additional check for Processor declarations with child objects.
  #
  if [[ $(cat "$filename" | egrep -o '5b83[0-9a-f]{2}04') ]];
    then
      printf "Processor {.} Declaration(s) found in DSDT"
    else
      #
      # Check for Processor declarations without child objects.
      #
      if [[ $(cat "$filename" | egrep -o '5b830b') ]];
        then
          printf "Processor {} Declaration(s) found in DSDT"
      fi
  fi
  #
  # Check for Processor declarations with RootChar in DSDT.
  #
  local data=$(cat "$filename" | egrep -o '5b83[0-9a-f]{2}5c2e[0-9a-f]{8}')

  if [[ $data ]];
    then
      printf "Processor {...} Declaration(s) with RootChar ('\\\') found in DSDT"
      gScope="\\"$(echo ${data:10:8} | xxd -r -p)

      if [[ $gScope == "\_PR_" ]];
        then
          echo ' (ACPI 1.0 compliant)'
        elif [[ $gScope == "\_SB_" ]];
          then
            echo ' (none ACPI 1.0 compliant)'
          else
            echo ' - ERROR: Invalid Scope Used!'
      fi

      return
  fi
  #
  # Check for Processor declarations with DualNamePrefix in the DSDT.
  #
  local data=$(cat "$filename" | egrep -o '5b83[0-9a-f]{2}2e[0-9a-f]{8}')

  if [[ $data ]]; then
    printf "Processor {...} Declaration(s) with DualNamePrefix ('.') found in DSDT"
    gScope="\\"$(echo ${data:8:8} | xxd -r -p)

    if [[ $gScope == "\_PR_" ]];
      then
        echo ' (ACPI 1.0 compliant)'
      elif [[ $gScope == "\_SB_" ]];
        then
          echo ' (none ACPI 1.0 compliant)'
        else
          echo ' - ERROR: Invalid Scope Used!'
    fi

    return
  fi
  #
  # Check for Processor declarations with MultiNamePrefix (without leading backslash) in the DSDT.
  #
  local data=$(cat "$filename" | egrep -o '5b83[0-9a-f]{2}2f[0-9a-f]{2}')

  if [[ $data ]];
    then
      printf "Processor {...} Declaration(s) with MultiNamePrefix ('/') found in DSDT"

      let scopeLength=("0x"${data:8:2})*4*2
      local data=$(cat "$filename" | egrep -o '5b83[0-9a-f]{2}2f[0-9a-f]{'$scopeLength'}')
      partOne=$(echo ${data:10:8} | xxd -r -p)
      partTwo=$(echo ${data:18:8} | xxd -r -p)
      gScope="\\${partOne}.${partTwo}"

      if [[ $gScope =~ "\_PR_" ]];
        then
          echo ' (ACPI 1.0 compliant)'
        elif [[ $gScope =~ "\_SB_" ]];
          then
            echo ' (none ACPI 1.0 compliant)'
          else
            echo ' - ERROR: Invalid Scope Used!'
      fi

      return
  fi
  #
  # Check for Processor declarations with MultiNamePrefix (with leading backslash) in the DSDT.
  #
  local data=$(cat "$filename" | egrep -o '5b83[0-9a-f]{2}5c2f[0-9a-f]{2}')

  if [[ $data ]];
    then
      printf "Processor {...} Declaration(s) with MultiNamePrefix ('/') found in DSDT"

      let scopeLength=("0x"${data:10:2})*4*2
      local data=$(cat "$filename" | egrep -o '5b83[0-9a-f]{2}5c2f[0-9a-f]{'$scopeLength'}')
      partOne=$(echo ${data:12:8} | xxd -r -p)
      partTwo=$(echo ${data:20:8} | xxd -r -p)
      gScope="\\${partOne}.${partTwo}"

      if [[ $gScope =~ "\_PR_" ]];
        then
          echo ' (ACPI 1.0 compliant)'
        elif [[ $gScope =~ "\_SB_" ]];
          then
            echo ' (none ACPI 1.0 compliant)'
        else
          echo ' - ERROR: Invalid Scope Used!'
      fi

      return
  fi
  #
  # Check for Processor declarations with ParentPrefixChar in the DSDT.
  #
  local data=$(cat "$filename" | egrep -o '5b83[0-9a-f]{2}5e[0-9a-f]{8}')

  if [[ $data ]];
    then
      printf "Processor {...} Declaration(s) with ParentPrefixChar ('^') found in DSDT\n"
      gScope=$(echo ${data:6:2} | xxd -r -p)

# ioreg -w0 -p IOACPIPlane -c IOACPIPlatformDevice -n _SB -r > /tmp/dsdt.txt

      if [[ $gScope =~ "^" ]];
        then
          printf "Searching for Parent Scope ... "
        else
          echo ' - ERROR: Invalid Scope Used!'
      fi

      return
  fi
  #
  # No match so far. Let's check for '_PR_' in the DSDT.
  #
  local data=$(cat "$filename" | egrep -o '5f50525f')

  if [[ $data ]];
    then
      gScope="\_PR_"
      printf 'Processor {} Declaration(s) found in DSDT (ACPI 1.0 compliant)'
  fi
  #
  # If that also fails then, as a last resort, check for '_PR' in broken ACPI tables.
  #
  local data=$(cat "$filename" | egrep -o '5f5052')

  if [[ $data ]];
    then
      gScope="\_PR_"
      printf 'Processor {} Declaration(s) found in DSDT (ACPI 1.0 compliant)'
    else
      #
      # Not a single check matched thus the processor scope is '_SB_'
      #
      gScope="\_SB_"
      printf 'Processor {} Declaration(s) found in DSDT (ACPI 1.0 compliant)'
  fi
}

#--------------------------------------------------------------------------------

function _getCPUtype()
{
  #
  # Grab 'cpu-type' property from ioreg (stripped with sed / RegEX magic).
  #
  local grepStr=$(ioreg -p IODeviceTree -n "${gProcessorNames[0]}"@0 -k cpu-type | grep cpu-type | sed -e 's/["cputype" ,<>|=-]//g')

  # Swap bytes with help of ${str:pos:num}
  #
  echo ${grepStr:2:2}${grepStr:0:2}
}

#--------------------------------------------------------------------------------

function _getCPUModel()
{
  #
  # Returns the hexadecimal value of machdep.cpu.model
  #
  echo 0x$(echo "obase=16; `sysctl machdep.cpu.model | sed -e 's/^machdep.cpu.model: //'`" | bc)
}

#--------------------------------------------------------------------------------

function _getCPUSignature()
{
  #
  # Returns the hexadecimal value of machdep.cpu.signature
  #
  echo 0x$(echo "obase=16; `sysctl machdep.cpu.signature | sed -e 's/^machdep.cpu.signature: //'`" | bc)
}

#--------------------------------------------------------------------------------

function _getSystemType()
{
  #
  # Grab 'system-type' property from ioreg (stripped with sed / RegEX magic).
  #
  # Note: This property is checked (cmpb $0x02) in X86PlatformPlugin::configResourceCallback
  #
  echo `ioreg -p IODeviceTree -d 2 -k system-type | grep system-type | sed -e 's/ *[-="<0a-z>]//g'`
}

#--------------------------------------------------------------------------------

function _findIasl()
{
  #
  # Do we have to call IASL?
  #
  if (( $gCallIasl ));
    then
      #
      # Yes. Do a quick lookup of iasl (should also be there after the first run).
      #
      if [ ! -f /usr/local/bin/iasl ];
        then
          printf "\nIASL not found. "
          #
          # First we check the target directory (should be there after the first run)
          #
          # XXX: Jeroen, try curl --create-dirs without the mkdir here ;)
          if [ ! -d /usr/local/bin ];
            then
              printf "Creating target directory... "
              sudo mkdir -p /usr/local/bin/
              sudo chown -R root:wheel /usr/local/bin/
          fi

          printf "Downloading iasl...\n"
          sudo curl -o /usr/local/bin/iasl https://raw.github.com/Piker-Alpha/RevoBoot/clang/i386/libsaio/acpi/Tools/iasl
#         sudo curl https://raw.github.com/Piker-Alpha/RevoBoot/clang/i386/libsaio/acpi/Tools/iasl -o /usr/local/bin/iasl --create-dirs
          sudo chmod +x /usr/local/bin/iasl
          echo 'Done.'
      fi

      iasl=/usr/local/bin/iasl
  fi
}

#--------------------------------------------------------------------------------

function _checkSourceFilename
{
  #
  # Check for RevoBoot (legacy) setup on root volume.
  #
  if [[ -d /Extra/ACPI && -d /Extra/EFI ]];
    then
      let gIsLegacyRevoBoot=1

      if [[ $gDestinationPath != "/Extra/ACPI/" ]];
        then
          gDestinationPath="/Extra/ACPI/"
          _debugPrint "ACPI target directory changed to: ${gDestinationPath}\n"
      fi

      if [[ $gDestinationFile != "ssdt_pr.aml" ]];
        then
          gSsdtID="ssdt_pr"
          gSsdtPR="${gPath}/${gSsdtID}.dsl"
          gDestinationFile="ssdt_pr.aml"
          _debugPrint "ACPI target filename changed to: ${gDestinationFile}\n"
      fi
  fi
}

#--------------------------------------------------------------------------------

function _setDestinationPath
{
  #
  # Check for mounted EFI volume.
  #
  if [ ! -d /Volumes/EFI ];
    then
      #
      # Not there.
      #
      echo 'Creating temporarily mount point: /Volumes/EFI'
      sudo mkdir /Volumes/EFI
      printf 'Mounting EFI partition...\n'
      #
      # TODO: Get target disk from diskutil list
      #
      sudo mount_hfs /dev/disk0s1 /Volumes/EFI
      let gUnmountEFIPartition=1
  fi

  #
  # Check for RevoBoot (legacy) setup on EFI volume.
  #
  if [ -d /Volumes/EFI/Extra/ACPI ];
    then
      #
      # Update destination path.
      #
      gDestinationPath="/Volumes/EFI/Extra/ACPI/"
      _debugPrint "ACPI target directory changed to: ${gDestinationPath}"

      if [[ $gDestinationFile != "ssdt_pr.aml" ]];
        then
          gSsdtID="ssdt_pr"
          gSsdtPR="/Volumes/EFI/Extra/ACPI/${gSsdtID}.dsl"
          gDestinationFile="ssdt_pr.aml"
          _debugPrint "ACPI target filename changed to: ${gDestinationFile}\n"
      fi
    else
      #
      # Check for the new RevoBoot EFI edition.
      #
      if [ -d /Volumes/EFI/RevoEFI/ACPI ];
        then
          gDestinationPath="/Volumes/EFI/RevoEFI/ACPI/"
          _debugPrint "ACPI target directory changed to: ${gDestinationPath}\n"
          return
      fi
      #
      # Clover checks... must be checked or will be removed!!!
      #
      if [ -d /Volumes/EFI/Clover/ACPI/patched ];
        then
          gDestinationPath="/Volumes/EFI/CLOVER/ACPI/patched/"
          _debugPrint "ACPI target directory changed to: ${gDestinationPath}\n"
        else
          #
          # Check for older versions of Clover.
          #
          if [ -d /EFI/ACPI/patched ];
            then
              gDestinationPath="/EFI/ACPI/patched/"
              echo 'ACPI target directory changed to: '$gDestinationPath
          fi
      fi
  fi
}

#--------------------------------------------------------------------------------

function _getCPUNumberFromBrandString
{
  #
  # Get CPU brandstring
  #
  gBrandString=$(echo `sysctl machdep.cpu.brand_string` | sed -e 's/machdep.cpu.brand_string: //')
  #
  # Show brandstring (this helps me to debug stuff).
  #
  printf "Brandstring '${gBrandString}'\n"
  #
  # Save default (0) delimiter
  #
  local ifs=$IFS
  #
  # Change delimiter to a space character
  #
  IFS=" "
  #
  # Split brandstring into array (data)
  #
  local data=($gBrandString)
  #
  # Teststrings
  #
  # local data=("Intel(R)" "Xeon(R)" "CPU" "E3-1220" "@" "2.5GHz")
  # local data=("Intel(R)" "Xeon(R)" "CPU" "E3-1220" "v2" "@" "2.5GHz")
  # local data=("Intel(R)" "Xeon(R)" "CPU" "E3-1220" "v3" "@" "2.5GHz")
  # local data=("Intel(R)" "Xeon(R)" "CPU" "E3-1220" "0" "@" "2.5GHz")
  # local data=("Intel(R)" "Core(TM)" "i5-4670K" "CPU" "@" "3.40GHz")

  #
  # Example from a MacBookPro10,2
  #
  # echo "${data[0]}" # Intel(R)
  # echo "${data[1]}" # Core(TM)
  # echo "${data[2]}" # i5-3210M
  # echo "${data[3]}" # CPU
  # echo "${data[4]}" # @
  # echo "${data[5]}" # 2.50GHz
  #
  # or: "Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz"
  #
  # echo "${data[0]}" # Intel(R)
  # echo "${data[1]}" # Xeon(R)
  # echo "${data[2]}" # CPU
  # echo "${data[3]}" # E3-12XX
  # echo "${data[4]}" # V2
  # echo "${data[5]}" # @
  # echo "${data[6]}" # 3.30GHz
  #
  # Restore the default delimiter
  #
  IFS=$ifs

  let length=${#data[@]}

  if (( length > 7 ));
    then
      echo 'Warning: The brandstring has an unexpected length!'
  fi

  #
  # Is this a Xeon processor model?
  #
  if [[ "${data[1]}" == "Xeon(R)" ]];
    then
      #
      # Yes. Check for lower/upper case 'v' or '0' for OEM processors.
      #
      if [[ "${data[4]}" =~ "v" || "${data[4]}" =~ "V" ]];
        then
            #
            # Use a lowercase 'v' because that is what we use in our data.
            #
            gProcessorNumber="${data[3]} v${data[4]:1:1}"
        elif [[ "${data[4]}" == "0" ]];
          then
            #
            # OEM CPU's have been reported to use a "0" instead of "v2"
            # and thus let's use that to make our data match the CPU.
            #
            gProcessorNumber="${data[3]} v2"
      fi
    else
      #
      # All other non-Xeon processor models.
      #
      gProcessorNumber="${data[2]}"
  fi
}

#--------------------------------------------------------------------------------

function _getCPUDataByProcessorNumber
{
  #
  # Local function definition
  #
  function __searchList()
  {
    local ifs=$IFS
    let targetType=0

    case $1 in
        2) local cpuSpecLists=("gDesktopSandyBridgeCPUList[@]" "gMobileSandyBridgeCPUList[@]" "gServerSandyBridgeCPUList[@]")
           ;;
        4) local cpuSpecLists=("gDesktopIvyBridgeCPUList[@]" "gMobileIvyBridgeCPUList[@]" "gServerIvyBridgeCPUList[@]")
           ;;
        8) local cpuSpecLists=("gDesktopHaswellCPUList[@]" "gMobileHaswellCPUList[@]" "gServerHaswellCPUList[@]")
           ;;
       16) local cpuSpecLists=("gDesktopBroadwellCPUList[@]" "gMobileBroadwellCPUList[@]" "gServerBroadwellCPUList[@]")
           ;;
    esac

    for cpuList in ${cpuSpecLists[@]}
    do
      let targetType+=1
      local targetCPUList=("${!cpuList}")

      for cpuData in "${targetCPUList[@]}"
      do
        IFS=","
        data=($cpuData)

        if [[ ${data[0]} == $gProcessorNumber ]];
          then
            gProcessorData="$cpuData"
            let gTypeCPU=$targetType
            let gBridgeType=$1
            IFS=$ifs
            return
        fi
      done
    done

    IFS=$ifs
  }

  #
  # Local function callers
  #
  __searchList $SANDY_BRIDGE

  if (!(( $gTypeCPU )));
    then
      __searchList $IVY_BRIDGE
  fi

  if (!(( $gTypeCPU )));
    then
      __searchList $HASWELL
  fi

  if (!(( $gTypeCPU )));
    then
      __searchList $BROADWELL
  fi

}

#--------------------------------------------------------------------------------

function _showLowPowerStates()
{
  #
  # Local function definition
  #
  function __print()
  {
    local mask=1
    local cStates=$1

    printf "Injected C-States for ${gProcessorNames[$2]} ("
    #
    # Haswell    : C0, C1, C1E, C2E, C3, C4, C6 and C7
    # Haswell-ULT: C0, C1, C1E, C2E, C3, C4, C6, C7, C8, C9 and C10
    #
    for state in C1 C2 C3 C6 C7 C8 C9 C10
    do
      if (($cStates & $mask));
        then
          if (($mask > 1));
            then
              printf ","
          fi

          printf "$state"
        fi

        let mask=$(($mask << 1))
    done

    echo ')'
  }

  #
  # Local function callers
  #
  __print $gACST_CPU0 0

  if [ $gBridgeType -ge $IVY_BRIDGE ];
    then
      __print $gACST_CPU1 1
  fi
}

#--------------------------------------------------------------------------------

function _checkPlatformSupport()
{
  #
  # Local function definition
  #
  function __searchList()
  {
    local data=`awk '/<key>'${1}'<\/key>.*/,/<\/array>/' /System/Library/CoreServices/PlatformSupport.plist`
    local targetList=(`echo $data | egrep -o '(<string>.*</string>)' | sed -e 's/<\/*string>//g'`)

    for item in "${targetList[@]}"
    do
      if [ "$item" == "$2" ];
        then
          return 1
      fi
    done

    return 0
  }
  #
  # This check is required for Snow Leopard compatibility!
  #
  if [ -f /System/Library/CoreServices/PlatformSupport.plist ];
    then
      __searchList 'SupportedModelProperties' $1

      if (( $? == 0 ));
        then
          __searchList 'SupportedBoardIds' $2

          if (($? == 0));
            then
              echo 'Warning: Model identifier ['$1'] and board-id ['$2'] missing in: /S*/L*/CoreServices/PlatformSupport.plist'
          fi
      fi
    else
      echo 'Warning: /S*/L*/C*/PlatformSupport.plist not found (normal for Snow Leopard)!'
  fi
}

#--------------------------------------------------------------------------------

function _checkSMCKeys()
{
    #
    # TODO: Check SMC keys to see if they are there and properly initialized!
    #
    # Note: Do <i>not</i> dump SMC keys with HWSensors/iStat or other SMC plug-ins installed!
    #
    local filename="/System/Library/Extensions/FakeSMC.kext/Contents/Info.plist"
    local data=`grep -so '<key>[a-zA-Z]*</key>' $filename | sed -e 's/<key>//' -e 's/<\/key>//g'`

    local status=`echo $data | grep -oe 'DPLM'`

    if [ $status == 'DPLM' ]; then
        # DPLM  [{lim]  (bytes 00 00 00 00 00)
        # CPU, Idle, IGPU, EGPU and Memory P-State limits
        echo "SMC key 'DPLM' found (OK)"
    fi
set -x
    local status=`echo $data | grep -oe 'MSAL'`

    if [ $status == 'MSAL' ]; then
        # MSAL  [hex_]  (bytes 4b)
        echo "SMC key 'MSAL' found (OK)"
    fi
}

#--------------------------------------------------------------------------------

function _checkForXCPM()
{
  #
  # Check OS version ('machdep.xcpm' is introduced in 10.8.5)
  #
  if [[ $gOSVersion > 1084 ]];
    then
      #
      # Yes. Update global variable.
      #
      let gXcpm=$(/usr/sbin/sysctl -n machdep.xcpm.mode)
      #
      # Is xcpm active?
      #
      if [[ $gXcpm -eq 1 && $gIvyWorkAround -gt 0 ]];
        then
          #
          # Yes. Disable Ivy Bridge workarounds.
          #
          let gIvyWorkAround=0
          #
          # Is the target processor an Ivy Bridge one?
          #
          if [[ $gBridgeType == $IVY_BRIDGE ]];
            then
              #
              # Yes. inform the user about the change.
              #
              printf "\nXCPM detected (Ivy Bridge workarounds disabled)\n\n"
          fi
      fi
  fi
}


#--------------------------------------------------------------------------------

function _initSandyBridgeSetup()
{
  gSystemType=2
  gACST_CPU0=29   # C1, C3, C6 and C7
  gACST_CPU1=7    # C1, C2 and C3

  case $boardID in
    Mac-942B5BF58194151B) gSystemType=1
                          gMacModelIdentifier="iMac12,1"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-942B59F58194171B) gSystemType=1
                          gMacModelIdentifier="iMac12,2"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-8ED6AF5B48C039E1) gSystemType=1
                          gMacModelIdentifier="Macmini5,1"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-4BC72D62AD45599E) gSystemType=1
                          gMacModelIdentifier="Macmini5,2"
                          gACST_CPU0=13   # C1, C3, C6 and C7
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-7BA5B2794B2CDB12) gSystemType=1
                          gMacModelIdentifier="Macmini5,3"
                          gACST_CPU0=13   # C1, C3, C6 and C7
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-94245B3640C91C81) gMacModelIdentifier="MacBookPro8,1"
                          ;;

    Mac-94245A3940C91C80) gMacModelIdentifier="MacBookPro8,2"
                          ;;

    Mac-942459F5819B171B) gMacModelIdentifier="MacBookPro8,3"
                          ;;

    Mac-C08A6BB70A942AC2) gMacModelIdentifier="MacBookAir4,1"
                          ;;

    Mac-742912EFDBEE19B3) gMacModelIdentifier="MacBookAir4,2"
                          ;;
  esac
}

#--------------------------------------------------------------------------------

function _initIvyBridgeSetup()
{
  gSystemType=2
  gACST_CPU0=29   # C1, C3, C6 and C7
  gACST_CPU1=7    # C1, C2 and C3

  case $boardID in
    Mac-00BE6ED71E35EB86) gSystemType=1
                          gMacModelIdentifier="iMac13,1"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-FC02E91DDD3FA6A4) gMacModelIdentifier="iMac13,2"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-031AEE4D24BFF0B1) gMacModelIdentifier="Macmini6,1"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-F65AE981FFA204ED) gMacModelIdentifier="Macmini6,2"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-4B7AC7E43945597E) gMacModelIdentifier="MacBookPro9,1"
                          ;;

    Mac-6F01561E16C75D06) gMacModelIdentifier="MacBookPro9,2"
                          ;;

    Mac-C3EC7CD22292981F) gMacModelIdentifier="MacBookPro10,1"
                          ;;

    Mac-AFD8A9D944EA4843) gMacModelIdentifier="MacBookPro10,2"
                          ;;

    Mac-66F35F19FE2A0D05) gMacModelIdentifier="MacBookAir5,1"
                          ;;

    Mac-2E6FAB96566FE58C) gMacModelIdentifier="MacBookAir5,2"
                          ;;

    Mac-F60DEB81FF30ACF6) gSystemType=3
                          gMacModelIdentifier="MacPro6,1"
                          gACST_CPU0=13   # C1, C3, C6
                          gACST_CPU1=13   # C1, C3, C6
                          ;;
	esac
}

#--------------------------------------------------------------------------------

function _initHaswellSetup()
{
  gSystemType=2
  gACST_CPU0=29   # C1, C3, C6 and C7
  gACST_CPU1=7    # C1, C2 and C3

  case $boardID in
    Mac-031B6874CF7F642A) gSystemType=1
                          gMacModelIdentifier="iMac14,1"
                          ;;

    Mac-27ADBB7B4CEE8E61) gSystemType=1
                          gMacModelIdentifier="iMac14,2"
                          ;;

    Mac-77EB7D7DAF985301) gSystemType=1
                          gMacModelIdentifier="iMac14,3"
                          ;;

    Mac-189A3D4F975D5FFC) gMacModelIdentifier="MacBookPro11,1"
                          gACST_CPU0=253  # C1, C3, C6, C7, C8, C9 and C10
                          gACST_CPU1=31   # C1, C2, C3, C6 and C7
                          ;;

    Mac-3CBD00234E554E41) gMacModelIdentifier="MacBookPro11,2"
                          gACST_CPU0=253  # C1, C3, C6, C7, C8, C9 and C10
                          gACST_CPU1=31   # C1, C2, C3, C6 and C7
                          ;;

    Mac-2BD1B31983FE1663) gMacModelIdentifier="MacBookPro11,3"
                          gACST_CPU0=253  # C1, C3, C6, C7, C8, C9 and C10
                          gACST_CPU1=31   # C1, C2, C3, C6 and C7
                          ;;

    Mac-35C1E88140C3E6CF) gMacModelIdentifier="MacBookAir6,1"
                          ;;

    Mac-7DF21CB3ED6977E5) gMacModelIdentifier="MacBookAir6,2"
                          ;;

    Mac-F60DEB81FF30ACF6) gSystemType=3
                          gMacModelIdentifier="MacPro6,1"
                          gACST_CPU0=13   # C1, C3, C6
                          gACST_CPU1=13   # C1, C3, C6
                          ;;
  esac
}

#--------------------------------------------------------------------------------

function _initBroadwellSetup()
{
  gSystemType=2
  gACST_CPU0=253  # C1, C3, C6, C7, C8, C9 and C10
  gACST_CPU1=31   # C1, C2, C3, C6 and C7

  case $boardID in
    Mac-APPLE-BROADWELLS) gSystemType=1
                          gMacModelIdentifier="Macmini7,1"
                          ;;
  esac
}

#--------------------------------------------------------------------------------

function _exitWithError()
{
  case "$1" in
      2) echo -e "\nError: 'MaxTurboFrequency' must be in the range of $frequency-$gMaxOCFrequency... exiting\n" 1>&2
         exit 2
         ;;
      3) echo -e "\nError: 'TDP' must be in the range of 10-150 Watts... exiting\n" 1>&2
         exit 3
         ;;
      4) echo -e "\nError: 'BridgeType' must be 0, 1 or 2... exiting\n" 1>&2
         exit 4
         ;;
      5) echo -e "\nError: Unknown processor number... exiting\n" 1>&2
         exit 5
         ;;
      6) echo -e "\nError: Processor label length is less than 3... exiting\n" 1>&2
         exit 6
         ;;
      7) echo -e "\nError: Processor label not found... exiting\n" 1>&2
         exit 7
         ;;
      8) echo -e "\nError: Processor Declaration not found... exiting\n" 1>&2
         exit 8
         ;;
      *) exit 1
         ;;
  esac
}

#--------------------------------------------------------------------------------

function main()
{
  #
  # Local variable definitions.
  #
  local turboStates
  local assumedTDP
  local modelSpecified
  local maxTurboFrequency

  printf "\nssdtPRGen.sh v0.9 Copyright (c) 2011-2012 by † RevoGirl\n"
  echo   '             v6.6 Copyright (c) 2013 by † Jeroen'
  printf "             v$gScriptVersion Copyright (c) 2013-$(date "+%Y") by Pike R. Alpha\n"
  echo   '-----------------------------------------------------------------'
  printf "System information: $gProductName $gProductVersion ($gBuildVersion)\n"

  let assumedTDP=0
  let modelSpecified=0
  let maxTurboFrequency=0

  _checkSourceFilename
  _getCPUNumberFromBrandString

#   _debugPrint "\ngProcessorNumber: $gProcessorNumber\n"

    if [[ "$1" != "" ]];
      then
        # Sandy Bridge checks
        if [[ ${1:0:4} == "i3-2" || ${1:0:4} == "i5-2" || ${1:0:4} == "i7-2" ]];
          then
            let modelSpecified=1
            gProcessorNumber=$1
        fi
        # Ivy Bridge checks
        if [[ ${1:0:4} == "i3-3" || ${1:0:4} == "i5-3" || ${1:0:4} == "i7-3" ]];
          then
            let modelSpecified=1
            gProcessorNumber=$1
        fi
        # Haswell checks
        if [[ ${1:0:4} == "i3-4" || ${1:0:4} == "i5-4" || ${1:0:4} == "i7-4" ]];
          then
            let modelSpecified=1
            gProcessorNumber=$1
        fi
        # Xeon check
        if [[ ${1:0:1} == "E" ]];
          then
            let modelSpecified=1
            gProcessorNumber=$1
        fi
    fi

    _getCPUDataByProcessorNumber

    if [[ $modelSpecified -eq 1 && $gTypeCPU -eq 0 ]];
      then
        _exitWithError $PROCESSOR_NUMBER_ERROR
    fi

    if [[ $gBridgeType -eq 0 ]];
      then
        local model=$(_getCPUModel)

        if (($model==0x2A));
          then
            let gTdp=95
            let gBridgeType=2
        fi

        if (($model==0x2D));
          then
            let assumedTDP=1
            let gTdp=130
            let gBridgeType=2
        fi

        if (($model==0x3A || $model==0x3B || $model==0x3E));
          then
            let assumedTDP=1
            let gTdp=77
            let gBridgeType=4
        fi

        # Haswell
        if (($model==0x3C));
          then
            let assumedTDP=1
            let gTdp=84
            let gBridgeType=8
            let gMaxOCFrequency=8000
        fi

        # Haswell SVR
        if (($model==0x3F));
          then
            let assumedTDP=1
            let gTdp=130
            let gBridgeType=8
        fi

        # Haswell ULT
        if (($model==0x45));
          then
            let assumedTDP=1
            let gTdp=15
            let gBridgeType=8
        fi
    fi

    case $gBridgeType in
        2) local bridgeTypeString="Sandy Bridge"
           ;;
        4) local bridgeTypeString="Ivy Bridge"
           ;;
        8) local bridgeTypeString="Haswell"
           ;;
        *) local bridgeTypeString="Unknown"
           ;;
    esac

    _getBoardID
    _getProcessorNames
    _getProcessorScope

    local modelID=$(_getModelName)
    local cpu_type=$(_getCPUtype)
    local currentSystemType=$(_getSystemType)
    local cpuSignature=$(_getCPUSignature)

    echo "Generating ${gSsdtID}.dsl for a $modelID [$boardID]"
    echo "$bridgeTypeString Core $gProcessorNumber processor [$cpuSignature] setup [0x${cpu_type}]"

    #
    # gTypeCPU is greater than 0 when the processor is found in one of the CPU lists
    #
    if (($gTypeCPU));
      then
        local ifs=$IFS
        IFS=","
        local cpuData=($gProcessorData)
        gTdp=${cpuData[1]}
        let lfm=${cpuData[2]}
        let frequency=${cpuData[3]}
        let maxTurboFrequency=${cpuData[4]}

        if [ $maxTurboFrequency == 0 ];
          then
            let maxTurboFrequency=$frequency
        fi

        let gLogicalCPUs=${cpuData[6]}

        IFS=$ifs

        echo 'With a maximum TDP of '$gTdp' Watt, as specified by Intel'

        #
        # Check Low Frequency Mode (may be 0 aka still unknown)
        #
        if (($lfm > 0));
          then
            let gBaseFrequency=$lfm
          else
            echo -e "\nWarning: Low Frequency Mode is 0 (unknown/unconfirmed)"

            if (($gTypeCPU == gMobileCPU));
              then
                echo -e "         Now using 1200 MHz for Mobile processor\n"
                let gBaseFrequency=1200
               else
                 echo -e "         Now using 1600 MHz for Server/Desktop processors\n"
                 let gBaseFrequency=1600
            fi
        fi
      else
        let gLogicalCPUs=$(echo `sysctl machdep.cpu.thread_count` | sed -e 's/^machdep.cpu.thread_count: //')
        let frequency=$(echo `sysctl hw.cpufrequency` | sed -e 's/^hw.cpufrequency: //')
        let frequency=($frequency / 1000000)

        if [[ $assumedTDP -eq 1 ]];
          then
            echo "With a maximum TDP of ${gTdp} Watt - assumed/undetected CPU may require override value!"
        fi
    fi

    #
    # Script argument checks
    #
    if [[ $# -ge 2 ]];
      then
        if [[ "$2" =~ ^[0-9]+$ ]];
          then
            if [[ $2 -lt $frequency || $2 -gt $gMaxOCFrequency ]];
              then
                _exitWithError $MAX_TURBO_FREQUENCY_ERROR

              else
                if [[ $2 -gt $maxTurboFrequency ]];
                  then
                    echo "Override value: Max Turbo Frequency, now using: $2 MHz!"
                    let maxTurboFrequency=$2
                fi
            fi
        fi
    fi

    if [ $# -ge 3 ];
      then
        if [[ "$3" =~ ^[0-9]+$ ]];
          then
            if [[ $3 -lt 10 || $3 -gt 150 ]];
              then
                _exitWithError $MAX_TDP_ERROR

              else
                if [[ $gTdp != $3 ]];
                  then
                    let gTdp=$3
                    echo "Override value: Max TDP, now using: $gTdp Watt!"
                fi
            fi
          else
            _exitWithError $MAX_TDP_ERROR
        fi
    fi

    if [ $# -ge 4 ];
      then
        if [[ "$4" =~ ^[0-9]+$ ]];
          then
            local detectedBridgeType=$gBridgeType

            case "$4" in
                  0) let gBridgeType=2
                     local bridgeTypeString='Sandy Bridge'
                     ;;
                  1) let gBridgeType=4
                     local bridgeTypeString='Ivy Bridge'
                     ;;
                  2) let gBridgeType=8
                     local bridgeTypeString='Haswell'
                     ;;
                  *) _exitWithError $TARGET_CPU_ERROR
                     ;;
            esac

            if [[ $detectedBridgeType -ne $((2 << $4)) ]];
              then
                echo "Override value: CPU type, now using: $bridgeTypeString"
            fi
          else
            _exitWithError $TARGET_CPU_ERROR
        fi
    fi

    if [ $# -eq 5 ];
      then
        if [ ${#5} -eq 3 ];
          then
            gProcLabel=$(echo "$5" | tr '[:lower:]' '[:upper:]')
            echo "Override value: Now using '$gProcLabel' for ACPI processor names!"
            _updateProcessorNames ${#gProcessorNames[@]}

          else
            _exitWithError $PROCESSOR_LABEL_LENGTH_ERROR
        fi
    fi

    echo "Number logical CPU's: $gLogicalCPUs (Core Frequency: $frequency MHz)"

    if [ $gLogicalCPUs -gt ${#gProcessorNames[@]} ];
      then
        _updateProcessorNames $gLogicalCPUs
    fi

    #
    # Check maxTurboFrequency
    #
    if [ $maxTurboFrequency -eq 0 ];
      then
        _exitWithError $MAX_TURBO_FREQUENCY_ERROR
    fi

	#
    # Get number of Turbo states.
    #
    let turboStates=$(echo "(($maxTurboFrequency - $frequency) / 100)" | bc)

    #
    # Check number of Turbo states.
    #
    if [ $turboStates -lt 0 ];
      then
        let turboStates=0
    fi

    #
    # Report number of Turbo States
    #
    if [ $turboStates -gt 0 ];
      then
        let minTurboFrequency=($frequency+100)
        echo "Number of Turbo States: $turboStates ($minTurboFrequency-$maxTurboFrequency MHz)"

      else
        echo "Number of Turbo States: 0"
    fi

    local packageLength=$(echo "((($maxTurboFrequency - $gBaseFrequency)+100) / 100)" | bc)

    echo "Number of P-States: $packageLength ($gBaseFrequency-$maxTurboFrequency MHz)"

    _printHeader
    _printExternals
    _checkForXCPM
    _printScopeStart $turboStates $packageLength $maxTurboFrequency
    _printPackages $frequency $turboStates $maxTurboFrequency

    case "$gBridgeType" in
      $SANDY_BRIDGE) local cpuTypeString="06"
                     _initSandyBridgeSetup
                     _printScopeACST 0
                     _printScopeCPUn
                     ;;
        $IVY_BRIDGE) local cpuTypeString="07"
                     _initIvyBridgeSetup
                     _printScopeACST 0
                     _printMethodDSM
                     _printScopeCPUn
                     ;;
        $HASWELL)    local cpuTypeString="08"
                     _initHaswellSetup
                     _printScopeACST 0
                     _printMethodDSM
                     _printScopeCPUn
                     ;;
        $BROADWELL)  local cpuTypeString="09"
                     _initBroadwellSetup
                     _printScopeACST 0
                     _printMethodDSM
                     _printScopeCPUn
                     ;;
    esac
    #
    # Is this a MacPro6,1 model?
    #
    if [[ $modelID == 'MacPro6,1' ]];
      then
        #
        # Yes. Use the correct string/value for the cpu-type suggestion.
        #
        local cpuTypeString="0a"
    fi

    _showLowPowerStates
    _checkPlatformSupport $modelID $boardID

    #
    # Some Sandy Bridge/Ivy Bridge CPUPM specific configuration checks
    #
    if [[ $gBridgeType -ne $HASWELL ]];
      then
        if [[ ${cpu_type:0:2} != $cpuTypeString ]];
          then
            echo -e "\nWarning: 'cpu-type' may be set improperly (0x$cpu_type instead of 0x$cpuTypeString${cpu_type:2:2})"
          elif [[ $gSystemType -eq 0 ]];
            then
                echo -e "\nWarning: 'board-id' [$boardID] is not supported by $bridgeTypeString PM"
            else
              if [ "$gMacModelIdentifier" != "$modelID" ];
                then
                  echo "Error: board-id [$boardID] and model [$modelID] mismatch"
              fi
        fi
    fi

    if [ $currentSystemType -ne $gSystemType ];
      then
        echo -e "\nWarning: 'system-type' may be set improperly ($currentSystemType instead of $gSystemType)"
    fi
}

#==================================== START =====================================

clear

if [ $# -eq 0 ];
  then
    main "" $1 $2 $3 $4
  else
    if [[ "$1" =~ ^[0-9]+$ ]];
      then
        main "" $1 $2 $3 $4
      else
        main "$1" $2 $3 $4 $5
    fi
fi

_findIasl

if (( $gCallIasl ));
  then
    #
    # Compile ssdt.dsl
    #
    sudo "$iasl" $gSsdtPR

    #
    # Copy ssdt_pr.aml to /Extra/ssdt.aml (example)
    #
    if (( $gAutoCopy ));
      then
        if [ -f ${gPath}/${gSsdtID}.aml ];
          then
            echo -e
            read -p "Do you want to copy ${gPath}/${gSsdtID}.aml to ${gDestinationPath}${gDestinationFile}? (y/n)?" choice
            case "$choice" in
                y|Y ) if [[ $gIsLegacyRevoBoot -eq 0 ]];
                        then
                          _setDestinationPath
                      fi

                      sudo cp ${gPath}/${gSsdtID}.aml ${gDestinationPath}${gDestinationFile}
                      #
                      # Check if we need to unmount the EFI volume.
                      #
                      if [[ $gIsLegacyRevoBoot -eq 0 && $gUnmountEFIPartition ]];
                        then
                          _debugPrint "Unmounting EFI partition...\n"
                          sudo umount -f /Volumes/EFI
                          #
                          # Check return status for Success.
                          #
                          # Note: Without this check we may end up removing the whole freaking EFI directory!
                          #
                          if [[ $? -eq 0 ]];
                            then
                              read -p  "Do you want to remove the temporarily mount point (y/n)?" choice2
                              case "$choice2" in
                                    y|Y ) #
                                          # You fool: don't use <em>rm</em> commands in a script!
                                          #
#                                         read -p  "Do you want to remove the temporarily mount point (y/n)?" choice3
#                                         case "$choice3" in
#                                             y|Y ) _debugPrint "Removing temporarily mount point...\n"
                                                    sudo rm -r /Volumes/EFI
#                                                   ;;
#                                         esac
                                          ;;
                              esac
                          fi
                      fi
                      ;;
            esac
        fi
    fi
fi
#
# Ask for confirmation before opening the new SSDT.dsl?
#
if [[ $gCallOpen -eq 2 ]];
  then
    #
    # Yes. Ask for confirmation.
    #
    read -p "Do you want to open ${gSsdtID}.dsl (y/n)?" openAnswer
    case "$openAnswer" in
        y|Y ) #
              # Ok. Override default behaviour.
              #
              let gCallOpen=1
        ;;
    esac
fi
#
# Should we open the new SSDT.dsl?
#
if [[ $gCallOpen -eq 1 ]];
  then
    #
    # Yes. Fire up the users editor of choice.
    #
    open $gSsdtPR
fi

exit 0
#================================================================================