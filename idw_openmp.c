#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>  // Include OpenMP header

// Rest of the code

double inverse_distance_weighted_average(double *p, int n, int knn)
{
    // Rest of the code

    #pragma omp parallel for reduction(+:fi)
    for (int i = 0; i < knn; i++) {
        // Rest of the code
    }

    // Rest of the code

    return fi;
}

// Rest of the code
