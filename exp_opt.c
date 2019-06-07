#include <stdio.h>
#include <math.h>

float getIterations(float);
float exponential(float, float);


int main() {
	float parameter = 15.0;
	float iterations = getIterations(parameter);
	printf("%d iterations\n", iterations);

	float result = exponential(parameter, iterations);
	printf("e(%f): %f\n", parameter, result);
	printf("error of %f\n", exp(parameter) - result);
	
	
	return 1;
}

/**
 * Approximates the optimal number of terms (see documentation)
 */
float getIterations(float x) {
	if (x < 14) return 34;
	return 430 / (x + 10) + 14;
}

/**
 * Optimized calculation of e(x)
 * 	Caching the numerator and denominator
 */
float exponential(float x, float iterations) {
	float result = 1.0;
	float numerator = 1.0;
	float denominator = 1.0;

	for(float i = 1; i <= iterations; i++) {
		numerator = numerator * x;
		denominator = denominator * i;
		float part = numerator/denominator;
		result += part;
	}
	return result;
}