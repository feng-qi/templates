#include <algorithm>
#include <random>

auto rand_lambda = [](int lower, int upper){
    static std::mt19937 generator(std::random_device{}());
    static std::uniform_int_distribution<> dist(lower, upper);
    return dist(generator);
};

int rand_int(int lower, int upper) {
    static std::mt19937 generator(std::random_device{}());
    static std::uniform_int_distribution<> dist(lower, upper);
    return dist(generator);
}
