#!/bin/bash
#
# Script (ssdtPRGen.sh) to create ssdt-pr.dsl for Apple Power Management Support.
#
# Version 0.9 - Copyright (c) 2012 by RevoGirl
#
# Version 21.5 - Copyright (c) 2014-2017 by Pike <PikeRAlpha@yahoo.com>
#
# Readme......: https://github.com/Piker-Alpha/ssdtPRGen.sh/blob/master/README.md
#
# Change log..: https://github.com/Piker-Alpha/ssdtPRGen.sh/blob/master/CHANGELOG.md
#
# Contributors: https://github.com/Piker-Alpha/ssdtPRGen.sh/blob/master/CONTRIBUTORS.md
#
# Bug reports.: https://github.com/Piker-Alpha/ssdtPRGen.sh/issues
#
#			    Please provide clear steps to reproduce the bug, the terminal output
#			    of the script (the log data) and the resulting SSDT.dsl Thank you!
#

# set -x # Used for tracing errors (can be used anywhere in the script).

#================================= GLOBAL VARS ==================================

#
# Script version info.
#
gScriptVersion=21.5

#
# GitHub branch to pull data from (master or Beta).
#
gGitHubBranch="Beta"

#
# Github download URL.
#
gGitHubContentURL="https://raw.githubusercontent.com/Piker-Alpha/ssdtPRGen.sh/${gGitHubBranch}"

#
# Change this to 1 if you want to use the Github project directory instead of ~/Library/ssdtPRGen
#
let gDeveloperMode=0

#
# The script expects '0.5' but non-US localizations use '0,5' so we export
# LC_NUMERIC here (for the duration of the ssdtPRGen.sh) to prevent errors.
#
export LC_NUMERIC="en_US.UTF-8"

#
# Prevent non-printable/control characters (see issue #180).
#
unset GREP_OPTIONS
unset GREP_COLORS
unset GREP_COLOR

#
# Change this to 1 if you want to enable custom mode by default:
#
# Note: Custom mode will look for ~/Desktop/DSDT/APIC.aml and use that instead
#       of the ACPI tables (extracted during normal mode) from the host computer.
#
# _getProcessorNames - will use hardcoded processor names (not ioreg extracted).
# _extractAcpiTables – will not extract ACPI tables.
#
let gCustomMode=0

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
let gCPUWorkArounds=0

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
# Custom ACPI processor label (initialised by _updateProcessorNames).
#
gProcLabel=""

gProcessorNames=""
#
# Uncomment/change this for dry runs.
#
# gProcessorNames=("C000" "C001" "C002" "C003" "C100" "C101" "C102" "C103")
# gProcessorNames=("C000" "C001" "C002" "C003" "C004" "C005" "C006" "C007" "C008" "C009" "C00A" "C00B")
# gProcessorNames=("C000" "C001" "C002" "C003" "C004" "C005" "C006" "C007" "C008" "C009" "C00A" "C00B" "C00C" "C00D" "C00E" "C00F" \
#                  "C100" "C101" "C102" "C103" "C104" "C105" "C106" "C107" "C108" "C109" "C10A" "C10B" "C10C" "C10D" "C10E" "C10F")

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
# Number of physical processors.
#
let gPhysicalCPUs=1

#
# Initialised in _getScriptArguments and used in .
#
let gTargetProcessorType=0

#
# Number of logical cores per ACPI processor scope (initialised in main).
#
let gLogicalCPUsPerScope=0

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
# Note: Set this to 0 if you want to inject ACPI Processor (...) {} declarations intead of External () objects.
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
gHome=$(echo $HOME)
gPath="${gHome}/Library/ssdtPRGen"
gDataPath="${gPath}/Data"
gToolPath="${gPath}/Tools"
gSsdtID="ssdt"
gSsdtPR="${gPath}/${gSsdtID}.dsl"
gACPITablePath="${gPath}/ACPI"

#
# Default override path for -mode custom
#
# Note: Path used to convert APIC/DSDT.aml to data format.
#
gOverridePath="${gHome}/Desktop"

let gDesktopCPU=1
let gMobileCPU=2
let gServerCPU=3

let gSystemType=0

let gACST_CPU0=13
let gACST_CPU1=7

gTargetMacModel=""

let USER_DEFINED=1
let SANDY_BRIDGE=2
let IVY_BRIDGE=4
let HASWELL=8
let BROADWELL=16
let SKYLAKE=32
let KABYLAKE=64

#
# Array with configuration files (used to show version information).
#
gProcessorDataConfigFiles=("User Defined" "Sandy Bridge" "Ivy Bridge" "Haswell" "Broadwell" "Skylake" "Kaby Lake")

#
# Global variable used as target cpu/bridge type.
#
let gBridgeType=-1

let gTypeCPU=0
let gProcessorStartIndex=0
let gLfm=0
let gTdp=0
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
let FILE_NOT_FOUND_ERROR=9
let LFM_ERROR=10

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
  _PRINT_MSG "Aborting ...\nDone.\n\n"

  exit $1
}


#
#--------------------------------------------------------------------------------
#

function _printHeader()
{
    echo '/*'                                                                         >  "$gSsdtPR"
    echo ' * Intel ACPI Component Architecture'                                       >> "$gSsdtPR"
    echo ' * AML Disassembler version 20140210-00 [Feb 10 2014]'                      >> "$gSsdtPR"
    echo ' * Copyright (c) 2000 - 2014 Intel Corporation'                             >> "$gSsdtPR"
    echo ' * '                                                                        >> "$gSsdtPR"
    echo ' * Original Table Header:'                                                  >> "$gSsdtPR"
    echo ' *     Signature        "SSDT"'                                             >> "$gSsdtPR"
    echo ' *     Length           0x0000036A (874)'                                   >> "$gSsdtPR"
    echo ' *     Revision         0x01'                                               >> "$gSsdtPR"
    echo ' *     Checksum         0x00'                                               >> "$gSsdtPR"
    echo ' *     OEM ID           "APPLE "'                                           >> "$gSsdtPR"
    echo ' *     OEM Table ID     "CpuPm"'                                            >> "$gSsdtPR"
  printf ' *     OEM Revision     '$gRevision' (%d)\n' $gRevision                     >> "$gSsdtPR"
    echo ' *     Compiler ID      "INTL"'                                             >> "$gSsdtPR"
    echo ' *     Compiler Version 0x20140210 (538182160)'                             >> "$gSsdtPR"
    echo ' */'                                                                        >> "$gSsdtPR"
    echo ''                                                                           >> "$gSsdtPR"
    echo 'DefinitionBlock ("'$gSsdtID'.aml", "SSDT", 1, "APPLE ", "CpuPm", '$gRevision')' >> "$gSsdtPR"
    echo '{'                                                                          >> "$gSsdtPR"
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
  #
  # Local variable initialisation.
  #
  let index=0
  let scopeIndex=1
  #
  # Loop through all processor scopes.
  #
  for scope in "${gScope[@]}"
  do
    let maxCoresPerScope=($gLogicalCPUsPerScope*$scopeIndex)
    #
    # Are we done yet?
    #
    if [[ $index -eq $gLogicalCPUs ]];
      then
        #
        # Yes. Bail out early.
        #
        return
    fi
    #
    # Are we targeting a multi-processor configuration?
    #
    if [[ $gPhysicalCPUs -gt 1 ]];
      then
        #
        # Yes. Add a comment about the target device scope.
        #
        echo '    /* Device('${scope}') */'                                           >> "$gSsdtPR"
    fi
    #
    # Inject External () object for each logical processor in this processor scope.
    #
    while [ $index -lt $maxCoresPerScope ];
    do
      echo '    External ('${scope}'.'${gProcessorNames[$index]}', DeviceObj)'        >> "$gSsdtPR"
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
  # Get Processor Control Block (P_BLK) address from offset: 152/0x98 in FACP.aml
  #
  local data=$(xxd -s 152 -l 4 -ps "${gPath}/facp.aml")
  #
  # Convert data to Little Endian
  #
  local pblockAddress="0x${data:6:2}${data:4:2}${data:2:2}${data:0:2}"
  #
  # Increase P_BLK address with 16
  #
  let pblockAddress+=0x10
  #
  # Return P_BLK address + 16
  #
  echo $(printf "0x%08x" $pblockAddress)
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
  local pBlockAddress=$(_getPBlockAddress)
  #
  # Local variable initialisation.
  #
  let index=0
  let scopeIndex=1
  #
  # Loop through all processor scopes.
  #
  for scope in "${gScope[@]}"
  do
    let maxCoresPerScope=($gLogicalCPUsPerScope*$scopeIndex)
    #
    # Do we have a device name?
    #
    if [[ $scope =~ ^"\_SB_." ]];
      then
        local scopeName=$(echo $scope | sed -e 's/^\\_SB_\.//')

        echo '    Scope(\_SB_)'                                                       >> "$gSsdtPR"
        echo '    {'                                                                  >> "$gSsdtPR"
        echo '        Device ('$scopeName')'                                          >> "$gSsdtPR"
        echo '        {'                                                              >> "$gSsdtPR"
        echo '            Name (_HID, "ACPI0004")'                                    >> "$gSsdtPR"
      else
        echo '    Scope('$scope')'                                                    >> "$gSsdtPR"
        echo '    {'                                                                  >> "$gSsdtPR"
    fi
    #
    # Inject Processor () object for each logical processor in this processor scope.
    #
    while [ $index -lt $maxCoresPerScope ];
    do
      if [[ $scope =~ ^"\_SB_." ]];
        then
          echo ''                                                                     >> "$gSsdtPR"
          echo '            Processor ('${gProcessorNames[$index]}', '$index', '$pBlockAddress', Zero)' >> "$gSsdtPR"
          echo '            {'                                                        >> "$gSsdtPR"
          echo '                Name (_HID, "ACPI0007")'                              >> "$gSsdtPR"
          echo '                Name (_STA, 0x0F)'                                    >> "$gSsdtPR"
          echo '            }'                                                        >> "$gSsdtPR"
        else
          echo "        Processor ("${gProcessorNames[$index]}", "$index", "$pBlockAddress", 0x06) {}" >> "$gSsdtPR"
      fi
      #
      # Next logical processor.
      #
      let index+=1
    done

    if [[ $scope =~ ^"\_SB_." ]];
      then
        echo '        }'                                                              >> "$gSsdtPR"
    fi

    echo '    }'                                                                      >> "$gSsdtPR"
    #
    # 
    #
    if [[ $scopeIndex -lt ${#gScope[@]} ]];
      then
        echo ''                                                                       >> "$gSsdtPR"
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

  echo '        Method (_INI, 0, NotSerialized)'                                       >> "$gSsdtPR"
  echo '        {'                                                                     >> "$gSsdtPR"
  echo '            Store ("ssdtPRGen version.....: '$gScriptVersion' / '$gProductName' '$gProductVersion' ('$gBuildVersion')", Debug)'  >> "$gSsdtPR"
  echo '            Store ("custom mode...........: '$gCustomMode'", Debug)'            >> "$gSsdtPR"
  echo '            Store ("host processor........: '$gBrandString'", Debug)'           >> "$gSsdtPR"
  echo '            Store ("target processor......: '$gProcessorNumber'", Debug)'       >> "$gSsdtPR"
  echo '            Store ("number of processors..: '$gPhysicalCPUs'", Debug)'          >> "$gSsdtPR"
  echo '            Store ("baseFrequency.........: '$gBaseFrequency'", Debug)'         >> "$gSsdtPR"
  echo '            Store ("frequency.............: '$frequency'", Debug)'              >> "$gSsdtPR"
  echo '            Store ("busFrequency..........: '$gBusFrequency'", Debug)'          >> "$gSsdtPR"
  echo '            Store ("logicalCPUs...........: '$gLogicalCPUs'", Debug)'           >> "$gSsdtPR"
  echo '            Store ("maximum TDP...........: '$gTdp'", Debug)'                   >> "$gSsdtPR"
  echo '            Store ("packageLength.........: '$packageLength'", Debug)'          >> "$gSsdtPR"
  echo '            Store ("turboStates...........: '$turboStates'", Debug)'            >> "$gSsdtPR"
  echo '            Store ("maxTurboFrequency.....: '$maxTurboFrequency'", Debug)'      >> "$gSsdtPR"
  #
  # CPU workarounds requested?
  #
  if [[ $gCPUWorkArounds -gt 0 ]];
    then
          echo '            Store ("CPU Workarounds.......: '$gCPUWorkArounds'", Debug)' >> "$gSsdtPR"
  fi
  #
  # XCPM mode initialised?
  #
  if [[ $gXcpm -ne -1 ]];
    then
       echo '            Store ("machdep.xcpm.mode.....: '$gXcpm'", Debug)'             >> "$gSsdtPR"
  fi
  #
  # Do we have more than one ACPI processor scope?
  #
  if [[ "${#gScope[@]}" -gt 1 ]];
   then
      echo '            Store ("number of ACPI scopes.: '${#gScope[@]}'", Debug)'       >> "$gSsdtPR"
  fi

  echo '        }'                                                                     >> "$gSsdtPR"
  echo ''                                                                              >> "$gSsdtPR"
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
  let index=($gLogicalCPUsPerScope*$scopeIndex)
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

  echo ''                                                                             >> "$gSsdtPR"
  echo '    Scope ('${gScope[${scopeIndex}]}'.'${gProcessorNames[$index]}')'          >> "$gSsdtPR"
  echo '    {'                                                                        >> "$gSsdtPR"

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
      if (( $gBridgeType == $IVY_BRIDGE && $gCPUWorkArounds & 2 ));
        then
          let lowFrequencyPStates=($gBaseFrequency/100)-7

          if [[ $lowFrequencyPStates -lt 0 ]];
            then
              let lowFrequencyPStates=$(echo ${lowFrequencyPStates#-})
              printf "lowFrequencyPStates: $lowFrequencyPStates\n"
          fi
      fi

      let packageLength=($packageLength+$lowFrequencyPStates)

      if [[ $lowFrequencyPStates -gt 0 ]];
        then
          if [[ $lowFrequencyPStates -gt 1 ]];
            then
              printf "        Name (APLF, 0x%02x)\n" $lowFrequencyPStates             >> "$gSsdtPR"
            else
              printf "        Name (APLF, One)\n"                                     >> "$gSsdtPR"
           fi
        else
          # Prevent optimization warning.
          echo "        Name (APLF, Zero)"                                            >> "$gSsdtPR"
      fi

      if [[ $gBridgeType -eq $IVY_BRIDGE && ($gCPUWorkArounds -eq 1 || $gCPUWorkArounds -eq 3) ]];
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
          echo '        Name (APSN, One)'                                             >> "$gSsdtPR"
        else
          echo '        Name (APSN, Zero)'                                            >> "$gSsdtPR"
      fi
    else
      # TODO: Remove this when CPUPM for IB works properly!
      if (( $useWorkArounds ));
        then
          let turboStates+=1
      fi

      printf "        Name (APSN, 0x%02X)\n" $turboStates                             >> "$gSsdtPR"
  fi

  # TODO: Remove this when CPUPM for IB works properly!
  if (( $useWorkArounds ));
    then
      let packageLength+=1
  fi

  printf "        Name (APSS, Package (0x%02X)\n" $packageLength                      >> "$gSsdtPR"
  echo '        {'                                                                    >> "$gSsdtPR"

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

      let extraR=($maxTurboFrequency/$gBusFrequency)+1

      if [ $gBusFrequency -eq 100 ];
        then
          echo '            /* CPU Workaround #1 */'                                    >> "$gSsdtPR"
          printf "            Package (0x06) { 0x%04X, 0x%06X, 0x0A, 0x0A, 0x%02X00, 0x%02X00 },\n" $extraF $maxTDP $extraR $extraR >> "$gSsdtPR"
        else
          echo "            /* Workaround for AppleIntelCPUPowerManagement mode */"     >> "$gSsdtPR"
          printf "            Package (0x06) { 0x%04X, 0x%06X, 0x0A, 0x0A, 0x00%02X, 0x00%02X },\n" $extraF $maxTDP $extraR $extraR >> "$gSsdtPR"
      fi
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
  local multipliedBusFrequency
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
  let multipliedBusFrequency=($gBusFrequency*10)

  case "$gBusFrequency" in
    133) let multipliedBusFrequency+=3
         ;;
    166) let multipliedBusFrequency+=6
         ;;
  esac

  #
  # Do we need to add additional (Low Frequency) P-States for Ivy Bridge?
  #
  if (( $gBridgeType == $IVY_BRIDGE && $gCPUWorkArounds & 2 ));
    then
      let minRatio=7
  fi

  if (( $turboStates ));
    then
      echo '            /* High Frequency Modes (turbo) */'                           >> "$gSsdtPR"
  fi

  while [ $ratio -ge $minRatio ];
  do
    if [ $frequency -eq $gBaseFrequency ];
      then
        echo '            /* Low Frequency Mode */'                                   >> "$gSsdtPR"
    fi

    if [ $frequency -eq $maxNonTurboFrequency ];
      then
        echo '            /* High Frequency Modes (non-turbo) */'                     >> "$gSsdtPR"
    fi

    if (( $ratio == $minRatio && $gBridgeType == $IVY_BRIDGE && $gCPUWorkArounds & 2 ));
      then
        echo '            /* CPU Workaround #2 */'                                    >> "$gSsdtPR"
    fi

    printf "            Package (0x06) { 0x%04X, " $frequency                         >> "$gSsdtPR"

    if [ $frequency -lt $maxNonTurboFrequency ];
      then
        if [ $gBusFrequency -eq 100 ];
          then
            power=$(echo "scale=6;m=((1.1-(($p0Ratio-$powerRatio)*0.00625))/1.1);(($powerRatio/$p0Ratio)*(m*m)*$maxTDP);" | bc | sed -e 's/.[0-9A-F]*$//')
            let powerRatio-=1
          else
            let ratioFactor=($ratio*30)/$p0Ratio;
            power=$(echo "scale=6;(($ratioFactor*$ratioFactor*$ratioFactor*$maxTDP)/27000);" | bc | sed -e 's/.[0-9A-F]*$//')
            let powerRatio-=1
        fi
      else
        power=$maxTDP
    fi

    if [ $frequency -ge $gBaseFrequency ];
      then
        printf "0x%06X, " $power                                                      >> "$gSsdtPR"
      else
        printf '    Zero, '                                                           >> "$gSsdtPR"
    fi

    if [ $gBusFrequency -eq 100 ];
      then
        printf "0x0A, 0x0A, 0x%02X00, 0x%02X00 }" $ratio $ratio                       >> "$gSsdtPR"
      else
        printf "0x0A, 0x0A, 0x00%02X, 0x00%02X }" $ratio $ratio                       >> "$gSsdtPR"
    fi

    let ratio-=1
    let frequency=$(printf "%.f\n" $(echo "scale=1;((($multipliedBusFrequency/10)*$ratio)+0.5)" | bc))

    if [ $ratio -ge $minRatio ];
      then
        echo ','                                                                      >> "$gSsdtPR"
      else
        echo ''                                                                       >> "$gSsdtPR"
    fi

  done

  echo '        })'                                                                   >> "$gSsdtPR"
}


#
#--------------------------------------------------------------------------------
#

function _printMethodDSM()
{
  if [[ ($gBridgeType -ge $IVY_BRIDGE && $gBusFrequency -eq 100) || $gXcpm -eq 1 ]];
    then
      #
      # New stand-alone version of Method _DSM - Copyright (c) 2009 by Master Chief
      #
      echo ''                                                                             >> "$gSsdtPR"
      echo '        Method (_DSM, 4, NotSerialized)'                                      >> "$gSsdtPR"
      echo '        {'                                                                    >> "$gSsdtPR"

      if [[ $gDebug -eq 1 ]];
        then
          local debugScopeName=$(echo $scope | sed -e 's/^\\//')

          echo '            Store ("Method '$debugScopeName'.'${gProcessorNames[0]}'._DSM Called", Debug)'  >> "$gSsdtPR"
          echo ''                                                                         >> "$gSsdtPR"
      fi

      echo '            If (LEqual (Arg2, Zero))'                                         >> "$gSsdtPR"
      echo '            {'                                                                >> "$gSsdtPR"
      echo '                Return (Buffer (One)'                                         >> "$gSsdtPR"
      echo '                {'                                                            >> "$gSsdtPR"
      echo '                    0x03'                                                     >> "$gSsdtPR"
      echo '                })'                                                           >> "$gSsdtPR"
      echo '            }'                                                                >> "$gSsdtPR"
      echo ''                                                                             >> "$gSsdtPR"
      #
      # This property is required to get X86Platform[Plugin/Shim].kext loaded.
      #
      echo '            Return (Package (0x02)'                                           >> "$gSsdtPR"
      echo '            {'                                                                >> "$gSsdtPR"
      echo '                "plugin-type",'                                               >> "$gSsdtPR"
      echo '                One'                                                          >> "$gSsdtPR"
      echo '            })'                                                               >> "$gSsdtPR"
      echo '        }'                                                                    >> "$gSsdtPR"
      echo '    }'                                                                        >> "$gSsdtPR"
    elif [[ $gBridgeType -gt $SANDY_BRIDGE ]];
      then
        echo '    }'                                                                      >> "$gSsdtPR"
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

  echo ''                                                                             >> "$gSsdtPR"
  echo '        Method (ACST, 0, NotSerialized)'                                      >> "$gSsdtPR"
  echo '        {'                                                                    >> "$gSsdtPR"

  if (( $gDebug ));
    then
     local debugScopeName=$(echo $scope | sed -e 's/^\\//')

      echo '            Store ("Method '$debugScopeName'.'${gProcessorNames[$targetCPU]}'.ACST Called", Debug)'  >> "$gSsdtPR"
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
      echo '            Store ("'${gProcessorNames[$targetCPU]}' C-States    : '$targetCStates'", Debug)' >> "$gSsdtPR"
      echo ''                                                                         >> "$gSsdtPR"
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

    echo "            /* Low Power Modes for ${gProcessorNames[$1]} */"               >> "$gSsdtPR"
  printf "            Return (Package (0x%02x)\n" $pkgLength                          >> "$gSsdtPR"
    echo '            {'                                                              >> "$gSsdtPR"
    echo '                One,'                                                       >> "$gSsdtPR"
  printf "                0x%02x,\n" $numberOfCStates                                 >> "$gSsdtPR"
    echo '                Package (0x04)'                                             >> "$gSsdtPR"
    echo '                {'                                                          >> "$gSsdtPR"
    echo '                    ResourceTemplate ()'                                    >> "$gSsdtPR"
    echo '                    {'                                                      >> "$gSsdtPR"
    echo '                        Register (FFixedHW,'                                >> "$gSsdtPR"
    echo '                            0x01,               // Bit Width'               >> "$gSsdtPR"
    echo '                            0x02,               // Bit Offset'              >> "$gSsdtPR"
  printf "                            0x%016x, // Address\n" $hintCode                >> "$gSsdtPR"
    echo '                            0x01,               // Access Size'             >> "$gSsdtPR"
    echo '                            )'                                              >> "$gSsdtPR"
    echo '                    },'                                                     >> "$gSsdtPR"
    echo '                    One,'                                                   >> "$gSsdtPR"
    echo '                    '$latency_C1','                                         >> "$gSsdtPR"
    echo '                    0x03E8'                                                 >> "$gSsdtPR"

  if (($C2));
    then
      let hintCode+=0x10
      echo '                },'                                                       >> "$gSsdtPR"
      echo ''                                                                         >> "$gSsdtPR"
      echo '                Package (0x04)'                                           >> "$gSsdtPR"
      echo '                {'                                                        >> "$gSsdtPR"
      echo '                    ResourceTemplate ()'                                  >> "$gSsdtPR"
      echo '                    {'                                                    >> "$gSsdtPR"
      echo '                        Register (FFixedHW,'                              >> "$gSsdtPR"
      echo '                            0x01,               // Bit Width'             >> "$gSsdtPR"
      echo '                            0x02,               // Bit Offset'            >> "$gSsdtPR"
    printf "                            0x%016x, // Address\n" $hintCode              >> "$gSsdtPR"
      echo '                            0x03,               // Access Size'           >> "$gSsdtPR"
      echo '                            )'                                            >> "$gSsdtPR"
      echo '                    },'                                                   >> "$gSsdtPR"
      echo '                    0x02,'                                                >> "$gSsdtPR"
      echo '                    '$latency_C2','                                       >> "$gSsdtPR"
      echo '                    0x01F4'                                               >> "$gSsdtPR"
  fi

  if (($C3));
    then
      let hintCode+=0x10
      local power_C3=0x01F4
      #
      # Is this for CPU1?
      #
      if (($1));
        then
          if [[ ${gModelID:0:7} == "iMac13," ]];
            then
              local power_C3=0x15E
              latency_C3=0xA9
            else
              local power_C3=0xC8
              let hintCode+=0x10
          fi
      fi

      echo '                },'                                                       >> "$gSsdtPR"
      echo ''                                                                         >> "$gSsdtPR"
      echo '                Package (0x04)'                                           >> "$gSsdtPR"
      echo '                {'                                                        >> "$gSsdtPR"
      echo '                    ResourceTemplate ()'                                  >> "$gSsdtPR"
      echo '                    {'                                                    >> "$gSsdtPR"
      echo '                        Register (FFixedHW,'                              >> "$gSsdtPR"
      echo '                            0x01,               // Bit Width'             >> "$gSsdtPR"
      echo '                            0x02,               // Bit Offset'            >> "$gSsdtPR"
    printf "                            0x%016x, // Address\n" $hintCode              >> "$gSsdtPR"
      echo '                            0x03,               // Access Size'           >> "$gSsdtPR"
      echo '                            )'                                            >> "$gSsdtPR"
      echo '                    },'                                                   >> "$gSsdtPR"
      echo '                    0x03,'                                                >> "$gSsdtPR"
      echo '                    '$latency_C3','                                       >> "$gSsdtPR"
      echo '                    '$power_C3                                            >> "$gSsdtPR"
  fi

  if (($C6));
    then
      let hintCode+=0x10
      echo '                },'                                                       >> "$gSsdtPR"
      echo ''                                                                         >> "$gSsdtPR"
      echo '                Package (0x04)'                                           >> "$gSsdtPR"
      echo '                {'                                                        >> "$gSsdtPR"
      echo '                    ResourceTemplate ()'                                  >> "$gSsdtPR"
      echo '                    {'                                                    >> "$gSsdtPR"
      echo '                        Register (FFixedHW,'                              >> "$gSsdtPR"
      echo '                            0x01,               // Bit Width'             >> "$gSsdtPR"
      echo '                            0x02,               // Bit Offset'            >> "$gSsdtPR"
    printf "                            0x%016x, // Address\n" $hintCode              >> "$gSsdtPR"
      echo '                            0x03,               // Access Size'           >> "$gSsdtPR"
      echo '                            )'                                            >> "$gSsdtPR"
      echo '                    },'                                                   >> "$gSsdtPR"
      echo '                    0x06,'                                                >> "$gSsdtPR"
      echo '                    '$latency_C6','                                       >> "$gSsdtPR"
      echo '                    0x015E'                                               >> "$gSsdtPR"
  fi

  if (($C7));
    then
      #
      # If $hintCode is already 0x30 then use 0x31 otherwise 0x30
      #
      if [ $hintCode -eq 48 ];
        then
          let hintCode+=0x01
        else
          let hintCode+=0x10
      fi
      echo '                },'                                                       >> "$gSsdtPR"
      echo ''                                                                         >> "$gSsdtPR"
      echo '                Package (0x04)'                                           >> "$gSsdtPR"
      echo '                {'                                                        >> "$gSsdtPR"
      echo '                    ResourceTemplate ()'                                  >> "$gSsdtPR"
      echo '                    {'                                                    >> "$gSsdtPR"
      echo '                        Register (FFixedHW,'                              >> "$gSsdtPR"
      echo '                            0x01,               // Bit Width'             >> "$gSsdtPR"
      echo '                            0x02,               // Bit Offset'            >> "$gSsdtPR"
    printf "                            0x%016x, // Address\n" $hintCode              >> "$gSsdtPR"
      echo '                            0x03,               // Access Size'           >> "$gSsdtPR"
      echo '                            )'                                            >> "$gSsdtPR"
      echo '                    },'                                                   >> "$gSsdtPR"
      echo '                    0x07,'                                                >> "$gSsdtPR"
      echo '                    '$latency_C7','                                       >> "$gSsdtPR"
      echo '                    0xC8'                                                 >> "$gSsdtPR"
  fi

  echo '                }'                                                            >> "$gSsdtPR"
  echo '            })'                                                               >> "$gSsdtPR"
  echo '        }'                                                                    >> "$gSsdtPR"
  #
  # Do we need to add a closing bracket?
  #
  # Note: The injected _DSM method will otherwise take care of it.
  #
  if [[ $gBridgeType -le $SANDY_BRIDGE && $gXcpm -ne 1 ]];
    then
      echo '    }'                                                                    >> "$gSsdtPR"
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
  local bspIndex
  local apIndex
  #
  # Local variable initialisation.
  #
  let index=1
  let scopeIndex=$1
  let bspIndex=$gLogicalCPUsPerScope*$scopeIndex
  let apIndex=$bspIndex+1

  local scope=${gScope[$scopeIndex]}

  while [ $index -lt $gLogicalCPUsPerScope ];
  do
    echo ''                                                                             >> "$gSsdtPR"
    echo '    Scope ('${scope}'.'${gProcessorNames[${apIndex}]}')'                      >> "$gSsdtPR"
    echo '    {'                                                                        >> "$gSsdtPR"
    echo '        Method (APSS, 0, NotSerialized)'                                      >> "$gSsdtPR"
    echo '        {'                                                                    >> "$gSsdtPR"

    if (( $gDebug ));
      then
        local debugScopeName=$(echo $scope | sed -e 's/^\\//')

        echo '            Store ("Method '$debugScopeName'.'${gProcessorNames[${apIndex}]}'.APSS Called", Debug)'  >> "$gSsdtPR"
        echo ''                                                                         >> "$gSsdtPR"
    fi

    echo '            Return ('${scope}'.'${gProcessorNames[${bspIndex}]}'.APSS)'       >> "$gSsdtPR"
    echo '        }'                                                                    >> "$gSsdtPR"
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
            echo ''                                                                     >> "$gSsdtPR"
            local processorName=${gProcessorNames[$bspIndex+1]}
            echo '        Method (ACST, 0, NotSerialized) { Return ('$scope'.'$processorName'.ACST ()) }' >> "$gSsdtPR"
        fi
    fi

    echo '    }'                                                                        >> "$gSsdtPR"

    let index+=1
    let apIndex+=1
  done
  #
  # Next processor scope.
  #
  let scopeIndex+=1

  if [[ $scopeIndex -eq ${#gScope[@]} ]];
    then
      echo '}'                                                                          >> "$gSsdtPR"
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
  local threadCount
  local processorLabels
  local processorModelSpecified=$1

  if [[ $gCustomMode -eq 0 ]];
    then
      #
      # Note: -k clock-frequency filters out the inactive cores.
      #
      local acpiNames=$(ioreg -p IODeviceTree -c IOACPIPlatformDevice -k cpu-type -k clock-frequency | egrep name | sed -e 's/ *[-|="<a-z>]//g')
      processorLabels=($acpiNames)
  fi
  #
  # Target processor model specified with -p argument?
  #
  if [[ $gTargetProcessorType -eq 0 ]];
    then
      #
      # No. Get processor model from the host computer.
      #
      _getCPUNumberFromBrandString $gTargetProcessorType
      #
      # Get CPU data of the host computer.
      #
      _getCPUDataByProcessorNumber
      #
      # Set thread count to that of the host computer.
      #
      let threadCount=${#processorLabels[@]}
    else
      #
      # Yes. Get CPU data based on the specified processor model.
      #
      _getCPUDataByProcessorNumber
      #
      # Target processor model located?
      #
      if [[ $gTypeCPU -gt 0 ]];
        then
          #
          # Set thread count to that of the target processor.
          #
          let threadCount=${gProcessorData[6]}
#         let gLogicalCPUs=$threadCount*$gPhysicalCPUs
      fi
  fi
  #
  # Check if -l argument is used.
  #
  if [[ $gLogicalCPUs -eq 0 ]];
    then
      let gLogicalCPUs=$threadCount*$gPhysicalCPUs
    else
      let threadCount=$gLogicalCPUs/$gPhysicalCPUs
  fi
  #
  # Check if -cpus argument is used.
  #
#if [[ $gPhysicalCPUs -gt 1 ]];
#  then
     let gLogicalCPUsPerScope=$threadCount
#  else
#    let gLogicalCPUsPerScope=$threadCount/${#gScope[@]}
# fi

  _initProcessorScope
  #
  # Custom ACPI Processor labels defined?
  #
  if [[ ${#gProcessorNames[@]} -eq 0 ]];
    then
      #
      # No. Is argument -mode custom used?
      #
      if [[ $gCustomMode -eq 0 ]];
        then
          #
          # No. Is argument -acpi used?
          #
          if [[ ${#gProcLabel} -eq 0 ]];
            then
              #
              # No. Use the ACPI Processor declarations from the host computer.
              #
              gProcessorNames=($acpiNames)
              gProcLabel=${gProcessorNames[0]}
            else
              #
              #
              #
              printf "YES-1\n"
          fi
        else
          #
          # Yes. Argument -mode custom is used.

          printf "YES-2\n"
#         _initProcessorScope
      fi
  fi

  _debugPrint "Number of Scopes: ${#gScope[@]}\n"

  if [[ $gPhysicalCPUs -lt ${#gScope[@]} ]];
    then
	  let gPhysicalCPUs+=1
  fi

  #
  # Do we have two or more logical processor cores?
  #
  if [[ ${#gProcessorNames[@]} -lt 2 ]];
    then
      #
      # No. Bail out with error.
      #
      _exitWithError $PROCESSOR_NAMES_ERROR
  fi
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

function _checkForProcessorDeclarations()
{
  #
  # Local variable definitions/initialisation.
  #
  local status=0
  local targetData=$1
  local deviceName=$2
  local isACPI10Compliant=$3
  local processorID
  local processorLabel
  local processorIsEnabled
  local processorDeclarationLenth
  local overrideProcessorEnableState

  local variableList=(16,18,20,22,24,30 6,8,10,12,14,20 8,10,12,14,16,22)

  let overrideProcessorEnableState=0
  let enabledProcessorsPerScope=0

  for varList in "${variableList[@]}"
  do
    #
    # Save default (0) delimiter.
    #
    local ifs=$IFS
    #
    # Change delimiter to a comma character.
    #
    IFS=","
    #
    # Split vars.
    #
    local vars=(${varList})
    #
    # Restore the default (0) delimiter.
    #
    IFS=$ifs
    #
    #
    #
    local deviceObjectData=($(echo "${targetData}" | egrep -o "${AML_PROCESSOR_SCOPE_OPCODE}[0-9a-f]{${vars[5]}}06"))
    #
    # The above grep pattern may fail, in which case we fall back to a previously used grep pattern.
    # See also: https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/215
    #
    if [[ ${#deviceObjectData[@]} -eq 1 ]];
      then
        local deviceObjectData=($(echo "${targetData}" | egrep -o "${AML_PROCESSOR_SCOPE_OPCODE}[0-9a-f]{${vars[5]}}"))
    fi

    if [[ $deviceObjectData ]];
      then
        #
        #
        #
        if [[ ${#deviceName} -gt 0 ]];
          then
#          _debugPrint "Device ($gScope/$deviceName): \n"
           _debugPrint "Device ($deviceName): \n"
        fi

        for processorDeclaration in "${deviceObjectData[@]}"
        do
          #
          # Get ProcessorID.
          #
          processorID="${processorDeclaration:${vars[4]}:2}"
          #
          # Check APIC data to see if this (logical) processor is enabled.
          #
          _isEnabledProcessor "${processorID}"
          #
          # Assign local variable with the return value.
          #
          processorIsEnabled=$?
          #
          # Processor enabled (first check)?
          #
          if [[ $processorIsEnabled -eq 0 && $enabledProcessorsPerScope -lt $gLogicalCPUsPerScope ]];
            then
              #
              # Override the enabled state.
              #
              overrideProcessorEnableState=1
              _debugPrint "Overriding processor enable state (now enabled)!\n"
            else
              overrideProcessorEnableState=0
          fi
#printf "overrideProcessorEnableState: $overrideProcessorEnableState\n"
          #
          # Is the (logical) processor enabled?
          #
          if [[ $processorIsEnabled -eq 1 || $overrideProcessorEnableState -eq 1 ]];
            then
              #
              # Yes it is (may be overriden). Check shell for invocation of sh ssdtPRGen.sh (see issue #279).
              #
              if [[ $BASH =~ "/bin/bash" ]];
                then
                  processorLabel=$(echo -e "\x${processorDeclaration:${vars[0]}:2}\x${processorDeclaration:${vars[1]}:2}\x${processorDeclaration:${vars[2]}:2}\x${processorDeclaration:${vars[3]}:2}")
                else
                  processorLabel=$(echo "\x${processorDeclaration:${vars[0]}:2}\x${processorDeclaration:${vars[1]}:2}\x${processorDeclaration:${vars[2]}:2}\x${processorDeclaration:${vars[3]}:2}")
              fi

              _debugPrint "processorID: ${processorID} $processorLabel\n"

              gProcessorNames[$gProcessorStartIndex]=$processorLabel
              #
              #
              #
              let gProcessorStartIndex+=1
              #
              # Keep track of the number of enabled (logical) processors.
              #
#printf "enabledProcessorsPerScope: ${enabledProcessorsPerScope}\n"
              let enabledProcessorsPerScope+=1
#printf "enabledProcessorsPerScope: ${enabledProcessorsPerScope}\n"
          fi
          #
          # Did we collact all the required (logical) processors?
          #
          if [[ $enabledProcessorsPerScope -eq $gLogicalCPUsPerScope ]];
            then
              #
              # Yes. We're done here.
              #
              #printf "break\n"
              break;
          fi
        done

        printf "\n"
    fi
  done

  return $gProcessorStartIndex
}


#
#--------------------------------------------------------------------------------
#

function _getACPIProcessorScope()
{
  #
  # Local variable definitions/initialisation.
  #
  local filename="$1"
  local basename=$(basename "${filename%.*}")
  local variableList=(10,6,40 12,8,42 24,20,40 14,10,44)
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
    # Change delimiter to a comma character.
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
    # Restore the default (0) delimiter.
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
            _debugPrint "${objectCount} Name (_HID, \"ACPI0004\") object(s) found in ${basename}\n"
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
          let scopeLength-=${vars[2]}
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
          # Check return status.
          #
#         if [[ $? -eq ${#gProcessorNames[@]} ]];
          if [[ $? -eq $gLogicalCPUs ]];
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
              return 1
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

                  _debugPrint "gScope              : ${#gScope[@]}\n"
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

  return 0
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
  local filename="$1"
  local scopeLength=0
  local basename=$(basename "${filename%.*}")
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
      # "528310[0-9a-f]{2}${grepPattern}"
      # "528310[0-9a-f]{4}${grepPattern}"
      # "528310[0-9a-f]{6}${grepPattern}"
      # "528310[0-9a-f]{8}${grepPattern}"
      #
      local data=$(egrep -o "${AML_PROCESSOR_SCOPE_OPCODE}${AML_SCOPE_OPCODE}[0-9a-f]{${typeEncoding}}${grepPattern}" "$filename")
      let patternLengthCorrection=0

      if [[ ${#data} -eq 0 ]];
        then
          #
          # "10[0-9a-f]{2}${grepPattern}"
          # "10[0-9a-f]{4}${grepPattern}"
          # "10[0-9a-f]{6}${grepPattern}"
          # "10[0-9a-f]{8}${grepPattern}"
          #
          local data=$(egrep -o "${AML_SCOPE_OPCODE}[0-9a-f]{${typeEncoding}}${grepPattern}" "$filename")
          let patternLengthCorrection=2
      fi

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

              _debugPrint $objectCount" Scope ("$scopeName") {"$scopeDots"} object(s) found in ${basename}\n"

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
            let grepPatternLength="${#AML_SCOPE_OPCODE}+$typeEncoding+${#grepPattern}-${patternLengthCorrection}"
            #
            # Lower scopeLength with the number of characters that we used for the match.
            #
            let scopeLength-=$grepPatternLength
            _debugPrint "scopeLength: $scopeLength (egrep pattern length: $grepPatternLength)\n"
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
                # and $(($index < 5)) informs it about the ACPI 1.0 compliance (true/false).
                #
                _checkForProcessorDeclarations $scopeObjectData "" $(($index < 5))
                #
                # Check return status (0 is SUCCESS).
                #
#               if [[ $? -eq 0 ]];
#               if [[ $? -eq ${#gProcessorNames[@]} ]];
                if [[ $? -eq $gLogicalCPUs ]];
                  then
                    #
                    # Reinitialise scopeLength (lowered for the repetitionString).
                    #
                    let scopeLength="${#scopeObjectData}"

                    printf "Scope ("$scopeName") {"$scopeLength" bytes} with ACPI Processor declarations found in ${basename} (ACPI 1.0 compliant)\n"
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

function _getEnabledProcessors()
{
  #
  # Check APIC structure type 00 for enabled processors.
  #
  gEnabledProcessors=($(egrep -o '0008[0-9a-f]{4}01000000' "/tmp/APIC.dat"))
  #
  # Note: Here is an explanation of the data:
  #
  # 0008000001000000
  # ^^ = APIC structure type (Processor Local APIC).
  #
  # 0008000001000000
  #   ^^ = APIC structure length (8).
  #
  # 0008000001000000
  #     ^^ = ACPI Processor ID.
  #
  # 0008000001000000
  #       ^^ = APIC ID.
  #
  # 0008000001000000
  #         ^^^^^^^^ = APIC flags (enabled processors = 01 / disabled = 00).
  #
  # Do we have the minimum number (2) of logical processors?
  #
  if [[ ${#gEnabledProcessors[@]} -lt 2 ]];
    then
      #
      # No. Error out.
      #
      _PRINT_MSG "Error: Not enough enabled processors found in: ${gOverridePath}/APIC.aml!"
      _ABORT
  fi
}


#
#--------------------------------------------------------------------------------
#

function _isEnabledProcessor()
{
  local processorID
  local targetProcessorID=$1
  #
  # Loop through the array with enabled processors.
  #
  for processorID in "${gEnabledProcessors[@]}"
  do
    #
    # Is this the processorID we are looking for?
    #
    if [[ ${processorID:4:2} == $targetProcessorID ]];
      then
        #
        # Yes. Check APIC flags to see if the processor is enabled.
        #
        if [[ ${processorID:8:8} == "01000000" ]];
          then
            #
            # Processor enabled.
            #
            return 1
        fi
    fi
  done
  #
  # ProcessorID not found, or procesor not enabled.
  #
  return 0
}


#
#--------------------------------------------------------------------------------
#

function _convertACPIFiles()
{
  #
  # Is argument -mode custom used?
  #
  if [[ $gCustomMode -eq 1 ]];
    then
      #
      # Yes. Use override path for ACPI files.
      #
      local path="${gOverridePath}"
    else
      #
      # ACPI table path specified (argument -extract)?
      #
      if [[ $gExtractionPath ]];
        then
          #
          # Yes. Use given path.
          #
          local path="${gExtractionPath}"
        else
          #
          # No. Use default path (~/Library/ssdtPRGen/ACPI)
          #
          local path="${gACPITablePath}"
      fi
  fi
  #
  # Is argument -developer 1 used, and not -extract [some path]?
  #
  if [[ $gDeveloperMode -eq 1 ]] &&
     [[ ! $gExtractionPath ]];
    then
      #
      # Yes. Fixup ACPI table path.
      #
      local path="${gPath}/ACPI"
  fi
  #
  # Check SSDT(-n).AML files for scope SCK0.
  #
  targetDataFiles=(`grep -l SCK0 ${gPath}/ACPI/SSDT*.aml`)
  #
  # Loop through all matchingFilenames.
  #
  for match in "${targetDataFiles[@]}"
  do
    _debugPrint "matchingFilename: ${match[@]}\n"
    #
    # Convert AML file to postscript format.
    #
    local filename=$(basename $match)
    xxd -c 256 -ps "${match}" | tr -d '\n' > "/tmp/${filename%.*}.dat"
  done
  #
  # Check for required file DSDT.aml
  #
  if [[ -f "${path}/DSDT.aml" ]];
    then
      #
      # Convert the override DSDT.aml file to postscript format.
      #
      xxd -c 256 -ps "${path}/DSDT.aml" | tr -d '\n' > "/tmp/DSDT.dat"
    else
      #
      #
      #
      _PRINT_MSG "Error: ${path}/DSDT.aml not found!"
      _ABORT
  fi
  #
  # Check for required file APIC.aml
  #
  if [[ -f "${path}/APIC.aml" ]];
    then
      #
      #
      #
      xxd -c 256 -ps "${path}/APIC.aml" | tr -d '\n' > "/tmp/APIC.dat"
    else
      #
      #
      #
      _PRINT_MSG "Error: ${path}/APIC.aml not found!"
      _ABORT
  fi
}


#
#--------------------------------------------------------------------------------
#

function _initProcessorScope()
{
  #
  # Local variable declarations.
  #
  local filename="/tmp/DSDT.dat"
  local basename=$(basename "${filename%.*}")
  local processorDeclarationsFound
  #
  # Local variable initialisation.
  #
  let processorDeclarationsFound=0
  #
  # Loop through all matching files.
  #
  for filename in "${targetDataFiles[@]}"
    do
    #
    # Setup file- and basename.
    #
    basename=$(basename "${filename}")
    filename="/tmp/${basename%.*}.dat"

    _debugPrint "_getACPIProcessorScope: ${filename}\n"
    #
    # Check for Device()s with enclosed Name (_HID, "ACPI0004") objects in SSDT(-*).dat
    #
    _getACPIProcessorScope "${filename}"

    if [ $? -eq 1 ];
      then
        _debugPrint "_getACPIProcessorScope: Done.\n"
        break
    fi
  done
  #
  # Processor declarationsa found?
  #
  if [[ $gScope == "" ]];
    then
      #
      # No. Check for Device()s with enclosed Name (_HID, "ACPI0004") objects in DSDT.dat
      #
      filename="/tmp/DSDT.dat"
      basename=$(basename "${filename%.*}")
      _getACPIProcessorScope "$filename"
  fi
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
      #
      # Note: This is not necessarily an error!
      #
      _debugPrint "Name (_HID, \"ACPI0004\") NOT found in ${basename}\n"
  fi
  #
  # Search for ACPI v1.0 compliant scopes (like _PR and _PR_).
  #
  _getProcessorScope "${filename}"
  #
  # Do we have a scope with processor declarations in it?
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
          printf 'ACPI Processor {.} Declaration(s) found in ${basename}\n'
          let processorDeclarationsFound=1
        else
          #
          # Check for processor declarations without child objects.
          #
          if [[ $(egrep -o '5b830b' "$filename") ]];
            then
              printf 'ACPI Processor {} Declaration(s) found in ${basename}\n'
              let processorDeclarationsFound=1
          fi
      fi
      #
      # Check for processor declarations with RootChar in DSDT.
      #
      local data=$(egrep -o '5b83[0-9a-f]{2}5c2e[0-9a-f]{8}' "$filename")

      if [[ $data ]];
        then
          printf "ACPI Processor {...} Declaration(s) with RootChar ('\\\') found in ${basename}"
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
          printf "ACPI Processor {...} Declaration(s) with DualNamePrefix ('.') found in ${basename}"
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
          printf "ACPI Processor {...} Declaration(s) with MultiNamePrefix ('/') found in ${basename}"

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
          printf "ACPI Processor {...} Declaration(s) with MultiNamePrefix ('/') found in ${basename}"

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
          printf "ACPI Processor {...} Declaration(s) with ParentPrefixChar ('^') found in ${basename}\n"
          gScope=$(echo ${data:6:2} | xxd -r -p)

          # ioreg -w0 -p IOACPIPlane -c IOACPIPlatformDevice -n _SB -r > ~/Library/ssdtPRGen/dsdt2.txt

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

  _PRINT_MSG "\nWarning: No ACPI Processor declarations found in ${basename}!\n\t Using assumed Scope ("$gScope") {}\n"
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
  # Return the hexadecimal value of machdep.cpu.model
  #
  echo 0x$(sysctl machdep.cpu.model | awk '{ printf("%X", $2) }')
}


#
#--------------------------------------------------------------------------------
#

function _getCPUSignature()
{
  #
  # Return the hexadecimal value of machdep.cpu.signature
  #
  echo 0x$(sysctl machdep.cpu.signature | awk '{ printf("%X", $2) }')
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

function _checkForExecutableFile()
{
  local targetFile=$1
  #
  # Check target file.
  #
  if [ ! -f "${gToolPath}/${targetFile}" ];
    then
      #
      # Not there. Do we have the ZIP file?
      #
      if [ ! -f "${gToolPath}/${targetFile}.zip" ];
        then
          #
          # No. Download it from the Github repository.
          #
          _PRINT_MSG "Notice: Downloading ${targetFile}.zip ..."
          curl -o "${gPath}/${targetFile}.zip" --silent "${gGitHubContentURL}/Tools/${targetFile}.zip"
          #
          # Unzip ZIP file.
          #
          _debugPrint "Unzipping ${targetFile}.zip ..."
          unzip -qu "${gPath}/${targetFile}.zip" -d "${gToolPath}/"
          #
          # Remove downloaded ZIP file.
          #
          _debugPrint 'Cleanups ..'
          rm "${gPath}/${targetFile}.zip"
        else
          #
          # Unzip ZIP file.
          #
          _debugPrint "Unzipping ${targetFile}.zip ..."
          unzip -qu "${gToolPath}/${targetFile}.zip" -d "${gToolPath}/"
      fi
  fi
  #
  #  Check executing bit.
  #
  _debugPrint "Setting executing bit of ${targetFile} ...\n"

  if [ ! -x "${gToolPath}/${targetFile}" ];
    then
      #
      # Set executing bit.
      #
      printf "Fixing executing bit of ${targetFile} ...\n"
      chmod +x "${gToolPath}/${targetFile}"
  fi

   _debugPrint "_checkForExecutableFile(${targetFile}) Done.\n"
}

#
#--------------------------------------------------------------------------------
#

function _findIasl()
{
  #
  # Do we have to call IASL?
  #
  if [[ $gCallIasl -eq 1 ]];
    then
      #
      # Yes. Do a quick lookup of IASL.
      #
      local iasl="$(type -p iasl)"
      #
      # Now we have to check if the file is still there.
      #
      if [ -x "${iasl}" ];
        then
          #
          # Yes it is. Let's use it.
          #
          gIasl="${iasl}"
          #
          # Done (no need to download it from the Github repository).
          #
          return
      fi
      #
      # IASL should be there after the first run, but may have been removed since.
      #
      _checkForExecutableFile "iasl"
  fi

  gIasl="${gToolPath}/iasl"
}


#
#--------------------------------------------------------------------------------
#

function _extractAcpiTables()
{
  #
  # extractACPITables should be there after the first run, but may have been removed since.
  #
  _checkForExecutableFile "extractACPITables"
  #
  # Do we have a given path for ACPI table extraction?
  #
  if [[ $gExtractionPath ]];
    then
      #
      # Yes. Use given target path for extractACPITables v0.6 and greater.
      #
      export SSDTPRGEN_EXTRACTION_PATH="${gExtractionPath}"
    else
      #
      # No. Use default ACPI table path.
      #
      export SSDTPRGEN_EXTRACTION_PATH="${gPath}/ACPI"
  fi
  #
  # Does the target directory exist?
  #
  if [[ ! -d "${SSDTPRGEN_EXTRACTION_PATH}" ]];
    then
      #
      # No. We need to create it.
      #
      mkdir -p "${SSDTPRGEN_EXTRACTION_PATH}"
  fi
  #
  # About to extract the ACPI tables.
  #
  _debugPrint 'Extracting ACPI tables ... '
  "${gToolPath}/extractACPITables"

  _debugPrint 'Done.\n'
}


#
#--------------------------------------------------------------------------------
#

function _checkSourceFilename
{
  #
  # Check for RevoBoot (legacy) setup on root volume.
  #
  if [[ -d "/Extra/ACPI" && -d "/Extra/EFI" ]];
    then
      let gIsLegacyRevoBoot=1

      if [[ $gDestinationPath != "/Extra/ACPI/" ]];
        then
          gDestinationPath="/Extra/ACPI/"
          _debugPrint "ACPI target directory changed to: ${gDestinationPath}\n"
      fi

      if [[ "$gDestinationFile" != "ssdt_pr.aml" ]];
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

      if [[ "$gDestinationFile" != "ssdt_pr.aml" ]];
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
  #
  # Save default (0) delimiter
  #
  local ifs=$IFS
  #
  # Change delimiter to a space character
  #
  IFS=" "
  #
  # Split brandstring (pulled in by _showSystemData) into array (data)
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
  # Restore the default (0) delimiter.
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
            # -target argument used?
            #
            if [[ $gBridgeType -gt 0 ]];
              then
                #
                # Yes. Check target processor model (represented here as 'gBridgeType').
                #
                case "$gBridgeType" in
                  $SANDY_BRIDGE) gProcessorNumber="${data[3]}"
                                 ;;
                  $IVY_BRIDGE)   gProcessorNumber="${data[3]} v2"
                                 ;;
                esac
              else
                #
                # No. Check Processor model.
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
      # Is this a Pentium processor model?
      #
      if [[ "${data[1]}" == "Pentium(R)" ]];
        then
          #
          # Yes. Use fourth value from brandstring ("Intel(R) Pentium(R) CPU G3420 @ 3.20GHz")
          #
          gProcessorNumber="${data[3]}"
        else
          #
          # No. Use third value from brandstring for all other processor models.
          #
          gProcessorNumber="${data[2]}"
      fi
  fi
}


#
#--------------------------------------------------------------------------------
#

function _checkForConfigFile
{
  #
  # Check given file.
  #
  if [ ! -f "${gDataPath}/${1}" ];
    then
      #
      # Not there.
      #
      return 1
  fi
  #
  # Do we have a local Data directory?
  #
  if [ -d "Data" ];
    then
      #
      # Yes. Compare the files.
      #
      if [[ $(cmp -s "${gDataPath}/${1}" "Data/${1}") ]];
        then
          return 2
      fi
  fi
  #
  # Check file length.
  #
  if [[ $(wc -c "${gDataPath}/${1}" | awk '{print $1}') -lt 100 ]];
    then
      rm "${gDataPath}/$1"
      return 3
  fi

  return 0
}


#
#--------------------------------------------------------------------------------
#

function _checkForConfigFileUpdate
{
  #
  # New update available for download?
  #
  case "$1" in
      0) if [[ $gLatestDataVersion_Model -gt $gModelDataVersion ]];
           then
             return 1
         fi
         ;;

      1) let gCPUDataVersion=-1
         ;;

      2) if [[ $gLatestDataVersion_SandyBridge -gt $gSandyBridgeCPUDataVersion ]];
           then
             return 1
           else
             let gCPUDataVersion=$gSandyBridgeCPUDataVersion
         fi
         ;;

      4) if [[ $gLatestDataVersion_IvyBridge -gt $gIvyBridgeCPUDataVersion ]];
           then
             return 1
           else
             let gCPUDataVersion=$gIvyBridgeCPUDataVersion
         fi
         ;;

      8) if [[ $gLatestDataVersion_Haswell -gt $gHaswellCPUDataVersion ]];
           then
             return 1
           else
             let gCPUDataVersion=$gHaswellCPUDataVersion
         fi
         ;;

     16) if [[ $gLatestDataVersion_Broadwell -gt $gBroadwellCPUDataVersion ]];
           then
             return 1
           else
             let gCPUDataVersion=$gBroadwellCPUDataVersion
         fi
         ;;

     32) if [[ $gLatestDataVersion_Skylake -gt $gSkylakeCPUDataVersion ]];
           then
             return 1
           else
             let gCPUDataVersion=$gSkylakeCPUDataVersion
         fi
         ;;

     64) if [[ $gLatestDataVersion_KabyLake -gt $gKabyLakeCPUDataVersion ]];
           then
             return 1
           else
             let gCPUDataVersion=$gKabyLakeCPUDataVersion
         fi
         ;;
  esac

  return 0
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
    local data
    local cpuData
    #
    # Save default (0) delimiter.
    #
    local ifs=$IFS
    let cpuType=0

    case $1 in
        1) local cpuSpecLists=("gUserDefinedCPUList[@]")
           ;;
        2) local cpuSpecLists=("gDesktopSandyBridgeCPUList[@]" "gMobileSandyBridgeCPUList[@]" "gServerSandyBridgeCPUList[@]")
           ;;
        4) local cpuSpecLists=("gDesktopIvyBridgeCPUList[@]" "gMobileIvyBridgeCPUList[@]" "gServerIvyBridgeCPUList[@]")
           ;;
        8) local cpuSpecLists=("gDesktopHaswellCPUList[@]" "gMobileHaswellCPUList[@]" "gServerHaswellCPUList[@]")
           ;;
       16) local cpuSpecLists=("gDesktopBroadwellCPUList[@]" "gMobileBroadwellCPUList[@]" "gServerBroadwellCPUList[@]")
           ;;
       32) local cpuSpecLists=("gDesktopSkylakeCPUList[@]" "gMobileSkylakeCPUList[@]" "gServerSkylakeCPUList[@]")
           ;;
       64) local cpuSpecLists=("gDesktopKabyLakeCPUList[@]" "gMobileKabyLakeCPUList[@]" "gServerKabyLakeCPUList[@]")
           ;;
    esac

    for cpuList in "${cpuSpecLists[@]}"
    do
      let cpuType+=1
      local targetCPUList=("${!cpuList}")

      for cpuData in "${targetCPUList[@]}"
      do
        #
        # Change delimiter to comma character.
        #
        IFS=","
        #
        # Split vars.
        #
        data=($cpuData)

        if [[ "${data[0]}" == "${gProcessorNumber}" ]];
          then
            #
            # Make processor data globally available.
            #
            gProcessorData=($cpuData)
            let gTypeCPU=$cpuType
            #
            # Is gBridgeType still uninitialised i.e. is argument -target not used?
            #
            if [[ $gBridgeType -eq -1 ]];
              then
                if [[ "${#data[@]}" -ge 8 ]];
                  then
                    let gBridgeType="${data[7]}"
                  else
                    let gBridgeType=$1
                fi
            fi
            #
            # Do we have a custom BCLK/bus frequency?
            #
            if [[ "${#data[@]}" -eq 9 ]];
              then
                let gBusFrequency="${data[8]}"
            fi
            #
            # Restore the default (0) delimiter.
            #
            IFS=$ifs
            _debugPrint "Processor data found for the Intel ${gProcessorNumber}\n"
            return 1
        fi
      done
    done
    #
    # Restore the default (0) delimiter.
    #
    IFS=$ifs

    return 0
  }

  let arrayIndex=0
  let targetBridgeType=1
  #
  # From here on we check/download/load the processor data file(s).
  #
  for dataFile in "${gProcessorDataConfigFiles[@]}"
  do
    _checkForConfigFile "${dataFile}.cfg"
    #
    # File not found?
    #
    if [[ $? -gt 0 ]];
      then
        #
        # No. Download it.
        #
        _PRINT_MSG "Notice: Downloading ${dataFile}.cfg ..."
		curl -o "${gDataPath}/${dataFile}.cfg" --silent $(echo "${gGitHubContentURL}/Data/${dataFile}.cfg" | sed 's/ /%20/g')
    fi

    source "${gDataPath}/${dataFile}.cfg"

    _checkForConfigFileUpdate $targetBridgeType
    #
    # New update available?
    #
    if [[ $? -gt 0 ]];
      then
        #
        # Yes. Download it.
        #
        _PRINT_MSG "Notice: Downloading Update of ${dataFile}.cfg ..."
        curl -o "${gDataPath}/${dataFile}.cfg" --silent $(echo "${gGitHubContentURL}/Data/${dataFile}.cfg" | sed 's/ /%20/g')
        source "${gDataPath}/${dataFile}.cfg"
    fi

    _debugPrint "Checking ${dataFile} processor data ...\n"
    __searchList $targetBridgeType
    #
    # Target processor data located?
    #
    if [[ $gTypeCPU -gt 0 ]];
      then
        #
        # Yes. Show version information (helping me to debug issues).
        #
        _PRINT_MSG "Version: models.cfg v${gModelDataVersion} / ${gProcessorDataConfigFiles[($arrayIndex)]}.cfg v${gCPUDataVersion}\n"
        return
    fi
    #
    # Next
    #
    let arrayIndex+=1
    let "targetBridgeType <<= 1"
  done
  #
  # No. The processor data was not found (error out).
  #
  _exitWithError $PROCESSOR_NUMBER_ERROR $2
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
    local matched=`echo $data | egrep -o $2`

    if [ ${#matched} -gt 1 ];
      then
        return 1
    fi

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
          _PRINT_MSG 'Warning: Model identifier ('$gModelID') not found in..: /S*/L*/CoreServices/PlatformSupport.plist\n'
      fi

      __searchList 'SupportedBoardIds' $gBoardID

      if [ $? == 0 ];
        then
          _PRINT_MSG 'Warning: board-id ('$gBoardID') not found in: /S*/L*/CoreServices/PlatformSupport.plist\n'
      fi
    else
       _PRINT_MSG 'Warning: /S*/L*/C*/PlatformSupport.plist not found (normal for Snow Leopard)!'
  fi
  #
  # Check for FrequencyVectors in plist.
  #
  if [ $gBridgeType -ge $HASWELL ];
    then
       local plist="/System/Library/Extensions/IOPlatformPluginFamily.kext/Contents/PlugIns/X86PlatformPlugin.kext/Contents/Resources/${gBoardID}.plist"

       if [ -e "$plist" ];
         then
           local freqVectorMatched=$(grep -c 'FrequencyVectors' "$plist")

           if [ $freqVectorMatched -eq 0 ];
             then
               _PRINT_MSG "Warning..: FrequencyVectors missing in ${gBoardID}.plist"
               printf "\t Download https://github.com/Piker-Alpha/freqVectorsEdit.sh to fix this\n"
           fi
         else
           _PRINT_MSG "Warning: File ${gBoardID}.plist Not Found!"
       fi
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
      if [[ $gOSVersion -gt 1084 ]];
        then
          #
          # Yes. Update global variable.
          #
          let gXcpm=$(/usr/sbin/sysctl -n machdep.xcpm.mode)
          #
          # Is XCPM mode active/ -x 1 argument used?
          #
          if [[ $gXcpm -eq 1 && $gCPUWorkArounds -gt 0 ]];
            then
              #
              # Yes. Disable Ivy Bridge workarounds.
              #
              let gCPUWorkArounds=0
              #
              # Is the target processor an Ivy Bridge one?
              #
              if [[ $gBridgeType == $IVY_BRIDGE ]];
                then
                  #
                  # Yes. Inform the user about the change.
                  #
                  printf "\nXCPM mode detected (Ivy Bridge workarounds disabled)\n\n"
              fi
          fi
      fi
  fi
  #
  # Is this a multiprocessor system using XCPM mode?
  #
  if [[ $gPhysicalCPUs -gt 1 && $gXcpm -eq 1 ]];
    then
    #
    # Yes. Inform user to use inter-processor interrupt power management.
    #
    _PRINT_MSG "\n\nWarning: You must use the -xcpm_ipi boot argument instead of -xcpm on multiprocessor systems.\n\n\n"
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

    Mac-06F11FD93F0323C5) gTargetMacModel="MacBookPro11,4"
                          ;;

    Mac-06F11F11946D27C5) gTargetMacModel="MacBookPro11,5"
                          ;;

    Mac-35C1E88140C3E6CF) gTargetMacModel="MacBookAir6,1"
                          ;;

    Mac-7DF21CB3ED6977E5) gTargetMacModel="MacBookAir6,2"
                          ;;

    Mac-35C5E08120C7EEAF) gSystemType=1
                          gTargetMacModel="Macmini7,1"
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
    Mac-E43C1C25D4880AD6) gTargetMacModel="MacBookPro12,1"
                          ;;

    Mac-9F18E312C5C2BF0B) gTargetMacModel="MacBookAir7,1"
                          ;;

    Mac-937CB26E2E02BB01) gTargetMacModel="MacBookAir7,2"
                          ;;

    Mac-BE0E8AC46FE800CC) gTargetMacModel="MacBook8,1"
                          ;;

    Mac-A369DDC4E67F1C45) gSystemType=1
                          gTargetMacModel="iMac16,1"
                          ;;

    Mac-FFE5EF870D7BA81A) # Retina 4K, 21.5-inch, Core i5 3.1GHz
                          gSystemType=1
                          gTargetMacModel="iMac16,2"
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

function _initSkylakeSetup()
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
    Mac-9AE82516C7C6B903) # Retina, 12-inch, Intel Core m3/m3
                          gTargetMacModel="MacBook9,1"
                          ;;


    Mac-65CE76090165799A) # Retina 5K, 27-inch, Intel Core i7 4.0GHz
                          gSystemType=1
                          gTargetMacModel="iMac17,1"
                          ;;

    Mac-B809C3757DA9BB8D) # Retina 5K, 27-inch, Intel Core i5 3.3GHz
                          gSystemType=1
                          gTargetMacModel="iMac17,1"
                          ;;

    Mac-DB15BD556843C820) # Retina 5K, 27-inch, Intel Core i5 3.2GHz
                          gSystemType=1
                          gTargetMacModel="iMac17,1"
                          ;;

    Mac-473D31EABEB93F9B) # Retina MacBook Pro (Late 2016)
                          gSystemType=2
                          gTargetMacModel="MacBookPro13,1"
                          ;;

    Mac-66E35819EE2D0D05) # Retina MacBook Pro (Late 2016)
                          gSystemType=2
                          gTargetMacModel="MacBookPro13,2"
                          ;;

    Mac-A5C67F76ED83108C) # Retina MacBook Pro (Late 2016)
                          gSystemType=2
                          gTargetMacModel="MacBookPro13,3"
                          ;;

  esac
}


#
#--------------------------------------------------------------------------------
#

function _initKabyLakeSetup()
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
    Mac-B4831CEBD52A0C4C) gTargetMacModel="MacBookPro14,1"
                          ;;

    Mac-CAD6701F7CEA0921) gTargetMacModel="MacBookPro14,2"
                          ;;

    Mac-551B86E5744E2388) gTargetMacModel="MacBookPro14,3"
                          ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _exitWithError()
{
  case "$1" in
      2)  _PRINT_MSG "\nError: 'MaxTurboFrequency' must be in the range of $frequency-$gMaxOCFrequency ..."
          _ABORT 2
          ;;
      3)  _PRINT_MSG "\nError: -t [TDP] must be in the range of 11.5 - 150 Watt ..."
          _ABORT 3
          ;;
      4)  _PRINT_MSG "\nError: 'BridgeType' must be 0, 1, 2 or 3 ..."
          _ABORT 4
          ;;
      5)  printf "\e[A\e[K"
          _PRINT_MSG "\nError: Unknown processor model ..."

          if [[ $2 -eq 0 ]];
            then
              printf "       Visit http://ark.intel.com to gather the required data:\n"
              printf "       Processor Number\n"
              printf "       TDP\n"
              printf "       Low Frequency Mode (use AppleIntelInfo.kext)\n"
              printf "       Base Frequency\n"
              printf "       Max Turbo Frequency\n"
              printf "       Cores\n"
              printf "       Threads\n"
          fi
          _ABORT 5
          ;;
      6)  _PRINT_MSG "\nError: Processor label length is less than 3 ..."
          _ABORT 6
          ;;
      7)  _PRINT_MSG "\nError: Processor name(s) not found ..."
          _ABORT 7
          ;;
      8)  _PRINT_MSG "\nError: Processor Declarations not found ..."
          _ABORT 8
          ;;
      9)  _PRINT_MSG "\nError: File not found ..."
          _ABORT 9
          ;;
      10) _PRINT_MSG "\nError: Low Frequency Mode is 0 ..."
          _ABORT 10
          ;;
      *)  _ABORT 1
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
  _PRINT_MSG "\nError: Invalid argument detected: ${1} (check ssdtPRGen.sh -h)"
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
           Skylake) local modelDataList="gSkylakeModelData[@]"
                    ;;
          Kabylake) local modelDataList="gKabylakeModelData[@]"
                     ;;
  esac
  #
  # Split 'modelDataList' into array.
  #
  local targetList=("${!modelDataList}")

  printf "${STYLE_BOLD}$1${STYLE_RESET}\n"

  if [[ "${#targetList[@]}" -gt 1 ]];
    then
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
        local data=($modelData)
        echo "${data[0]} / ${data[1]}"
      done
    else
      echo "Mac-XXXXXXXXXXXXXXXX / Undefined"
  fi
  #
  # Restore the default (0) delimiter.
  #
  IFS=$ifs
  #
  # Print extra newline for a cleaner layout.
  #
  printf "\n"
}

#
#--------------------------------------------------------------------------------
#

function _checkLibraryDirectory()
{
  #
  # Download Versions.cfg so that we can check for new updates.
  #
  curl -o "${gDataPath}/Versions.cfg" --silent "${gGitHubContentURL}/Data/Versions.cfg"
  #
  # Load versions numbers.
  #
  source "${gDataPath}/Versions.cfg"
  #
  # Are we running in the Github project directory?
  #
  if [ $gDeveloperMode -eq 1 ] &&
     [ -d .git ] &&
     [ -f .gitIgnore ] &&
     [ -f CHANGELOG.md ] &&
     [ -f CONTRIBUTORS.md ] &&
     [ -f README.md ] &&
     [ -d Data ] &&
     [ -f Data/Broadwell.cfg ] &&
     [ -f Data/Haswell.cfg ] &&
     [ -f "Data/Ivy bridge.cfg" ] &&
     [ -f "Data/Kaby lake.cfg" ] &&
     [ -f Data/Models.cfg ] &&
     [ -f Data/Restrictions.cfg ] &&
     [ -f "Data/Sandy Bridge.cfg" ] &&
     [ -f Data/Skylake.cfg ] &&
     [ -f Data/Versions.cfg ] &&
     [ -d Tools ] &&
     [ -f Tools/extractACPITables.zip ] &&
     [ -f Tools/iasl.zip ] &&
     [ -f Tools/Makefile ] &&
     [ -f ssdtPRGen.sh ];
    then
      #
      # Yes. Update path info.
      #
      gPath="$(pwd)"
      gDataPath="${gPath}/Data"
      gToolPath="${gPath}/Tools"
      gSsdtPR="${gPath}/${gSsdtID}.dsl"
      #
      # Write preferences with path info for extractACPITables v0.7 and greater.
      #
      defaults write com.wordpress.pikeralpha ssdtPRGenData $gDataPath
      defaults write com.wordpress.pikeralpha ssdtPRGenTools $gToolPath
    else
      #
      # Do we have the required Data directory?
      #
      if [ ! -d "${gDataPath}" ];
        then
          mkdir -p "${gDataPath}"
      fi
      #
      #
      #
      _checkForConfigFile "Models.cfg"
      #
      # Is the return value of _checkForConfigFile 1?
      #
      if [[ $? -eq 1 ]];
        then
          curl -o "${gDataPath}/Models.cfg" --silent "${gGitHubContentURL}/Data/Models.cfg"
      fi
  fi
  #
  # Load model data.
  #
  source "${gDataPath}/Models.cfg"
}

#
#--------------------------------------------------------------------------------
#

function _showSystemData
{
  printf "\n${STYLE_BOLD}System information${STYLE_RESET}: $gProductName $gProductVersion ($gBuildVersion)\n"
  #
  # Show brandstring (this helps me to debug stuff).
  #
  gBrandString=$(echo `sysctl machdep.cpu.brand_string` | sed -e 's/machdep.cpu.brand_string: //')
  printf "${STYLE_BOLD}Brandstring${STYLE_RESET}: \"${gBrandString}\"\n\n"

  if [[ $gTargetProcessorType -eq 0 && "${gBrandString}" == "Genuine Intel(R) CPU 0000" ]];
    then
      _PRINT_MSG "Error:\tUnable to determine CPU model!\n\tUse -p <cpu model> argument for Engineering Samples!"
      _ABORT
  fi
}

#
#--------------------------------------------------------------------------------
#

function _getScriptArguments()
{
  local currentPath=$(pwd)
  #
  # Are we fired up with arguments?
  #
  if [ $# -gt 0 ];
    then
      #
      # Yes. Do we have a single (-h or -help) argument?
      #
      local argument=$(echo "$1" | tr '[:upper:]' '[:lower:]')

      if [[ $# -eq 1 && "$argument" == "-h" || "$argument" == "-help"  ]];
        then
          printf "\n${STYLE_BOLD}Usage:${STYLE_RESET} ./ssdtPRGen.sh [-abcdefghiklmnoprsutwx]\n"
          printf "       -${STYLE_BOLD}a${STYLE_RESET}cpi Processor name (example: CPU0, C000)\n"
          printf "       -${STYLE_BOLD}bclk${STYLE_RESET} frequency (base clock frequency)\n"
          printf "       -${STYLE_BOLD}b${STYLE_RESET}oard-id (example: Mac-F60DEB81FF30ACF6)\n"
          printf "       -${STYLE_BOLD}cpus${STYLE_RESET} number of physical processors [1-4]\n"
          printf "       -${STYLE_BOLD}d${STYLE_RESET}ebug output [0-3]\n"
          printf "          0 = no debug injection/debug output\n"
          printf "          1 = inject debug statements in: ${gSsdtID}.dsl\n"
          printf "          2 = show debug output\n"
          printf "          3 = both\n"
          printf "       -${STYLE_BOLD}developer${STYLE_RESET} mode [0-1]\n"
          printf "          0 = disabled – Use files from: ${gPath}\n"
          printf "          1 = enabled  – Use files from: ${currentPath}\n"
          printf "       -${STYLE_BOLD}extract${STYLE_RESET} ACPI tables to [target path]\n"
          printf "       -${STYLE_BOLD}f${STYLE_RESET}requency (clock frequency)\n"
          printf "       -${STYLE_BOLD}h${STYLE_RESET}elp info (this)\n"
          printf "       -${STYLE_BOLD}lfm${STYLE_RESET}ode, lowest idle frequency\n"
          printf "       -${STYLE_BOLD}l${STYLE_RESET}ogical processors [2-128]\n"
          printf "       -${STYLE_BOLD}mode${STYLE_RESET} script mode [normal/custom]:\n"
          printf "          normal – Use ACPI/IOREG data from the host computer\n"
          printf "          custom – Use ACPI data from: ${gOverridePath/APIC.aml}\n"
          printf "                 –                   : ${gOverridePath/DSDT.aml}\n"
          printf "       -${STYLE_BOLD}m${STYLE_RESET}odel (example: MacPro6,1)\n"
          printf "       -${STYLE_BOLD}o${STYLE_RESET}pen the previously generated SSDT\n"
          printf "       -${STYLE_BOLD}p${STYLE_RESET}rocessor model (example: 'E3-1285L v3')\n"
          printf "       -${STYLE_BOLD}show${STYLE_RESET} supported board-id and model combinations:\n"
          printf "          Sandy Bridge\n"
          printf "          Ivy Bridge\n"
          printf "          Haswell\n"
          printf "          Broadwell\n"
          printf "          Skylake\n"
          printf "          Kabylake\n"
          printf "       -${STYLE_BOLD}target${STYLE_RESET} CPU type:\n"
          printf "          0 = Sandy Bridge\n"
          printf "          1 = Ivy Bridge\n"
          printf "          2 = Haswell\n"
          printf "          3 = Broadwell\n"
          printf "          4 = Skylake\n"
          printf "          5 = Kabylake\n"
          printf "       -${STYLE_BOLD}turbo${STYLE_RESET} maximum (turbo) frequency:\n"
          printf "          6300 for Sandy Bridge and Ivy Bridge\n"
          printf "          8000 for Haswell, Broadwell and greater\n"
          printf "       -${STYLE_BOLD}t${STYLE_RESET}dp [11.5 - 150]\n"
          printf "       -${STYLE_BOLD}c${STYLE_RESET}ompatibility workarounds:\n"
          printf "          0 = no workarounds\n"
          printf "          1 = inject extra (turbo) P-State at the top with maximum (turbo) frequency + 1 MHz\n"
          printf "          2 = inject extra P-States at the bottom\n"
          printf "          3 = both\n"
          printf "       -${STYLE_BOLD}x${STYLE_RESET}cpm mode [0-1]:\n"
          printf "          0 = XCPM mode disabled\n"
          printf "          1 = XCPM mode enabled\n\n"
          #
          # Stop script (success).
          #
          exit 0
      fi

      if [[ $# -eq 1 && "$argument" == "-show" ]];
        then
          printf "\nSupported board-id / model combinations for:\n"
          echo -e "--------------------------------------------\n"

          _showSupportedBoardIDsAndModels "Kaby Lake"
          _showSupportedBoardIDsAndModels "Skylake"
          _showSupportedBoardIDsAndModels "Broadwell"
          _showSupportedBoardIDsAndModels "Haswell"
          _showSupportedBoardIDsAndModels "Ivy Bridge"
          _showSupportedBoardIDsAndModels "Sandy Bridge"
          #
          # Stop script (success).
          #
          exit 0
      fi

      if [[ $# -eq 2 && "$argument" == "-show" ]];
        then
          printf "\nSupported board-id / model combinations for:\n"
          echo -e "--------------------------------------------\n"

          case "$(echo $2 | tr '[:lower:]' '[:upper:]')" in
            SANDY*   ) _showSupportedBoardIDsAndModels "Sandy Bridge"
                       ;;
            IVY*     ) _showSupportedBoardIDsAndModels "Ivy Bridge"
                       ;;
            HASWELL  ) _showSupportedBoardIDsAndModels "Haswell"
                       ;;
            BROADWELL) _showSupportedBoardIDsAndModels "Broadwell"
                       ;;
              SKYLAKE) _showSupportedBoardIDsAndModels "Skylake"
                       ;;
             KABYLAKE) _showSupportedBoardIDsAndModels "Kaby Lake"
                       ;;
          esac
          #
          # Stop script (success).
          #
          exit 0
        else
          _showSystemData
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
            if [[ "${flag}" =~ ^[-abcdefghiklmnoprsutvwx]+$ ]];
              then
                #
                # Yes. Figure out what flag it is.
                #
                case "${flag}" in
                  -a|-acpi) shift

                            if [[ "$1" =~ ^[a-zA-Z0-9]+$ ]];
                              then
                                if [ ${#1} -eq 4 ];
                                  then
                                    gProcLabel=$(echo "$1" | tr '[:lower:]' '[:upper:]')
                                    _PRINT_MSG "Override value: (-acpi) label for ACPI Processors, now using '${gProcLabel}'!"
                                  else
                                    _exitWithError $PROCESSOR_LABEL_LENGTH_ERROR
                                fi
                              else
                                _invalidArgumentError "-a $1"
                            fi
                            ;;

                  -bclk) shift

                         if [[ "$1" =~ ^[0-9]+$ ]];
                           then
                             if [[ $1 < 167 ]];
                               then
                                 _PRINT_MSG "Override value: (-bclk) frequency, now using: ${1} MHz!"
                                 let gBusFrequency=$1
                               else
                                 _invalidArgumentError "-bclk $1 (use 100, 133 or 166)"
                             fi
                           else
                             _invalidArgumentError "-bclk $1"
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

                  -cpus) shift

                      if [[ "$1" =~ ^[1-4]+$ ]];
                        then
                          #
                          # Sanity checking.
                          #
                          if [[ $1 -gt 0 && $1 -lt 5 ]];
                            then
                              let gPhysicalCPUs=$1
                              _PRINT_MSG "Override value: (-cpus) number of processors, now using: ${1}!"
                            else
                              _invalidArgumentError "-cpus $1"
                          fi
                        else
                          _invalidArgumentError "-cpus $1"
                      fi
                      ;;

                  -developer) shift

                      if [[ "$1" =~ ^[01]+$ ]];
                        then
                          if [[ $gDeveloperMode -ne $1 ]];
                            then
                              let gDeveloperMode=$1
                              _PRINT_MSG "Override value: (-developer) mode, now using: ${gDebug}!"
                          fi
                        else
                          _invalidArgumentError "-developer $1"
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

                  -extract) shift

                      if [[ "$1" == "." || "$1" == " " ]];
                        then
                          #
                          # Get current path for extractACPITables v0.6 and greater.
                          #
                          gExtractionPath="${currentPath}"
                        else
                          #
                          # Use given path for extractACPITables v0.6 and greater.
                          #
                          gExtractionPath="${1}"
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

                  -mode) shift

                         argument=$(echo "$1" | tr '[:upper:]' '[:lower:]')

                         if [[ "$argument" == "normal" ]];
                           then
                             if [[ $gCustomMode -eq 0 ]];
                               then
                                 _PRINT_MSG "Override value: (-mode) ignored, script mode is already set to normal!"
                               else
                                 _PRINT_MSG "Override value: (-mode) script mode changed to normal!"
                                 let gCustomMode=0
                             fi
                         elif [[ "$argument" == "custom" ]];
                             then
                               if [[ $gCustomMode -eq 1 ]];
                                 then
                                   _PRINT_MSG "Override value: (-mode) ignored, script mode is already set to custom!"
                                 else
                                   _PRINT_MSG "Override value: (-mode) script mode changed to custom!"
                                   let gCustomMode=1
                               fi
                           else
                             _invalidArgumentError "-mode $1"
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

                  -o|-open) shift

                            if [ -e "$gSsdtPR" ];
                              then
                                open -e "$gSsdtPR"
                              else
                                _exitWithError $FILE_NOT_FOUND_ERROR
                            fi
                            exit 0
                            ;;

                  -p) shift

                      if [[ "$1" =~ ^[a-zA-Z0-9\ \-]+$ ]];
                        then
                          if [ "$gProcessorNumber" != "$1" ];
                            then
                              let gTargetProcessorType=1
                              #
                              # Sandy Bridge checks.
                              #
                              if [[ ${1:0:4} == "i3-2" || ${1:0:4} == "i5-2" || ${1:0:4} == "i7-2" ]];
                                then
                                  let gTargetProcessorType=2
                              fi
                              #
                              # Ivy Bridge checks.
                              #
                              if [[ ${1:0:4} == "i3-3" || ${1:0:4} == "i5-3" || ${1:0:4} == "i7-3" ]];
                                then
                                  let gTargetProcessorType=4
                              fi
                              #
                              # Haswell/Haswell-E checks.
                              #
                              if [[ ${1:0:4} == "i3-4" || ${1:0:4} == "i5-4" || ${1:0:4} == "i7-4" || ${1:0:4} == "i7-5" ]];
                                then
                                  let gTargetProcessorType=5
                              fi
                              #
                              # Skylake checks.
                              #
                              if [[ ${1:0:4} == "i5-6" || ${1:0:4} == "i7-6" ]];
                                then
                                  let gTargetProcessorType=5
                              fi
                              #
                              # Xeon check.
                              #
                              if [[ ${1:0:1} == "E" ]];
                                then
                                  let gTargetProcessorType=7
                              fi
                              #
                              # Set processor model override and inform user about the change.
                              #
                              if [ $gTargetProcessorType -gt 0 ];
                                then
                                  gProcessorNumber=$1
                                  _PRINT_MSG "Override value: (-p) processor model, now using: ${gProcessorNumber}!"
                                else
                                  gProcessorNumber=""
                              fi
                          fi
                        else
                          _invalidArgumentError "-p $1"
                      fi
                      ;;

                  -target) shift

                            if [[ "$1" =~ ^[012345]+$ ]];
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
                                  4) local bridgeType=$SKYLAKE
                                     local bridgeTypeString="Skylake"
                                     ;;
                                  5) local bridgeType=$KABYLAKE
                                     local bridgeTypeString="Kaby Lake"
                                     ;;
                                esac

                                if [[ $detectedBridgeType -ne $((2 << $1)) ]];
                                  then
                                    let gBridgeType=$bridgeType
                                    _PRINT_MSG "Override value: (-target) CPU, now using: ${bridgeTypeString}!"
                                fi
                              else
                                _exitWithError $TARGET_CPU_ERROR
                            fi
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


                  -t|-tdp) shift

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

                  -c) shift

                      if [[ "$1" =~ ^[0123]+$ ]];
                        then
                          if [[ $gCPUWorkArounds -ne $1 ]];
                            then
                              let gCPUWorkArounds=$1
                              _PRINT_MSG "Override value: (-c) CPU workarounds, now set to: ${1}!"
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
                          _invalidArgumentError "-c $1"
                      fi
                      ;;

                  -x|-xcpm) shift

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
    else
      _showSystemData
  fi
}

#
#--------------------------------------------------------------------------------
#

function _checkLFMCompatibility()
{
  _checkForConfigFile "Restrictions.cfg"

  if [[ $? -eq 1 ]];
    then
      _PRINT_MSG "Notice: Downloading Restrictions.cfg ..."
      curl -o "${gDataPath}/Restrictions.cfg" --silent "${gGitHubContentURL}/Data/Restrictions.cfg"
  fi

  source "${gDataPath}/Restrictions.cfg"

  for boardID in "${gBoardIDsWithLFMRestrictions[@]}"
  do

    if [[ "$boardID" == "$gBoardID" ]];
      then
        _PRINT_MSG "\nNotice: The LFM frequency in $gBoardID.plist is set to 1300MHz!"
        printf "\tThis problem can be fixed with help of freqVectorsEdit.sh from:\n"
        printf "\thttps://github.com/Piker-Alpha/freqVectorsEdit.sh\n\n"
        return
    fi
  done
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

  printf "\n${STYLE_BOLD}ssdtPRGen.sh${STYLE_RESET} v0.9  Copyright (c) 2011-2012 by † RevoGirl\n"
  echo   '             v6.6  Copyright (c) 2013 by † Jeroen'
  printf "             v$gScriptVersion Copyright (c) 2013-$(date "+%Y") by Pike R. Alpha\n"
  echo   '-----------------------------------------------------------'
  printf "${STYLE_BOLD}Bugs${STYLE_RESET} > https://github.com/Piker-Alpha/ssdtPRGen.sh/issues <\n"

  _checkSourceFilename
  _checkLibraryDirectory
  _getScriptArguments "$@"
  #
  # Fired up with -mode custom?
  #
  if [[ $gCustomMode -eq 0 ]];
    then
      #
      # No. Extract ACPI data from host computer.
      #
      _extractAcpiTables
  fi
  #
  # Convert APIC.aml and DSDT.aml into data files.
  #
  _convertACPIFiles
  _getEnabledProcessors
  _getProcessorNames
  #
  #
  #
  if [[ $gCustomMode -eq 1 ]];
    then
      #
      # Yes. Show some basic info (in case we need the log).
      #
      _PRINT_MSG "\nNotice: Custom mode enabled"
      printf "\tSkipping ACPI table extraction from host computer!\n\tGetting enabled Processors from...: ${gOverridePath}/APIC.aml\n"
      printf "\tGetting Processor declaration from: ${gOverridePath}/DSDT.aml\n"
      printf "\tUsed ACPI processor labels: "
      #
      # Check number of logical processors. Less/equal than 8?
      #
      if [[ ${#gProcessorNames[@]} -le 8 ]];
        then
          #
          # Yes. Use the same line.
          #
          echo -e "${gProcessorNames[@]}\n"
        else
          #
          # No. Use (a) new line(s) to show the processor names.
          #
          let nameCount=0
          #
          # Use (a) new line(s) to show the processor names.
          #
          printf "\n\t–"
          #
          # loop through all processorNames.
          #
          for processorName in "${gProcessorNames[@]}"
          do
            if [[ $nameCount -eq $gLogicalCPUsPerScope ]];
              then
                printf "\n\t–"
            fi

            printf " ${processorName}"
            let nameCount+=1
          done
      fi
      printf "\n\n"
  fi
  #
  # Set local variable from global function variable.
  #
  let modelSpecified=$gTargetProcessorType
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

  _checkLFMCompatibility

  case $gBridgeType in
       2) local bridgeTypeString="Sandy Bridge"
          ;;
       4) local bridgeTypeString="Ivy Bridge"
          ;;
       8) local bridgeTypeString="Haswell"
          ;;
      16) local bridgeTypeString="Broadwell"
          ;;
      32) local bridgeTypeString="Skylake"
          ;;
      64) local bridgeTypeString="Kaby Lake"
          ;;
       *) local bridgeTypeString="Unknown"
          ;;
  esac

  local cpu_type=$(_getCPUtype)
  local currentSystemType=$(_getSystemType)
  local cpuSignature=$(_getCPUSignature)

  echo "Generating ${gSsdtID}.dsl for a '${gModelID}' with board-id [${gBoardID}]"
  #
  # Intel Core processor model?
  #
  if [ $modelSpecified -eq 1 ];
    then
      echo "Intel $gProcessorNumber processor [$cpuSignature] setup [0x${cpu_type}]"
    else
      echo "$bridgeTypeString Core $gProcessorNumber processor [$cpuSignature] setup [0x${cpu_type}]"
  fi
  #
  # gTypeCPU is greater than 0 when the processor is found in one of the CPU lists
  #
  if [ $gTypeCPU -gt 0 ];
    then
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
          gTdp=${gProcessorData[1]}
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
          let lfm=${gProcessorData[2]}
      fi
      #
      # Check if -f argument is used.
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
          let frequency=${gProcessorData[3]}
      fi
      #
      # Check if -turbo argument is used.
      #
      if [[ $gMaxTurboFrequency -gt 0 ]];
        then
          let maxTurboFrequency=$gMaxTurboFrequency
        else
          let maxTurboFrequency=${gProcessorData[4]}
      fi
      #
      # Sanity check.
      #
      if [ $maxTurboFrequency == 0 ];
        then
          let maxTurboFrequency=$frequency
      fi
      #
      # Check if -l argument is used.
      #
      if [ $gLogicalCPUs -eq 0 ];
        then
          #
          # No. Get thread count (logical cores) from CPU data.
          #
          let gLogicalCPUs=${gProcessorData[6]}
      fi
      #
      # Restore the default (0) delimiter.
      #
      IFS=$ifs
      #
      # Check Low Frequency Mode (may be 0 aka still unknown)
      #
      if [ $lfm -gt 0 ];
        then
          let gBaseFrequency=$lfm
        else
          _PRINT_MSG "\nWarning: Low Frequency Mode is 0 (unknown/unconfirmed)"

         if [ $gTypeCPU == $gMobileCPU ];
            then
              echo -e "         Now using 1200 MHz for Mobile processor\n"
              let gBaseFrequency=1200
             else
               echo -e "         Now using 1600 MHz for Server/Desktop processors\n"
               let gBaseFrequency=1600
          fi
      fi
      #
      # Check Ivy Bridge, XCPM mode and if -c argument is used.
      #
      if [[ $gBridgeType -eq $IVY_BRIDGE && $gXcpm -eq -1 && $gCPUWorkArounds -eq 0 ]];
        then
          if [[ $gOSVersion -gt 10100 ]];
            then
              let gCPUWorkArounds=3;
            else
              let gCPUWorkArounds=2;
          fi
      fi
    else
      printf "Processor NOT matched, checking required arguments!\n"
      #
      # Check if -lfm argument was used.
      #
      if [[ $gLfm -eq 0 ]];
        then
          _exitWithError $LFM_ERROR
      fi
      #
      # Check if -t argument was used.
      #
      if [[ $gTdp -eq 0 ]];
        then
          _exitWithError $MAX_TDP_ERROR
      fi
      #
      # No CPU data found. Check if -l argument is used.
      #
      if [ $gLogicalCPUs -eq 0 ];
        then
          #
          # No. Get thread count (logical cores) from the running system.
          #
          let gLogicalCPUs=$(sysctl machdep.cpu.thread_count | awk '{ print $2 }')
      fi
      #
      # Check if -f argument is used.
      #
      if [ $gFrequency -eq -1 ];
        then
          #
          # No. Get the clock frequency from the running system.
          #
          let frequency=$(sysctl hw.cpufrequency | awk '{ print($2) / 1000000 }')
          let gFrequency=frequency

          _PRINT_MSG "Warning: Core Frequency is unknown, now using $gFrequency MHz from sysctl hw.cpufrequency!"
        else
          let frequency=$gFrequency
      fi
      #
      # Check if -turbo argument is used.
      #
      if [[ $gMaxTurboFrequency -gt 0 ]];
        then
          let maxTurboFrequency=$gMaxTurboFrequency
        else
          let maxTurboFrequency=$frequency
          let gMaxTurboFrequency=$frequency

          _PRINT_MSG "Warning: Maximum Turbo Frequency is unknown, now using $gMaxTurboFrequency MHz from Core Frequency!"
      fi

      let gCoreCount=$(sysctl machdep.cpu.core_count | awk '{ print $2 }')

      printf "${gProcessorNumber},${gTdp},${gLfm},${gFrequency},${gMaxTurboFrequency},${gCoreCount},${gLogicalCPUs}\n"
  fi

  echo "Number logical CPU's: $gLogicalCPUs (Core Frequency: $frequency MHz)"

# if [ $gLogicalCPUs -gt "${#gProcessorNames[@]}" ];
#   then
#     _updateProcessorNames $gLogicalCPUs
# fi
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
# let turboStates=$(printf "%.f" $(echo "scale=1;((($maxTurboFrequency - $frequency) / $gBusFrequency)+0.5)" | bc))
  let turboStates=$(echo "(($maxTurboFrequency - $frequency) / $gBusFrequency)" | bc)
  #
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
      let minTurboFrequency=($frequency+$gBusFrequency)
      echo "Number of Turbo States: $turboStates ($minTurboFrequency-$maxTurboFrequency MHz)"
    else
      echo "Number of Turbo States: 0"
  fi

  local packageLength=$(echo "((($maxTurboFrequency - $gBaseFrequency)+$gBusFrequency) / $gBusFrequency)" | bc)

  echo "Number of P-States: $packageLength ($gBaseFrequency-$maxTurboFrequency MHz)"

  _printHeader
  #
  # Check if -cpus argument is used.
  #
  if [[ $gPhysicalCPUs -gt 1 ]];
    then
      let gLogicalCPUsPerScope=$gLogicalCPUs/$gPhysicalCPUs
    else
      let gLogicalCPUsPerScope=$gLogicalCPUs/${#gScope[@]}

      if [[ 0 -eq 1 ]];
        then
          exit -1
      fi
  fi
  #
  # Do we need to inject External () objects?
  #
  if [[ $gInjectExternalObjects -eq 1 ]];
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
         $SKYLAKE) local cpuTypeString="09"
                   _initSkylakeSetup
                   ;;
        $KABYLAKE) local cpuTypeString="09"
                   _initKabyLakeSetup
;;
  esac

  let scopeIndex=0
  #
  # Loop through all processor scopes.
  #
  for scope in "${gScope[@]}"
  do
    #
    # Are we done yet?
    #
    if [[ $gLogicalCPUsPerScope*$scopeIndex -ge $gLogicalCPUs ]];
      then
        #
        # Yes. Add closing bracket to the end of the injected data.
        #
        echo '}' >> "$gSsdtPR"
        #
        # Break out the do loop.
        #
        break;
      else
        #
        # No. Continue.
        #
        _printScopeStart $scopeIndex $turboStates $packageLength $maxTurboFrequency
        _printPackages $frequency $turboStates $maxTurboFrequency
        _printScopeACST 0

        if [ $scopeIndex -eq 0 ];
          then
            _printMethodDSM
          else
            if [ $gBridgeType -ge $IVY_BRIDGE ];
              then
                echo '    }' >> "$gSsdtPR"
            fi
        fi

        _printScopeCPUn $scopeIndex

        let scopeIndex+=1
    fi
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
          printf "\t - Clover users should read https://clover-wiki.zetam.org/Configuration/CPU#cpu_type"
      fi

      if [[ $gSystemType -eq 0 ]];
        then
          _PRINT_MSG "\nWarning: 'board-id' [${gBoardID}] is not supported by ${bridgeTypeString} power management"
        else
          if [ "${gTargetMacModel}" == "" ];
            then
             _confirmUnsupported "\nError: board-id [${gBoardID}] not supported by ${bridgeTypeString} – check SMBIOS data / use the -target option\n"
            elif [ "$gTargetMacModel" != "$gModelID" ];
              then
                _confirmUnsupported 'Warning: board-id ['$gBoardID'] and model ['$gModelID'] mismatch – check SMBIOS data\n'
          fi
      fi
  fi

  if [ $currentSystemType -ne $gSystemType ];
    then
      _PRINT_MSG "Warning: 'system-type' may be set improperly ($currentSystemType instead of $gSystemType)"
      printf "\t - Clover users should read https://clover-wiki.zetam.org/Configuration/ACPI#acpi_smartups"
  fi

  _findIasl

  if [[ $gCallIasl -eq 1 && -f "$gSsdtPR" ]];
    then
      #
      # Compile ssdt_pr.dsl
      #
      printf "\n${STYLE_BOLD}Compiling:${STYLE_RESET} ssdt_pr.dsl"
      "$gIasl" "$gSsdtPR"

      let iaslStatus=$?

      if [ $iaslStatus -ne 0 ];
        then
          _PRINT_MSG "Error: IASL status: ${iaslStatus} (Failed)\n"
      fi
      #
      # Copy ssdt_pr.aml to /Extra/ssdt.aml (example)
      #
      if [[ $iaslStatus -eq 0 && $gAutoCopy -eq 1 ]];
        then
          if [[ -f "${gPath}/${gSsdtID}.aml" && -d "${gDestinationPath}" ]];
            then
              echo ""
              read -p "Do you want to copy ${gPath}/${gSsdtID}.aml to ${gDestinationPath}${gDestinationFile}? (y/n)? " choice
              case "$choice" in
                  y|Y ) if [[ $gIsLegacyRevoBoot -eq 0 ]];
                          then
                            _setDestinationPath
                        fi
                        #
                        # Check write permissions.
                        #
                        if [ -w "${gDestinationPath}${gDestinationFile}" ];
                          then
                            cp "${gPath}/${gSsdtID}.aml" "${gDestinationPath}${gDestinationFile}"
                          else
                            sudo cp "${gPath}/${gSsdtID}.aml" "${gDestinationPath}${gDestinationFile}"
                        fi
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

                      sudo -k
                      ;;
            esac
        fi
    fi
  fi
  #
  # Ask for confirmation before opening the new SSDT.dsl?
  #
  if [[ $gCallOpen -eq 2 && -f "$gSsdtPR" ]];
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

main "$@"

exit 0

#================================================================================
