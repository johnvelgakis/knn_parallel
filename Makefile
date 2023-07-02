DIM ?= 16
KNN ?= 32
TRA ?= 1048576
QUE ?= 1024

LOW ?=  0
HIGH ?= 2

CFLAGS  = -DPROBDIM=$(DIM) -DNNBS=$(KNN) -DTRAINELEMS=$(TRA) -DQUERYELEMS=$(QUE) -DLB=$(LOW) -DUB=$(HIGH) -g -ggdb -O3
CFLAGS += -DSURROGATES -Wall
LDFLAGS += -lm

OPENMP_FLAGS = -Xpreprocessor -fopenmp
OPENMP_LIBS = -lomp
OPENMP_INCLUDE = -I/usr/local/opt/libomp/include
OPENMP_LIBDIR = -L/usr/local/opt/libomp/lib

all: gendata myknn idw myknn_open idw_open

gendata: gendata.o
	clang -o gendata gendata.o $(LDFLAGS)

gendata.o: gendata.c func.c
	clang $(CFLAGS) -c gendata.c

myknn: myknn.o
	clang -o myknn myknn.o $(LDFLAGS)

myknn.o: myknn.c func.c
	clang $(CFLAGS) -c myknn.c

idw: idw.o
	clang -o idw idw.o $(LDFLAGS)

idw.o: idw.c func.c
	clang $(CFLAGS) -c idw.c

myknn_open: myknn_open.o
	clang $(OPENMP_FLAGS) $(OPENMP_LIBS) myknn_open.o -o myknn_open $(LDFLAGS) $(OPENMP_LIBDIR)

myknn_open.o: myknn_open.c func.c
	clang $(CFLAGS) $(OPENMP_FLAGS) $(OPENMP_INCLUDE) -c myknn_open.c

idw_open: idw_open.o
	clang $(OPENMP_FLAGS) $(OPENMP_LIBS) idw_open.o -o idw_open $(LDFLAGS) $(OPENMP_LIBDIR)

idw_open.o: idw_open.c func.c
	clang $(CFLAGS) $(OPENMP_FLAGS) $(OPENMP_INCLUDE) -c idw_open.c

clean:
	rm -f gendata myknn idw myknn_open idw_open *.o
