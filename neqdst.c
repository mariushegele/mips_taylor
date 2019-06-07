#include <stdio.h>
#include <math.h>

void neqdst(unsigned int, float, float);
float ln(float, unsigned int);
float ln0(float, unsigned int);
float getIterations(float);
float exponential(float, float);

int main() {
    neqdst(10, 1.0, 10.0);
    return 1;

}

/**
 * Calculates n equidistant values between x_min and x_max
 *  and prints e(n) and ln(e(n)) = n
 * param: n     number of equidistant values
 * param: xmin  lower bound for values
 * param: xmax  upper bound for values
 */
void neqdst(unsigned int n, float xmin, float xmax) {
    if(xmin >= xmax) {
        return;
    }

    float dist = (xmax - xmin + 1) / n;
    float x = xmin;
    printf("x \t\ty \t\tz \n");
    while(x <= xmax) {

        printf("%f \t", x);
        float y = exponential(x, getIterations(x));
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

/**
 * Approximates the optimal number of terms for e (see documentation)
 */
float getIterations(float x) {
	if (x < 14) return 34;
	return 430 / (x + 10) + 14;
}

/**
 * Optimized calculation of e(x)
 * 	Caching the nominator and denominator
 */
float exponential(float x, float iterations) {
	float result = 1.0;
	float nominator = 1.0;
	float denominator = 1.0;

	for(float i = 1; i < iterations; i++) {
		nominator = nominator * x;
		denominator = denominator * i;
		float part = nominator/denominator;
		result += part;
	}
	return result;
}