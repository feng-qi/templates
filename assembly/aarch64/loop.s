.text
  .global _start

  start = 1
  max = 31

_start:
  mov x9, start
  mov x10, 10

loop:
  mov x11, x9

  udiv x12, x11, x10
  msub x13, x10, x12, x11

  add x14,x13,0x30
  adr x15, msg
  strb w14, [x15, 7]

  cmp x12, 0
  b.eq noTens

  add x14, x12, 0x30
  adr x15, msg
  strb w14, [x15, 6]

noTens:

  mov x0, 1
  adr x1, msg
  mov x2, len
  mov x8, 64
  svc 0

  add x9, x11, 1
  cmp x9, max
  b.ne loop

  mov x0, 0
  mov x8, 93
  svc 0

.data

msg: .ascii "Loop    \n"
  len = . - msg
