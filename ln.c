#include <stdio.h>
#include <math.h>

float optimize_ln();
void main_eq(unsigned int, float, float);
float ln(float, unsigned int);
float ln0(float, unsigned int);
float myexp(float);

int main() {
    main_eq(20, -5.0, 5.0);
    //optimize_ln();
    return 1;

}

/**
 * Determination of an optimal number of terms seems to be unnecessary with ln()
 * -> converges towards 0 difference with the correct values
 */
float optimize_ln() {
    int K = 100000;
    float mindiff = 0.0;
    int optK = 1;
    for(int k = 1; k < K; k++) {
        //printf("%d ", k);
        float diffsum = 0.0;
        for(float x = 1.0; x < 100; x += 20) {
            float mine = ln(x, k);
            float real = logf(x);
            diffsum += fabs(mine - real);
        }

        if(diffsum < mindiff || mindiff == 0.0) {
            mindiff = diffsum;
            optK = k;
        }
    }

    printf("\nK: %d diff %f\n", optK, mindiff);

    return optK;
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
    while(x <= xmax) {

        printf("%f \t", x);
        float y = /*my*/exp(x);
        printf("%f \t", y);
        float z = ln(y, 10000);
        printf("%f \t", z);

        printf("\n");
        x += dist;
    }
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
