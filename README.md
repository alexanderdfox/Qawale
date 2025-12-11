https://www.youtube.com/shorts/yBH1DbpbLpk 

# Qawale

A frequency-based programming language that executes commands based on simulated CPU frequency values.

## Project Structure

```
Qawale/
├── src/                    # Source code implementations
│   ├── python/            # Python implementation
│   ├── c/                 # C implementation
│   ├── bash/              # Bash implementation
│   ├── assembly/          # ARM assembly implementation
│   └── holyc/             # HolyC implementation
├── bin/                   # Build output directory (gitignored)
├── docs/                  # Documentation
├── LICENSE                # BSD 3-Clause License
├── README.md              # This file
├── roadmap.md             # Project roadmap
└── Makefile               # Build system
```

## Overview

Qawale is an experimental programming language concept where program execution is driven by CPU frequency measurements. Different frequency ranges trigger different operations, creating a unique programming paradigm where timing and system state determine program behavior.

## Concept

The language uses time-based simulation to generate frequency values. These frequency values are mapped to specific operations:
- **START** (200ms): Program initialization
- **PRINT** (400ms): Print memory value
- **ADD** (600ms): Add 10 to memory
- **SUBTRACT** (800ms): Subtract 5 from memory
- **END** (0ms): Program termination (frequency wraps to 0 when cycle completes)

## Implementations

This repository contains multiple implementations of the Qawale interpreter:

### Python (`src/python/Simulation.py`)
- Pure Python implementation
- Cross-platform compatible
- Easy to modify and experiment with

**Usage:**
```bash
python3 src/python/Simulation.py              # Direct execution
# or
make run-python                                # Using Makefile (recommended)
python3 src/python/Simulation.py -n 20 -d 0.5 # With options
```

### HolyC (`src/holyc/Simulation.holyc`)
- Implementation for TempleOS
- Uses HolyC language features

**Usage:**
Compile and run within TempleOS environment.

### Bash (`src/bash/Simulation.sh`)
- Shell script implementation
- No external dependencies (besides standard Unix tools)
- Works on Linux and macOS

**Usage:**
```bash
chmod +x src/bash/Simulation.sh && ./src/bash/Simulation.sh  # Direct execution
# or
make run-bash                                                  # Using Makefile (recommended)
./src/bash/Simulation.sh 20 0.5                               # With arguments (iterations, delay)
```

### C (`src/c/Simulation.c`)
- Native C implementation
- Cross-platform (macOS and Linux)
- Closely mirrors the ARM assembly implementation
- Uses platform-specific high-resolution timing APIs

**Build and Usage:**
```bash
make c          # Recommended: build using Makefile
make run-c      # Run the built executable
# or manually:
cc -o qawale-c src/c/Simulation.c        # macOS
cc -o qawale-c src/c/Simulation.c -lrt   # Linux
./qawale-c
```

### ARM Assembly (`src/assembly/AppleARM.asm`)
- Native ARM64 assembly for Apple Silicon Macs
- Direct system calls for performance
- Minimal dependencies

**Build and Usage:**
```bash
make assembly      # Recommended: build using Makefile
make run-assembly  # Run the built executable
# or manually:
as -arch arm64 src/assembly/AppleARM.asm -o AppleARM.o
ld -arch arm64 -o AppleARM AppleARM.o -lSystem -syslibroot $(xcrun --show-sdk-path) -e _main
./AppleARM
```

## Building with Make

A comprehensive Makefile is provided to build and manage all implementations:

**Quick Start:**
```bash
make              # Build all implementations
make help         # Show all available targets
make test         # Test all implementations
```

**Available Targets:**
- `make all` - Build all implementations (Python, Bash, C, ARM)
- `make python` - Set up Python implementation
- `make bash` - Set up Bash implementation
- `make c` - Build C implementation (macOS/Linux)
- `make assembly` - Build ARM assembly (macOS only)
- `make holyc` - Show instructions for HolyC compilation
- `make run-python` - Run Python implementation
- `make run-bash` - Run Bash implementation
- `make run-c` - Run C implementation
- `make run-assembly` - Run ARM assembly implementation
- `make test` - Test all implementations
- `make clean` - Remove build artifacts
- `make install` - Install to `/usr/local/bin`

**Examples:**
```bash
make run-python ITER=20          # Run Python with 20 iterations
make run-bash ITER=5 DELAY=0.5   # Run Bash with 5 iterations, 0.5s delay
make test                        # Test all implementations
```

## Architecture

### Frequency Simulation

The interpreter simulates CPU frequency by:
1. Getting current system time in milliseconds
2. Applying modulo 1000 to get a value between 0-999
3. Comparing this value against frequency thresholds
4. Executing the corresponding action

### Memory Model

- Single global memory register (initially 0)
- Modified by ADD and SUBTRACT operations
- Displayed by PRINT operation

## Examples

The default program runs 10 iterations, each checking the simulated frequency and executing the corresponding action.

See [roadmap.md](roadmap.md) for planned features and development milestones.

## Limitations

- Frequency values are simulated, not actual CPU measurements
- Single global memory register (no variables)
- Limited instruction set
- No control flow (loops, conditionals based on data)

## Future Improvements

- Real CPU frequency monitoring
- Extended instruction set
- Multiple memory registers/variables
- Control flow constructs
- Standard library
- Compiler for Qawale source code

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions welcome! Please feel free to submit issues or pull requests.
