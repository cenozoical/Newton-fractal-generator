#include "constants.h"


struct complex
{
double real;
double im;
};
double getAmplitude(complex a)
{
return sqrt(a.real*a.real+ a.im*a.im);
}
double getNorm(complex a)
{
return a.real*a.real+ a.im*a.im;

}
double getAngle(complex a)
{
double angle = atan2(a.im, a.real);
if(angle < 0) angle += 2*PI;
return angle;
}
complex add(complex a, complex b)
{
complex result;
result.real = a.real + b.real;
result.im = a.im + b.im;
return result;
}
complex sub(complex a, complex b)
{
complex result;
result.real = a.real - b.real;
result.im = a.im - b.im;
return result;
}

complex mul(complex a, complex b)
{
complex result;
result.real = a.real*b.real - a.im * b.im;
result.im = a.real*b.im + a.im*b.real;
return result;
}
complex div(complex a, complex b)
{
complex result;
result.real = (a.real*b.real + a.im * b.im)/(b.real*b.real + b.im*b.im);
result.im =   (-a.real*b.im + a.im*b.real)/(b.real*b.real + b.im*b.im);
return result;
}

//get f = a^n
complex complex_pow(complex a, int n)
{
complex result;

double angle = getAngle(a);
double ampl = getAmplitude(a);

angle = angle * n;
ampl = pow(ampl, n);

result.im = sin(angle)*ampl;
result.real = cos(angle) * ampl;

return result;
}

export void calculate_roots(uniform double roots_real[], uniform double roots_im[], uniform int n)
{
    foreach (i = 0 ... n) {
            double angle = 2*i*PI/(double)n;
            roots_real[i] = cos(angle);
            roots_im[i] = sin(angle);
        }


}
//returns a pure color that a root indexes angle represents in HSV/HSL color models
void getColor(int iterations, int root_index, int& R, int& G, int& B, int n) {
    const double angle = (double)root_index*360.0/(double)n;

    const int sector_index = floor(angle/60.0);
    const double offset_fract = (angle-((double)sector_index)*60.0)/60.0;

    const int q = (int)(offset_fract * 255.0);
    const int t = (int)((1.0 - offset_fract) * 255.0);

    switch (sector_index) {
        case 0: R = 255; G = q; B = 0; break;
        case 1: R = t; G = 255; B = 0; break;
        case 2: R = 0; G = 255; B = q; break;
        case 3: R = 0; G = t; B = 255; break;
        case 4: R = q; G = 0; B = 255; break;
        case 5: R = 255; G = 0; B = t; break;
    }

    const double intensity = ((double)iterations) / ((double)max_iterations);
    R = (int)((double)(R) * (1.0 - intensity));
    G = (int)((double)(G) * (1.0 - intensity));
    B = (int)((double)(B) * (1.0 - intensity));

}
export void process_pixels(uniform int n,uniform double roots_real[], uniform double roots_im[],uniform int red_values[], uniform int green_values[], uniform int blue_values[])
{
    uniform double x_min = -pane_width/2;
    uniform double x_max = pane_width/2;
    uniform double y_min = -pane_height/2;
    uniform double y_max = pane_height/2;


    uniform int pixel_count = ppm_width*ppm_height;
    foreach_tiled (x = 0 ... ppm_width, y = 0 ... ppm_height)
    {

        int i = y*ppm_width + x;
        double real_part = x_min + ((double)x / (double)ppm_width) * (x_max - x_min);
        double imag_part = y_min + ((double)y / (double)ppm_height)* (y_max - y_min);



        complex z, initial;
        z.real = real_part;
        z.im = imag_part;
        initial = z;
        int iterations = 0;
        while (iterations < max_iterations) {

            complex derivative, difference, new_z, f_value;
            {
                derivative = complex_pow(z,n-1);//temp value
                f_value = mul(derivative , z);
                f_value.real -=  1;
                derivative.real *= (float)n;
                derivative.im *= (float)n;
            }
            if (getNorm(derivative) < 1e-12) break;


            difference = div(f_value,derivative);

            new_z = sub(z, difference);


            if (getNorm(difference)< tolerance) {
                // Converged

                z = new_z;
                break;
            }
            z = new_z;
            iterations++;
        }

        int r, g, b;
        r = g = b = 0;

        {
            double angle = getAngle(z);

            int root_index = (int)(round((angle*(double)(n))/(2.0f*PI)));

            if(root_index == n) root_index = 0;
            complex nearest_root;

            nearest_root.real  = roots_real[root_index];
            nearest_root.im = roots_im[root_index];

            if (getNorm(sub(nearest_root,z)) < tolerance) getColor(iterations, root_index, r , g ,b, n);
        }
        red_values[i] = r;
        green_values[i] = g;
        blue_values[i] = b;

    }

}