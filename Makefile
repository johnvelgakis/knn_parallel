DIM ?= 16
KNN ?= 32
TRA ?= 1048576
QUE ?= 1024

LOW ?= 0
HIGH ?= 2

CFLAGS = -DPROBDIM=$(DIM) -DNNBS=$(KNN) -DTRAINELEMS=$(TRA) -DQUERYELEMS=$(QUE) -DLB=$(LOW) -DUB=$(HIGH) -g -ggdb -O3 -DSURROGATES -Wall
LDFLAGS = -lm -L/usr/local/opt/libomp/lib
CPPFLAGS = -I/usr/local/opt/libomp/include

all: gendata myknn idw myknn_open idw_open

gendata: gendata.c
	clang $(CFLAGS) -c gendata.c
	clang -o gendata gendata.o $(LDFLAGS)

myknn: myknn.c func.c
	clang $(CFLAGS) -c myknn.c
	clang -c func.c
	clang -o myknn myknn.o func.o $(LDFLAGS)

idw: idw.c func.c
	clang $(CFLAGS) -c idw.c
	clang -c func.c
	clang -o idw idw.o func.o $(LDFLAGS)

myknn_open: myknn_open.c func.c
	clang -Xpreprocessor -fopenmp $(CPPFLAGS) -c myknn_open.c $(CFLAGS)
	clang -c func.c
	clang -Xpreprocessor -fopenmp -lomp myknn_open.o func.o -o myknn_open $(LDFLAGS)

idw_open: idw_open.c func.c
	clang -Xpreprocessor -fopenmp $(CPPFLAGS) -c idw_open.c $(CFLAGS)
	clang -c func.c
	clang -Xpreprocessor -fopenmp -lomp idw_open.o func.o -o idw_open $(LDFLAGS)

clean:
	rm -f gendata myknn idw myknn_open idw_open *.o
