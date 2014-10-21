#!/bin/bash
#
# Script (ssdtPRGen.sh) to create ssdt-pr.dsl for Apple Power Management Support.
#
# Version 0.9 - Copyright (c) 2012 by RevoGirl
# Version 14.0 - Copyright (c) 2014 by Pike <PikeRAlpha@yahoo.com>
#
# Updates:
#			- 		Added support for Ivy Bridge (Pike, January 2013)
#			- 		Filename error fixed (Pike, January 2013)
#			- 		Namespace error fixed in _printScopeStart (Pike, January 2013)
#			- 		Model and board-id checks added (Pike, January 2013)
#			- 		SMBIOS cpu-type check added (Pike, January 2013)
#			- 		Copy/paste error fixed (Pike, January 2013)
#			- 		Method ACST added to CPU scopes for IB CPUPM (Pike, January 2013)
#			- 		Method ACST corrected for latest version of iasl (Dave, January 2013)
#			- 		Changed path/filename to ~/Desktop/SSDT_PR.dsl (Dave, January 2013)
#			- 		P-States are now one-liners instead of blocks (Pike, January 2013)
#			- 		Support for flexible ProcessorNames added (Pike, Februari 2013)
#			- 		Better feedback and Debug() injection added (Pike, Februari 2013)
#			- 		Automatic processor type detection (Pike, Februari 2013)
#			- 		TDP and processor type are now optional arguments (Pike, Februari 2013)
#			- 		system-type check (used by X86PlatformPlugin) added (Pike, Februari 2013)
#			- 		ACST injection for all logical processors (Pike, Februari 2013)
#			- 		Introducing a stand-alone version of method _DSM (Pike, Februari 2013)
#			- 		Fix incorrect turbo range (Pike, Februari 2013)
#			- 		Restore IFS before return (Pike, Februari 2013)
#			- 		Better/more complete feedback added (Jeroen, Februari 2013)
#			- 		Processor data for desktop/mobile and server CPU's added (Jeroen, Februari 2013)
#			- 		Improved power calculation, matching Apple's new algorithm (Pike, Februari 2013)
#			- 		Fix iMac13,N latency and power values for C3 (Jeroen/Pike, Februari 2013)
#			- 		IASL failed to launch when path included spaces (Pike, Februari 2013)
#			- 		Typo in cpu-type check fixed (Jeroen, Februari 2013)
#			- 		Error in CPU data (i5-3317U) fixed (Pike, Februari 2013)
#			- 		Setting added for the target path/filename (Jeroen, Februari 2013)
#			- 		Initial implementation of auto-copy (Jeroen, Februari 2013)
#			- 		Additional checks added for cpu data/turbo modes (Jeroen, Februari 2013)
#			- 		Undo filename change done by Jeroen (Pike, Februari 2013)
#			- 		Improved/faster search algorithm to locate iasl (Jeroen, Februari 2013)
#			- 		Bug fix, automatic revision update and better feedback (Pike, Februari 2013)
#			- 		Turned auto copy on (Jeroen, Februari 2013)
#			- 		Download IASL if it isn't there where we expect it (Pike, Februari 2013)
#			- 		A sweet dreams update for Pike who wants better feedback (Jeroen, Februari 2013)
#			- 		First set of Haswell processors added (Pike/Jeroen, Februari 2013)
#			- 		More rigid testing for user errors (Pike/Jeroen, Februari 2013)
#			- 		Getting ready for new Haswell setups (Pike/Jeroen, Februari 2013)
#			- 		Typo and ssdtPRGen.command breakage fixed (Jeroen, Februari 2013)
#			- 		Target folder check added for _findIASL (Pike, Februari 2013)
#			- 		Set $baseFreqyency to $lfm when the latter isn't zero (Pike, Februari 2013)
#			- 		Check PlatformSupport.plist for supported model/board-id added (Jeroen, Februari 2013)
#			- 		New/expanded Sandy Bridge CPU lists, thanks to Francis (Jeroen, Februari 2013)
#			- 		More preparations for the official Haswell launch (Pike, Februari 2013)
#			- 		Fix for home directory with space characters (Pike, Februari 2013)
#			- 		Sandy Bridge CPU lists rearranged/extended, thanks to 'stinga11' (Jeroen, Februari 2013)
#			- 		Now supporting up to 16 logical cores (Jeroen, Februari 2013)
#			- 		Improved argument checking, now supporting a fourth argument (Jeroen/Pike, Februari 2013)
#			- 		Suppress override output when possible (Jeroen, Februari 2013)
#			- 		Get processor label from ioreg (Jeroen/Pike, Februari 2013)
#			- 		Create /usr/local/bin when missing (Jeroen, Februari 2013)
#			- 		Changed warnings to make them pop out in the on-screen log (Pike, March 2013)
#			- 		Now using the ACPI processor names of the running system (Pike, March 2013)
#			- 		Now supporting up to 256/0xff logical processors (Pike, March 2013)
#			- 		Command line argument for processor labels added (Pike, March 2013)
#			- 		Bug fix, overriding the cpu type displayed the wrong name (Jeroen, March 2013)
#			- 		Automatic detection of CPU scopes added (Pike, March 2013)
#			- 		Show warnings for Sandy Bridge systems as well (Jeroen, March 2013)
#			- 		New Intel Haswell processors added (Jeroen, April 2013)
#			- 		Improved Processor declaration detection (Jeroen/Pike, April 2013)
#			- 		New path for Clover revision 1277 (Jeroen, April 2013)
#			- 		Haswell's minimum core frequency is 800 MHz (Jeroen, April 2013)
#			- 		CPU signature output added (Jeroen/Pike, April 2013)
#			- 		Updating to v6.4 after Jeroen's accidental RM of my local RevoBoot directory (Pike, May 2013)
#			- v6.5	Updating to v6.5 with bugs fixes and EFI partition checking for Clover compatibility (Pike, May 2013)
#			- 		Output of Clover ACPI directory detection fixed (Pike, June 2013)
#			- 		Haswell CPUs added (Jeroen, June 2013)
#			- 		board-id's for new MacBookAir6,[1/2] added (Pike, June 2013)
#			- 		board-id's for new iMac14,[1/2/3] added (Pike, October 2013)
#			- 		board-id's for new MacBookPro11,[1/2/3] added (Pike, October 2013)
#			- 		Cleanups and board-id for new MacPro6,1 added (Pike, October 2013)
#			– 		Frequency error in i7-4700MQ data fixed, thanks to RehabMan (Pike, November 2013)
#			- 		Intel i5-4200M added (Pike, December 2013)
#			- 		LFM fixed in the Intel i7-3930K data (Pike, December 2013)
#			- 		Intel E5-2695 V2 added (Pike, December 2013)
#			- 		Intel i3-3250 added (Pike, December 2013)
#			- 		Sed RegEx error fixed in _getCPUtype (Pike, January 2014)
#			- 		Fixed a typo 's/i7-2640M/i7-2674M/' (Pike, January 2014)
#			- 		Fixed a typo 's/gHaswellCPUList/gServerHaswellCPUList/' (Pike, January 2014)
#			- 		Intel E5-26nn v2 Xeon Processors added (Pike, January 2014)
#			- v8.0	Show the CPU brandstring at all times (Pike, January 2014)
#			- 		Fixed cpu-type suggestion for MacPro6,1 (Pike, January 2014)
#			- 		Intel i7-4771 added (Pike, January 2014)
#			- 		A couple Intel Haswell/Crystal Well processor models added (Pike, January 2014)
#			- 		Moved a couple of Ivy Bridge desktop model processors to the right spot (Pike, January 2014)
#			- 		Experimental code added for Gringo Vermelho (Pike, January 2014)
#			- 		Fixed a typo so that checking gIvyWorkAround really works (Pike, January 2014)
#			- 		Added extra OS checks (as a test) to filter out possibly unwanted LFM P-States (Pike, January 2014)
#			- 		Let gIvyWorkAround control the additional LFM P-States (Pike, January 2014)
#			- 		Fixed a typo in processor data (i7-4960K should be i7-4960X) (Pike, January 2014)
#			- v9.5	Missing Haswell i3 processor data added (Pike, Februari 2014)
#			- 		TDP can now also be a floating-point number (Pike, Februari 2014)
#			- 		New Broadwell processor preps (Pike, Februari 2014)
#			- 		Reformatted code layout (Pike, Februari 2014)
#			- 		Changed a bunch of misnamed (local) variables (Pike, Februari 2014)
#			- 		Fixed a couple of let/local mixups (Pike, Februari 2014)
#			- 		Destination path/filename no longer defauls to RevoBoot (Pike, Februari 2014)
#			- 		Support for RevoEFI added (Pike, Februari 2014)
#			- 		Changed SSDT.dsl open behaviour/ask for confirmation (Pike, Februari 2014)
#			- 		Additional processor scope check to get \_SB_ (Pike, Februari 2014)
#			- 		Set gIvyWorkAround=0 when XCPM is being used (Pike, Februari 2014)
#			- 		Added a lost return (Pike, Februari 2014)
#			- 		Fixed some layout issues (Pike, Februari 2014)
#			- 		Removed a misleading piece of text (Pike, Februari 2014)
#			- v10.0	Search for Scope (\_PR_) instead of just "_PR_" (Pike, Februari 2014)
#			- 		Major rewrite/new routines added to search for the processor scope (Pike, Februari 2014)
#			- 		New error message/added text about SMBIOS (Pike, Februari 2014)
#			- 		Ask for confirmation when the script may break/produce errors (Pike, Februari 2014)
#			- 		Double "${" error on line 1640 fixed (Pike, Februari 2014)
#			- v11.0	gSystemType for Ivy Bridge desktop models fixed (Pike, Februari 2014)
#			- 		major rewrite to support more flexible script arguments (Pike, Februari 2014)
#			- 		lists with supported board-id/model combinations added (Pike, Februari 2014)
#			- 		renamed argument -l to -s (Pike, Februari 2014)
#			- 		argument -l is now used to override the number of logical processors (Pike, Februari 2014)
#			- 		fixed cpu/bridge type override logic (Pike, Februari 2014)
#			- 		more comments added (Pike, Februari 2014)
#			- 		change bridge type from Sandy Bridge to Ivy Bridge when -w argument is used (Pike, Februari 2014)
#			- 		Use Scope (_PR) {} if found for DSDT's without Processor declarations (Pike, Februari 2014)
#			- 		less cluttered output (Pike, Februari 2014)
#			- 		check all processor declarations instead of just the first one (Pike, Februari 2014)
#			- 		show warning if not all processor declarations are found in the DSDT (Pike, Februari 2014)
#			- 		first set of changes for multi-processor support (Pike, Februari 2014)
#			- v12.0	inconsistency in argument -c values fixed (Pike, Februari 2014)
#			- 		fixed a couple of typos (Pike, Februari 2014)
#			- 		show less/ignore some debug warnings (Pike, Februari 2014)
#			- 		multi-processor support added (Pike, Februari 2014)
#			- 		fixed an issue when argument -p was used (Pike, Februari 2014)
#			-		inconsistency in argument -a fixed (Pike, Februari 2014)
#			- 		mixup of $data / $matchingData fixed (Pike, Februari 2014)
#			- 		better deviceName check/stop warning with wrong values (Pike, Februari 2014)
#			- 		skip inactive cores with -k clock-frequency in function _getProcessorNames (Pike, March 2014)
#			- 		processor data for the Intel E5-2620 added (Pike, March 2014)
#			- v12.5	processor data for the Intel i3-3250T and i3-3245 added (Pike, March 2014)
#			- 		processor data for the Intel E5-1600 v2 product family added (Pike, March 2014)
#			- v12.7	processor data for the Intel E5-1650 v2 fixed (Pike, March 2014)
#			- v12.8	processor data for the Intel i5-4300 mobile processor series added (Pike, March 2014)
#			- v12.9	processor data for the Intel E5-2600 and E5-4600 processor series added (Pike, March 2014)
#			- v13.0	removed unused variable 'checkGlobalProcessorScope' (Pike, April 2014)
#			- 		missing deviceName in two calls to _debugPrint fixed (Pike, April 2014)
#			- 		fixed a typo in help text for -d and now -d 2 also works again (Pike, April 2014)
#			- 		made -help work (Pike, April 2014)
#			- 		stop overwriting the ACPI processor scope name with the last one, by using $scopeIndex (Pike, April 2014)
#			- 		debug data fixed/running processor was missing when the -p argument was used (Pike, April 2014)
#			- 		more text hidden/only shown when -d [2/3] argument is used (Pike, April 2014)
#			- 		improved multi-processor support (Pike, April 2014)
#			- v13.1	enhanced _debugPrint with argument support (Pike, April 2014)
#			- 		Haswell refresh (desktop) processor data added.
#			- 		triple/quad byte package length support added .
#			- 		typo in help text (-turbo) fixed.
#			- 		opcode error ('Name' instead of 'Device') fixed.
#			- v13.2	fix for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/21 (Pike, April 2014)
#			- v13.3	additional Haswell refresh (desktop/mobile) processor data added (Pike, April 2014)
#			- 		fix for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/25
#			- 		TDP value for the i5-4200Y and i3-4010Y fixed.
#			- v13.4	processor data for upcomming Xeon E3-12nn v3 models added (Pike, April 2014)
#			- v13.5	processor data for i5-4440S,i5-4570TE,i5-4400E,i5-4402E and i5-4200H added (Pike, May 2014)
#			- v13.6	processor data update for mobile i5/i7 and future Haswell-E processors (Pike, July 2014)
#			- v13.7	moved some processor data from mobile to desktop definitions (Pike, August 2014)
#			- 		fix for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/47
#			- 		processor data for missing i3 Haswell processors added.
#			- v13.8	processor data for i7-3900 Mobile Processor Extreme Edition added (Pike, September 2014)
#			- v13.9	processor data for Xeon E5-16NN v3 and E5-26NN v3 Processor Series added (Pike, September 2014)
#			- v14.0	zipped up data of acpiTableExtract tool added (Pike, October 2014)
#			-		Support for Yosemite added (no longer using ioreg to get ACPI table data).
#			-		Commit text/version information copied from Github (partly/too much work).
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
#			- Thanks to 'Rals2007' for reporting the double "${${" error on line 1640.
#			- Thanks to 'MMMProd' for reporting the -eg instead of -eq error on line 3567.
#			- Thanks to 'DKMN' for reporting the omision of the Intel E5-2620.
#			- Thanks to 'nijntje' (blog) for reporting the omision of the Intel i3-3245.
#			- Thanks to 't2m' for (blog) for reporting the omision of the Intel E5-1600 product family.
#			- Thanks to 'arkanisman' for reporting the missing data of the Intel E5-2650.
#			- Thanks to 'dsaltos' on Github issues for reporting the omision of the Intel i5-4400S.
#
# Bugs:
#			- Bug reports can be filed at https://github.com/Piker-Alpha/RevoBoot/issues
#			  Please provide clear steps to reproduce the bug, the output of the
#			  script and the resulting SSDT.dsl Thank you!
#
# Usage (v11.0 and greater):
#
#           - ./ssdtPRGen.sh -h[elp]
#

# set -x # Used for tracing errors (can be used anywhere in the script).

#================================= GLOBAL VARS ==================================

#
# Script version info.
#
gScriptVersion=14.0

#
# Initial xcpm mode. Default value is -1 (uninitialised).
#
let gXcpm=-1

#
# Change this when your CPU is stuck in Low Frequency Mode!
#
# 1 - Injects one extra Turbo P-State at he top with max-Turbo frequency + 1 MHz.
# 2 - Injects N extra Turbo P-States at the bottom.
# 3 - Injects both of them.
#
# Note: Will be changed to 0 in _checkForXCPM() when XCPM mode is detected.
#
let gIvyWorkAround=0

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
# Get user id
#
let gID=$(id -u)

#
# Lowest possible idle frequency (user configurable). Also known as Low Frequency Mode.
#
let gBaseFrequency=1600

#
# This is the default processor label (verified by _setProcessorLabel).
#
gProcLabel="CPU"

#
# The Processor scope will be initialised by _initProcessorScope).
#
gScope=""

#
# Legacy RevoBoot status (default value is 0).
#
let gIsLegacyRevoBoot=0

#
# Change this to 0 if you don't want additional styling (bold/underlined).
#
let gExtraStyling=1

#
# Global variable used by some functions to return a value to the callee. 
#
let gFunctionReturn=0

#
# Global variable used for the used/target board-id.
#
gBoardID=""

#
# Global variable used for the used/target board-id.
#
gModelID=""

#
# Number of logical processors.
#
let gLogicalCPUs=0

#
# Clock frequency (uninitialised).
#
let gFrequency=-1

#
# Set to 1 if _PR scope is found in the DSDT.
#
let gScopePRFound=0

#
# For future use!
#
# Note: Set this to 0 when you want to inject ACPI Processor (...) {} declarations intead of External () objects.
#
let gInjectExternalObjects=1

#
# Output styling.
#
STYLE_RESET="[0m"
STYLE_BOLD="[1m"
STYLE_UNDERLINED="[4m"

#
# Other global variables.
#

gRevision='0x000'${gScriptVersion:0:2}${gScriptVersion:3:1}'00'

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

gTargetMacModel=""

let SANDY_BRIDGE=2
let IVY_BRIDGE=4
let HASWELL=8
let BROADWELL=16

#
# Global variable used as target cpu/bridge type.
#
let gBridgeType=-1

let gTypeCPU=0
let gProcessorStartIndex=0
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
# Setup supported byte encodings
#
# Note: value is number of characters that we read.
#
let AML_SINGLE_BYTE_ENCODING=2
let AML_DUAL_BYTE_ENCODING=4
let AML_TRIPLE_BYTE_ENCODING=6
let AML_QUAD_BYTE_ENCODING=8

#
# Setup used AML encoding values.
#
AML_SCOPE_OPCODE=10
AML_DEVICE_OPCODE=5b82
AML_PROCESSOR_SCOPE_OPCODE=5b83

#
# Global variable with supported board-id / model name for Sandy Bridge processors.
#
gSandyBridgeModelData=(
Mac-942B5BF58194151B:iMac12,1
Mac-942B59F58194171B:iMac12,2
Mac-8ED6AF5B48C039E1:Macmini5,1
Mac-4BC72D62AD45599E:Macmini5,2
Mac-7BA5B2794B2CDB12:Macmini5,3
Mac-94245B3640C91C81:MacBookPro8,1
Mac-94245A3940C91C80:MacBookPro8,2
Mac-942459F5819B171B:MacBookPro8,3
Mac-C08A6BB70A942AC2:MacBookAir4,1
Mac-742912EFDBEE19B3:MacBookAir4,2
)


#
# Global variable with supported board-id / model name for Ivy Bridge processors.
#
gIvyBridgeModelData=(
Mac-00BE6ED71E35EB86:iMac13,1
Mac-FC02E91DDD3FA6A4:iMac13,2
Mac-031AEE4D24BFF0B1:Macmini6,1
Mac-F65AE981FFA204ED:Macmini6,2
Mac-4B7AC7E43945597E:MacBookPro9,1
Mac-6F01561E16C75D06:MacBookPro9,2
Mac-C3EC7CD22292981F:MacBookPro10,1
Mac-AFD8A9D944EA4843:MacBookPro10,2
Mac-66F35F19FE2A0D05:MacBookAir5,1
Mac-2E6FAB96566FE58C:MacBookAir5,2
Mac-F60DEB81FF30ACF6:MacPro6,1
)

#
# Global variable with supported board-id / model name for Haswell processors.
#
gHaswellModelData=(
Mac-031B6874CF7F642A:iMac14,1
Mac-27ADBB7B4CEE8E61:iMac14,2
Mac-77EB7D7DAF985301:iMac14,3
Mac-189A3D4F975D5FFC:MacBookPro11,1
Mac-3CBD00234E554E41:MacBookPro11,2
Mac-2BD1B31983FE1663:MacBookPro11,3
Mac-35C1E88140C3E6CF:MacBookAir6,1
Mac-7DF21CB3ED6977E5:MacBookAir6,2
Mac-F60DEB81FF30ACF6:MacPro6,1
)

#
# Global variable with supported board-id / model name for Broadwell processors.
#
gBroadwellModelData=(
)

#
# Processor Number, Max TDP, Low Frequency Mode, Clock Speed, Max Turbo Frequency, Cores, Threads
#

gServerSandyBridgeCPUList=(
# E5-2600 Xeon Processor Series
E5-2648L,70,1200,1800,2100,8,16
E5-2658,95,1200,2100,2400,8,16
E5-2687W,150,1200,3100,3800,8,16
E5-2680,130,1200,2700,3500,8,16
E5-2660,95,1200,2200,3000,8,16
E5-2650L,70,1200,1800,2300,8,16
E5-2630L,60,1200,2000,2500,6,12
E5-2643,130,1200,3300,3500,4,8
E5-2609,80,1200,2400,2400,4,4
E5-2667,130,1200,2900,3500,6,12
E5-2650,95,1200,2000,2800,8,16
E5-2640,95,1200,2500,3000,6,12
E5-2603,80,1200,1900,1800,4,4
E5-2630,95,1200,2300,2800,6,12
E5-2620,95,1200,2000,2500,6,12
E5-2670,115,1200,2600,3300,8,16
E5-2690,135,1200,2900,3800,8,16
E5-2665,115,1200,2400,3100,8,16
E5-2637,80,1200,3000,3500,2,2
# E5-4600 Xeon Processor Series
E5-4610,95,1200,2400,2900,6,12
E5-4640,95,1200,2400,2800,8,16
E5-4607,95,1200,2200,2200,6,12
E5-4650L,115,1200,2600,3100,8,16
E5-4620,95,1200,2200,2600,8,16
E5-4617,130,1200,2900,3400,6,6
E5-4603,95,1200,2000,2000,4,8
E5-4650,130,1200,2700,3300,8,16
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
# E5-1600 Xeon Processor Series
'E5-1620 v2',130,1200,3700,3900,4,8
'E5-1650 v2',130,1200,3500,3900,6,12
'E5-1660 v2',130,1200,3700,4000,6,12
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
i3-3250T,25,1600,3000,0,2,4
i3-3245,55,1600,3400,0,2,4
i3-3240,55,1600,3400,0,2,4
i3-3240T,35,1600,2900,0,2,4
i3-3225,55,1600,3300,0,2,4
i3-3220,55,1600,3300,0,2,4
i3-3220T,35,1600,2800,0,2,4
i3-3210,55,1600,3200,0,2,4
)

gMobileIvyBridgeCPUList=(
# i7-3900 Mobile Processor Extreme Edition
i7-3940XM,55,1200,3000,3900,4,8
i7-3920XM,55,1200,2900,3800,4,8
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
i7-3517U,17,800,1900,3000,2,4
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
'E3-1286L v3',65,800,3200,4000,4,8
'E3-1285 v3',84,800,3600,4000,4,8
'E3-1286 v3',84,800,3700,4100,4,8
'E3-1280 v3',82,800,3600,4000,4,8
'E3-1281 v3',82,800,3700,4100,4,8
'E3-1275 v3',84,800,3500,3900,4,8
'E3-1276 v3',84,800,3600,4000,4,8
'E3-1270 v3',80,800,3500,3900,4,8
'E3-1271 v3',80,800,3600,4000,4,8
'E3-1268L v3',45,800,2300,3300,4,8
'E3-1265L v3',45,800,2500,3700,4,8
'E3-1245 v3',84,800,3400,3800,4,8
'E3-1246 v3',84,800,3500,3900,4,8
'E3-1240 v3',80,800,3400,3800,4,8
'E3-1241 v3',80,800,3500,3900,4,8
'E3-1230L v3',25,800,1800,2800,4,8
'E3-1230 v3',80,800,3300,3700,4,8
'E3-1231 v3',80,800,3400,3800,4,8
'E3-1225 v3',80,800,3200,3600,4,4
'E3-1226 v3',80,800,3300,3700,4,4
'E3-1220 v3',80,800,3100,3500,4,4
'E3-1220L v3',13,800,1100,1500,2,4
# E5-1600 v3 Xeon Processor Series (AVX2 Turbo Frequency)
'E5-1620 v3',140,1200,3500,3600,4,8
'E5-1630 v3',140,1200,3700,3800,4,8
'E5-1650 v3',140,1200,3500,3800,6,12
'E5-1660 v3',140,1200,3000,3500,8,16
'E5-1680 v3',140,1200,3200,3800,8,16
# E5-2600 v3 Xeon Processor Series (AVX2 Turbo Frequency)
'E5-2683 v3',120,1200,2000,3000,14,28
'E5-2695 v3',120,1200,2300,3300,14,28
'E5-2697 v3',145,1200,2600,3600,14,28
'E5-2698 v3',135,1200,2300,3600,16,32
'E5-2699 v3',145,1200,2300,3600,18,36
'E5-2628L v3',75,1200,2000,2500,10,20
'E5-2650 v3',105,1200,2300,3000,10,20
'E5-2660 v3',105,1200,2600,3300,10,20
'E5-2670 v3',120,1200,2300,3100,12,24
'E5-2690 v3',135,1200,2600,3500,12,24
'E5-2609 v3',85,1200,1900,1900,6,6
'E5-2643 v3',135,1200,3400,3700,6,12
'E5-2648L v3',75,1200,1900,2500,12,24
'E5-2650L v3',65,1200,1800,2500,12,24
'E5-2658 v3',105,1200,2200,2900,12,24
'E5-2680 v3',120,1200,2500,3300,12,24
'E5-2687W v3',160,1200,3100,3500,10,20
'E5-2603 v3',85,1200,1600,1600,6,6
'E5-2608L v3',52,1200,2000,2000,6,12
'E5-2618L v3',75,1200,2300,3400,6,12
'E5-2620 v3',85,1200,2400,3200,6,12
'E5-2623 v3',105,1200,3000,3500,4,8
'E5-2630 v3',85,1200,2400,3200,8,16
'E5-2630L v3',55,1200,1800,2900,8,16
'E5-2637 v3',135,1200,3500,3700,4,8
'E5-2640 v3',90,1200,2600,2400,8,16
'E5-2667 v3',135,1200,3200,3600,8,16
)

gDesktopHaswellCPUList=(
# Haswell-E Processor Series (socket 2011-3)
i7-5960X,140,1200,3000,3400,8,16
i7-5930K,140,1200,3500,3900,6,12
i7-5820K,140,1200,3300,3700,6,12
# Socket 1150 (Standard Power)
i7-4790K,88,800,4000,4400,4,8
i5-4690K,88,800,3500,3900,4,4
i7-4790,84,800,3600,4000,4,8
i7-4770K,84,800,3500,3900,4,8
i7-4771,84,800,3500,3900,4,8
i7-4770,84,800,3400,3900,4,8
i5-4590K,84,800,3300,3700,4,4
i5-4590,84,800,3300,3700,4,4
i5-4670K,84,800,3400,3800,4,4
i5-4670,84,800,3400,3800,4,4
i5-4570,84,800,3200,3600,4,4
i5-4440,84,800,3100,3300,4,4
i5-4440S,65,800,2800,3300,4,4
i5-4430,84,800,3000,3200,4,4
# Socket 1150 (Low Power)
i7-4790S,65,800,3200,4000,4,8
i7-4790T,45,800,2700,3900,4,8
i7-4785T,35,800,2200,3200,4,8
i7-4770S,65,800,3100,3900,4,8
i7-4770T,45,800,2500,3700,4,8
i7-4765T,35,800,2000,3000,4,8
i5-4690,65,800,3300,3900,4,4
i5-4690S,65,800,3200,3900,4,4
i5-4690T,45,800,2500,3500,4,4
i5-4670S,65,800,3100,3800,4,4
i5-4670T,45,800,2300,3300,4,4
i5-4590,84,800,3300,3700,4,4
i5-4590S,65,800,3000,3700,4,4
i5-4590T,35,800,3000,3700,4,4
i5-4570S,65,800,2900,3600,4,4
i5-4570T,35,800,2900,3600,4,4
i5-4570TE,35,800,2700,3300,2,4
i5-4460,84,800,3200,3400,4,4
i5-4460T,35,800,1900,2700,4,4
i5-4460S,65,800,2900,3600,4,4
i5-4430S,65,800,2700,3200,4,4
# BGA
i7-4770R,65,800,3200,3900,4,8
i5-4670R,65,800,3000,3700,4,4
#FCLGA1150
i3-4130,54,800,3400,3400,2,4
i3-4130T,35,800,2900,2900,2,4
i3-4150,54,800,3500,3500,2,4
i3-4150T,35,800,3000,3000,2,4
i3-4160,54,800,3600,3600,2,4
i3-4160T,35,800,3100,3100,2,4
i3-4330,54,800,3500,3500,2,4
i3-4330T,35,800,3000,3000,2,4
i3-4330TE,35,800,2400,2400,2,4
i3-4340,54,800,3600,3600,2,4
i3-4340TE,35,800,2600,2600,2,4
i3-4350,54,800,3600,3600,2,4
i3-4350T,35,800,3100,3100,2,4
i3-4360,54,800,3700,3700,2,4
i3-4360T,35,800,3200,3200,2,4
i3-4370,54,800,3800,3800,2,4
)

gMobileHaswellCPUList=(
# Socket FCBGA1364
i7-4980HQ,47,800,2800,4000,4,8
i7-4960HQ,47,800,2600,3800,4,8
i7-4950HQ,47,800,2400,3600,4,8
i7-4870HQ,47,800,2500,3700,4,8
i7-4860HQ,47,800,2400,3600,4,8
i7-4850HQ,47,800,2300,3500,4,8
i7-4770HQ,47,800,2200,3400,4,8
i7-4760HQ,47,800,2100,3300,4,8
i7-4750HQ,47,800,2000,3200,4,8
i7-4702HQ,37,800,2200,3200,4,8
i7-4700HQ,47,800,2400,3400,4,8
i7-4710HQ,47,800,2500,3500,4,8
i7-4712HQ,37,800,2300,3300,4,8
i7-4700EC,43,800,2700,2700,4,8
i7-4702EC,27,800,2000,2000,4,8
# Extreme Edition Series - socket FCPGA946
i7-4930MX,57,800,3000,3900,4,8
# Socket FCPGA946
i7-4910MQ,47,800,2900,3900,4,8
i7-4900MQ,47,800,2800,3800,4,8
i7-4810MQ,47,800,2800,3800,4,8
i7-4800MQ,47,800,2700,3700,4,8
i7-4702MQ,37,800,2200,3200,4,8
i7-4700MQ,47,800,2400,3400,4,8
i7-4710MQ,47,800,2500,3500,4,8
i7-4712MQ,37,800,2300,3300,4,8
i7-4610M,37,800,3000,3700,4,8
i7-4600M,37,800,2900,3300,4,8
i5-4200M,37,800,2500,3100,2,4
# Socket FCBGA1168
i7-4650U,15,800,1700,3300,2,4
i7-4650U,15,800,1700,3300,2,4
i7-4600U,15,800,2100,3300,2,4
i7-4610Y,11.5,800,1700,2900,2,4
i7-4578U,28,800,3000,3500,2,4
i7-4558U,28,800,2800,3300,2,4
i7-4550U,15,800,1500,3000,2,4
i7-4500U,15,800,1800,3000,2,4
i7-4510U,15,800,2000,3100,2,4
i5-4360U,15,800,1500,3000,2,4
i5-4350U,15,800,1400,2900,2,4
i5-4310U,15,800,2000,3000,2,4
i5-4308U,28,800,2800,3300,2,4
i5-4300U,15,800,1900,2900,2,4
i5-4302Y,11.5,800,1600,2300,2,4
i5-4300Y,11.5,800,1600,2300,2,4
i5-4288U,28,800,2600,3100,2,4
i5-4278U,28,800,2600,3100,2,4
i5-4258U,28,800,2400,2900,2,4
i5-4250U,15,800,1300,2600,2,4
i5-4200U,15,800,1600,2600,2,4
i5-4200Y,11.5,800,1400,1900,2,4
i5-4202Y,11.5,800,1600,2000,2,4
i5-4210Y,11.5,800,1500,1900,2,4
i5-4210U,15,800,1700,2700,2,4
i5-4220Y,11.5,800,1600,2000,2,4
i5-4260U,15,800,1400,2700,2,4
# Socket FCPGA946
i5-4340M,37,800,2900,3600,2,4
i5-4330M,37,800,2800,3500,2,4
i5-4310M,37,800,2700,3400,2,4
i5-4300M,37,800,2600,3300,2,4
i5-4210M,37,800,2600,3200,2,4
i3-4000M,37,800,2400,2400,2,4
i3-4100M,37,800,2500,2500,2,4
i3-4110M,37,800,2600,2600,2,4
# Socket FCBGA1364
i3-4100E,37,800,2400,2400,2,4
i3-4110E,37,800,2600,2600,2,4
i3-4102E,25,800,1600,1600,2,4
i3-4112E,25,800,1800,1800,2,4
i5-4400E,37,800,2700,3300,2,4
i5-4410E,37,800,2900,2900,2,4
i5-4422E,25,800,1800,2900,2,4
i5-4402E,25,800,1600,2700,2,4
i5-4402EC,27,800,2500,2500,2,4
i5-4200H,47,800,2800,3400,2,4
i5-4210H,47,800,2900,3500,2,4
# Socket FCBGA1168
i3-4005U,15,800,1700,1700,2,4
i3-4010U,15,800,1700,1700,2,4
i3-4100U,15,800,1800,1800,2,4
i3-4010Y,11.5,800,1300,1300,2,4
i3-4158U,28,800,2000,2000,2,4
i3-4012Y,11.5,800,1500,1500,2,4
i3-4020Y,11.5,800,1500,1500,2,4
i3-4120U,15,800,2000,2000,2,4
i3-4030U,15,800,1900,1900,2,4
i3-4025U,15,800,1900,1900,2,4
i3-4030Y,11.5,800,1600,1600,2,4
)

#
# New Broadwell processors.
#
gServerBroadwellCPUList=()
gDesktopBroadwellCPUList=()
gMobileBroadwellCPUList=()

#
#--------------------------------------------------------------------------------
# https://github.com/Piker-Alpha/RevoBoot/blob/clang/i386/libsaio/acpi/Tools/extractACPITables.c
#

acpiTableExtract="
\x50\x4B\x03\x04\x14\x00\x08\x00\x08\x00\x80\xB9\x53\x45\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x10\x00\x61\x63
\x70\x69\x54\x61\x62\x6C\x65\x45\x78\x74\x72\x61\x63\x74\x55\x58\x0C\x00\x34\x29\x44\x54\x20\x29\x44\x54\xF5\x01\x14\x00\xED\x5A
\x7F\x6C\x1B\xD5\x1D\x7F\x76\xD2\x24\x6B\xD3\xDA\x21\x6C\x6B\x35\xD8\x4C\xD7\x40\xCA\x50\x9C\x6E\x54\x2A\x1A\xDB\x72\x75\x1C\xEC
\x36\x21\x21\x49\xBB\xA8\x1A\xBA\x9E\x9D\xE7\xDA\xE4\x7C\x8E\xEE\x9E\xD7\x18\xA9\x53\x46\x1A\x94\x93\x1B\x66\x4D\x0C\xF5\x8F\x49
\x14\x6D\x42\x1A\x02\x29\x7F\x20\x0D\x3A\xA9\x44\x5B\x7F\x21\x26\xD8\xF8\x6B\x12\x08\xD0\x04\xE8\x82\xBA\xA9\x9A\xA6\x52\x55\x10
\xEF\xFB\x7D\xF7\x1C\x9F\xCF\x8E\xAB\x69\x7F\xEE\xBE\xD2\x7B\xDF\x1F\xEF\x7D\x3F\xF7\xBD\x7B\x3F\xEE\xDD\x7B\xF7\xCE\xAD\x7F\xAC
\xB7\x13\xE2\x6B\x21\x64\xDE\x4F\x08\xB9\x03\xD2\x6C\x1B\x21\x8B\x24\x44\x90\x76\x41\x8A\x41\x92\xE5\x31\xE9\x91\xE8\xB1\xE8\xF8
\x28\xA9\x23\x5F\xBD\xA9\x8E\x10\xA7\xD7\x8F\x38\x93\xD1\xA9\xC9\x06\xFE\x41\x97\x83\xD0\x21\x36\xB2\x05\x52\x9B\x30\xCB\x32\xA3
\x73\xAC\x5A\xCD\x8D\xB7\xD2\x69\xE3\xFD\xDC\x57\xD5\x5B\x9D\xB8\xAD\x64\xDE\xA9\xCA\xB2\xC1\xF2\x09\x63\x53\xBC\xEF\xEE\xB0\xF1
\x8E\xB9\xF4\x0A\x75\x08\xBC\x6A\x7C\x88\x27\xA7\xA9\x3A\x4B\xF5\x06\x78\x67\x84\xFF\x8B\x0E\xDD\xDF\x34\xBE\xA4\xC1\xF4\x8C\x76
\x62\xB3\xF8\x02\x36\x5E\xBF\x43\x77\x92\xBF\x56\x05\xFF\xBC\x76\x32\xA3\x4D\xCB\x19\x2D\x95\x6B\x80\x97\x10\x78\x31\x87\xDE\x8C
\x64\x99\xA6\xE5\x94\xAE\x64\x69\xE3\xF8\x56\x5C\x78\xA8\xB7\x34\xC1\xC3\x7E\xB2\xE4\x43\x9C\x41\x69\x52\x72\x14\x04\x5D\xFD\xC4
\xC5\xB1\x9F\x20\x6E\xA5\xAD\x65\x59\x53\x65\xA3\x90\x4D\xE4\x54\x79\x96\xE9\x9B\xE2\x05\x1D\xBA\x33\x2E\x6C\x4F\xE7\xAD\xCB\xF2
\x89\x1C\xAB\xD1\x6B\xF1\x82\x2E\xBC\x60\x03\xBC\xAE\x1A\x7F\x55\x69\x16\x5F\x48\xE0\xCD\x39\x74\x27\x1E\xDE\x6F\x77\x0D\x5E\x32
\xE5\xEC\x28\x6E\xBC\xB3\x02\x2F\xE4\xD0\x6F\xD7\x0E\xF6\xB8\x1F\x8E\x3F\x7A\x38\x3A\x18\xAF\xB4\x69\xC8\xD5\x0E\x02\x70\xA0\xAD
\x1A\x97\x73\x7C\xEC\x86\x79\xA5\x5F\xD4\xEB\x00\xD6\x01\x7C\xC9\x51\x5E\x02\x3D\x0D\x0E\x37\xEF\xB1\xFB\x30\xF6\xD7\x9D\x90\x2C
\x70\xFC\x2A\xF0\xD5\x3D\x00\x00\xE5\xDB\x40\x1E\x73\xC5\xE8\x17\xA9\x9B\x6C\x4E\x07\xF6\xF0\x18\xEA\x68\x87\x08\x1D\xA6\x07\x12
\xCE\x1B\x7A\x58\xCD\x24\xC2\xD3\x05\x75\x5A\x94\x7F\x43\xC4\xD1\xC9\x9E\xFA\xF3\xF7\xDA\xBF\x1F\xF9\xFD\xD3\x6F\x3E\x3C\x73\xF3
\xBE\xCB\x7B\x2A\xB7\xDE\xB1\x95\xA7\xFB\x49\xED\xD4\xD5\x0B\xE1\xA2\x1F\xCE\x3B\x4E\x42\x75\x4A\x60\xDA\x63\xB2\xDB\x87\x4F\x2A
\x3C\x51\x30\x18\xCD\x86\x87\x33\x09\x5D\xD1\x0B\xE1\x21\x1C\x4A\x27\x73\xFA\x8C\x11\x8E\x8F\x1E\xCE\xB0\xBE\x54\xC5\x10\x3E\x4A
\x75\x23\x93\xD3\x8C\xB0\x64\x17\x6D\xE0\xA6\x9D\xB8\xDD\x16\xB0\xE7\x9A\xE1\x46\x72\x3A\x1D\xCA\xE5\xB5\x69\x85\x01\x5C\xE3\x0B
\xD4\xD6\x11\xD7\x39\xE0\xBC\x4E\xCB\xEF\x08\x8F\xBF\xF2\xEC\x20\xD9\x97\xEC\x3B\xD8\x07\xCF\x31\x93\xB0\xEF\xFB\x5E\xF1\x7C\x7A
\x77\xDB\xED\xBF\x57\xE8\xFD\xA2\x51\xBE\xE3\xD0\x5F\x6B\xD2\x8E\x1E\x79\xE4\x91\x47\x1E\xFD\x7F\xD3\x91\x98\xF9\x89\xF4\x63\xE9
\xA8\x74\x44\x9A\x9C\x88\x2D\x5C\x9B\x8A\x2D\xFF\xE0\x09\x78\x21\x59\x27\xE1\x75\x1A\x2B\x6E\x1F\x84\x45\x4D\xF1\xA1\x98\x79\xD9
\x3A\x0E\x86\xC5\xD5\xC0\x69\xC9\x2E\xF8\x76\x0B\xB2\xAE\xD8\xF2\xFE\x17\x40\x32\xAF\x98\xA7\x9E\xDD\xF7\xA6\xB5\x1F\x0B\xCD\x3F
\x49\x17\xD6\xCB\xE5\x72\x6C\xF1\xBD\xC0\x69\x3F\xB7\x7C\x68\x3D\x04\x3C\x6E\x5E\x89\x99\x74\xFE\xD0\x72\xEB\x97\xB8\x16\x8C\x2D
\x7C\x74\x3D\x6E\x7E\x1C\xDF\x7B\x71\x18\x72\xF3\x93\xF8\xDE\x4B\xC3\xE6\x35\xA8\x1C\x33\x1F\x5F\x1A\x36\x3F\x1D\x36\x3F\xB3\x3A
\xC0\x6D\x64\xB1\xFC\x3A\xC6\x1A\x78\xE6\x37\x90\xEF\x5B\x8D\x2D\x3F\xBE\x12\xF8\xD6\x69\x1E\xBF\x19\x7D\x39\x5E\x3C\x45\xAC\xB7
\x11\xCF\x8C\x9E\xE3\xCA\x15\x5B\x39\x1B\x2F\x3E\xBC\x67\xDF\x0D\xEB\x2F\x5C\xFD\x70\xDF\x8D\xF3\x21\x94\x96\xB7\xBF\xC2\x63\x59
\xED\x5F\xB5\xFE\x60\x17\x5D\xF0\xC1\x72\xEB\xFC\x6F\xC1\x0C\x36\xBC\x96\x64\x5E\x7E\xFD\x4B\xB8\x05\x69\x61\xBD\xCC\xEE\x8E\x15
\xA3\x67\xCD\x3F\x0E\x9A\x9F\xC7\x8A\xF9\x73\xD6\xF3\x50\x0E\xB2\xB5\x08\xBC\x38\xF2\x72\x7C\xE1\x62\x47\x7C\xE1\x52\x47\xBC\xFC
\x8E\x79\x35\xB0\x38\x83\x37\x5E\x3C\xB5\x64\xBE\x65\x8D\x23\x78\x91\xCE\x4B\xE6\x07\xC5\x53\xCF\x5A\xDD\xC2\x6F\x02\xF8\x1B\x50
\xAB\x6C\xC5\x41\x2A\x95\x7B\x2C\xB8\x6E\xB9\xE7\x33\x9E\x5F\xE3\xF9\x3F\x79\x7E\x9D\xE7\xFF\xE2\xF9\xBF\x79\x7E\x83\xE7\x37\x79
\x7E\x8B\xE7\x5F\xF0\x7C\x9D\xE7\xB8\x90\x28\xF7\xF8\x79\xDE\x0A\xF9\xF0\xF2\xDD\x79\x28\x90\x26\xCA\x3D\x14\x78\x09\xD7\x35\x64
\xED\x53\xB8\x72\xFA\xEB\x28\xBD\x8F\xD2\x0F\x51\x7A\x17\x25\x05\xA5\xAB\x28\x3D\x89\xD2\x05\x94\x7E\x89\xD2\xAB\x28\xE1\xF2\x64
\xED\x25\x94\x2E\xA1\x74\x0E\xA5\x35\x94\x9E\x43\xE9\x16\x4A\x67\x38\x32\x5C\x69\xED\x29\x94\x1E\x40\x69\x0E\x25\x6C\xFB\x35\x0D
\xA5\x21\x94\xA6\x51\x9A\x40\xE9\x18\x3E\xE2\xD9\x59\x95\x4A\x91\xB1\xF8\x98\xAA\xB0\x54\x4E\xCF\x46\xE7\xE0\x53\x8F\x11\x34\x85
\x26\x95\x84\x4A\x0D\x12\x66\xD9\xD9\x70\x8F\xD1\xA7\x64\x55\xBE\x1A\xBE\x4B\xF4\x5E\x27\xC7\x55\x14\xAE\x12\x1F\x24\x76\xC2\x2F
\x4B\x22\x64\x5C\x99\x77\x82\x67\x50\xAC\xA5\xFF\x3A\xB5\x45\x2C\xAA\xEF\x14\x08\xBE\x27\xC7\x89\x6F\x2E\xE8\x0B\x76\xB6\x77\x94
\xA0\xEC\x01\x81\xFA\xD1\x17\x65\x4E\x95\xEF\x5F\x22\xED\x08\x3E\xED\x8F\x6C\x6F\x1B\x59\x68\x3F\xD3\xB6\xBC\xE5\x99\xD6\x5F\x34
\x5B\xF6\xD7\xD1\xAF\x2B\xDF\xAB\x82\xAF\x08\x7E\x5E\xF0\x8B\x82\xBF\x2D\xF8\xDF\x04\xFF\xBB\xE0\xD7\x04\xBF\x51\xF9\x6E\x16\xDF
\x83\x5B\x05\xBF\x53\xF0\x6F\x0A\xDE\x1B\xA8\xFD\x7E\xB8\xDA\x6E\xF3\x43\xC2\xBE\xED\xBF\x09\xDE\x23\x8F\x3C\xF2\xC8\x23\x8F\x3C
\xF2\xC8\x23\x8F\x3C\xF2\xC8\x23\x8F\x3C\xE2\xD4\xB5\x3B\x74\x3C\x70\xF0\x31\xD2\x35\x20\xCF\xC4\x47\x47\x14\x83\x51\x7D\x2C\xA7
\xB3\x41\x9A\x52\xF2\x2A\x23\x8F\xE9\x3B\x4B\x77\x0C\xC8\xB2\x1C\x19\x8A\xE4\x34\x83\x29\x1A\x9B\xE0\xC7\x8C\x11\x55\x31\x8C\x71
\x9A\xA2\x3A\xD5\x92\x94\xCC\xCF\x95\x00\x21\x32\x24\xA9\x6A\x2E\xA9\xB0\x9C\x5E\x01\x98\xBF\xBE\x6E\xEF\x48\x94\x7D\xA5\xEE\x01
\x3C\x61\xB3\x4F\xC8\x13\x19\x6D\x9A\xEA\x64\xDE\x2A\x6F\x14\x63\x3C\x7A\x08\x22\x89\x8F\x8E\x26\x9E\xA0\x49\x36\x4E\x55\xAA\x18
\x94\x94\x88\xDE\xCB\xCD\xE3\xF4\x44\xC6\x60\x7A\x21\xAA\x41\x16\xD1\xA9\xC2\x68\x64\x68\x4C\xCF\xE1\x06\x4C\x01\xAB\xF5\xF3\x6A
\x13\x54\xFF\x69\x26\x49\x1F\xA1\x6C\x44\x61\xC9\x34\x44\x2B\x2C\x58\xE5\x80\xB3\x4A\xA5\x1C\x0B\x06\xE0\x3E\x23\x43\x83\x0A\x53
\xC0\xF1\x60\x81\xD1\x31\xA6\xA3\x3D\xE6\xB4\x0F\x53\xED\x04\x4B\xA3\x79\xCC\x36\x67\x92\x78\x42\xA6\xE8\x05\x28\x8C\xE4\xF2\x1A
\xC3\xB2\xA9\xFA\xB2\xC3\xB4\x60\x48\xDA\xF4\x51\x45\xCD\x53\x03\xEB\x1C\xE7\x75\x1C\xB7\x98\xE6\x06\xFB\xE9\x22\x98\x2D\x89\x20
\x66\xBB\xB1\x11\x8C\x59\x30\xB1\x94\x9C\x4C\xCF\xA0\x71\x0E\x8C\x49\x35\x67\xBB\xCF\xFB\x40\xA3\x73\x19\x1E\xC0\x12\x2A\xF0\x58
\x34\x54\x4A\xA8\x9C\xD4\x33\x0C\xEB\x55\xC8\x27\x93\x2D\xC4\x2F\x67\xD3\xE0\x43\x93\x79\x46\xE5\x34\x55\xB0\x45\xEE\xC9\x2A\x19
\x8D\xF4\xE0\xF6\x54\x0B\x59\xD9\x25\xAA\x57\x84\x5B\x1F\x74\xE2\xEF\x18\xAF\x91\xEA\xF1\x31\x1E\x89\xE2\xD6\xCC\x4F\x88\xBD\xA9
\x55\x82\x3A\x68\x3F\x20\xEC\x6D\xC2\xBE\x2B\x99\xCB\xF6\x29\xB8\x7B\x56\x3D\x73\xEC\xAB\x9E\x64\x92\x16\xE1\xF7\xA0\xCB\x6F\x67
\xD5\xAF\xEE\x58\xB2\xE2\xD3\xEB\xF2\xD9\xE6\x38\x8E\xE4\xD8\x68\x0C\xF8\xEC\x93\x5A\xAC\xF8\x35\xAE\x57\xFF\x17\xB9\xCB\xB6\x6F
\xFC\x2E\xD1\xE7\xD2\x7F\xE4\xD2\x8F\xB8\x74\xC3\xA5\xFF\xCC\xA5\xFF\xCA\xD6\x37\xB6\xB6\x5E\x74\xE9\x57\x5C\xFA\xC7\x2E\xFD\x73
\x17\xDE\x2E\xBB\x70\x63\x2F\xAF\xD7\xA5\x87\x5D\xFA\x7E\x5F\xAD\xFF\x21\x5F\x2D\xFE\x71\x57\xFD\x94\x4B\xCF\xBA\x74\x3C\xCB\xFD
\x0A\xA4\xAD\xC4\xDE\x93\xB3\xBB\x8B\xFD\xFF\x45\xE5\x7F\x1D\xDC\xBA\xDB\x4E\xEC\xB3\x76\xDC\x3F\xC7\x7F\x8B\x70\x53\x59\xEC\x61
\x0E\x60\x6B\x74\xFD\x8F\x58\x21\x22\x37\xE8\xC3\x32\xEF\xC3\xF5\xA3\xB9\x6E\x1C\x37\x1E\xC1\xCD\xC7\xAE\x63\xD4\x6E\x32\x5E\xEB
\x26\xB0\xDB\x4E\x5D\x4D\x27\xAD\x06\xD3\xD5\xED\x27\x64\xD7\x6C\x21\xE6\x09\x7B\x82\x68\x38\x51\x37\x9E\xFF\xED\x49\x44\xCC\x1E
\x75\xB3\x37\x21\xFF\x01\x50\x4B\x07\x08\x28\x51\x4F\x88\x48\x07\x00\x00\x40\x26\x00\x00\x50\x4B\x01\x02\x15\x03\x14\x00\x08\x00
\x08\x00\x80\xB9\x53\x45\x28\x51\x4F\x88\x48\x07\x00\x00\x40\x26\x00\x00\x10\x00\x0C\x00\x00\x00\x00\x00\x00\x00\x00\x40\xED\x81
\x00\x00\x00\x00\x61\x63\x70\x69\x54\x61\x62\x6C\x65\x45\x78\x74\x72\x61\x63\x74\x55\x58\x08\x00\x34\x29\x44\x54\x20\x29\x44\x54
\x50\x4B\x05\x06\x00\x00\x00\x00\x01\x00\x01\x00\x4A\x00\x00\x00\x96\x07\x00\x00\x00\x00"
#
# Removing newline characters.
#
strippedData=$(echo "$acpiTableExtract" | tr -d '\n')
#
# Writing data to zip file.
#
printf "$strippedData" > acpiTableExtract.zip
#
# Unzipping command line tool.
#
unzip -qu acpiTableExtract.zip -d /usr/local/bin/
#
# Extracting ACPI tables.
#
/usr/local/bin/acpiTableExtract

#
#--------------------------------------------------------------------------------
#

function _PRINT_MSG()
{
 local message=$1

  if [[ $gExtraStyling -eq 1 ]];
    then
      if [[ $message =~ 'Aborting ...' ]];
        then
          local message=$(echo $message | sed -e 's/^Aborting ...//')
          local messageType='Aborting ...'
        else
          local messageType=$(echo $message | sed -e 's/:.*//g')

          if [[ $messageType =~ ^"\n" ]];
            then
              local messageTypeStripped=$(echo $messageType | sed -e 's/^[\n]*//')
            else
              local messageTypeStripped=$messageType
          fi

          local message=":"$(echo $message | sed -e "s/^[\n]*${messageTypeStripped}://")
      fi

      printf "${STYLE_BOLD}${messageType}${STYLE_RESET}$message\n"
    else
      printf "${message}\n"
  fi
}


#
#--------------------------------------------------------------------------------
#

function _ABORT()
{
  _PRINT_MSG "Aborting ...\nDone\n\n"

  exit $1
}


#
#--------------------------------------------------------------------------------
#

function _printHeader()
{
    echo '/*'                                                                         >  $gSsdtPR
    echo ' * Intel ACPI Component Architecture'                                       >> $gSsdtPR
    echo ' * AML Disassembler version 20140210-00 [Feb 10 2014]'                      >> $gSsdtPR
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
    echo ' *     Compiler Version 0x20140210 (538182160)'                             >> $gSsdtPR
    echo ' */'                                                                        >> $gSsdtPR
    echo ''                                                                           >> $gSsdtPR
    echo 'DefinitionBlock ("'$gSsdtID'.aml", "SSDT", 1, "APPLE ", "CpuPm", '$gRevision')' >> $gSsdtPR
    echo '{'                                                                          >> $gSsdtPR
}


#
#--------------------------------------------------------------------------------
#

function _printExternalObjects()
{
  #
  # Local variable definition.
  #
  local index
  local scopeIndex
  local maxCoresPerScope
  local numberOfLogicalCPUsPerScope
  #
  # Local variable initialisation.
  #
  let index=0
  let scopeIndex=1
  let logicalCPUsPerScope=$gLogicalCPUs/${#gScope[@]}
  #
  # Loop through all processor scopes.
  #
  for scope in "${gScope[@]}"
  do
    let maxCoresPerScope=($logicalCPUsPerScope*$scopeIndex)
    #
    # Inject External () object for each logical processor in this processor scope.
    #
    while [ $index -lt $maxCoresPerScope ];
    do
      echo '    External ('${scope}'.'${gProcessorNames[$index]}', DeviceObj)'        >> $gSsdtPR
      #
      # Next logical processor.
      #
      let index+=1
    done
      #
      # Next processor scope.
      #
      let scopeIndex+=1
  done
}


#
#--------------------------------------------------------------------------------
#

function _getPBlockAddress()
{
  #
  # Local variable definition/initialisation.
  #
  local filename="/tmp/facp.txt"
  #
  # Extract FACP from ioreg.
  #
  local data=$(ioreg -c AppleACPIPlatformExpert -rd1 -w0 | egrep -o 'FACP"=<[0-9a-f]+')
  #
  # The offset is (0x98/152 * 2) + 7 (for: FACP"=<)
  #
  pblockAddress="0x${data:317:2}${data:315:2}${data:313:2}10"
  #
  # Return P_BLK address + 10
  #
  echo $pblockAddress
}


#
#--------------------------------------------------------------------------------
#

function _printProcessorDefinitions()
{
  #
  # Local variable definition.
  #
  local index
  local scopeIndex
  local maxCoresPerScope
  local numberOfLogicalCPUsPerScope
  local pBlockAddress=$(_getPBlockAddress)
  #
  # Local variable initialisation.
  #
  let index=0
  let scopeIndex=1
  let logicalCPUsPerScope=$gLogicalCPUs/${#gScope[@]}
  #
  # Loop through all processor scopes.
  #
  for scope in "${gScope[@]}"
  do
    let maxCoresPerScope=($logicalCPUsPerScope*$scopeIndex)
    #
    # Do we have a device name?
    #
    if [[ $scope =~ ^"\_SB_." ]];
      then
        local scopeName=$(echo $scope | sed -e 's/^\\_SB_\.//')

        echo '    Scope(\_SB_)'                                                       >> $gSsdtPR
        echo '    {'                                                                  >> $gSsdtPR
        echo '        Device ('$scopeName')'                                          >> $gSsdtPR
        echo '        {'                                                              >> $gSsdtPR
        echo '            Name (_HID, "ACPI0004")'                                    >> $gSsdtPR
      else
        echo '    {'                                                                  >> $gSsdtPR
        echo '    Scope('$scope')'                                                    >> $gSsdtPR
    fi
    #
    # Inject Processor () object for each logical processor in this processor scope.
    #
    while [ $index -lt $maxCoresPerScope ];
    do
      if [[ $scope =~ ^"\_SB_." ]];
        then
          echo ''                                                                     >> $gSsdtPR
          echo '            Processor ('${gProcessorNames[$index]}', '$index', '$pBlockAddress', Zero)' >> $gSsdtPR
          echo '            {'                                                        >> $gSsdtPR
          echo '                Name (_HID, "ACPI0007")'                              >> $gSsdtPR
          echo '                Name (_STA, 0x0F)'                                    >> $gSsdtPR
          echo '            }'                                                        >> $gSsdtPR
        else
          echo '    Processor ('${gProcessorNames[$index]}', '$index', '$pBlockAddress', 0x06) {}' >> $gSsdtPR
      fi
      #
      # Next logical processor.
      #
      let index+=1
    done

    if [[ $scope =~ ^"\_SB_." ]];
      then
        echo '        }'                                                              >> $gSsdtPR
    fi

    echo '    }'                                                                      >> $gSsdtPR
    #
    # 
    #
    if [[ $scopeIndex -lt ${#gScope[@]} ]];
      then
        echo ''                                                                       >> $gSsdtPR
    fi
    #
    # Next processor scope.
    #
    let scopeIndex+=1
  done
  #
  # Done.
  #
}


#
#--------------------------------------------------------------------------------
#

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
  echo '            Store ("ssdtPRGen version....: '$gScriptVersion' / '$gProductName' '$gProductVersion' ('$gBuildVersion')", Debug)'  >> $gSsdtPR
  echo '            Store ("target processor.....: '$gProcessorNumber'", Debug)'      >> $gSsdtPR
  echo '            Store ("running processor....: '$gBrandString'", Debug)'          >> $gSsdtPR
  echo '            Store ("baseFrequency........: '$gBaseFrequency'", Debug)'        >> $gSsdtPR
  echo '            Store ("frequency............: '$frequency'", Debug)'             >> $gSsdtPR
  echo '            Store ("busFrequency.........: '$gBusFrequency'", Debug)'         >> $gSsdtPR
  echo '            Store ("logicalCPUs..........: '$gLogicalCPUs'", Debug)'          >> $gSsdtPR
  echo '            Store ("maximum TDP..........: '$gTdp'", Debug)'                  >> $gSsdtPR
  echo '            Store ("packageLength........: '$packageLength'", Debug)'         >> $gSsdtPR
  echo '            Store ("turboStates..........: '$turboStates'", Debug)'           >> $gSsdtPR
  echo '            Store ("maxTurboFrequency....: '$maxTurboFrequency'", Debug)'     >> $gSsdtPR
  #
  # Ivy Bridge workarounds requested?
  #
  if [[ $gIvyWorkAround -gt 0 ]];
    then
       echo '            Store ("IvyWorkArounds.......: '$gIvyWorkAround'", Debug)'   >> $gSsdtPR
  fi
  #
  # XCPM mode initialised?
  #
  if [[ $gXcpm -ne -1 ]];
    then
       echo '            Store ("machdep.xcpm.mode....: '$gXcpm'", Debug)'            >> $gSsdtPR
  fi
  #
  # Do we have more than one ACPI processor scope?
  #
 if [[ "${#gScope[@]}" -gt 1 ]];
   then
      echo '            Store ("number of ACPI scopes: '${#gScope[@]}'", Debug)'      >> $gSsdtPR
  fi

  echo '        }'                                                                    >> $gSsdtPR
  echo ''                                                                             >> $gSsdtPR
}


#
#--------------------------------------------------------------------------------
#

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
  let scopeIndex=$1
  let turboStates=$2
  let packageLength=$3
  let maxTurboFrequency=$4
  let useWorkArounds=0

  let logicalCPUsPerScope=$gLogicalCPUs/${#gScope[@]}
  let index=($logicalCPUsPerScope*$scopeIndex)
  #
  # Have we injected External () objects?
  #
  if [[ $scopeIndex -eq 0 && $gInjectExternalObjects -ne 1 ]];
    then
      #
      # No. Inject ACPI Processor (...) {} declarations.
      #
      _printProcessorDefinitions
  fi

  echo ''                                                                             >> $gSsdtPR
  echo '    Scope ('${gScope[${scopeIndex}]}'.'${gProcessorNames[$index]}')'          >> $gSsdtPR
  echo '    {'                                                                        >> $gSsdtPR

  if (( $scopeIndex == 0 && $gDebug & 1 ))
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

      let packageLength=($packageLength+$lowFrequencyPStates)

      if [[ $lowFrequencyPStates -gt 0 ]];
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


#
#--------------------------------------------------------------------------------
#

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
      let tdp=$gTdp
      let maxTDP=(tdp*1000)
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


#
#--------------------------------------------------------------------------------
#

function _printMethodDSM()
{
  if [[ $gBridgeType -ge $IVY_BRIDGE || $gXcpm -eq 1 ]];
    then
      #
      # New stand-alone version of Method _DSM - Copyright (c) 2009 by Master Chief
      #
      echo ''                                                                             >> $gSsdtPR
      echo '        Method (_DSM, 4, NotSerialized)'                                      >> $gSsdtPR
      echo '        {'                                                                    >> $gSsdtPR

      if [[ $gDebug -eq 1 ]];
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
  fi
}


#
#--------------------------------------------------------------------------------
#

function _debugPrint()
{
  if (( $gDebug & 2 ));
    then
      printf "$@"
  fi
}


#
#--------------------------------------------------------------------------------
#

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
            if [[ ${gModelID:0:7} == "iMac13," ]];
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
  # Do we need to add a closing bracket?
  #
  if [[ $gBridgeType -eq $SANDY_BRIDGE && $gXcpm -ne 1 ]];
    then
      echo '    }'                                                                      >> $gSsdtPR
#   else
#     echo ''                                                                           >> $gSsdtPR
  fi
}


#
#--------------------------------------------------------------------------------
#

function _printScopeCPUn()
{
  #
  # Local variable definition.
  #
  local index
  local scopeIndex
  local logicalCPUsPerScope
  local bspIndex
  local apIndex
  #
  # Local variable initialisation.
  #
  let index=1
  let scopeIndex=$1
  let logicalCPUsPerScope=$gLogicalCPUs/${#gScope[@]}
  let bspIndex=$logicalCPUsPerScope*$scopeIndex
  let apIndex=$bspIndex+1

  local scope=${gScope[$scopeIndex]}

  while [ $index -lt $logicalCPUsPerScope ];
  do
    echo ''                                                                             >> $gSsdtPR
    echo '    Scope ('${scope}'.'${gProcessorNames[${apIndex}]}')'                      >> $gSsdtPR
    echo '    {'                                                                        >> $gSsdtPR
    echo '        Method (APSS, 0, NotSerialized)'                                      >> $gSsdtPR
    echo '        {'                                                                    >> $gSsdtPR

    if (( $gDebug ));
      then
        local debugScopeName=$(echo $scope | sed -e 's/^\\//')

        echo '            Store ("Method '$debugScopeName'.'${gProcessorNames[${apIndex}]}'.APSS Called", Debug)'  >> $gSsdtPR
        echo ''                                                                         >> $gSsdtPR
    fi

    echo '            Return ('${scope}'.'${gProcessorNames[${bspIndex}]}'.APSS)'       >> $gSsdtPR
    echo '        }'                                                                    >> $gSsdtPR
    #
    # IB CPUPM tries to parse/execute CPUn.ACST (see debug data) and thus we add
    # this method, conditionally, since SB CPUPM doesn't seem to care about it.
    #
    if [ $gBridgeType -ge $IVY_BRIDGE ];
      then
        if [ $index -eq 1 ];
          then
            _printScopeACST 1
          else
            echo ''                                                                     >> $gSsdtPR
            local processorName=${gProcessorNames[$bspIndex+1]}
            echo '        Method (ACST, 0, NotSerialized) { Return ('$scope'.'$processorName'.ACST ()) }' >> $gSsdtPR
        fi
    fi

    echo '    }'                                                                        >> $gSsdtPR

    let index+=1
    let apIndex+=1
  done
  #
  # Next processor scope.
  #
  let scopeIndex+=1

  if [[ $scopeIndex -eq ${#gScope[@]} ]];
    then
      echo '}'                                                                          >> $gSsdtPR
  fi
  #
  # Done.
  #
}


#
#--------------------------------------------------------------------------------
#

function _getModelID()
{
  #
  # Grab 'compatible' property from ioreg (stripped with sed / RegEX magic).
  #
  gModelID=$(ioreg -p IODeviceTree -d 2 -k compatible | grep compatible | sed -e 's/ *["=<>]//g' -e 's/compatible//')
}


#
#--------------------------------------------------------------------------------
#

function _getBoardID()
{
  #
  # Grab 'board-id' property from ioreg (stripped with sed / RegEX magic).
  #
  gBoardID=$(ioreg -p IODeviceTree -d 2 -k board-id | grep board-id | sed -e 's/ *["=<>]//g' -e 's/board-id//')
}


#
#--------------------------------------------------------------------------------
#

function _getProcessorNames()
{
  #
  # Local variable definition/initialisation.
  #
  # Note: -k clock-frequency filters out the inactive cores.
  #
  local acpiNames=$(ioreg -p IODeviceTree -c IOACPIPlatformDevice -k cpu-type -k clock-frequency | egrep name  | sed -e 's/ *[-|="<a-z>]//g')
  #
  # Global variable initialisation.
  #
  # Note: COmment this out for dry runs.
  #
  gProcessorNames=($acpiNames)
  #
  # Uncomment/change this for dry runs.
  #
  # gProcessorNames=("C000" "C001" "C002" "C003" "C100" "C101" "C102" "C103")
  # gProcessorNames=("C000" "C001" "C002" "C003" "C004" "C005" "C006" "C007" "C008" "C009" "C00A" "C00B")
  # gProcessorNames=("C000" "C001" "C002" "C003" "C004" "C005" "C006" "C007" "C008" "C009" "C00A" "C00B" "C00C" "C00D" "C00E" "C00F" \
  #                  "C100" "C101" "C102" "C103" "C104" "C105" "C106" "C107" "C108" "C109" "C10A" "C10B" "C10C" "C10D" "C10E" "C10F")
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
  #
  # Is the -l argument, to specify the number of logical cores, used?
  #
  if [ $gLogicalCPUs -eq 0 ];
    then
      #
      # No. Use number of processor names.
      #
      let gLogicalCPUs=${#gProcessorNames[@]}
  fi
}


#
#--------------------------------------------------------------------------------
#

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
      _PRINT_MSG "\nWarning: Target CPU has $gLogicalCPUs logical cores, the running system only ${#gProcessorNames[@]}"
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


#
#--------------------------------------------------------------------------------
#

function _getPackageLength()
{
  #
  # Local variable definition/initialisation.
  #
  local data=$1
  local pkgLengthByte=0
  local start=0
  local packageLength=0
  #
  # Called with a AML Scope object?
  #
  if [[ ${data:0:2} == $AML_SCOPE_OPCODE ]];
    then
      # Yes.
      let start=$AML_SINGLE_BYTE_ENCODING
    else
      # No. Must be a Processor declaration.
      let start=$AML_DUAL_BYTE_ENCODING
  fi
  #
  # The package length is encoded as a series of 1 to 4 bytes with the most significant
  # two bits of byte zero indicating how many following bytes are in the encoding.
  # The next two bits are only used in one-byte encodings, which allows for one-byte
  # encodings on a length up to 0x3F. Longer encodings, which do not use these two bits,
  # have a maximum length of the following:
  #
  # 0x0FFF for two-byte encodings.
  # 0x0FFFFF for three-byte encodings.
  # 0x0FFFFFFFFF for four-byte encodings.
  #

  #
  # Get package length from given data.
  #
  let pkgLengthByte="0x"${1:${start}:2}
  #
  # Mask the first byte – the one after the opcode byte(s) – with 0x3f.
  #
  let maskedByte=$((0x${data:${start}:2} & 0x3f))

  if [[ $pkgLengthByte -gt 192 ]];
    then
      _debugPrint 'Four-byte encoding detected (maximum length 0x0FFFFFFFFF/68719476735)\n'
      printf -v packageLength '0x%2%2s%2s%x' "${data:${start}+6:2}" "${data:${start}+4:2}" "${data:${start}+2:2}" $maskedByte
    elif [[ $pkgLengthByte -gt 128 ]];
      then
        _debugPrint 'Three-byte encoding detected (maximum length 0x0FFFFF/1048575)\n'
        printf -v packageLength '0x%2s%2s%x' "${data:${start}+4:2}" "${data:${start}+2:2}" $maskedByte
    elif [[ $pkgLengthByte -gt 64 ]];
      then
        _debugPrint 'Two-byte encoding detected (maximum length 0x0FFF/4095)\n'
        printf -v packageLength '0x%2s%x' "${data:${start}+2:2}" $maskedByte
    else
      _debugPrint 'One-byte encoding detected (maximum length 0x3F/77)\n'
      packageLength=$maskedByte
  fi

  _debugPrint "pkgLengthByte: 0x%x/${pkgLengthByte}\n" $pkgLengthByte
  _debugPrint "packageLength: ${packageLength}/%d\n" $packageLength

  let gFunctionReturn=$packageLength
}


#
#--------------------------------------------------------------------------------
#
function _checkProcessorDeclarationsforAP()
{
  #
  # Local variable definitions/initialisation.
  #
  local targetData="$1"
  local deviceName=$2
  local typeEncoding=$3
  #
  # Loop through all ACPI processor names extracted from the ioreg.
  #
  for logicalCore in "${gProcessorNames[@]}"
  do
    #
    # Convert (example) 'C000' to '43303030'
    #
    local processorNameBytes=$(echo -n ${gProcessorNames[$gProcessorStartIndex]} | xxd -ps)
    #
    # Search for a Processor {} declaration in targetData for the application processor.
    #
    # Examples (single/dual byte encoding):
    #          5b831a4330303000 (C000)
    #          0123456789 12345
    #
    #          5b834a044330303000 (C200)
    #          0123456789 1234567
    #
    local processorObjectData=$(echo "${targetData}" | egrep -o "${AML_PROCESSOR_SCOPE_OPCODE}[0-9a-f]{$typeEncoding}${processorNameBytes}")
    #
    # ACPI processor declaration name found?
    #
    if [[ ${#processorObjectData} -gt 8 ]];
      then
        _debugPrint "logicalCore: ${gProcessorStartIndex} ${gProcessorNames[$gProcessorStartIndex]}\n"
        #
        # Up
        #
        let gProcessorStartIndex+=1
    fi

    if [[ $gProcessorStartIndex -eq ${#gProcessorNames[@]} ]];
      then
        return 0
    fi
  done
  #
  # Do we have all ACPI processor declarations?
  #
  if [[ $gProcessorStartIndex -eq ${#gProcessorNames[@]} ]];
    then
      #
      # Yes. Return SUCCESS.
      #
      return 0
    else
      #
      # No. Was a deviceName given?
      #
      if [[ $deviceName == "" ]];
        then
          #
          # No. Don't display a deviceName in the warning.
          #
          local deviceText=""
        else
          #
          # Yes. Display the deviceName in the warning.
          #
          local deviceText=" in Device(${deviceName}) {}"
      fi

      if [[ $gProcessorStartIndex -lt ${#gProcessorNames[@]} ]];
        then
          _debugPrint "Warning: only ${gProcessorStartIndex} of ${#gProcessorNames[@]} ACPI Processor declarations found${deviceText}"
      fi
  fi
  #
  # Return number of ACPI processor declarations that we found (so far).
  #
  # Note: This number should match the number of logical cores (single processor setups) but can
  #       be lower when a deviceName was given (multi-processor setups may use multiple devices).
  #
  return $gProcessorStartIndex
}


#
#--------------------------------------------------------------------------------
#

function _checkForProcessorDeclarations()
{
  #
  # Local variable definitions/initialisation.
  #
  local targetData=$1
  local deviceName=$2

  local isACPI10Compliant=$3
  local status=0
  #
  # Convert (example) 'C000' to '43303030'
  #
  local processorNameBytes=$(echo -n ${gProcessorNames[$gProcessorStartIndex]} | xxd -ps)
  #
  # Search for the first ACPI Processor {} declaration in $objectData.
  #
  # Example:
  #          5b831a4330303000 (C000)
  #          0123456789 12345
  #
  local processorObjectData=$(echo "${targetData}" | egrep -o "${AML_PROCESSOR_SCOPE_OPCODE}[0-9a-f]{2}${processorNameBytes}")
  #
  # Do we have a match for the first ACPI processor declaration?
  #
  if [[ $processorObjectData ]];
    then
      #
      # Yes. Print the result.
      #
      _debugPrint "ACPI Processor declaration (${gProcessorNames[0]}) {0x${processorObjectData:4:2} bytes} found in "
      #
      # Do we have a device name?
      #
      if [[ ${#deviceName} -gt 1 ]];
        then
          _debugPrint "Device (${deviceName}) (non ACPI 1.0 compliant)\n"
        else
          _debugPrint 'the DSDT '

          if [[ $isACPI10Compliant ]];
            then
              _debugPrint '(ACPI 1.0 compliant)\n'
            else
              _debugPrint '(not ACPI 1.0 compliant)\n'
          fi
      fi
      #
      # The ACPI processor declaration for the first logical core (bootstrap processor / BSP) is found,
      # now check the targetData for processor declaration for the application processors (AP).
      #
      _checkProcessorDeclarationsforAP $targetData "$deviceName" $AML_SINGLE_BYTE_ENCODING
      #
      # Return number of ACPI processor declarations that we found (so far).
      #
      return $?
    else
      #
      # No. Search for the first ACPI Processor {...} declaration with enclosed child objects.
      #
      # Example:
      #          5b834a044330303000 (C200)
      #          0123456789 1234567
      #
      processorObjectData=$(echo "$targetData" | egrep -o "${AML_PROCESSOR_SCOPE_OPCODE}[0-9a-f]{4}${processorNameBytes}")

      if [[ $processorObjectData ]];
        then
          _debugPrint "ACPI Processor declaration (${gProcessorNames[$gProcessorStartIndex]}) found in Device (${deviceName}) {...} (non ACPI 1.0 compliant)\n"
          #
          # The ACPI processor declaration for the first logical core (bootstrap processor / BSP) is found,
          # now check the targetData for processor declaration for the application processors (AP).
          #
          _checkProcessorDeclarationsforAP $targetData "$deviceName" $AML_DUAL_BYTE_ENCODING
          #
          # Return number of ACPI processor declarations that we found (so far).
          #
          return $?
      fi
  fi

  #
  # Free up some memory.
  #
  unset processorObjectData
  #
  # Return ERROR.
  #
  # Note: The return value can be anything between 0 and 255 and thus -1 is actually 255
  #       but we use -1 here to make it clear (obviously) that something went wrong.
  #
  return -1
}


#
#--------------------------------------------------------------------------------
#

function _getACPIProcessorScope()
{
  #
  # Local variable definitions/initialisation.
  #
  local filename=$1
  local variableList=(10,6,4,40 12,8,6,42)
  local varList
  local scopeLength
  local index
  local scopeIndex
  #
  # Local variable initialisation.
  #
  let index=0
  let scopeIndex=0
  #
  # Convert (example) 'C000' to '43303030'
  #
  local processorNameBytes=$(echo -n ${gProcessorNames[0]} | xxd -ps)
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
    local matchingData=$(egrep -o "${AML_DEVICE_OPCODE}[0-9a-f]{${vars[0]}}085f4849440d414350493030303400" "$filename")
    #
    # Example:
    #          5b824d9553434b30085f4849440d414350493030303400 (N times)
    #          0123456789 123456789 123456789 123456789 12345
    #
    if [[ $matchingData ]];
      then
        local hidObjectList=($matchingData)
        local let objectCount=${#hidObjectList[@]}

        if [ $objectCount -gt 0 ];
          then
            _debugPrint "${objectCount} Name (_HID, \"ACPI0004\") object(s) found in the DSDT\n"
            _debugPrint "matchingData:\n$matchingData\n"
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
          _debugPrint "Searching for ACPI Processor declarations in Device($deviceName) {}\n"
          #
          # Get the length of the device scope.
          #
          _getPackageLength $hidObjectData
          let scopeLength=$gFunctionReturn
          _debugPrint "scopeLength: $scopeLength\n"
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
          local deviceObjectData=$(egrep -o "${hidObjectData}${repetitionString}" "$filename" | tr -d '\n')
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
          # Check for ACPI Processor () {} declarations.
          #
          _checkForProcessorDeclarations $deviceObjectData $deviceName 0
          #
          # Check return status (0 is SUCCESS).
          #
          if [[ $? -eq 0 ]];
            then
              #
              # Update the global processor scope.
              #
              gScope[$scopeIndex]="\_SB_.${deviceName}"
              #
              # Next scope.
              #
              let scopeIndex+=1
              #
              # Done.
              #
              return
            else
              #
              #
              #
              if [ $? -lt ${#gProcessorNames[@]} ];
                then
                  #
                  # Update the global processor scope.
                  #
                  gScope[$scopeIndex]="\_SB_.${deviceName}"
                  #
                  # Next scope.
                  #
                  let scopeIndex+=1

                  _debugPrint "gProcessorStartIndex: $gProcessorStartIndex\n"
                  _debugPrint "gLogicalCPUs        : $gLogicalCPUs\n"
                  _debugPrint "gProcessorNames     : ${#gProcessorNames[@]}\n"

                  let nextTargetCores=${#gProcessorNames[@]}-$gProcessorStartIndex
                  _debugPrint "Searching for ${nextTargetCores} additional Processor declaration ...\n"
              fi
          fi
        done
    fi
  done
}


#
#--------------------------------------------------------------------------------
#

function _getProcessorScope()
{
  #
  # Local variable definitions/initialisation.
  #
  local index=0
  local filename=$1
  local scopeLength=0
  #
  # Target Scopes ('\_PR_', '\_PR', '_PR_', '_PR', '\_SB_', '\_SB', '_SB_', '_SB')
  #
  local grepPatternList=('5c5f50525f' '5c5f5052' '5f50525f' '5f5052' '5c5f53425f' '5c5f5342' '5f53425f' '5f5342')

  #
  # Loop through the target pattern list.
  #
  for grepPattern in "${grepPatternList[@]}"
  do
    #
    # Up scope index counter.
    #
    let index+=1;
    #
    # Setup array with supported type of byte encodings.
    #
    local byteEncodingList=($AML_SINGLE_BYTE_ENCODING $AML_DUAL_BYTE_ENCODING $AML_TRIPLE_BYTE_ENCODING $AML_QUAD_BYTE_ENCODING)

    for typeEncoding in "${byteEncodingList[@]}"
    do
      #
      # "10[0-9a-f]{2}${grepPattern}"
      # "10[0-9a-f]{4}${grepPattern}"
      # "10[0-9a-f]{6}${grepPattern}"
      # "10[0-9a-f]{8}${grepPattern}"
      #
      local data=$(egrep -o "${AML_SCOPE_OPCODE}[0-9a-f]{${typeEncoding}}${grepPattern}" "$filename")

      if [[ $data ]];
        then
          local scopeObjectList=($data)
          #
          # Get number of target objects to check.
          #
          let objectCount=${#scopeObjectList[@]}
          #
          # Get Scope name from current pattern.
          #
          local scopeName=$(echo -n $grepPattern | xxd -ps -r)

          if [[ $objectCount -gt 0 ]];
            then
              if [ $typeEncoding -eq $AML_SINGLE_BYTE_ENCODING ];
                then
                  local scopeDots=".";
                else
                  local scopeDots="..";
              fi

              _debugPrint $objectCount' Scope ('$scopeName') {'$scopeDots'} object(s) found in the DSDT\n'

              if [[ $index -lt 5 && $scopeName =~ "PR" ]];
                then
                  let gScopePRFound=1
              fi
          fi
          #
          # Loop through all Scope (...) objects.
          #
          for scopeObjectData in "${scopeObjectList[@]}"
          do
            _debugPrint "scopeObjectData: $scopeObjectData\n"
            #
            # Get the length of the Scope.
            #
            _getPackageLength $scopeObjectData
            let scopeLength=$gFunctionReturn
            _debugPrint "scopeLength: $scopeLength\n"
            # echo $scopeLength
            #
            # Convert number of bytes to number of characters.
            #
            let scopeLength*=2
            # echo $scopeLength
            #
            # Get number of characters in grep pattern.
            #
            let grepPatternLength="${#AML_SCOPE_OPCODE}+$typeEncoding+${#grepPattern}"
            #
            # Lower scopeLength with the number of characters that we used for the match.
            #
            let scopeLength-=$grepPatternLength
            _debugPrint "scopeLength: $scopeLength (egrep pattern length)\n"
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
            # Extract the whole Scope() {}.
            #
            local scopeObjectData=$(egrep -o "${scopeObjectData}${repetitionString}" "$filename" | tr -d '\n')
            # echo "scopeObjectData: $scopeObjectData"
            _debugPrint "scopeObjectData length ${#scopeObjectData} (includes egrep pattern)\n"

            if [[ $scopeObjectData ]];
              then
                #
                # Check for target scope in $scopeObjectData, there is no device name ("")
                # and $(($index < 5)) informs it about the ACPI 1.0 compliance (trye/false).
                #
                _checkForProcessorDeclarations $scopeObjectData "" $(($index < 5))
                #
                # Check return status (0 is SUCCESS).
                #
                if [[ $? -eq 0 ]];
                  then
                    #
                    # Reinitialise scopeLength (lowered for the repetitionString).
                    #
                    let scopeLength="${#scopeObjectData}"

                    printf 'Scope ('$scopeName') {'$scopeLength' bytes} with ACPI Processor declarations found in the DSDT (ACPI 1.0 compliant)\n'
                    #
                    # Construct processor scope name.
                    #
                    if [[ $scopeName =~ ^[\\] ]];
                      then
                        gScope=$scopeName
                      else
                        #
                        # Without the leading '\' the IASL compiler fails with:
                        #
                        # Error 4085 - Object not found or not accessible from scope ^ (_PR_.CPU0.APSS)
                        # Error 4085 - Object not found or not accessible from scope ^ (_PR_.CPU1.ACST)
                        #
                        gScope='\'$scopeName
                    fi

                    return
                  else
                    _debugPrint 'Scope ('$scopeName') {'$scopeLength' bytes} without ACPI Processor declarations ...\n\n'
                fi
            fi
          done
      fi
    done
  done
}


#
#--------------------------------------------------------------------------------
#

function _initProcessorScope()
{
  #
  # Local variable declarations.
  #
  local filename="/tmp/dsdt.txt"
  #
  # Note: Dry runs can be done with help of; xxd -c 256 -ps [path]dsdt.aml | tr -d '\n' > /tmp/dsdt.txt
  #       You may also need to change the CPU ID to get a match.
  #
  # gProcessorNames[0]="C000"
  #
  local processorDeclarationsFound
  #
  # Local variable initialisation.
  #
  let processorDeclarationsFound=0
  #
  # Convert extracted DSDT.aml file to postscript format.
  #
  # Note: Comment this out for dry runs!
  #
  xxd -ps /tmp/DSDT.aml | tr -d '\n' > "$filename"
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
      # Yes. We're done searching for the processor scope/declarations.
      #
      return
    else
      _debugPrint "Name (_HID, \"ACPI0004\") NOT found in the DSDT\n"
  fi
  #
  # Search for Scope (_PR) and the like.
  #
  _getProcessorScope $filename
  #
  # Do we have a processor scope with processor declarations?
  #
  if [[ $gScope != "" ]];
    then
      #
      # Yes. We're done searching for the processor scope/declarations.
      #
      return
    else
      #
      # Additional check for processor declarations with child objects.
      #
      if [[ $(egrep -o '5b83[0-9a-f]{2}04' "$filename") ]];
        then
          printf 'ACPI Processor {.} Declaration(s) found in DSDT\n'
          let processorDeclarationsFound=1
        else
          #
          # Check for processor declarations without child objects.
          #
          if [[ $(egrep -o '5b830b' "$filename") ]];
            then
              printf 'ACPI Processor {} Declaration(s) found in DSDT\n'
              let processorDeclarationsFound=1
          fi
      fi
      #
      # Check for processor declarations with RootChar in DSDT.
      #
      local data=$(egrep -o '5b83[0-9a-f]{2}5c2e[0-9a-f]{8}' "$filename")

      if [[ $data ]];
        then
          printf "ACPI Processor {...} Declaration(s) with RootChar ('\\\') found in DSDT"
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
      # Check for processor declarations with DualNamePrefix in the DSDT.
      #
      local data=$(egrep -o '5b83[0-9a-f]{2}2e[0-9a-f]{8}' "$filename")

      if [[ $data ]];
        then
          printf "ACPI Processor {...} Declaration(s) with DualNamePrefix ('.') found in DSDT"
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
      # Check for processor declarations with MultiNamePrefix (without leading backslash) in the DSDT.
      #
      local data=$(egrep -o '5b83[0-9a-f]{2}2f[0-9a-f]{2}' "$filename")

      if [[ $data ]];
        then
          printf "ACPI Processor {...} Declaration(s) with MultiNamePrefix ('/') found in DSDT"

          let scopeLength=("0x"${data:8:2})*4*2
          local data=$(egrep -o '5b83[0-9a-f]{2}2f[0-9a-f]{'$scopeLength'}' "$filename")
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
      # Check for processor declarations with MultiNamePrefix (with leading backslash) in the DSDT.
      #
      local data=$(egrep -o '5b83[0-9a-f]{2}5c2f[0-9a-f]{2}' "$filename")

      if [[ $data ]];
        then
          printf "ACPI Processor {...} Declaration(s) with MultiNamePrefix ('/') found in DSDT"

          let scopeLength=("0x"${data:10:2})*4*2
          local data=$(egrep -o '5b83[0-9a-f]{2}5c2f[0-9a-f]{'$scopeLength'}' "$filename")
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
      # Check for processor declarations with ParentPrefixChar in the DSDT.
      #
      local data=$(egrep -o '5b83[0-9a-f]{2}5e[0-9a-f]{8}' "$filename")

      if [[ $data ]];
        then
          printf "ACPI Processor {...} Declaration(s) with ParentPrefixChar ('^') found in DSDT\n"
          gScope=$(echo ${data:6:2} | xxd -r -p)

          # ioreg -w0 -p IOACPIPlane -c IOACPIPlatformDevice -n _SB -r > /tmp/dsdt2.txt

          if [[ $gScope =~ "^" ]];
            then
              printf "Searching for Parent Scope ... "
            else
              echo ' - ERROR: Invalid Scope Used!'
          fi

          return
      fi
  fi
  #
  # Did we find a Scope (_PR) {} object in the DSDT?
  #
  # Note: We end up here if all patterns failed to match anything but the _PR scope.
  #
  if [[ $gScopePRFound -eq 1 ]];
    then
      gScope="\_PR"
    else
      gScope="\_SB"
  fi

  _PRINT_MSG '\nWarning: No ACPI Processor declarations found in the DSDT!\n\t Using assumed Scope ('$gScope') {}\n'
}


#
#--------------------------------------------------------------------------------
#

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


#
#--------------------------------------------------------------------------------
#

function _getCPUModel()
{
  #
  # Returns the hexadecimal value of machdep.cpu.model
  #
  echo 0x$(echo "obase=16; `sysctl machdep.cpu.model | sed -e 's/^machdep.cpu.model: //'`" | bc)
}


#
#--------------------------------------------------------------------------------
#

function _getCPUSignature()
{
  #
  # Returns the hexadecimal value of machdep.cpu.signature
  #
  echo 0x$(echo "obase=16; `sysctl machdep.cpu.signature | sed -e 's/^machdep.cpu.signature: //'`" | bc)
}


#
#--------------------------------------------------------------------------------
#

function _getSystemType()
{
  #
  # Grab 'system-type' property from ioreg (stripped with sed / RegEX magic).
  #
  # Note: This property is checked (cmpb $0x02) in X86PlatformPlugin::configResourceCallback
  #
  echo `ioreg -p IODeviceTree -d 2 -k system-type | grep system-type | sed -e 's/ *[-="<0a-z>]//g'`
}


#
#--------------------------------------------------------------------------------
#

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
          sudo curl -o /usr/local/bin/iasl https://raw.githubusercontent.com/Piker-Alpha/RevoBoot/clang/i386/libsaio/acpi/Tools/iasl
          sudo chmod +x /usr/local/bin/iasl
          echo 'Done.'
      fi

      iasl=/usr/local/bin/iasl
  fi
}


#
#--------------------------------------------------------------------------------
#

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


#
#--------------------------------------------------------------------------------
#

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


#
#--------------------------------------------------------------------------------
#

function _getCPUNumberFromBrandString
{
  local modelSpecified=$1
  #
  # Get CPU brandstring
  #
  gBrandString=$(echo `sysctl machdep.cpu.brand_string` | sed -e 's/machdep.cpu.brand_string: //')

  #
  # Show brandstring (this helps me to debug stuff).
  #
  printf "Brandstring '${gBrandString}'\n\n"

  if [[ $modelSpecified -eq 0 ]];
    then
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
                # -c argument used?
                #
                if [[ $gBridgeType -gt 0 ]];
                  then
                    #
                    # Yes. Check target CPU model (represented here as 'gBridgeType').
                    #
                    case "$gBridgeType" in
                      $SANDY_BRIDGE) gProcessorNumber="${data[3]}"
                                     ;;
                      $IVY_BRIDGE)   gProcessorNumber="${data[3]} v2"
                                     ;;
                    esac
                  else
                    #
                    # No. Check CPU model.
                    #
                    case $(_getCPUModel) in
                      0x2A|0x2C|0x2D) gProcessorNumber="${data[3]}"
                                      ;;
                      0x3A|0x3B|0x3E) gProcessorNumber="${data[3]} v2"
                                      ;;
                    esac
                fi
          fi
        else
          #
          # All other non-Xeon processor models.
          #
          gProcessorNumber="${data[2]}"
      fi
  fi
}


#
#--------------------------------------------------------------------------------
#

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
            #
            # Is gBridgeType still uninitialised i.e. is argument -c not used?
            #
            if [[ $gBridgeType -eq -1 ]];
              then
                let gBridgeType=$1
            fi

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
  #
  # Bail out with error if we failed to find the CPU data.
  #
  if [[ $gTypeCPU -eq 0 ]];
    then
      _exitWithError $PROCESSOR_NUMBER_ERROR
  fi
}


#
#--------------------------------------------------------------------------------
#

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


#
#--------------------------------------------------------------------------------
#

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
      __searchList 'SupportedModelProperties' $gModelID

      if [ $? == 0 ];
        then
          __searchList 'SupportedBoardIds' $gBoardID

          if [ $? == 0 ];
            then
              _PRINT_MSG '\nWarning: Model identifier ['$gModelID'] and board-id ['$gBoardID'] \n\t are missing in: /S*/L*/CoreServices/PlatformSupport.plist'
          fi
      fi
    else
       _PRINT_MSG 'Warning: /S*/L*/C*/PlatformSupport.plist not found (normal for Snow Leopard)!'
  fi
}


#
#--------------------------------------------------------------------------------
#

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


#
#--------------------------------------------------------------------------------
#

function _checkForXCPM()
{
  #
  # Is XCPM mode still uninitialised?
  #
  if [[ $gXcpm -eq -1 ]];
    then
      #
      # Check OS version (the 'machdep.xcpm' class is introduced in 10.8.5)
      #
      if [[ $gOSVersion > 1084 ]];
        then
          #
          # Yes. Update global variable.
          #
          let gXcpm=$(/usr/sbin/sysctl -n machdep.xcpm.mode)
          #
          # Is XCPM mode active/ -x 1 argument used?
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
                  printf "\nXCPM mode detected (Ivy Bridge workarounds disabled)\n\n"
              fi
          fi
      fi
  fi
}


#
#--------------------------------------------------------------------------------
#

function _initSandyBridgeSetup()
{
  #
  # Global variable (re)initialisation.
  #
  gSystemType=2
  gACST_CPU0=29   # C1, C3, C6 and C7
  gACST_CPU1=7    # C1, C2 and C3
  #
  # Overrides are set below.
  #
  case $gBoardID in
    Mac-942B5BF58194151B) gSystemType=1
                          gTargetMacModel="iMac12,1"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-942B59F58194171B) gSystemType=1
                          gTargetMacModel="iMac12,2"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-8ED6AF5B48C039E1) gSystemType=1
                          gTargetMacModel="Macmini5,1"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-4BC72D62AD45599E) gSystemType=1
                          gTargetMacModel="Macmini5,2"
                          gACST_CPU0=13   # C1, C3, C6 and C7
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-7BA5B2794B2CDB12) gSystemType=1
                          gTargetMacModel="Macmini5,3"
                          gACST_CPU0=13   # C1, C3, C6 and C7
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-94245B3640C91C81) gTargetMacModel="MacBookPro8,1"
                          ;;

    Mac-94245A3940C91C80) gTargetMacModel="MacBookPro8,2"
                          ;;

    Mac-942459F5819B171B) gTargetMacModel="MacBookPro8,3"
                          ;;

    Mac-C08A6BB70A942AC2) gTargetMacModel="MacBookAir4,1"
                          ;;

    Mac-742912EFDBEE19B3) gTargetMacModel="MacBookAir4,2"
                          ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _initIvyBridgeSetup()
{
  #
  # Global variable (re)initialisation.
  #
  gSystemType=2
  gACST_CPU0=29   # C1, C3, C6 and C7
  gACST_CPU1=7    # C1, C2 and C3
  #
  # Overrides are set below.
  #
  case $gBoardID in
    Mac-00BE6ED71E35EB86) gSystemType=1
                          gTargetMacModel="iMac13,1"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-FC02E91DDD3FA6A4) gSystemType=1
                          gTargetMacModel="iMac13,2"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-031AEE4D24BFF0B1) gSystemType=1
                          gTargetMacModel="Macmini6,1"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-F65AE981FFA204ED) gSystemType=1
                          gTargetMacModel="Macmini6,2"
                          gACST_CPU0=13   # C1, C3 and C6
                          gACST_CPU1=7    # C1, C2 and C3
                          ;;

    Mac-4B7AC7E43945597E) gTargetMacModel="MacBookPro9,1"
                          ;;

    Mac-6F01561E16C75D06) gTargetMacModel="MacBookPro9,2"
                          ;;

    Mac-C3EC7CD22292981F) gTargetMacModel="MacBookPro10,1"
                          ;;

    Mac-AFD8A9D944EA4843) gTargetMacModel="MacBookPro10,2"
                          ;;

    Mac-66F35F19FE2A0D05) gTargetMacModel="MacBookAir5,1"
                          ;;

    Mac-2E6FAB96566FE58C) gTargetMacModel="MacBookAir5,2"
                          ;;

    Mac-F60DEB81FF30ACF6) gSystemType=3
                          gTargetMacModel="MacPro6,1"
                          gACST_CPU0=13   # C1, C3, C6
                          gACST_CPU1=13   # C1, C3, C6
                          ;;
	esac
}


#
#--------------------------------------------------------------------------------
#

function _initHaswellSetup()
{
  #
  # Global variable (re)initialisation.
  #
  gSystemType=2
  gACST_CPU0=29   # C1, C3, C6 and C7
  gACST_CPU1=7    # C1, C2 and C3
  #
  # Overrides are set below.
  #
  case $gBoardID in
    Mac-031B6874CF7F642A) gSystemType=1
                          gTargetMacModel="iMac14,1"
                          ;;

    Mac-27ADBB7B4CEE8E61) gSystemType=1
                          gTargetMacModel="iMac14,2"
                          ;;

    Mac-77EB7D7DAF985301) gSystemType=1
                          gTargetMacModel="iMac14,3"
                          ;;

    Mac-189A3D4F975D5FFC) gTargetMacModel="MacBookPro11,1"
                          gACST_CPU0=253  # C1, C3, C6, C7, C8, C9 and C10
                          gACST_CPU1=31   # C1, C2, C3, C6 and C7
                          ;;

    Mac-3CBD00234E554E41) gTargetMacModel="MacBookPro11,2"
                          gACST_CPU0=253  # C1, C3, C6, C7, C8, C9 and C10
                          gACST_CPU1=31   # C1, C2, C3, C6 and C7
                          ;;

    Mac-2BD1B31983FE1663) gTargetMacModel="MacBookPro11,3"
                          gACST_CPU0=253  # C1, C3, C6, C7, C8, C9 and C10
                          gACST_CPU1=31   # C1, C2, C3, C6 and C7
                          ;;

    Mac-35C1E88140C3E6CF) gTargetMacModel="MacBookAir6,1"
                          ;;

    Mac-7DF21CB3ED6977E5) gTargetMacModel="MacBookAir6,2"
                          ;;

    Mac-F60DEB81FF30ACF6) gSystemType=3
                          gTargetMacModel="MacPro6,1"
                          gACST_CPU0=13   # C1, C3, C6
                          gACST_CPU1=13   # C1, C3, C6
                          ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _initBroadwellSetup()
{
  #
  # Global variable (re)initialisation.
  #
  gSystemType=2
  gACST_CPU0=253  # C1, C3, C6, C7, C8, C9 and C10
  gACST_CPU1=31   # C1, C2, C3, C6 and C7
  #
  # Overrides are set below.
  #
  case $gBoardID in
    Mac-APPLE-BROADWELLS) gSystemType=1
                          gTargetMacModel="Macmini7,1"
                          ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _exitWithError()
{
  case "$1" in
      2) _PRINT_MSG "\nError: 'MaxTurboFrequency' must be in the range of $frequency-$gMaxOCFrequency ..."
         _ABORT 2
         ;;
      3) _PRINT_MSG "\nError: -t [TDP] must be in the range of 11.5 - 150 Watt ..."
         _ABORT 3
         ;;
      4) _PRINT_MSG "\nError: 'BridgeType' must be 0, 1, 2 or 3 ..."
         _ABORT 4
         ;;
      5) _PRINT_MSG "\nError: Unknown processor model ..."
         _ABORT 5
         ;;
      6) _PRINT_MSG "\nError: Processor label length is less than 3 ..."
         _ABORT 6
         ;;
      7) _PRINT_MSG "\nError: Processor label not found ..."
         _ABORT 7
         ;;
      8) _PRINT_MSG "\nError: Processor Declarations not found ..."
         _ABORT 8
         ;;
      *) _ABORT 1
         ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _confirmUnsupported()
{
  _PRINT_MSG "$1"

  read -p "Do you want to continue (y/n)? " unsupportedConfirmed
  case "$unsupportedConfirmed" in
       y|Y) return
            ;;
         *) exit 1
            ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _invalidArgumentError()
{
  _PRINT_MSG "\nError: Invalid argument detected: ${1} "
  _ABORT
}


#
#--------------------------------------------------------------------------------
#
function _showSupportedBoardIDsAndModels()
{
  #
  # Save default (0) delimiter.
  #
  local ifs=$IFS
  #
  # Setup a local variable pointing to a list with supported model data.
  #
  case "$1" in
    'Sandy Bridge') local modelDataList="gSandyBridgeModelData[@]"
                    ;;
      'Ivy Bridge') local modelDataList="gIvyBridgeModelData[@]"
                    ;;
           Haswell) local modelDataList="gHaswellModelData[@]"
                    ;;
         Broadwell) local modelDataList="gBroadwellModelData[@]"
                    ;;
  esac

  printf "\nSupported board-id / model combinations:\n\n"
  #
  # Split 'modelDataList' into array.
  #
  local targetList=("${!modelDataList}")
  #
  # Change delimiter to a colon character.
  #
  IFS=":"
  #
  # Loop through target list.
  #
  for modelData in "${targetList[@]}"
  do
    #
    # Split 'modelData' into array.
    #
    data=($modelData)
    echo "${data[0]} / ${data[1]}"
  done
  #
  # Restore default (0) delimiter.
  #
  IFS=$ifs
  #
  # Print extra newline for a cleaner layout.
  #
  printf "\n"
  #
  # Stop script (success).
  #
  exit 0
}

#
#--------------------------------------------------------------------------------
#

function _getScriptArguments()
{
  #
  # Are we fired up with arguments?
  #
  if [ $# -gt 0 ];
    then
      #
      # Yes. Do we have a single (-help) argument?
      #
      local argument=$(echo "$1" | tr '[:upper:]' '[:lower:]')

      if [[ $# -eq 1 && "$argument" == "-h" || "$argument" == "-help" ]];
        then
          printf "${STYLE_BOLD}Usage:${STYLE_RESET} ./ssdtPRGen.sh [-abcdfhlmptwx]\n"
          printf "       -${STYLE_BOLD}a${STYLE_RESET}cpi Processor name (example: CPU0, C000)\n"
          printf "       -${STYLE_BOLD}b${STYLE_RESET}oard-id (example: Mac-F60DEB81FF30ACF6)\n"
          printf "       -${STYLE_BOLD}c${STYLE_RESET}pu type [0/1/2/3]\n"
          printf "          0 = Sandy Bridge\n"
          printf "          1 = Ivy Bridge\n"
          printf "          2 = Haswell\n"
          printf "          3 = Broadwell\n"
          printf "       -${STYLE_BOLD}d${STYLE_RESET}ebug output [0/1/3]\n"
          printf "          0 = no debug injection/debug output\n"
          printf "          1 = inject debug statements in: ${gSsdtID}.dsl\n"
          printf "          2 = show debug output\n"
          printf "          3 = both\n"
          printf "       -${STYLE_BOLD}f${STYLE_RESET}requency (clock frequency)\n"
          printf "       -${STYLE_BOLD}h${STYLE_RESET}elp info (this)\n"
          printf "       -${STYLE_BOLD}lfm${STYLE_RESET}ode, lowest idle frequency\n"
          printf "       -${STYLE_BOLD}l${STYLE_RESET}ogical processors [2-128]\n"
          printf "       -${STYLE_BOLD}m${STYLE_RESET}odel (example: MacPro6,1)\n"
          printf "       -${STYLE_BOLD}p${STYLE_RESET}rocessor model (example: 'E3-1285L v3')\n"
          printf "       -${STYLE_BOLD}s${STYLE_RESET}how supported board-id and model combinations:\n"
          printf "          'Sandy Bridge'\n"
          printf "          'Ivy Bridge'\n"
          printf "           Haswell\n"
          printf "           Broadwell\n"
          printf "       -${STYLE_BOLD}turbo${STYLE_RESET} maximum (turbo) frequency:\n"
          printf "          6300 for Sandy Bridge and Ivy Bridge\n"
          printf "          8000 for Haswell and Broadwell\n"
          printf "       -${STYLE_BOLD}t${STYLE_RESET}dp [11.5 - 150]\n"
          printf "       -${STYLE_BOLD}w${STYLE_RESET}orkarounds for Ivy Bridge [0/1/2/3]\n"
          printf "          0 = no workarounds\n"
          printf "          1 = inject extra (turbo) P-State at the top with maximum (turbo) frequency + 1 MHz\n"
          printf "          2 = inject extra P-States at the bottom\n"
          printf "          3 = both\n"
          printf "       -${STYLE_BOLD}x${STYLE_RESET}cpm mode [0/1]\n"
          printf "          0 = XCPM mode disabled\n"
          printf "          1 = XCPM mode enabled\n\n"
          exit 0
        else
          #
          # Figure out what arguments are used.
          #
          while [ "$1" ];	
          do
            #
            # Store lowercase value of $1 in $flag
            #
            local flag=$(echo "$1" | tr '[:upper:]' '[:lower:]')
            #
            # Is this a valid flag?
            #
            # Note 'uro' was only added to support '-turbo'
            #
            if [[ "${flag}" =~ ^[-abcdfhlmpsturowx]+$ ]];
              then
                #
                # Yes. Figure out what flag it is.
                #
                case "${flag}" in
                  -a) shift

                      if [[ "$1" =~ ^[a-zA-Z0-9]+$ ]];
                        then
                          if [ ${#1} -eq 3 ];
                            then
                              gProcLabel=$(echo "$1" | tr '[:lower:]' '[:upper:]')
                              _PRINT_MSG "Override value: (-a) label for ACPI Processors, now using '${gProcLabel}'!"
                              _updateProcessorNames ${#gProcessorNames[@]}
                            else
                              _exitWithError $PROCESSOR_LABEL_LENGTH_ERROR
                          fi
                        else
                          _invalidArgumentError "-a $1"
                      fi
                      ;;

                  -b) shift

                      if [[ "$1" =~ ^Mac-[0-9A-F]+$ ]];
                        then
                          if [[ $gBoardID != "$1" ]];
                            then
                              gBoardID=$1
                              _PRINT_MSG "Override value: (-b) board-id, now using: ${gBoardID}!"
                          fi
                        else
                          _invalidArgumentError "-b $1"
                      fi
                      ;;

                  -c) shift

                      if [[ "$1" =~ ^[0123]+$ ]];
                        then
                          local detectedBridgeType=$gBridgeType

                          case "$1" in
                              0) local bridgeType=$SANDY_BRIDGE
                                 local bridgeTypeString="Sandy Bridge"
                                 ;;
                              1) local bridgeType=$IVY_BRIDGE
                                 local bridgeTypeString="Ivy Bridge"
                                 ;;
                              2) local bridgeType=$HASWELL
                                 local bridgeTypeString="Haswell"
                                 ;;
                              3) local bridgeType=$BROADWELL
                                 local bridgeTypeString="Broadwell"
                                 ;;
                          esac

                          if [[ $detectedBridgeType -ne $((2 << $1)) ]];
                            then
                              let gBridgeType=$bridgeType
                              _PRINT_MSG "Override value: (-c) CPU type, now using: ${bridgeTypeString}!"
                          fi
                        else
                          _exitWithError $TARGET_CPU_ERROR
                      fi
                      ;;

                  -d) shift

                      if [[ "$1" =~ ^[0123]+$ ]];
                        then
                          if [[ $gDebug -ne $1 ]];
                            then
                              let gDebug=$1
                              _PRINT_MSG "Override value: (-d) debug mode, now using: ${gDebug}!"
                          fi
                        else
                          _invalidArgumentError "-d $1"
                      fi
                      ;;

                  -f) shift

                      if [[ "$1" =~ ^[0-9]+$ ]];
                        then
                          _PRINT_MSG "Override value: (-f) clock frequency, now using: ${1} MHz!"
                          let gFrequency=$1
                        else
                          _invalidArgumentError "-f $1"
                      fi
                      ;;

                  -lfm) shift

                        let gLfm=$1
                         _PRINT_MSG "Override value: (-lfm) low frequency mode, now using: ${gLfm}!"
                        ;;

                  -l) shift

                      if [[ "$1" =~ ^[0-9]+$ ]];
                        then
                          #
                          # Sanity checking.
                          #
                          if [[ $1 -gt 1 && $1 -lt 129 ]];
                            then
                              let gLogicalCPUs=$1
                              _PRINT_MSG "Override value: (-l) number of logical processors, now using: ${gLogicalCPUs}!"
                            else
                              _invalidArgumentError "-l $1"
                          fi
                        else
                          _invalidArgumentError "-l $1"
                      fi
                      ;;

                  -m) shift

                      if [[ "$1" =~ ^[a-zA-Z,0-9]+$ ]];
                        then
                          if [[ "$gModelID" != "$1" ]];
                            then
                              _PRINT_MSG "Override value: (-m) model, now using: ${1}!"
                              gModelID="$1"
                          fi
                        else
                          _invalidArgumentError "-m $1"
                      fi
                      ;;

                  -p) shift

                      if [[ "$1" =~ ^[a-zA-Z0-9\ \-]+$ ]];
                        then
                          if [ "$processorNumber" != "$1" ];
                            then
                              let gFunctionReturn=0
                              #
                              # Sandy Bridge checks.
                              #
                              if [[ ${1:0:4} == "i3-2" || ${1:0:4} == "i5-2" || ${1:0:4} == "i7-2" ]];
                                then
                                  let gFunctionReturn=1
                              fi
                              #
                              # Ivy Bridge checks.
                              #
                              if [[ ${1:0:4} == "i3-3" || ${1:0:4} == "i5-3" || ${1:0:4} == "i7-3" ]];
                                then
                                  let gFunctionReturn=1
                              fi
                              #
                              # Haswell/Haswell-E checks.
                              #
                              if [[ ${1:0:4} == "i3-4" || ${1:0:4} == "i5-4" || ${1:0:4} == "i7-4" || ${1:0:4} == "i7-5" ]];
                                then
                                  let gFunctionReturn=1
                              fi
                              #
                              # Xeon check.
                              #
                              if [[ ${1:0:1} == "E" ]];
                                then
                                  let gFunctionReturn=1
                              fi
                              #
                              # Set processor model override and inform user about the change.
                              #
                              if [ $gFunctionReturn -eq 1 ];
                                then
                                  gProcessorNumber=$1
                                  _PRINT_MSG "Override value: (-p) processor model, now using: ${gProcessorNumber}!"
                              fi
                          fi
                        else
                          _invalidArgumentError "-p $1"
                      fi
                      ;;

                  -s) shift

                      case "$1" in
                          'Sandy Bridge') _showSupportedBoardIDsAndModels "${1}"
                                          ;;
                            'Ivy Bridge') _showSupportedBoardIDsAndModels "${1}"
                                          ;;
                               'Haswell') _showSupportedBoardIDsAndModels "${1}"
                                          ;;
                             'Broadwell') _showSupportedBoardIDsAndModels "${1}"
                                          ;;
                                       *) _invalidArgumentError "-s $1"
                                          ;;
                      esac
                      ;;

                  -turbo) shift

                          if [[ "$1" =~ ^[0-9]+$ ]];
                            then
                              #
                              # Sanity checking.
                              #
                              if [[ $1 -gt $gMaxOCFrequency ]];
                                then
                                  _exitWithError $MAX_TURBO_FREQUENCY_ERROR
                                else
                                  _PRINT_MSG "Override value: (-turbo) maximum (turbo) frequency, now using: ${1} MHz!"
                                  let gMaxTurboFrequency=$1
                              fi
                            else
                              _invalidArgumentError "-turbo $1"
                          fi
                          ;;


                  -t) shift

                      if [[ "$1" =~ ^[0-9]+$ ]];
                        then
                          #
                          # Sanity checking.
                          #
                          if [[ $1 -lt 11 || $1 -gt 150 ]];
                            then
                              _exitWithError $MAX_TDP_ERROR
                            else
                              let gTdp=$1
                              _PRINT_MSG "Override value: (-t) maximum TDP, now using: ${gTdp} Watt!"
                          fi
                        elif [[ "$1" =~ ^[0-9\.]*$ ]];
                          then
                            #
                            # Sanity checking.
                            #
                            if [[ $1 < "11.5" || $1 > "150" ]];
                              then
                                _exitWithError $MAX_TDP_ERROR
                              else
                                gTdp="$1"
                                _PRINT_MSG "Override value: (-t) maximum TDP, now using: ${gTdp} Watt!"
                            fi
                        else
                          _invalidArgumentError "-t $1"
                      fi
                      ;;

                  -w) shift

                      if [[ "$1" =~ ^[0123]+$ ]];
                        then
                          if [[ $gIvyWorkAround -ne $1 ]];
                            then
                              let gIvyWorkAround=$1
                              _PRINT_MSG "Override value: (-w) Ivy Bridge workarounds, now set to: ${1}!"
                          fi
                          #
                          # Running on Sandy Bridge platform?
                          #
                          if [[ $gBridgeType -eq $SANDY_BRIDGE ]];
                            then
                              #
                              # Yes. Change it to Ivy Bridge.
                              #
                              gBridgeType=$IVY_BRIDGE
                              _PRINT_MSG "Override value: CPU type changed, now using: Ivy Bridge!"
                          fi
                        else
                          _invalidArgumentError "-w $1"
                      fi
                      ;;

                  -x) shift

                      if [[ "$1" =~ ^[01]+$ ]];
                        then
                          let gXcpm=$1
                          _PRINT_MSG "Override value: (-x) XCPM mode, now set to: ${1}!"
                        else
                          _invalidArgumentError "-x $1"
                      fi
                      ;;

                   *) _invalidArgumentError "$1"
                      ;;
                esac
              else
                _invalidArgumentError "$1"
            fi
            shift;
          done;
      fi

      echo ''
  fi
}


#
#--------------------------------------------------------------------------------
#

function main()
{
  #
  # Local variable definitions.
  #
  local turboStates
  local assumedTDP
  local maxTurboFrequency
  local modelSpecified

  let assumedTDP=0
  let maxTurboFrequency=0

  printf "\nssdtPRGen.sh v0.9 Copyright (c) 2011-2012 by † RevoGirl\n"
  echo   '             v6.6 Copyright (c) 2013 by † Jeroen'
  printf "             v$gScriptVersion Copyright (c) 2013-$(date "+%Y") by Pike R. Alpha\n"
  echo   '-----------------------------------------------------------'
  printf "Bugs > https://github.com/Piker-Alpha/ssdtPRGen.sh/issues <\n\n"

  _checkSourceFilename
  _getScriptArguments "$@"
  #
  # Set local variable from global function variable.
  #
  let modelSpecified=$gFunctionReturn

  printf "System information: $gProductName $gProductVersion ($gBuildVersion)\n"
  #
  # Model override (-m) argument used?
  #
  if [[ $gModelID == "" ]];
    then
      #
      # No. Get model from ioreg.
      #
      _getModelID
  fi

  _getCPUNumberFromBrandString $modelSpecified
  _getCPUDataByProcessorNumber

  #
  # Was the -p flag used and no target processor found?
  #
  if [[ $modelSpecified -eq 1 && $gTypeCPU -eq 0 ]];
    then
      _exitWithError $PROCESSOR_NUMBER_ERROR
  fi
  #
  # Check if -c argument wasn't used.
  #
  # Note: Only happens if we failed to locate the processor data!
  #
  if [[ $gBridgeType -eq -1 ]];
    then
      local model=$(_getCPUModel)

      case $model in
          # Sandy Bridge
          0x2A) let gTdp=95
                let gBridgeType=2
                ;;
          # Sandy Bridge Xeon
          0x2D) let assumedTDP=1
                let gTdp=130
                let gBridgeType=2
                ;;
          # Ivy Bridge, Ivy Bridge EX and Ivy Bridge Xeon
          0x3A|0x3B|0x3E)
                let assumedTDP=1
                let gTdp=77
                let gBridgeType=4
                ;;
          # Haswell
          0x3C) let assumedTDP=1
                let gTdp=84
                let gBridgeType=8
                let gMaxOCFrequency=8000
                ;;
          # Haswell SVR
          0x3F) let assumedTDP=1
                let gTdp=130
                let gBridgeType=8
                ;;
          # Haswell ULT
          0x45) let assumedTDP=1
                let gTdp=15
                let gBridgeType=8
                ;;
             *) _confirmUnsupported 'Error: Unknown/unsupported processor model detected!\n'
                ;;
      esac
  fi
  #
  # Board-id override (-b) argument used?
  #
  if [[ $gBoardID == "" ]];
    then
      #
      # No. Get board-id from ioreg.
      #
      _getBoardID
  fi

  _getProcessorNames
  _initProcessorScope

  case $gBridgeType in
       2) local bridgeTypeString="Sandy Bridge"
          ;;
       4) local bridgeTypeString="Ivy Bridge"
          ;;
       8) local bridgeTypeString="Haswell"
          ;;
      16) local bridgeTypeString="Broadwell"
          ;;
       *) local bridgeTypeString="Unknown"
          ;;
  esac

  local cpu_type=$(_getCPUtype)
  local currentSystemType=$(_getSystemType)
  local cpuSignature=$(_getCPUSignature)

  echo "Generating ${gSsdtID}.dsl for a '${gModelID}' with board-id [${gBoardID}]"
  echo "$bridgeTypeString Core $gProcessorNumber processor [$cpuSignature] setup [0x${cpu_type}]"
  #
  # gTypeCPU is greater than 0 when the processor is found in one of the CPU lists
  #
  if [ $gTypeCPU -gt 0 ];
    then
      #
      # Save default (0) delimiter.
      #
      local ifs=$IFS
      #
      # Change delimiter to a comma character.
      #
      IFS=","
      #
      # Convert processor data into array.
      #
      local cpuData=($gProcessorData)
      #
      # -t argument used?
      #
      if [[ "$gTdp" > "0" ]];
        then
          echo "With a maximum TDP of '$gTdp' Watt, as specified by argument: -t ${gTdp}"
        else
          #
          # No. Get TDP from CPU data.
          #
          gTdp=${cpuData[1]}
          echo 'With a maximum TDP of '$gTdp' Watt, as specified by Intel'

          if [[ $assumedTDP -eq 1 ]];
            then
              echo "With a maximum TDP of ${gTdp} Watt - assumed/undetected CPU may require override value!"
          fi
      fi
      #
      # Check if -lfm argument was used.
      #
      if [[ $gLfm -gt 0 ]];
        then
          #
          # Yes. Use override value.
          #
          let lfm=$gLfm
        else
          #
          # No. Get LFM from CPU data.
          #
          let lfm=${cpuData[2]}
      fi
      #
      # Check if -f argument wasn't used.
      #
      if [[ $gFrequency -gt 0 ]];
        then
          #
          # Yes. Use override frequency.
          #
          let frequency=$gFrequency
        else
          #
          # No. Get clock frequency from CPU data.
          #
          let frequency=${cpuData[3]}
      fi
      #
      # Check if -turbo argument wasn't used.
      #
      if [[ $gMaxTurboFrequency -gt 0 ]];
        then
          let maxTurboFrequency=$gMaxTurboFrequency
        else
          let maxTurboFrequency=${cpuData[4]}
      fi
      #
      # Sanity check.
      #
      if [ $maxTurboFrequency == 0 ];
        then
          let maxTurboFrequency=$frequency
      fi
      #
      # Check if -l argument wasn't used.
      #
      if [ $gLogicalCPUs -eq 0 ];
        then
          #
          # No. Get thread count (logical cores) from CPU data.
          #
          let gLogicalCPUs=${cpuData[6]}
      fi
      #
      # Restore default (0) delimiter.
      #
      IFS=$ifs
      #
      # Check Low Frequency Mode (may be 0 aka still unknown)
      #
      if [ $lfm -gt 0 ];
        then
          let gBaseFrequency=$lfm
        else
          echo -e "\nWarning: Low Frequency Mode is 0 (unknown/unconfirmed)"

         if [ $gTypeCPU == $gMobileCPU ];
            then
              echo -e "         Now using 1200 MHz for Mobile processor\n"
              let gBaseFrequency=1200
             else
               echo -e "         Now using 1600 MHz for Server/Desktop processors\n"
               let gBaseFrequency=1600
          fi
      fi
    else
      #
      # No CPU data found.
      #
      # Note: We only get here when the -p argument wasn't used.
      #
      # Now check if -l argument wasn't used.
      #
      if [ $gLogicalCPUs -eq 0 ];
        then
          #
          # No. Get thread count (logical cores) from the running system.
          #
          let gLogicalCPUs=$(echo `sysctl machdep.cpu.thread_count` | sed -e 's/^machdep.cpu.thread_count: //')
      fi
      #
      # Check if -f argument wasn't used.
      #
      if [ $gFrequency -eq -1 ];
        then
          #
          # No. Get the clock frequency from the running system.
          #
          let frequency=$(echo `sysctl hw.cpufrequency` | sed -e 's/^hw.cpufrequency: //')
      fi

      let frequency=($frequency / 1000000)
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
  #
  # Do we need to inject External () objects?
  #
  if [ $gInjectExternalObjects -eq 1 ];
    then
      #
      # Yes. Inject External () objects for all processor declarations.
      #
      _printExternalObjects
  fi

  _checkForXCPM

  case "$gBridgeType" in
    $SANDY_BRIDGE) local cpuTypeString="06"
                   _initSandyBridgeSetup
                   ;;
      $IVY_BRIDGE) local cpuTypeString="07"
                   _initIvyBridgeSetup
                   ;;
         $HASWELL) local cpuTypeString="08"
                   _initHaswellSetup
                   ;;
       $BROADWELL) local cpuTypeString="09"
                   _initBroadwellSetup
                   ;;
  esac

  let scopeIndex=0
  #
  # Loop through all processor scopes.
  #
  for scope in "${gScope[@]}"
  do
    _printScopeStart $scopeIndex $turboStates $packageLength $maxTurboFrequency
    _printPackages $frequency $turboStates $maxTurboFrequency
    _printScopeACST 0

    if [ $scopeIndex -eq 0 ];
      then
        _printMethodDSM
      else
        if [ $gBridgeType -ge $IVY_BRIDGE ];
          then
            echo '    }' >> $gSsdtPR
        fi
    fi

    _printScopeCPUn $scopeIndex

    let scopeIndex+=1
  done

  #
  # Is this a MacPro6,1 model?
  #
  if [[ $gModelID == 'MacPro6,1' ]];
    then
      #
      # Yes. Use the correct string/value for the cpu-type suggestion.
      #
      local cpuTypeString="0a"
  fi

  _showLowPowerStates
  _checkPlatformSupport
  #
  # Some Sandy Bridge/Ivy Bridge CPUPM specific configuration checks
  #
  if [[ $gBridgeType -ne $HASWELL ]];
    then
      if [[ ${cpu_type:0:2} != $cpuTypeString ]];
        then
          _PRINT_MSG "Warning: 'cpu-type' may be set improperly (0x${cpu_type} instead of 0x${cpuTypeString}${cpu_type:2:2})"
      fi

      if [[ $gSystemType -eq 0 ]];
        then
          _PRINT_MSG "Warning: 'board-id' [${gBoardID}] is not supported by ${bridgeTypeString} power management"
        else
          if [ "${gTargetMacModel}" == "" ];
            then
             _confirmUnsupported "\nError: board-id [${gBoardID}] not supported by ${bridgeTypeString} – check SMBIOS data / use the -c option\n"
            elif [ "$gTargetMacModel" != "$gModelID" ];
              then
                _confirmUnsupported 'Warning: board-id ['$gBoardID'] and model ['$gModelID'] mismatch – check SMBIOS data\n'
          fi
      fi
  fi

  if [ $currentSystemType -ne $gSystemType ];
    then
      _PRINT_MSG "Warning: 'system-type' may be set improperly ($currentSystemType instead of $gSystemType)"
  fi

  _findIasl

  if [ $gCallIasl -eq 1 ];
    then
      #
      # Compile ssdt.dsl
      #
      sudo "$iasl" $gSsdtPR

      #
      # Copy ssdt_pr.aml to /Extra/ssdt.aml (example)
      #
      if [ $gAutoCopy -eq 1 ];
        then
          if [ -f ${gPath}/${gSsdtID}.aml ];
            then
              echo -e
              read -p "Do you want to copy ${gPath}/${gSsdtID}.aml to ${gDestinationPath}${gDestinationFile}? (y/n)? " choice
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
                              read -p  "Do you want to remove the temporarily mount point (y/n)? " choice2
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
      read -p "Do you want to open ${gSsdtID}.dsl (y/n)? " openAnswer
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
      # Yes. Open SSDT.dsl in TextEdit.
      #
      open -e "$gSsdtPR"
  fi
}

#==================================== START =====================================

clear

if [[ $gID -ne 0 ]];
  then
    echo "This script ${STYLE_UNDERLINED}must${STYLE_RESET} be run as root!" 1>&2
    #
    # Re-run script with arguments.
    #
    sudo "$0" "$@"
  else
    #
    # We are root. Call main with arguments.
    #
    main "$@"
fi

exit 0

#================================================================================