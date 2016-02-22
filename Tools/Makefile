FRAMEWORKS=-framework IOKit -framework CoreFoundation
OS_VERSION=-mmacosx-version-min=10.5
CFLAGS=-O2 -Wall $(FRAMEWORKS) $(OS_VERSION)

all: extractACPITables

extractACPITables: extractACPITables.c Makefile
	$(CC) $(CFLAGS) $(CURRENT_DIRECTORY) -o $@ $<
