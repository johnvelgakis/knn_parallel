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

gendata: gendata.o func.o
	clang -o gendata gendata.o func.o $(LDFLAGS)

gendata.o: gendata.c func.c
	clang $(CFLAGS) -c gendata.c

myknn: myknn.o func.o
	clang -o myknn myknn.o func.o $(LDFLAGS)

myknn.o: myknn.c func.c
	clang $(CFLAGS) -c myknn.c

idw: idw.o func.o
	clang -o idw idw.o func.o $(LDFLAGS)

idw.o: idw.c func.c
	clang $(CFLAGS) -c idw.c

myknn_open: myknn_open.o func.o
	clang -Xpreprocessor -fopenmp -lomp myknn_open.o func.o -o myknn_open $(LDFLAGS)

myknn_open.o: myknn_open.c func.c
	clang -Xpreprocessor -fopenmp $(CPPFLAGS) -c myknn_open.c $(CFLAGS)

idw_open: idw_open.o func.o
	clang -Xpreprocessor -fopenmp -lomp idw_open.o func.o -o idw_open $(LDFLAGS)

idw_open.o: idw_open.c func.c
	clang -Xpreprocessor -fopenmp $(CPPFLAGS) -c idw_open.c $(CFLAGS)

func.o: func.c func.h
	clang $(CFLAGS) -c func.c

clean:
	rm -f gendata myknn idw myknn_open idw_open *.o
