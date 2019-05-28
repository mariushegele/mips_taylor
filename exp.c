#include <stdio.h>
#include <math.h>

int fact (int parameter) {
	int result = 1;

	for(int i = 1; i <= parameter; i++)
	{
		result *= i;
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

int main() {
	float parameter = 1.0;
	int iterations = 10;
	printf("Exp(%lf):\n", parameter);

	float result = 0.0;
	for(int i = 0; i < iterations; i++)
	{
		float zaehler = power(parameter,i);
		int nenner = fact(i);
		float part = zaehler/nenner;
		// printf("Part: %lf\n", part);
		result += part;
	}

	printf("%i iterations\n", iterations);
	printf("Result: %lf\n", result);
	printf("Real result: %lf", exp(parameter));

	return 1;
}