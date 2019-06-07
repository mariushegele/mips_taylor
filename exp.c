#include <stdio.h>
#include <math.h>

int getIterations(float);
float fact (int parameter);
float power(float base, int exponent);
float exponential(float x, int n);

int main() {
	float parameter = 15.0;
	int iterations = getIterations(parameter);
	float result = exponential(parameter, iterations);
	printf("%i iterations\n", iterations);
	printf("e(%f) = %f\n", parameter, result);
	printf("error of %f\n", exp(parameter) - result);
	
	return 1;
}

/**
 * Approximates the optimal number of terms (see documentation)
 */
int getIterations(float x) {
	if (x < 14) return 34;
	return 430 / (x + 10) + 14;
}

/**
 * Calculates e(x) in an unoptimized manner: 
 * 	recalculating the factorial and exponential in each iteration without caching
 * 	-> optimization see exp_opt.c
 */ 
float exponential(float x, int n) {
	float result = 0.0;
	for(int i = 0; i < n; i++) {
		float zaehler = power(x, i);
		float nenner = fact(i);
		float part = zaehler/nenner;
		result += part;
	}
	return result;
}

float power(float base, int exponent) {
	float result = 1.0;

	while (exponent > 0) {
		result *= base;
		exponent--;
	}

	return result;
}

float fact (int parameter) {
	float result = 1;

	for(int i = 1; i <= parameter; i++) {
		result *= (float) i;
	}

	return result;
}