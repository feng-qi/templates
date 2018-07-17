#include <gtest/gtest.h>
#include "add.h"

TEST(TestAdd, Basic) {
    ASSERT_EQ(3+7, add(3, 7));
}

TEST(TestAdd, Simple) {
    ASSERT_EQ(3+4+5, add(3, add(4, 5)));
}

TEST(TestAdd, Fail) {
    ASSERT_EQ(3, add(3, 1));
}
