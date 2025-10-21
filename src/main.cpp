#include <iostream>
#include <fstream>
#include <complex>
#include <cmath>
#include <iomanip>
#include <unordered_map>
#include <vector>
#include "constants.h"
#include "vectorized_functions_ispc.h"

int n;




int main(int argc, const char * argv[]) {

    std::cout << "Please define n in a z^n - 1 = 0 equation: ";
    std::cin >> n;


    double *roots_real= new double[n];
    double *roots_im = new double[n];
    ispc::calculate_roots(roots_real,roots_im,n);

    std::ofstream file("newton_fractal.ppm");
    file << "P3\n" << ppm_width << " " << ppm_height << "\n255\n";

    int *red_values  = new int[ppm_height*ppm_width];
    int *green_values  = new int[ppm_height*ppm_width];
    int *blue_values  = new int[ppm_height*ppm_width];

    ispc::process_pixels(n, roots_real, roots_im, red_values, green_values, blue_values);
    for (int i = 0; i <ppm_width*ppm_height;i++) file << red_values[i] << " " << green_values[i] << " " << blue_values[i] << "\n";
    file.close();
    std::cout << "Generated newton_fractal.ppm" << std::endl;

    return 0;
}