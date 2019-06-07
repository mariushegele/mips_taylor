#include <stdio.h>
#include <math.h>

int getIterations(float);
float exponential(float, int);


int main() {
	float parameter = 15.0;
	int iterations = getIterations(parameter);
	printf("%d iterations\n", iterations);

	float result = exponential(parameter, iterations);
	printf("e(%f): %f\n", parameter, result);
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
 * Optimized calculation of e(x)
 * 	Caching the nominator and denominator
 */
float exponential(float x, int iterations) {
	float result = 1.0;
	float nominator = 1.0;
	float denominator = 1.0;

	for(float i = 1; i <= iterations; i++) {
		nominator = nominator * x;
		denominator = denominator * i;
		float part = nominator/denominator;
		result += part;
	}
	return result;
}