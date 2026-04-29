# Project Name (edit this)
TARGET_NAME = my_project
EXECUTABLE = bin/$(TARGET_NAME)

# Source files (edit these) - MUST be in src/ directory
SRCS = src/main.c src/example.c
# Header files (edit these if you add headers outside src/include/)
HDRS = src/include/example.h

# Object files (derived from SRCS, will be placed in the root directory)
OBJS = $(notdir $(SRCS:.c=.o))

# Compiler and flags
CC = gcc
# Comprehensive CFLAGS: enable all warnings, use C11 standard, and apply hardening.
# Using flags similar to mini-calc but without project-specific ones like GTK or ASan.
CFLAGS = -std=c11 -pedantic -Wall -Wextra -Werror -Wformat=2 -Wshadow -Wconversion -Wsign-conversion -Wundef -Wstrict-prototypes -Wmissing-prototypes -Wredundant-decls -Wpointer-arith -Wwrite-strings -Wold-style-definition
# Hardening flags
HARDENING = -D_FORTIFY_SOURCE=2 -fstack-protector-strong -fPIE -fstack-clash-protection -fcf-protection
# Optimization flags
OPTFLAGS = -O2 -march=native -flto

# Linker flags
LDFLAGS = -lm -pie -Wl,-z,relro,-z,now

# Combine all flags
ALL_CFLAGS = $(CFLAGS) $(HARDENING) $(OPTFLAGS)

# Targets
.PHONY: all clean run format lint

all: directories $(EXECUTABLE)

# Create output directories if they don't exist
directories:
	@mkdir -p bin

# Rule to compile .c files into .o files in the root directory
# $< is the prerequisite (source file in src/), $@ is the target (object file in root)
%.o: %.c
	@echo "Compiling $< ..."
	$(CC) $(ALL_CFLAGS) -c $< -o $@

# Rule to link the executable in the bin/ directory
$(EXECUTABLE): $(OBJS)
	@echo "Linking $@ ..."
	$(CC) $(ALL_CFLAGS) $(LDFLAGS) -o $(EXECUTABLE) $(OBJS)

# Rule to clean up build artifacts
clean:
	@echo "Cleaning up build artifacts..."
	@rm -f $(OBJS) $(EXECUTABLE)

# Rule to run the executable
run: $(EXECUTABLE)
	@echo "Running $(EXECUTABLE) ..."
	./$(EXECUTABLE)

# Format code using clang-format (requires .clang-format in root)
FORMAT_FILES = $(SRCS) $(HDRS)
format:
	@echo "Formatting code..."
	@clang-format -style=file:./.clang-format -i $(FORMAT_FILES)

# Run static analysis with clang-tidy (requires .clang-tidy in root)
CLANG_TIDY_CHECKS = -checks=-*,readability-*,bugprone-*,performance-*,clang-analyzer-*
CLANG_TIDY_FLAGS = -std=c11 -pedantic -Wall -Wextra -Werror
lint:
	@echo "Running static analysis..."
	@clang-tidy $(CLANG_TIDY_CHECKS) $(SRCS) -- $(CLANG_TIDY_FLAGS)
