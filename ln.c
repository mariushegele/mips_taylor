#include <stdio.h>
#include <math.h>

void main_eq(unsigned int, float, float);
float ln(float);
float ln0(float);
float myexp(float);


int main() {
    main_eq(20, -5.0, 5.0);
    return 1;

}

/**
 * param: n     number of equidistant values
 * param: xmin  lower bound for values
 * param: xmax  upper bound for values
 */
void main_eq(unsigned int n, float xmin, float xmax) {
    if(xmin >= xmax) {
        return;
    }

    float dist = (xmax - xmin) / n;
    float x = xmin;
    printf("x \t\ty \t\tz \n");
    while(x < xmax) {
        // TODO store in array?
        printf("%f \t", x);
        float y = /*my*/exp(x);
        printf("%f \t", y);
        float z = ln(y);
        printf("%f \t", z);

        printf("\n");
        x += dist;
    }
}

float ln0(float x) {

    const unsigned int K = 10000;

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


/* not working */
float myexp(float x) {
    const unsigned int K = 10000;

    float sum = 0;
    float enumerator = 1;
    float denominator = 1;
    int i = 1;
    while(i < K) {
        enumerator *= x;
        denominator *= i;
        sum += enumerator / denominator;
        i++;
    }

    return sum;
}
