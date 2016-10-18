ssdtPRGen.sh
============

You can download the latest Beta of ssdtPRGen.sh by entering the following command in a terminal window:

``` sh
curl -o ~/ssdtPRGen.sh https://raw.githubusercontent.com/Piker-Alpha/ssdtPRGen.sh/Beta/ssdtPRGen.sh
```

You can verify the size of the downloaded file with:

``` sh
wc -c ssdtPRGen.sh
```

That should match with what you see [here] (https://github.com/Piker-Alpha/ssdtPRGen.sh/blob/Beta/ssdtPRGen.sh). Right now that is 142KB. A failed download is usually much smaller (like 447 bytes or so).


This will download ssdtPRGen.sh to your home directory (~) and the next step is to change the permissions of the file (add +x) so that it can be run.
 
``` sh
chmod +x ~/ssdtPRGen.sh
```

Note: ssdtPRGen.sh v15.1 and greater require a working Internet connection so that it can download configuration data and command line tools. You can also download a complete zip archive by entering the following commands in a terminal window:

``` sh
curl -o ~/Library/ssdtPRGen.zip https://codeload.github.com/Piker-Alpha/ssdtPRGen.sh/zip/Beta
unzip -qu ~/Library/ssdtPRGen.zip -d ~/Library/
mv ~/Library/ssdtPRGen.sh-Beta ~/Library/ssdtPRGen
rm ~/Library/ssdtPRGen.zip
```


Help Information
----------------

``` sh
$ ~/ssdtPRGen.sh -h

Usage: ./ssdtPRGen.sh [-abcdefghiklmnoprsutwx]
       -acpi Processor name (example: CPU0, C000)
       -acpi Processor name (example: CPU0, C000)
       -bclk frequency (base clock frequency)
       -board-id (example: Mac-F60DEB81FF30ACF6)
       -cpus number of physical processors [1-4]
       -debug output [0-3]
          0 = no debug injection/debug output
          1 = inject debug statements in: ssdt_pr.dsl
          2 = show debug output
          3 = both
       -developer mode [0-1]
          0 = disabled – Use files from: /Users/[username]/Library/ssdtPRGen
          1 = enabled  – Use files from: /Users/[username]/Projects/ssdtPRGen.sh
       -extract ACPI tables to [target path]
       -frequency (clock frequency)
       -help info (this)
       -lfmode, lowest idle frequency
       -logical processors [2-128]
       -mode script mode [normal/custom]:
          normal – Use ACPI/IOREG data from the host computer
          custom – Use ACPI data from: /Users/[username]/Desktop
          –                          : /Users/[username]/Desktop
       -model (example: MacPro6,1)
       -open the previously generated SSDT
       -processor model (example: 'E3-1285L v3')
       -show supported board-id and model combinations:
          Sandy Bridge
          Ivy Bridge
          Haswell
          Broadwell
          Skylake
          Kabylake
       -target CPU type:
          0 = Sandy Bridge
          1 = Ivy Bridge
          2 = Haswell
          3 = Broadwell
          4 = Skylake
          5 = Kabylake
       -turbo maximum (turbo) frequency:
          6300 for Sandy Bridge and Ivy Bridge
          8000 for Haswell, Broadwell and greater
       -tdp [11.5 - 150]
       -compatibility workarounds:
          0 = no workarounds
          1 = inject extra (turbo) P-State at the top with maximum (turbo) frequency + 1 MHz
          2 = inject extra P-States at the bottom
          3 = both
       -xcpm mode:
          0 = XCPM mode disabled
          1 = XCPM mode enabled

Note: This is the output of version 20.4

```



User Defined Processor Data
---------------------------

The script was initially written for Intel Core processors and the processor data for (most) Intel processors should be readily available, but I have no intention to add the processor data for older processors. No worries. You can add the data yourself to: ~/Library/ssdtPRGen/Data/User Defined.cfg A few examples are there to help you.



Unknown CPU error
-----------------

The processor data for your processor may not (yet) be available, and this is – most likely – why you get the error. The other problem is a common user-error where people use the wrong processor label i.e. i76850k/i7-6850k instead of i7-6850K. If the latter is not the problem that you are facing, and you known that the data for a new processors is missing, then please open a [Github issue] (https://github.com/Piker-Alpha/ssdtPRGen.sh/issues/new) with the missing processor data (link to data). For older pre-Core I Intel processors see: ~/Library/Data/User Defined.cfg



Bugs
----

All bugs, so called 'issues', should be filed [here] (https://github.com/Piker-Alpha/ssdtPRGen.sh/issues). If the script fails to generate a SSDT then please attach the output of: ./ssdtPRGen.sh -d 2 and compressed: ~/Library/ssdtPRGen/ACPI folder. If you are using processor data from Data/User Defined.cfg then I also need to know what that data is. 

Please do **not** use my blog for this. Thank you!

