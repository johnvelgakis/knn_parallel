DIM ?= 16
KNN ?= 32
TRA ?= 1048576
QUE ?= 1024

LOW ?=  0
HIGH ?= 2

CC = clang
CFLAGS = -DPROBDIM=$(DIM) -DNNBS=$(KNN) -DTRAINELEMS=$(TRA) -DQUERYELEMS=$(QUE) -DLB=$(LOW) -DUB=$(HIGH) -g -ggdb -O3 -DSURROGATES -Wall
LDFLAGS = -lm -lomp
OPENMP_INCLUDE = -I/usr/local/opt/libomp/include
OPENMP_LIB = -L/usr/local/opt/libomp/lib
OPENMP_FLAGS = -Xpreprocessor -fopenmp -lomp

all: gendata myknn idw myknn_open idw_open

gendata: gendata.o
	$(CC) -o gendata gendata.o $(LDFLAGS)

gendata.o: gendata.c
	$(CC) $(CFLAGS) -c gendata.c

myknn: myknn.o
	$(CC) -o myknn myknn.o $(LDFLAGS)

myknn.o: myknn.c
	$(CC) $(CFLAGS) -c myknn.c

idw: idw.o
	$(CC) -o idw idw.o $(LDFLAGS)

idw.o: idw.c
	$(CC) $(CFLAGS) -c idw.c

myknn_open: myknn_open.o
	$(CC) -o myknn_open myknn_open.o $(LDFLAGS) $(OPENMP_LIB)

myknn_open.o: myknn_open.c
	$(CC) $(CFLAGS) $(OPENMP_FLAGS) $(OPENMP_INCLUDE) -c myknn_open.c


idw_open: idw_open.o
	$(CC) -o idw_open idw_open.o $(LDFLAGS) $(OPENMP_LIB)

idw_open.o: idw_open.c
	$(CC) $(CFLAGS) $(OPENMP_FLAGS) $(OPENMP_INCLUDE) -c idw_open.c

clean:
	rm -f myknn myknn_open idw idw_open gendata *.o
