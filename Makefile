CC=gcc
CFLAGS=
DEPS=
OUTPUT=bin
TARGETS=ln #e

all: $(addprefix $(OUTPUT)/, $(TARGETS))


$(OUTPUT)/%.o: %.c $(DEPS) $(OUTPUT)
	echo "Building " $<
	$(CC) -c -d -o $@ $< $(CFLAGS)

$(OUTPUT):
	$(SILENT_MKDIR)mkdir $(OUTPUT)