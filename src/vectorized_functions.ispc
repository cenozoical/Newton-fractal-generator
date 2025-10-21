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
//calculates function roots and RGB values of the pure colors in in HSV/HSL wheel they represent
export void calculate_roots(uniform double roots_real[], uniform double roots_im[],uniform int roots_red[],uniform int roots_green[],uniform int roots_blue[], uniform int n)
{
    foreach (i = 0 ... n) {
            double angle_rad = 2*i*PI/(double)n;
            roots_real[i] = cos(angle_rad);
            roots_im[i] = sin(angle_rad);


            const double angle = (double)i*360.0/(double)n;

            const int sector_index = floor(angle/60.0);
            const double offset_fract = (angle-((double)sector_index)*60.0)/60.0;

            const int q = (int)(offset_fract * 255.0);
            const int t = (int)((1.0 - offset_fract) * 255.0);

            switch (sector_index) {
                case 0: roots_red[i] = 255; roots_green[i] = q;   roots_blue[i] = 0; break;
                case 1: roots_red[i] = t;   roots_green[i] = 255; roots_blue[i] = 0; break;
                case 2: roots_red[i] = 0;   roots_green[i] = 255; roots_blue[i] = q; break;
                case 3: roots_red[i] = 0;   roots_green[i] = t;   roots_blue[i] = 255; break;
                case 4: roots_red[i] = q;   roots_green[i] = 0;   roots_blue[i] = 255; break;
                case 5: roots_red[i] = 255; roots_green[i] = 0;   roots_blue[i] = t; break;
            }
        }


}
//roots_red - red component given to the roots, red_values - red components for each pixel
export void process_pixels(uniform int n,uniform double roots_real[],uniform double roots_im[] , uniform int roots_red[],uniform int roots_green[],uniform int roots_blue[],uniform int red_values[], uniform int green_values[], uniform int blue_values[])
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

            if (getNorm(sub(nearest_root,z)) < tolerance)
            {
                r = roots_red[root_index];
                g = roots_green[root_index];
                b = roots_blue[root_index];
                const double intensity = ((double)iterations) / ((double)max_iterations);
                r = (int)((double)(r) * (1.0 - intensity));
                g = (int)((double)(g) * (1.0 - intensity));
                b = (int)((double)(b) * (1.0 - intensity));
            }


        }
        red_values[i] = r;
        green_values[i] = g;
        blue_values[i] = b;

    }

}