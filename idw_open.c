#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>
#define MAX_NNB 32
#ifndef PROBDIM
#define PROBDIM 2
#endif

#include "func.c"

double inverse_distance_weighted_average(double *p, int n, int knn)
{
    int nn_x[MAX_NNB];
    double nn_d[MAX_NNB];

    compute_knn_brute_force(xdata, p, TRAINELEMS, PROBDIM, knn, nn_x, nn_d); // brute-force /linear search

    int dim = PROBDIM;
    int nd = knn;   // number of points
    double xd[MAX_NNB*PROBDIM];   // points
    double fd[MAX_NNB];     // function values

    #pragma omp parallel for
    for (int i = 0; i < knn; i++) {
        fd[i] = ydata[nn_x[i]];
    }

    #pragma omp parallel for
    for (int i = 0; i < knn; i++) {
        for (int j = 0; j < PROBDIM; j++) {
            xd[i*dim+j] = xdata[nn_x[i]][j];
        }
    }

    double fi = 0.0;

    #pragma omp parallel for reduction(+:fi)
    for (int i = 0; i < knn; i++) {
        double weight = 1.0 / nn_d[i];  // Inverse distance weight
        fi += weight * fd[i];
    }

    return fi;
}

int main(int argc, char *argv[])
{
    double x[PROBDIM];

    if (argc != 3)
    {
        printf("usage: %s <trainfile> <queryfile>\n", argv[0]);
        exit(1);
    }

    char *trainfile = argv[1];
    char *queryfile = argv[2];

    double *xmem = (double *)malloc(TRAINELEMS*PROBDIM*sizeof(double));
    xdata = (double **)malloc(TRAINELEMS*sizeof(double *));
    for (int i = 0; i < TRAINELEMS; i++) xdata[i] = xmem + i*PROBDIM;

    FILE *fpin = open_traindata(trainfile);

    for (int i=0; i<TRAINELEMS; i++) {
        for (int k = 0; k < PROBDIM; k++)
            xdata[i][k] = read_nextnum(fpin);
#if defined(SURROGATES)
        ydata[i] = read_nextnum(fpin);
#else
        ydata[i] = 0;
#endif
    }
    fclose(fpin);

    fpin = open_querydata(queryfile);

    double *y = malloc(QUERYELEMS*sizeof(double));

    double t0, t1, t_first = 0.0, t_sum = 0.0;
    double sse = 0.0;
    double err, err_sum = 0.0;

    #pragma omp parallel for reduction(+:sse, err_sum) private(x, t0, t1) firstprivate(t_first)
    for (int i=0; i<QUERYELEMS; i++) {    /* requests */
        for (int k = 0; k < PROBDIM; k++)
            x[k] = read_nextnum(fpin);
#if defined(SURROGATES)
        y[i] = read_nextnum(fpin);
#else
        y[i] = 0.0;
#endif
        t0 = gettime();
        double yp = inverse_distance_weighted_average(x, PROBDIM, NNBS);
        t1 = gettime();
        t_sum += (t1-t0);
        if (i == 0) t_first = (t1-t0);

        double diff = y[i] - yp;
        sse += diff * diff;

        err = 100.0 * fabs(diff / y[i]);
        err_sum += err;
    }

    fclose(fpin);

    double mse = sse / QUERYELEMS;
    double ymean = compute_mean(y, QUERYELEMS);
    double var = compute_var(y, QUERYELEMS, ymean);
    double r2 = 1 - (mse / var);

    printf("Results for %d query points\n", QUERYELEMS);
    printf("APE = %.2f %%\n", err_sum / QUERYELEMS);
    printf("MSE = %.6f\n", mse);
    printf("R2 = 1 - (MSE/Var) = %.6lf\n", r2);

    t_sum = t_sum * 1000.0;         // convert to ms
    t_first = t_first * 1000.0;     // convert to ms
    printf("Total time = %lf ms\n", t_sum);
    printf("Time for 1st query = %lf ms\n", t_first);
    printf("Time for 2..N queries = %lf ms\n", t_sum - t_first);
    printf("Average time/query = %lf ms\n", (t_sum - t_first) / (QUERYELEMS - 1));

    return 0;
}
