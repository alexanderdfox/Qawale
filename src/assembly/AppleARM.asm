// Qawale - Frequency Based Programming Language (ARM Assembly Implementation)
// Native ARM64 assembly for Apple Silicon Macs
//
// Copyright (c) 2024, Qawale Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

.global _main
.extern _printf
.extern _mach_absolute_time
.extern _nanosleep

.data
memory:        .quad 0
fmt_mem:       .asciz "Memory: %lld\n"
fmt_add:       .asciz "Added 10. New memory value: %lld\n"
fmt_sub:       .asciz "Subtracted 5. New memory value: %lld\n"
msg_start:     .asciz "Program started...\n"
msg_end:       .asciz "Program ended.\n"

.align 3
timespec:      .quad 1        // tv_sec = 1 second
               .quad 0        // tv_nsec = 0
one_billion:   .quad 1000000000  // 1,000,000,000 nanoseconds = 1 second
one_million:   .quad 1000000     // 1,000,000 nanoseconds = 1 millisecond

.text

// int get_cpu_frequency()
// Returns: frequency value (0-999) based on current time modulo 1000
get_cpu_frequency:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    bl _mach_absolute_time       // returns uptime in nanoseconds in x0
    
    // We want milliseconds mod 1000, where milliseconds = nanoseconds / 1,000,000
    // Strategy: get nanoseconds mod 1,000,000,000 (last second), then divide by 1,000,000
    
    // Get nanoseconds mod 1,000,000,000 (keep only last second)
    // Load one_billion using PC-relative addressing
    adrp x1, one_billion@PAGE
    add x1, x1, one_billion@PAGEOFF
    ldr x1, [x1]                 // x1 = 1,000,000,000
    udiv x2, x0, x1              // x2 = nanoseconds / 1,000,000,000
    msub x0, x2, x1, x0          // x0 = nanoseconds mod 1,000,000,000
    
    // Now divide by 1,000,000 to get milliseconds (0-999)
    // Load one_million using PC-relative addressing
    adrp x1, one_million@PAGE
    add x1, x1, one_million@PAGEOFF
    ldr x1, [x1]                 // x1 = 1,000,000
    udiv x0, x0, x1              // x0 = milliseconds in range 0-999
    
    ldp x29, x30, [sp], #16
    ret

// void process_frequency(int freq)
process_frequency:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    cmp x0, #200
    beq .start
    cmp x0, #400
    beq .print
    cmp x0, #600
    beq .add
    cmp x0, #800
    beq .sub
    cmp x0, #1000
    beq .end

    // Unknown frequencies are silently ignored (no action)
    b .done

.start:
    adrp x0, msg_start@PAGE
    add x0, x0, msg_start@PAGEOFF
    bl _printf
    b .done

.print:
    adrp x1, memory@PAGE
    add x1, x1, memory@PAGEOFF
    ldr x1, [x1]                 // Load 64-bit value
    adrp x0, fmt_mem@PAGE
    add x0, x0, fmt_mem@PAGEOFF
    bl _printf
    b .done

.add:
    adrp x1, memory@PAGE
    add x1, x1, memory@PAGEOFF
    ldr x2, [x1]                 // Load 64-bit value
    add x2, x2, #10              // Add 10
    str x2, [x1]                 // Store 64-bit value
    adrp x0, fmt_add@PAGE
    add x0, x0, fmt_add@PAGEOFF
    mov x1, x2                   // Pass 64-bit value to printf
    bl _printf
    b .done

.sub:
    adrp x1, memory@PAGE
    add x1, x1, memory@PAGEOFF
    ldr x2, [x1]                 // Load 64-bit value
    sub x2, x2, #5               // Subtract 5
    str x2, [x1]                 // Store 64-bit value
    adrp x0, fmt_sub@PAGE
    add x0, x0, fmt_sub@PAGEOFF
    mov x1, x2                   // Pass 64-bit value to printf
    bl _printf
    b .done

.end:
    adrp x0, msg_end@PAGE
    add x0, x0, msg_end@PAGEOFF
    bl _printf

.done:
    ldp x29, x30, [sp], #16
    ret

// void run_program()
run_program:
    mov w20, #10          // loop counter

.loop:
    bl get_cpu_frequency
    bl process_frequency

    adrp x0, timespec@PAGE
    add x0, x0, timespec@PAGEOFF
    bl _nanosleep

    subs w20, w20, #1
    b.ne .loop
    ret

_main:
    bl run_program
    mov w0, #0
    ret
