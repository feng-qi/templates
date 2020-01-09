// -*- compile-command: "gcc -nostdlib -nodefaultlibs test.s" -*-

.text
.global _start
.p2align 2
.type _start, @function

// .align 1
// .org . + 3      // makes .text unaligned by 4
// .skip 3         // makes .text unaligned by 4
// .space 3        // makes .text unaligned by 4

_start:

  ldr x1, =values
  ld1 {v0.2s}, [x1]
  umov x1, v0.2d[0]

  // fmov d10, #&4F0000

  // ldr  w1, =0x40302010
  // mov  x0, 0
  // sxtb x0, w1

  // ldr x0, =values_len
  mov x0, 0
  mov x8, 93
  svc 0

  ret




.data
values:
  .word 0x01020304
  .word 0x05060708
  .ascii "abcdefghijklmn"

  values_len = . - values
