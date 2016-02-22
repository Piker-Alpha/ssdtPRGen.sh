/*
 * Name			: extractACPITables.c
 * Version		: 0.5
 * Type			: Command line tool
 * Copyright	: Pike R. Alpha (c) September 2014
 * Description	: ACPI table extractor.
 *
 * Usage		: ./extractACPITables			(writes all tables to.....: ~/Library/XXXX.aml)
 *				: ./extractACPITables DSDT		(writes DSDT.aml to.......: ~/Library/DSDT.aml)
 *				: ./extractACPITables SSDT		(writes all SSDT tables to: ~/Library/SSDT.aml)
 *				: ./extractACPITables SSDT-2	(writes SSDT-2.aml to.....: ~/Library/SSDT-2.aml)
 *
 * Compile with	: cc -O2 extractACPITables.c -o extractACPITables -Wall -framework IOKit -framework CoreFoundation
 *
 * Updates:
 *			v0.1	initial version.
 *			v0.2	renamed from acpiTableExtract.c to extractAcpiTables.c
 *			v0.3	check arguments, use argv[1] as target table.
 *			v0.4	changed output path from /tmp/ to ~/Library/ssdtPRGen
 *			v0.5	fix segmentation fault (thanks to theracermaster).
 */

#include <stdio.h>

#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>

//==============================================================================

int main(int argc, char * argv[])
{
	char tableName[8];
	char dirspec[1024];

	char * homeDirectory = NULL;

	int filedesc, status = 0;

	bool allTables = true;
	bool currentDirectory = false;

	io_service_t	service;
	CFDictionaryRef	tableDictionary;

	//==================================================================================

	if (argc >= 2)
	{
		if (strcmp(argv[1], "-c") == 0)
		{
			currentDirectory = true;
			argc--;
			argv++;
		}
	}

	if (argc == 2)
	{
		allTables = false;
	}

	setlocale(LC_ALL, "en_US"); // Many thanks to theracermaster!
	homeDirectory = getenv("HOME");

	if (homeDirectory)
	{
		if ((service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleACPIPlatformExpert"))))
		{
			if ((tableDictionary = (CFDictionaryRef) IORegistryEntryCreateCFProperty(service, CFSTR("ACPI Tables"), kCFAllocatorDefault, kNilOptions)))
			{
				CFIndex tableCount = CFDictionaryGetCount(tableDictionary);

				CFStringRef	tableNames[tableCount];
				CFDataRef	tableData[tableCount];

				CFDictionaryGetKeysAndValues(tableDictionary, (const void **)&tableNames, (const void **)&tableData);

				for (CFIndex i = 0; i < tableCount; i++)
				{
					UInt8 * buffer = (UInt8 *) CFDataGetBytePtr(tableData[i]);
					UInt32 numBytes = (UInt32) CFDataGetLength(tableData[i]);
				
					strcpy(tableName, CFStringGetCStringPtr(tableNames[i], kCFStringEncodingMacRoman));

					if (allTables || (strncasecmp(argv[1], (char *)tableName, strlen(argv[1])) == 0))
					{
						if (currentDirectory)
						{
							sprintf(dirspec, "%s.aml", tableName);
						}
						else
						{
							sprintf(dirspec, "%s/Library/ssdtPRGen/%s.aml", homeDirectory, tableName);
						}
						if ((filedesc = open(dirspec, O_WRONLY|O_CREAT|O_TRUNC, 0644)) != -1)
						{
							write(filedesc, buffer, numBytes);
							close(filedesc);
						}
						else
						{
							status = -4;
						}
					}
				}

				CFRelease(tableDictionary);
			}
			else
			{
				status = -3;
			}

			IOObjectRelease(service);
		}
		else
		{
			status = -2;
		}
		//  0 = success.
		// -2 = service is NULL.
		// -3 = tableDictionary is NULL.
		// -4 = one or more writes failed.
		exit(status);
	}

	exit(-1); // homeDirectory is NULL
}
