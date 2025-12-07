#!/bin/bash
#
# Qawale - Frequency Based Programming Language (Bash Implementation)
# Simulates CPU frequency-based program execution using time intervals.
#
# Copyright (c) 2024, Qawale Contributors
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

set -euo pipefail

# Action mappings for simulated frequencies (in milliseconds, modulo 1000)
readonly START_FREQ=200
readonly PRINT_FREQ=400
readonly ADD_FREQ=600
readonly SUBTRACT_FREQ=800
readonly END_FREQ=1000

# Program state
memory=0
running=1
iterations=${1:-10}  # Allow iterations as command-line argument
delay=${2:-1}        # Allow delay as command-line argument

# Function to get time in milliseconds (cross-platform compatible)
get_time_ms() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: date doesn't support %3N, use Python as fallback
        python3 -c "import time; print(int(time.time() * 1000))"
    else
        # Linux: date supports %3N
        date +%s%3N
    fi
}

# Function to simulate CPU frequency (using time intervals)
get_cpu_frequency() {
    # Get the current time in milliseconds since the epoch
    local time_ms
    time_ms=$(get_time_ms)
    
    # Use modulo to simulate cycling frequencies (0-999)
    echo $((time_ms % 1000))
}

# Function to process frequency and execute corresponding command
process_frequency() {
    local freq=$1
    
    if ((freq == START_FREQ)); then  # START
        echo "Program started..."
    elif ((freq == PRINT_FREQ)); then  # PRINT
        echo "Memory: $memory"
    elif ((freq == ADD_FREQ)); then  # ADD
        memory=$((memory + 10))
        echo "Added 10. New memory value: $memory"
    elif ((freq == SUBTRACT_FREQ)); then  # SUBTRACT
        memory=$((memory - 5))
        echo "Subtracted 5. New memory value: $memory"
    elif ((freq == END_FREQ)); then  # END
        echo "Program ended."
        running=0
    fi
    # Note: Unknown frequencies are silently ignored
}

# Simulate a sequence of CPU frequency-based events
run_program() {
    local i=0
    local cpu_freq
    
    running=1
    
    while ((i < iterations && running == 1)); do
        cpu_freq=$(get_cpu_frequency)
        process_frequency "$cpu_freq"
        
        if ((running == 1)); then
            sleep "$delay"
        fi
        
        ((i++))
    done
}

# Usage information
usage() {
    cat << EOF
Usage: $0 [iterations] [delay]

Arguments:
  iterations    Number of iterations to run (default: 10)
  delay         Delay between frequency checks in seconds (default: 1)

Examples:
  $0              # Run 10 iterations with 1 second delay
  $0 20           # Run 20 iterations with 1 second delay
  $0 10 0.5       # Run 10 iterations with 0.5 second delay

EOF
}

# Check for help flag
if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

# Validate arguments are numeric if provided
if [[ -n "${1:-}" ]] && ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: iterations must be a number" >&2
    usage
    exit 1
fi

if [[ -n "${2:-}" ]] && ! [[ "$2" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: delay must be a number" >&2
    usage
    exit 1
fi

# Main entry point
run_program
