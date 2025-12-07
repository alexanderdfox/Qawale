/*
 * Qawale - Frequency Based Programming Language (C Implementation)
 * Simulates CPU frequency-based program execution using time intervals.
 * Cross-platform implementation that works on macOS and Linux.
 *
 * Copyright (c) 2024, Qawale Contributors
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>

#ifdef __APPLE__
#include <mach/mach_time.h>
#endif

// Action mappings for simulated frequencies (in milliseconds, modulo 1000)
#define START_FREQ    200
#define PRINT_FREQ    400
#define ADD_FREQ      600
#define SUBTRACT_FREQ 800
#define END_FREQ      1000

// Program state
static int64_t memory = 0;

// Constants for time conversion
#define ONE_BILLION  1000000000LL  // 1,000,000,000 nanoseconds = 1 second
#define ONE_MILLION  1000000LL     // 1,000,000 nanoseconds = 1 millisecond

/**
 * Get CPU frequency value based on current time.
 * Returns: frequency value (0-999) based on current time modulo 1000
 */
int get_cpu_frequency(void) {
    uint64_t nanoseconds;
    
#ifdef __APPLE__
    // macOS: Use mach_absolute_time for high-resolution uptime
    nanoseconds = mach_absolute_time();
#else
    // Linux: Use clock_gettime with CLOCK_MONOTONIC
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    nanoseconds = (uint64_t)ts.tv_sec * ONE_BILLION + (uint64_t)ts.tv_nsec;
#endif
    
    // Get nanoseconds mod 1,000,000,000 (keep only last second)
    int64_t last_second = nanoseconds % ONE_BILLION;
    
    // Divide by 1,000,000 to get milliseconds (0-999)
    int milliseconds = (int)(last_second / ONE_MILLION);
    
    return milliseconds;
}

/**
 * Process frequency value and execute corresponding command.
 */
void process_frequency(int freq) {
    if (freq == START_FREQ) {
        printf("Program started...\n");
    } else if (freq == PRINT_FREQ) {
        printf("Memory: %lld\n", memory);
    } else if (freq == ADD_FREQ) {
        memory += 10;
        printf("Added 10. New memory value: %lld\n", memory);
    } else if (freq == SUBTRACT_FREQ) {
        memory -= 5;
        printf("Subtracted 5. New memory value: %lld\n", memory);
    } else if (freq == END_FREQ) {
        printf("Program ended.\n");
    }
    // Unknown frequencies are silently ignored
}

/**
 * Run the Qawale program.
 * Runs for the specified number of iterations.
 */
void run_program(int iterations) {
    struct timespec delay;
    delay.tv_sec = 1;   // 1 second
    delay.tv_nsec = 0;  // 0 nanoseconds
    
    for (int i = 0; i < iterations; i++) {
        int cpu_freq = get_cpu_frequency();
        process_frequency(cpu_freq);
        
        // Sleep for 1 second using nanosleep
        nanosleep(&delay, NULL);
    }
}

/**
 * Main entry point.
 */
int main(void) {
    run_program(10);  // Run 10 iterations by default
    return 0;
}

