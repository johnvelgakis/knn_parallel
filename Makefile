DIM ?= 16
KNN ?= 32
TRA ?= 1048576
QUE ?= 1024

LOW ?= 0
HIGH ?= 2

CFLAGS = -DPROBDIM=$(DIM) -DNNBS=$(KNN) -DTRAINELEMS=$(TRA) -DQUERYELEMS=$(QUE) -DLB=$(LOW) -DUB=$(HIGH) -g -ggdb -O3 -DSURROGATES -Wall
LDFLAGS = -lm

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
	clang -Xpreprocessor -fopenmp -lomp myknn_open.o -o myknn_open $(LDFLAGS)

myknn_open.o: myknn_open.c func.c
	clang -Xpreprocessor -fopenmp -c myknn_open.c $(CFLAGS)

idw_open: idw_open.o
	clang -Xpreprocessor -fopenmp -lomp idw_open.o -o idw_open $(LDFLAGS)

idw_open.o: idw_open.c func.c
	clang -Xpreprocessor -fopenmp -c idw_open.c $(CFLAGS)

clean:
	rm -f gendata myknn idw myknn_open idw_open *.o
