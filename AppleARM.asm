.global _main
.extern _printf
.extern _mach_absolute_time
.extern _nanosleep

.data
memory:        .quad 0
fmt_mem:       .asciz "Memory: %d\n"
fmt_add:       .asciz "Added 10. New memory value: %d\n"
fmt_sub:       .asciz "Subtracted 5. New memory value: %d\n"
msg_start:     .asciz "Program started...\n"
msg_end:       .asciz "Program ended.\n"
msg_unknown:   .asciz "Unknown frequency: %d\n"

.align 3
timespec:      .quad 1        // tv_sec = 1 second
               .quad 0        // tv_nsec = 0

.text

// int get_cpu_frequency()
get_cpu_frequency:
    bl _mach_absolute_time       // returns uptime in nanoseconds in x0
    mov x1, #1000000000          // Move lower 32-bit value into x1
    ubfx x2, x0, #0, #32         // Extract the lower 32 bits from x0 (nanoseconds to seconds)
    udiv x0, x2, x1              // Convert nanoseconds to seconds (x0 = uptime in seconds)
    mov x1, #1000
    udiv x2, x0, x1              // Convert seconds to milliseconds
    mov x3, x0                   // Save seconds in x3
    msub x0, x2, x1, x3          // x0 = x2 * 1000 + remainder (milliseconds)

    cmp x0, #500
    blt .low
    cmp x0, #300
    blt .mid

    mov x0, #100
    ret

.low:
    mov x0, #500
    ret

.mid:
    mov x0, #300
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

    // Unknown
    mov x1, x0
    ldr x0, =msg_unknown
    bl _printf
    b .done

.start:
    ldr x0, =msg_start
    bl _printf
    b .done

.print:
    ldr x1, =memory
    ldr w1, [x1]
    ldr x0, =fmt_mem
    bl _printf
    b .done

.add:
    ldr x1, =memory
    ldr w2, [x1]
    add w2, w2, #10
    str w2, [x1]
    ldr x0, =fmt_add
    mov x1, w2
    bl _printf
    b .done

.sub:
    ldr x1, =memory
    ldr w2, [x1]
    sub w2, w2, #5
    str w2, [x1]
    ldr x0, =fmt_sub
    mov x1, w2
    bl _printf
    b .done

.end:
    ldr x0, =msg_end
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

    ldr x0, =timespec
    bl _nanosleep

    subs w20, w20, #1
    b.ne .loop
    ret

_main:
    bl run_program
    mov w0, #0
    ret
