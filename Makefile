CC=gcc
CFLAGS=
DEPS=
OUTPUT=bin
TARGETS=ln exp exp_opt neqdst

all: $(addprefix $(OUTPUT)/, $(TARGETS))


$(OUTPUT)/%.o: %.c $(DEPS) $(OUTPUT)
	@echo "Building " $<
	$(CC) -c -o $@ $< $(CFLAGS)

$(OUTPUT):
	$(SILENT_MKDIR)mkdir $(OUTPUT)