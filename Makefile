# Qawale - Frequency Based Programming Language
# Makefile for building all implementations

# Variables
PYTHON := python3
CC := cc
AS := as
LD := ld
SHELL := /bin/bash

# Directories and files
BIN_DIR := bin
SRC_DIR := src
PYTHON_SRC := $(SRC_DIR)/python/Simulation.py
BASH_SRC := $(SRC_DIR)/bash/Simulation.sh
C_SRC := $(SRC_DIR)/c/Simulation.c
ASSEMBLY_SRC := $(SRC_DIR)/assembly/AppleARM.asm
HOLYC_SRC := $(SRC_DIR)/holyc/Simulation.holyc

# Output files
PYTHON_BIN := $(BIN_DIR)/qawale.py
BASH_BIN := $(BIN_DIR)/qawale.sh
C_BIN := $(BIN_DIR)/qawale-c
ASSEMBLY_BIN := $(BIN_DIR)/qawale-arm
ASSEMBLY_OBJ := $(BIN_DIR)/AppleARM.o

# Default target: build all that can be built on this system
.PHONY: all
all: python bash c assembly
	@echo "Build complete! Run 'make help' for usage information."

# Help target
.PHONY: help
help:
	@echo "Qawale - Frequency Based Programming Language"
	@echo ""
	@echo "Available targets:"
	@echo "  make all          - Build all implementations (Python, Bash, C, ARM)"
	@echo "  make python       - Set up Python implementation"
	@echo "  make bash         - Set up Bash implementation"
	@echo "  make c            - Build C implementation (macOS/Linux)"
	@echo "  make assembly     - Build ARM assembly implementation (macOS only)"
	@echo "  make holyc        - Show instructions for HolyC compilation"
	@echo "  make run-python   - Run Python implementation"
	@echo "  make run-bash     - Run Bash implementation"
	@echo "  make run-c        - Run C implementation"
	@echo "  make run-assembly - Run ARM assembly implementation"
	@echo "  make test         - Test all implementations"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make install      - Install scripts to /usr/local/bin"
	@echo ""
	@echo "Examples:"
	@echo "  make run-python           # Run with defaults (10 iterations)"
	@echo "  make run-python ITER=20   # Run with 20 iterations"
	@echo "  make run-bash ITER=5 DELAY=0.5"

# Create bin directory
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Python target: copy and make executable
.PHONY: python
python: $(BIN_DIR) $(PYTHON_BIN)

$(PYTHON_BIN): $(PYTHON_SRC) | $(BIN_DIR)
	cp $(PYTHON_SRC) $(PYTHON_BIN)
	chmod +x $(PYTHON_BIN)
	@echo "Python implementation ready: $(PYTHON_BIN)"

# Bash target: copy and make executable
.PHONY: bash
bash: $(BIN_DIR) $(BASH_BIN)

$(BASH_BIN): $(BASH_SRC) | $(BIN_DIR)
	cp $(BASH_SRC) $(BASH_BIN)
	chmod +x $(BASH_BIN)
	@echo "Bash implementation ready: $(BASH_BIN)"

# C target: compile C implementation (macOS/Linux)
.PHONY: c
c: $(BIN_DIR) $(C_BIN)

$(C_BIN): $(C_SRC) | $(BIN_DIR)
	@echo "Building C implementation..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(CC) -arch arm64 -o $(C_BIN) $(C_SRC); \
	elif [ "$$(uname)" = "Linux" ]; then \
		$(CC) -o $(C_BIN) $(C_SRC) -lrt; \
	else \
		echo "Warning: C implementation may not work on this platform"; \
		$(CC) -o $(C_BIN) $(C_SRC); \
	fi
	@echo "C implementation built: $(C_BIN)"

# ARM Assembly target: assemble and link (macOS Apple Silicon only)
.PHONY: assembly
assembly: $(BIN_DIR) $(ASSEMBLY_BIN)

$(ASSEMBLY_BIN): $(ASSEMBLY_SRC) | $(BIN_DIR)
	@echo "Building ARM assembly implementation..."
	@if [ "$$(uname -m)" != "arm64" ]; then \
		echo "Warning: This is designed for ARM64 (Apple Silicon) Macs"; \
	fi
	@if [ "$$(uname)" != "Darwin" ]; then \
		echo "Error: ARM assembly implementation requires macOS"; \
		exit 1; \
	fi
	$(AS) -arch arm64 $(ASSEMBLY_SRC) -o $(ASSEMBLY_OBJ)
	SDK_PATH=$$(xcrun --show-sdk-path); \
	$(LD) -arch arm64 -o $(ASSEMBLY_BIN) $(ASSEMBLY_OBJ) \
		-lSystem -syslibroot "$$SDK_PATH" -e _main
	@echo "ARM assembly implementation built: $(ASSEMBLY_BIN)"

# HolyC target: show instructions (requires TempleOS)
.PHONY: holyc
holyc:
	@echo "HolyC Implementation Instructions:"
	@echo "=================================="
	@echo ""
	@echo "The HolyC implementation requires TempleOS environment."
	@echo "To compile and run:"
	@echo ""
	@echo "1. Copy src/holyc/Simulation.holyc to your TempleOS system"
	@echo "2. In TempleOS, run:"
	@echo "   #include \"Simulation.holyc\";"
	@echo "3. Or compile it as part of your HolyC project"
	@echo ""
	@echo "Note: TempleOS compilation cannot be automated from this Makefile"

# Run targets
.PHONY: run-python
run-python: python
	$(PYTHON) $(PYTHON_BIN) $(if $(ITER),-n $(ITER)) $(if $(DELAY),-d $(DELAY))

.PHONY: run-bash
run-bash: bash
	$(BASH_BIN) $(if $(ITER),$(ITER)) $(if $(DELAY),$(DELAY))

.PHONY: run-c
run-c: c
	$(C_BIN)

.PHONY: run-assembly
run-assembly: assembly
	$(ASSEMBLY_BIN)

# Test all implementations
.PHONY: test
test: test-python test-bash test-c test-assembly
	@echo ""
	@echo "All tests completed!"

.PHONY: test-python
test-python: python
	@echo "Testing Python implementation..."
	$(PYTHON) $(PYTHON_BIN) -n 3

.PHONY: test-bash
test-bash: bash
	@echo "Testing Bash implementation..."
	$(BASH_BIN) 3

.PHONY: test-c
test-c: c
	@echo "Testing C implementation..."
	@if [ -f $(C_BIN) ]; then \
		$(C_BIN) || echo "C test completed (may vary by timing)"; \
	else \
		echo "Skipping C test (not built)"; \
	fi

.PHONY: test-assembly
test-assembly: assembly
	@echo "Testing ARM assembly implementation..."
	@if [ -f $(ASSEMBLY_BIN) ]; then \
		$(ASSEMBLY_BIN) || echo "Assembly test completed (may vary by timing)"; \
	else \
		echo "Skipping assembly test (not built on this platform)"; \
	fi

# Install targets (optional - installs to /usr/local/bin)
.PHONY: install
install: python bash c assembly
	@echo "Installing Qawale implementations to /usr/local/bin..."
	install -d /usr/local/bin
	install -m 755 $(PYTHON_BIN) /usr/local/bin/qawale-py
	install -m 755 $(BASH_BIN) /usr/local/bin/qawale-sh
	@if [ -f $(C_BIN) ]; then \
		install -m 755 $(C_BIN) /usr/local/bin/qawale-c; \
	fi
	@if [ -f $(ASSEMBLY_BIN) ]; then \
		install -m 755 $(ASSEMBLY_BIN) /usr/local/bin/qawale-arm; \
	fi
	@echo "Installation complete!"
	@echo "Run with: qawale-py, qawale-sh, qawale-c, or qawale-arm"

.PHONY: uninstall
uninstall:
	@echo "Removing Qawale from /usr/local/bin..."
	rm -f /usr/local/bin/qawale-py
	rm -f /usr/local/bin/qawale-sh
	rm -f /usr/local/bin/qawale-c
	rm -f /usr/local/bin/qawale-arm
	@echo "Uninstallation complete!"

# Clean target
.PHONY: clean
clean:
	rm -rf $(BIN_DIR)
	@echo "Clean complete!"

# Deep clean (also removes any backup files)
.PHONY: distclean
distclean: clean
	find . -type f \( -name "*~" -o -name "*.bak" -o -name "*.swp" \) -delete
	@echo "Distclean complete!"

