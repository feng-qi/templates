#include <iostream>
#include <vector>

template <typename T>
void print_vector(const T& v, char separator = ' ', int item_per_line = 0) {
    if (!item_per_line)
        item_per_line = v.size();
    for (int i = 0; i < v.size(); ++i)
        std::cout << v[i] << ((i+1) % item_per_line ? separator : '\n');
}
