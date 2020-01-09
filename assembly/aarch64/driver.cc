// -*- compile-command: "clang++ -std=c++17 driver.cc -lfmt && ./a.out" -*-

#include <numeric>
#include <iostream>
#include <fmt/format.h>
using namespace fmt;

// asm(R"(
// .global test
// test:
//   ldr  w1, =0x40302010
//   mov  x0, 0
//   sxtb x0, w1
//   ret
// )");
//
// extern "C" {
//     long test();
// }

void neon(int* output, int* input, int len) {
    asm volatile (
        "ld1 {v0.4s}, [%[input]]  \n"
        "st1 {v0.4s}, [%[output]] \n"
        : [output] "+r" (output)
        : [input] "r" (input)
        : "memory", "v0"
        );
}

void neon_8b(char* output, char* input, int len) {
    int i;

    asm volatile (
        "ld1  {v0.16b}, [%[input]]  \n"
        "st1  {v0.16b}, [%[output]] \n"
        // "smov %w[i], v0.b[0]     \n"
        "addv b1, v0.16b            \n"
        "umov %w[i], v1.s[0]        \n"
        : [output] "+r" (output), [i] "=r" (i)
        : [input] "r" (input)
        : "memory", "v0", "v1"
        );

    fmt::print("[neon_8b] value of i: {}\n", i);
}

void neon_4s(int* output, int* input, int len) {
    auto output_copy = output;
    long t = 0;
    asm volatile (
        "ld1 {v0.4s, v1.4s}, [%[input]], #32  \n"
        "st1 {v0.4s, v1.4s}, [%[output]], #32 \n"
        "ld1 {v0.4s, v1.4s}, [%[input]]       \n"
        "st1 {v0.4s, v1.4s}, [%[output]]      \n"
        "mov %[t], v0.d[0]                  \n"
        : [t] "=r" (t)
        : [output] "r" (output),
          [input] "r" (input)
        : "memory", "v0", "v1", "v2", "v3"
        );

    fmt::print("output - output_copy: {}\ntmp: {}\n", output - output_copy, t);
}

void neon_2d(long* output, long* input, int len) {
    auto output_copy = output;
    long t = 0;
    asm volatile (
        "ld1 {v0.2d, v1.2d}, [%[input]], #32  \n"
        "st1 {v0.2d, v1.2d}, [%[output]], #32 \n"
        "ld1 {v0.2d, v1.2d}, [%[input]]       \n"
        "st1 {v0.2d, v1.2d}, [%[output]]      \n"
        "mov %[t], v0.d[0]                  \n"
        : [output] "+r" (output), [t] "=r" (t)
        : [input] "r" (input)
        : "memory", "v0", "v1", "v2", "v3"
        );

    fmt::print("output - output_copy: {}\ntmp: {}\n", output - output_copy, t);
}

void neon_2s(float* output, float* input, int len) {
  int i;

  asm volatile (
    "ld1   {v0.4s}, [%[input]], 16  \n"
    // "ld1   {v1.4s}, [%[input]]      \n"
    // "fadd  v2.4s, v0.4s, v1.4s      \n"
    // "st1   {v2.4s}, [%[output]]     \n"
    "faddp s0, v0.2s                \n"
    "st1   {v0.2s}, [%[output]]     \n"
    // "st1   {v0.4s}, [%[output]], 16 \n"
    // "st1   {v1.4s}, [%[output]]     \n"
    // "smov %w[i], v0.b[0]         \n"
    // "addv b1, v0.4s              \n"
    // "umov %w[i], v1.s[0]         \n"
    : [output] "+r" (output) //, [i] "=r" (i)
    : [input] "r" (input)
    : "memory", "v0", "v1", "v2"
    );

  // fmt::print("[neon_8b] value of i: {}\n", i);
}

void scratch(float* output, float* input, int len) {
    int i;

    asm volatile (
      // "ld1   {v0.2s}, [%[input]], 8  \n"
      "ldr   d0, [%[input]]      \n"
      "faddp s0, v0.2s                \n"
      // "fadd  s0, v0.2s                \n"
      "st1   {v0.2s}, [%[output]]     \n"
      : [output] "+r" (output) //, [i] "=r" (i)
      : [input] "r" (input)
      : "memory", "v0", "v1", "v2"
      );

    // fmt::print("[neon_8b] value of i: {}\n", i);
}

void sxtb() {
  unsigned i = 0b1000'1011'1111;
  fmt::print("sxtb i: {:#034b}\n", i);
  asm volatile (
    "sxtb %w[i], %w[i] \n"
    : [i] "+r" (i)
    :
    :
    );
  fmt::print("sxtb i: {:#034b}\n", i);
}

void sxtl(short* output, char* input, int len) {
  asm volatile (
    "ld1   {v0.16b}, [%[input]]  \n"
    "sxtl  v2.8h,    v0.8b       \n"
    "st1   {v2.8h},  [%[output]] \n"
    : [output] "+r" (output)
    : [input] "r" (input)
    : "memory", "v0", "v1", "v2", "v3"
    );
}

void sshl(int* output, int* input, int len) {
  asm volatile (
    "ld1  {v0.4s}, [%[input]]      \n"
    "ld1  {v1.4s}, [%[input]]      \n"
    "sshl v2.4s,   v0.4s,   v1.4s  \n"
    // "eor  v2.16b,  v2.16b,  v2.16b \n"
    "st1  {v2.4s}, [%[output]]     \n"
    : [output] "+r" (output)
    : [input] "r" (input)
    : "memory", "v0", "v1", "v2", "v3"
    );
}

// void copy_asmq(int *a, int *b, int loop)
// {
//     int res_loop = loop%8;
//     int main_loop = loop - res_loop;
//     int i;
//     for (i = 0; i < main_loop; i += 8)
//     {
//         __asm__ __volatile__(
//             "ldr		q16, [%[b], #0]      \n\t"
//             "str		q16, [%[a], #0]      \n\t"
//             "ldr		q17, [%[b], #16]      \n\t"
//             "str		q17, [%[a], #16]      \n\t"
//             : [a] "+r" (a), [b] "+r" (b)
//             :
//             : "memory", "q16"
//             );
//         a += 8;
//         b += 8;
//     }
//     for (; i < loop; i++)
//         a[i] = b[i];
// }

int main(int argc, char *argv[])
{
  // long l = test();
  // fmt::print("{}\n", l);

  const int SIZE = 20;
  char  c_input[SIZE];         std::iota(std::begin(c_input), std::end(c_input), 1);
  char  c_output[SIZE] = {0};
  short s_input[SIZE];         std::iota(std::begin(s_input), std::end(s_input), 1);
  short s_output[SIZE] = {0};
  int   i_input[SIZE];         std::iota(std::begin(i_input), std::end(i_input), 1);
  int   i_output[SIZE] = {0};
  long  l_input[SIZE];         std::iota(std::begin(l_input), std::end(l_input), 1);
  long  l_output[SIZE] = {0};
  float f_input[SIZE];         std::iota(std::begin(f_input), std::end(f_input), 1.1);
  float f_output[SIZE] = {0};

  // neon_8b(c_output, c_input, 0);
  // neon_2d(l_output, l_input, 0);
  // neon_2s(f_output, f_input, 0);
  // scratch(f_output, f_input, 0);

  for (auto i : {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19})  { fmt::print("{:>10}", i); }
  fmt::print("\nsxtl:    --------------------\n");
  for (auto i : c_input)  { fmt::print("{:>10b}", int(i)); }     fmt::print("\n");
  for (auto i : s_output) { fmt::print("{:>10b}", int(i)); }     fmt::print("\n");
  sxtl(s_output, c_input, 0);
  for (auto i : c_input)  { fmt::print("{:>10b}", int(i)); }     fmt::print("\n");
  for (auto i : s_output) { fmt::print("{:>10b}", int(i)); }     fmt::print("\n");

  // for (auto i : {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19})  { fmt::print("{:>10}", i); }
  fmt::print("\nsshl:    --------------------\n");
  for (auto i : i_input)  { fmt::print("{:>10b}", int(i)); }     fmt::print("\n");
  for (auto i : i_output) { fmt::print("{:>10b}", int(i)); }     fmt::print("\n");
  sshl(i_output, i_input, 0);
  for (auto i : i_input)  { fmt::print("{:>10b}", int(i)); }     fmt::print("\n");
  for (auto i : i_output) { fmt::print("{:>10b}", int(i)); }     fmt::print("\n");

  sxtb();

  return 0;
}
