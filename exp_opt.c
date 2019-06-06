#include <stdio.h>
#include <math.h>

int fact (int parameter);
float power(float base, int exponent);
float exponential(float x, int n);

int main() {
	float parameter = 1.0;
	int iterations = 10;
	float result = exponential(parameter, iterations);
	printf("%i iterations\n", iterations);
	printf("Result: %lf\n", result);
	printf("Real result: %lf", exp(parameter));
	
	return 1;
}

float exponential(float x, int n) {
	printf("Exp(%lf):\n", x);

	float result = 0.0;
	float power = 1.0;
	int fact = 1.0;

	for(int i = 0; i < n; i++) {
		if (i != 0) {
            power = power * x;
            fact = fact * i;
        }
		float part = power/fact;
		printf("n: %i; Zähler: %lf; Nenner: %i; Part: %lf\n", n, power, fact, part);
		result += part;
	}
	return result;
}