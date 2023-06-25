#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>  // Include OpenMP header

#ifndef PROBDIM
#define PROBDIM 2
#endif

#include "func.c"

static double **xdata;
static double ydata[TRAINELEMS];

#define MAX_NNB	256

double find_knn_value(double *p, int n, int knn)
{
	int nn_x[MAX_NNB];
	double nn_d[MAX_NNB];

	compute_knn_brute_force(xdata, p, TRAINELEMS, PROBDIM, knn, nn_x, nn_d); // brute-force /linear search

	int dim = PROBDIM;
	int nd = knn;   // number of points
	double xd[MAX_NNB*PROBDIM];   // points
	double fd[MAX_NNB];     // function values

	for (int i = 0; i < knn; i++) {
		fd[i] = ydata[nn_x[i]];
	}

	for (int i = 0; i < knn; i++) {
		for (int j = 0; j < PROBDIM; j++) {
			xd[i*dim+j] = xdata[nn_x[i]][j];
		}
	}

	double fi;

	fi = predict_value(dim, nd, xd, fd, p, nn_d);

	return fi;
}


int main(int argc, char *argv[])
{
    // Rest of the code

    double *y = malloc(QUERYELEMS*sizeof(double));

    // Rest of the code

    #pragma omp parallel for
    for (int i=0; i<QUERYELEMS; i++) {    /* requests */
        // Rest of the code
    }

    // Rest of the code

    return 0;
}
