#include <stdio.h>
#include <math.h>

float ln(float, unsigned int);
float ln0(float, unsigned int);

int main() {
    float x = 15.0;
    int terms = 100;
    
    printf("ln(%f) = %f", x, ln(x, terms));
    printf("error of %f", log(x) - ln(x, terms));
    
    return 1;
}

/**
 *  converges for [0, 2] 
 */
float ln0(float x, unsigned int terms) {
    float el = (x-1); // the current element value
    float sum = el;
    for(unsigned int i=2; i<terms; i++) {
        // current numerator: previous num. * (1-x)
        // current denonimator: previous denum + 1
        // => previous element * (i-1) * (1-x) / i
        el = el * (i-1); // remove denominator of previous
        el = el * ((1-x) / i);
        sum += el;      
    }

    return sum;
}

/**
 * extends the convergence area of ln0 to any x > 0
 * if a <= 2, find
 *      x = a * 2^b, and calculate
 *      ln(x) = ln(a) + b * ln(2)
 */
float ln(float x, unsigned int terms) {
    float a = x;
    int b = 0;
    while(a > 2) {
        a = a / 2;
        b++;
    } // => a == x / 2^b

    return ln0(a, terms) + b * ln0(2, terms);
}
