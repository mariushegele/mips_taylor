#include <stdio.h>
#include <math.h>

int fact (int parameter);
float power(float base, int exponent);
float exponential(float x, int n);

int main() {
	float parameter = 15.0;
	int iterations = 6; // this implementation doesn't respect the optimal number of terms
	float result = exponential(parameter, iterations);

	printf("%i iterations\n", iterations);
	printf("e(%f) = %f\n", parameter, result);
	printf("error of %f\n", exp(parameter) - result);
	
	return 1;
}

/**
 * Calculates e(x) in an unoptimized manner: 
 * 	recalculating the factorial and exponential in each iteration without caching
 * 	-> optimization see exp_opt.c
 */ 
float exponential(float x, int n) {
	float result = 0.0;
	for(int i = 0; i < n; i++) {
		float numerator = power(x, i);
		int denominator = fact(i);
		float part = numerator / denominator;
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

/**
 * Potential for optimization: integer register can't hold high values
 * 	-> enforces low upper bound for n
 */
int fact (int parameter) {
	int result = 1;

	for(int i = 1; i <= parameter; i++) {
		result *= i;
	}

	return result;
}