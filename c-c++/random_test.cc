#include <gtest/gtest.h>
#include "random.h"

TEST(RandomIntTest, Simple) {
    for (int i = 1; i < 1001; ++i) {
        int r = rand_int(21, 31415);
        ASSERT_GE(r, 21);
        ASSERT_LE(r, 31415);
        // std::cout << r << (i % 10 ? '\t' : '\n');
    }
}

TEST(RandomIntTest, Lambda) {
    for (int i = 1; i < 1001; ++i) {
        int r = rand_lambda(21, 31415);
        ASSERT_GE(r, 21);
        ASSERT_LE(r, 31415);
        // std::cout << r << (i % 10 ? '\t' : '\n');
    }
}
