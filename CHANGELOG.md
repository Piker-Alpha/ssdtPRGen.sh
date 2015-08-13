Version 15.8 - Beta

 - Broadwell and Skylake processor data added (Pike, August 2015).
 - Initial support for Skylake processors added.

Version 15.7 - Beta

 - Lots of changes for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/80 (Pike, December 2014).
 - Support for 'User Defined' processor models added. See example below:

```
gUserDefinedCPUList=(
X5560,95,1600,2800,3200,8,16,2,133
)
```
Note the last two new values (cpu/bridge type, bclk/bus frequency). You can select a custom/override processor data with, in this case:

``` sh
./ssdtPRGen.sh -p X5560
```

 - Done some cleanups and other minor optimization changes.

Version 15.6

 - Fix for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/97 (Pike, December 2014).

Version 15.5

 - Additional changes for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/95 (Pike, December 2014).

Version 15.4

 - Additional changes for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/80 (Pike, December 2014).
 - First changes for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/95 (Pike, December 2014).

Version 15.3

 - Fix for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/88 (Pike, December 2014).

Version 15.2

 - Fix for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/93 (Pike, November 2014).

Version 15.1

 - Download/unzip of IASL should not require administrator privileges (Pike, November 2014).
 - Typo in bug report link fixed.
 - Help text/link for the 'Unknown processor model' error added.
 - Minor cleanups.
 - Separation of script and data, now using .cfg files for supported models/cpu data.

Version 15.0

 - Option -o(pen) now opens the previously generated SSDT (Pike, November 2014).
 - IASL now runs without administrator priviledges (sudo).
 - Output path changed from ~/Desktop/ and /tmp/ to ~/Library/ssdtPRGen/.
 - Command line tool extractACPITables will now be downloaded (removed from script).
 - Option -h no longer requires administrator priviledges.
 - Revoke administrator privileges after installation of iasl.
 - Option -s(how) is now case insensitive and now also supports sandy/ivy or all.
 - Moved update info to CHANGELOG.md
 - Moved contributors to CONTRIBUTORS.md
 - Fixed errors in function _getPBlockAddress.
 - New board-id/model combos added for the iMac15,N (Haswell).
 - New function _checkLibraryDirectory added (check/setup directory structure).
 - New function _extractAcpiTables added (checks/download tool, extracts ACPI tables).

Version 14.5

 - Argument -bclk allows you to specify a custom BCLK frequency (Pike, November 2014).
 - Help text for -bclk option added.
 - Basic support for pre-Jaketown/Sandy Bridge models added (power/control/status fields).

Version 14.4

 - Errors in processor data for the Intel i5-4690 fixed (Pike, November 2014).

Version 14.3

 - Error fixed, thanks to 'ginsbu' for reporting it on Github issues (Pike, November 2014).
 - Ivy Bridge workaround detection scheme changed.

Version 14.2

 - low frequency mode changed for some of the Intel E3-1200 series (Pike, November 2014).
 - Ivy Bridge workarounds (default value) now set based on the version of OS X.
 - Typo fixed (tr -d -> tr -D).

Version 14.1

 - low frequency mode fixed for the Intel i5-3317U (Pike, October 2014).

Version 14.0

 - zipped up data of acpiTableExtract tool added (Pike, October 2014)
 - Support for Yosemite added (no longer using ioreg to get ACPI table data).
 - Commit text/version information copied from Github (partly/too much work).

Version 13.9

 - processor data for Xeon E5-16NN v3 and E5-26NN v3 Processor Series added (Pike, September 2014)

Version 13.8

 - processor data for i7-3900 Mobile Processor Extreme Edition added (Pike, September 2014)

Version 13.7

 - moved some processor data from mobile to desktop definitions (Pike, August 2014)
 - fix for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/47
 - processor data for missing i3 Haswell processors added.

Version 13.6

 - processor data update for mobile i5/i7 and future Haswell-E processors (Pike, July 2014)

Version 13.5

 - processor data for i5-4440S,i5-4570TE,i5-4400E,i5-4402E and i5-4200H added (Pike, May 2014)

Version 13.4

 - processor data for upcomming Xeon E3-12nn v3 models added (Pike, April 2014)

Version 13.3

 - additional Haswell refresh (desktop/mobile) processor data added (Pike, April 2014)
 - fix for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/25
 - TDP value for the i5-4200Y and i3-4010Y fixed.

Version 13.2

 - fix for https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/21 (Pike, April 2014)

Version 13.1

 - enhanced _debugPrint with argument support (Pike, April 2014)
 - Haswell refresh (desktop) processor data added.
 - triple/quad byte package length support added .
 - typo in help text (-turbo) fixed.
 - opcode error ('Name' instead of 'Device') fixed.

Version 13.0

 - removed unused variable 'checkGlobalProcessorScope' (Pike, April 2014)
 - missing deviceName in two calls to _debugPrint fixed (Pike, April 2014)
 - fixed a typo in help text for -d and now -d 2 also works again (Pike, April 2014)
 - made -help work (Pike, April 2014)
 - stop overwriting the ACPI processor scope name with the last one, by using $scopeIndex (Pike, April 2014)
 - debug data fixed/running processor was missing when the -p argument was used (Pike, April 2014)
 - more text hidden/only shown when -d [2/3] argument is used (Pike, April 2014)
 - improved multi-processor support (Pike, April 2014)

Version 12.9

 - processor data for the Intel E5-2600 and E5-4600 processor series added (Pike, March 2014)

Version 12.8

 - processor data for the Intel i5-4300 mobile processor series added (Pike, March 2014)

Version 12.7

 - processor data for the Intel E5-1650 v2 fixed (Pike, March 2014)

Version 12.5

 - processor data for the Intel i3-3250T and i3-3245 added (Pike, March 2014)
 - processor data for the Intel E5-1600 v2 product family added (Pike, March 2014)

Version 12.0

 - inconsistency in argument -c values fixed (Pike, Februari 2014)
 - fixed a couple of typos (Pike, Februari 2014)
 - show less/ignore some debug warnings (Pike, Februari 2014)
 - multi-processor support added (Pike, Februari 2014)
 - fixed an issue when argument -p was used (Pike, Februari 2014)
 - inconsistency in argument -a fixed (Pike, Februari 2014)
 - mixup of $data / $matchingData fixed (Pike, Februari 2014)
 - better deviceName check/stop warning with wrong values (Pike, Februari 2014)
 - skip inactive cores with -k clock-frequency in function _getProcessorNames (Pike, March 2014)
 - processor data for the Intel E5-2620 added (Pike, March 2014)

Version 11.0

 - gSystemType for Ivy Bridge desktop models fixed (Pike, Februari 2014)
 - major rewrite to support more flexible script arguments (Pike, Februari 2014)
 - lists with supported board-id/model combinations added (Pike, Februari 2014)
 - renamed argument -l to -s (Pike, Februari 2014)
 - argument -l is now used to override the number of logical processors (Pike, Februari 2014)
 - fixed cpu/bridge type override logic (Pike, Februari 2014)
 - more comments added (Pike, Februari 2014)
 - change bridge type from Sandy Bridge to Ivy Bridge when -w argument is used (Pike, Februari 2014)
 - Use Scope (_PR) {} if found for DSDT's without Processor declarations (Pike, Februari 2014)
 - less cluttered output (Pike, Februari 2014)
 - check all processor declarations instead of just the first one (Pike, Februari 2014)
 - show warning if not all processor declarations are found in the DSDT (Pike, Februari 2014)
 - first set of changes for multi-processor support (Pike, Februari 2014)

Version 10.0

 - Search for Scope (\_PR_) instead of just "_PR_" (Pike, Februari 2014)
 - Major rewrite/new routines added to search for the processor scope (Pike, Februari 2014)
 - New error message/added text about SMBIOS (Pike, Februari 2014)
 - Ask for confirmation when the script may break/produce errors (Pike, Februari 2014)
 - Double "${" error on line 1640 fixed (Pike, Februari 2014)

Version 9.5

 - Missing Haswell i3 processor data added (Pike, Februari 2014)
 - TDP can now also be a floating-point number (Pike, Februari 2014)
 - New Broadwell processor preps (Pike, Februari 2014)
 - Reformatted code layout (Pike, Februari 2014)
 - Changed a bunch of misnamed (local) variables (Pike, Februari 2014)
 - Fixed a couple of let/local mixups (Pike, Februari 2014)
 - Destination path/filename no longer defauls to RevoBoot (Pike, Februari 2014)
 - Support for RevoEFI added (Pike, Februari 2014)
 - Changed SSDT.dsl open behaviour/ask for confirmation (Pike, Februari 2014)
 - Additional processor scope check to get \_SB_ (Pike, Februari 2014)
 - Set gIvyWorkAround=0 when XCPM is being used (Pike, Februari 2014)
 - Added a lost return (Pike, Februari 2014)
 - Fixed some layout issues (Pike, Februari 2014)
 - Removed a misleading piece of text (Pike, Februari 2014)

Version 8.0

 - Show the CPU brandstring at all times (Pike, January 2014)
 - Fixed cpu-type suggestion for MacPro6,1 (Pike, January 2014)
 - Intel i7-4771 added (Pike, January 2014)
 - A couple Intel Haswell/Crystal Well processor models added (Pike, January 2014)
 - Moved a couple of Ivy Bridge desktop model processors to the right spot (Pike, January 2014)
 - Experimental code added for Gringo Vermelho (Pike, January 2014)
 - Fixed a typo so that checking gIvyWorkAround really works (Pike, January 2014)
 - Added extra OS checks (as a test) to filter out possibly unwanted LFM P-States (Pike, January 2014)
 - Let gIvyWorkAround control the additional LFM P-States (Pike, January 2014)
 - Fixed a typo in processor data (i7-4960K should be i7-4960X) (Pike, January 2014)

Version 6.5

 - Updating to v6.5 with bugs fixes and EFI partition checking for Clover compatibility (Pike, May 2013)
 - Output of Clover ACPI directory detection fixed (Pike, June 2013)
 - Haswell CPUs added (Jeroen, June 2013)
 - board-id's for new MacBookAir6,[1/2] added (Pike, June 2013)
 - board-id's for new iMac14,[1/2/3] added (Pike, October 2013)
 - board-id's for new MacBookPro11,[1/2/3] added (Pike, October 2013)
 - Cleanups and board-id for new MacPro6,1 added (Pike, October 2013)
 – Frequency error in i7-4700MQ data fixed, thanks to RehabMan (Pike, November 2013)
 - Intel i5-4200M added (Pike, December 2013)
 - LFM fixed in the Intel i7-3930K data (Pike, December 2013)
 - Intel E5-2695 V2 added (Pike, December 2013)
 - Intel i3-3250 added (Pike, December 2013)
 - Sed RegEx error fixed in _getCPUtype (Pike, January 2014)
 - Fixed a typo 's/i7-2640M/i7-2674M/' (Pike, January 2014)
 - Fixed a typo 's/gHaswellCPUList/gServerHaswellCPUList/' (Pike, January 2014)
 - Intel E5-26nn v2 Xeon Processors added (Pike, January 2014)

Versions (without version info)

 - Added support for Ivy Bridge (Pike, January 2013)
 - Filename error fixed (Pike, January 2013)
 - Namespace error fixed in _printScopeStart (Pike, January 2013)
 - Model and board-id checks added (Pike, January 2013)
 - SMBIOS cpu-type check added (Pike, January 2013)
 - Copy/paste error fixed (Pike, January 2013)
 - Method ACST added to CPU scopes for IB CPUPM (Pike, January 2013)
 - Method ACST corrected for latest version of iasl (Dave, January 2013)
 - Changed path/filename to ~/Desktop/SSDT_PR.dsl (Dave, January 2013)
 - P-States are now one-liners instead of blocks (Pike, January 2013)
 - Support for flexible ProcessorNames added (Pike, Februari 2013)
 - Better feedback and Debug() injection added (Pike, Februari 2013)
 - Automatic processor type detection (Pike, Februari 2013)
 - TDP and processor type are now optional arguments (Pike, Februari 2013)
 - system-type check (used by X86PlatformPlugin) added (Pike, Februari 2013)
 - ACST injection for all logical processors (Pike, Februari 2013)
 - Introducing a stand-alone version of method _DSM (Pike, Februari 2013)
 - Fix incorrect turbo range (Pike, Februari 2013)
 - Restore IFS before return (Pike, Februari 2013)
 - Better/more complete feedback added (Jeroen, Februari 2013)
 - Processor data for desktop/mobile and server CPU's added (Jeroen, Februari 2013)
 - Improved power calculation, matching Apple's new algorithm (Pike, Februari 2013)
 - Fix iMac13,N latency and power values for C3 (Jeroen/Pike, Februari 2013)
 - IASL failed to launch when path included spaces (Pike, Februari 2013)
 - Typo in cpu-type check fixed (Jeroen, Februari 2013)
 - Error in CPU data (i5-3317U) fixed (Pike, Februari 2013)
 - Setting added for the target path/filename (Jeroen, Februari 2013)
 - Initial implementation of auto-copy (Jeroen, Februari 2013)
 - Additional checks added for cpu data/turbo modes (Jeroen, Februari 2013)
 - Undo filename change done by Jeroen (Pike, Februari 2013)
 - Improved/faster search algorithm to locate iasl (Jeroen, Februari 2013)
 - Bug fix, automatic revision update and better feedback (Pike, Februari 2013)
 - Turned auto copy on (Jeroen, Februari 2013)
 - Download IASL if it isn't there where we expect it (Pike, Februari 2013)
 - A sweet dreams update for Pike who wants better feedback (Jeroen, Februari 2013)
 - First set of Haswell processors added (Pike/Jeroen, Februari 2013)
 - More rigid testing for user errors (Pike/Jeroen, Februari 2013)
 - Getting ready for new Haswell setups (Pike/Jeroen, Februari 2013)
 - Typo and ssdtPRGen.command breakage fixed (Jeroen, Februari 2013)
 - Target folder check added for _findIASL (Pike, Februari 2013)
 - Set $baseFreqyency to $lfm when the latter isn't zero (Pike, Februari 2013)
 - Check PlatformSupport.plist for supported model/board-id added (Jeroen, Februari 2013)
 - New/expanded Sandy Bridge CPU lists, thanks to Francis (Jeroen, Februari 2013)
 - More preparations for the official Haswell launch (Pike, Februari 2013)
 - Fix for home directory with space characters (Pike, Februari 2013)
 - Sandy Bridge CPU lists rearranged/extended, thanks to 'stinga11' (Jeroen, Februari 2013)
 - Now supporting up to 16 logical cores (Jeroen, Februari 2013)
 - Improved argument checking, now supporting a fourth argument (Jeroen/Pike, Februari 2013)
 - Suppress override output when possible (Jeroen, Februari 2013)
 - Get processor label from ioreg (Jeroen/Pike, Februari 2013)
 - Create /usr/local/bin when missing (Jeroen, Februari 2013)
 - Changed warnings to make them pop out in the on-screen log (Pike, March 2013)
 - Now using the ACPI processor names of the running system (Pike, March 2013)
 - Now supporting up to 256/0xff logical processors (Pike, March 2013)
 - Command line argument for processor labels added (Pike, March 2013)
 - Bug fix, overriding the cpu type displayed the wrong name (Jeroen, March 2013)
 - Automatic detection of CPU scopes added (Pike, March 2013)
 - Show warnings for Sandy Bridge systems as well (Jeroen, March 2013)
 - New Intel Haswell processors added (Jeroen, April 2013)
 - Improved Processor declaration detection (Jeroen/Pike, April 2013)
 - New path for Clover revision 1277 (Jeroen, April 2013)
 - Haswell's minimum core frequency is 800 MHz (Jeroen, April 2013)
 - CPU signature output added (Jeroen/Pike, April 2013)
 - Updating to v6.4 after Jeroen's accidental RM of my local RevoBoot directory (Pike, May 2013)
