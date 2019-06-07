#include <stdio.h>
#include <math.h>

int fact (int parameter);
float power(float base, int exponent);
float exponential(float x, float n);

/*
int getIterations(float x) {
	if (x < 14) return 34;
	else return 400/(x+10) + 14;
} */

int main() {
	float parameter = 14.0;
	float iterations = 34;
	if (parameter >= 14) iterations = 400/ (parameter + 10) + 14;

	float result = exponential(parameter, iterations);
	printf("%i iterations\n", iterations);
	printf("Result: %lf\n", result);
	printf("Real result: %lf", exp(parameter));
	
	return 1;
}

float exponential(float x, float n) {
	printf("Exp(%lf):\n", x);

	float result = 0.0;
	float power = 1.0;
	float fact = 1.0;

	for(float i = 0; i < n; i++) {
		if (i != 0) {
            power = power * x;
            fact = fact * i;
        }
		float part = power/fact;
		printf("n: %lf; Zähler: %lf; Nenner: %lf; Part: %lf\n", n, power, fact, part);
		result += part;
	}
	return result;
}