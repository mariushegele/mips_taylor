#include <stdio.h>
#include <math.h>

int fact (int parameter);
float power(float base, int exponent);
float exponential(float x, int n);

int main() {
	float parameter = 1.0;
	int iterations = 6;
	float result = exponential(parameter, iterations);
	printf("%i iterations\n", iterations);
	printf("Result: %lf\n", result);
	printf("Real result: %lf", exp(parameter));
	
	return 1;
}

float exponential(float x, int n) {
	printf("Exp(%lf):\n", x);

	float result = 0.0;
	for(int i = 0; i < n; i++) {
		float zaehler = power(x, i);
		int nenner = fact(i);
		float part = zaehler/nenner;
		printf("n: %i; Zähler: %lf; Nenner: %i; Part: %lf\n", n, zaehler, nenner, part);
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

int fact (int parameter) {
	int result = 1;

	for(int i = 1; i <= parameter; i++) {
		result *= i;
	}

	return result;
}
