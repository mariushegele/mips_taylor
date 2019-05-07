#include <stdio.h>
#include <math.h>

float ln(float);
float ln0(float);

int main() {

    printf("ln0(1) %f\n", ln0(1));
    printf("ln0(1.1222) %f\n", ln0(1.1222));
    printf("ln0(2) %f\n", ln0(2));
    printf("ln0(3) %f\n", ln0(3)); // doesn't converge
    printf("ln(3) %f\n", ln(3));
    printf("ln(150) %f\n", ln(150));
    
    return 1;

}


float ln0(float x) {

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

/**
 * extends the convergence area of ln0 to any x > 0
 * if a <= 2, find
 *      x = a * 2^b, and calculate
 *      ln(x) = ln(a) + b * ln(2)
 */
float ln(float x) {
    float a = x;
    int b = 0;
    while(a > 2) {
        a = a / 2;
        b++;
    } // => a == x / 2^b

    return ln0(a) + b * ln0(2);
}

/**
 * param: n     number of equidistant values
 * param: xmin  lower bound for values
 * param: xmax  upper bound for values
 */
int main(unsigned int n, int xmin, int xmax) {
    if(xmin > xmax) {
        return 0;
    }

    int dist = (xmax - xmin) / n;
    int x = xmin;
    while(x != xmax) {
        printf("%d \t", x);
        int y = e(x);
        printf("%d \t", y);
        int z = ln(y);
        printf("%d \t", z);

        printf("\n");
        x += dist;
    }
}