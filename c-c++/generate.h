#include <algorithm>
#include <random>
#include <vector>

template <typename T>
void fill_vector(T& v) {
    std::generate(v.begin(), v.end(), [](int lower, int upper){
            static std::mt19937 generator(std::random_device{}());
            static std::uniform_int_distribution<> dist(lower, upper);
            return dist(generator);
        });
}
