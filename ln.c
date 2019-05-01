#include <stdio.h>
#include <math.h>

float ln(float);

int main() {

    printf("ln(1) %f\n", ln(1));
    printf("ln(1.1222) %f\n", ln(1.1222));
    printf("ln(2) %f\n", ln(2));
    printf("ln(3) %f\n", ln(3)); // doesn't converge
    
    return 1;

}


float ln(float x) {

    static unsigned int K = 1000;

    float el = (x-1); // the current element value
    float sum = el;
    for(unsigned int i=2; i<K; i++) {
        // current numerator: previous num. * (1-x)
        // current denonimator: previous denum + 1
        // => previous element * (i-1) * (1-x) / i
        el = el * (i-1); // remove denominator of previous
        el = el * ((1-x) / i);
        sum += el;      
    }

    return sum;
}