# IoT Processor Test Program
.text
.globl _start

_start:
    li x1, 10       # Load 10 into x1
    li x2, 5        # Load 5 into x2

    add x3, x1, x2  # x3 = x1 + x2
    sub x4, x1, x2  # x4 = x1 - x2
    mac x5, x1, x2  # x5 = (x1 * x2) + x5 (Multiply-Accumulate)
    andl x6, x1, x2 # Low-power AND
    orl x7, x1, x2  # Low-power OR

    sleep           # Enter Low-Power Mode
    wakeup          # Wake up Processor

    nop             # End Program
