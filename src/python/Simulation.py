#!/usr/bin/env python3
"""
Qawale - Frequency Based Programming Language (Python Implementation)
Simulates CPU frequency-based program execution using time intervals.

Copyright (c) 2024, Qawale Contributors
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
"""

import time
import sys
from typing import Optional

# Action mappings for simulated frequencies (in milliseconds, modulo 1000)
START_FREQ = 200
PRINT_FREQ = 400
ADD_FREQ = 600
SUBTRACT_FREQ = 800
END_FREQ = 1000

# Program state
memory = 0
RUNNING = True


def get_cpu_frequency() -> int:
    """
    Simulate CPU frequency by getting current time and applying modulo.
    
    Returns:
        int: A frequency value between 0-999 (milliseconds modulo 1000)
    """
    # Get current time in milliseconds since the epoch
    time_ms = int(time.time() * 1000)
    
    # Use modulo to simulate cycling frequencies (0-999)
    return time_ms % 1000

def process_frequency(freq: int) -> None:
    """
    Process frequency value and execute corresponding command.
    
    Args:
        freq: Frequency value (0-999) to process
    """
    global memory, RUNNING
    
    if freq == START_FREQ:  # START
        print("Program started...")
    elif freq == PRINT_FREQ:  # PRINT
        print(f"Memory: {memory}")
    elif freq == ADD_FREQ:  # ADD
        memory += 10
        print(f"Added 10. New memory value: {memory}")
    elif freq == SUBTRACT_FREQ:  # SUBTRACT
        memory -= 5
        print(f"Subtracted 5. New memory value: {memory}")
    elif freq == END_FREQ:  # END
        print("Program ended.")
        RUNNING = False
    # Note: Unknown frequencies are silently ignored (as expected in frequency-based programming)

def run_program(iterations: Optional[int] = None, delay: float = 1.0) -> None:
    """
    Run the Qawale program by checking frequencies and executing commands.
    
    Args:
        iterations: Number of iterations to run (None = run until END)
        delay: Delay between frequency checks in seconds
    """
    global RUNNING
    
    RUNNING = True
    iteration = 0
    
    while RUNNING:
        if iterations is not None and iteration >= iterations:
            break
            
        cpu_freq = get_cpu_frequency()
        process_frequency(cpu_freq)
        
        iteration += 1
        if RUNNING:  # Only sleep if we're still running
            time.sleep(delay)


def main() -> int:
    """Main entry point with command-line argument support."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Qawale - Frequency Based Programming Language",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 Simulation.py              # Run 10 iterations (default)
  python3 Simulation.py -n 20        # Run 20 iterations
  python3 Simulation.py -d 0.5       # Check frequency every 0.5 seconds
  python3 Simulation.py -n 0         # Run until END command is triggered
        """
    )
    parser.add_argument(
        "-n", "--iterations",
        type=int,
        default=10,
        help="Number of iterations to run (0 = run until END, default: 10)"
    )
    parser.add_argument(
        "-d", "--delay",
        type=float,
        default=1.0,
        help="Delay between frequency checks in seconds (default: 1.0)"
    )
    
    args = parser.parse_args()
    
    iterations = None if args.iterations == 0 else args.iterations
    run_program(iterations=iterations, delay=args.delay)
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
