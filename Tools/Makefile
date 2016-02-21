FRAMEWORKS=-framework IOKit -framework CoreFoundation
OS_VERSION=-mmacosx-version-min=10.5
CFLAGS=-O2 -Wall $(FRAMEWORKS) $(OS_VERSION)
# Set this to have tables dumped in the current directory
CURRENT_DIRECTORY=-DCURRENT_DIRECTORY

all: extractACPITables

extractACPITables: extractACPITables.c Makefile
	$(CC) $(CFLAGS) $(CURRENT_DIRECTORY) -o $@ $<
