// -*- compile-command: "gcc-8 -march=armv8-a+sve -nostdlib -nodefaultlibs test.s"; -*-

.text
.global _start
.p2align 2
.type _start, @function

_start:
  mov x0, 0
  // ld1w {z8.s}, p5/z, [x12]
  incw x0
  mov x8, 93
  svc 0
