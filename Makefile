DIM ?= 16
KNN ?= 32
TRA ?= 1048576
QUE ?= 1024

LOW ?= 0
HIGH ?= 2

CFLAGS  = -DPROBDIM=$(DIM) -DNNBS=$(KNN) -DTRAINELEMS=$(TRA) -DQUERYELEMS=$(QUE) -DLB=$(LOW) -DUB=$(HIGH) -g -ggdb -O3
CFLAGS += -Wall
LDFLAGS += -lm

ifeq ($(OPENMP), 1)
	CFLAGS += -fopenmp
	LDFLAGS += -fopenmp
endif

all: gendata myknn myknn_open idw idw_open

gendata: gendata.o
	gcc -o gendata gendata.o $(LDFLAGS)

gendata.o: gendata.c func.c
	gcc $(CFLAGS) -c gendata.c

myknn: myknn.o
	gcc -o myknn myknn.o $(LDFLAGS)

myknn.o: myknn.c func.c
	gcc $(CFLAGS) -c myknn.c

myknn_open: myknn_open.o
	gcc -o myknn_open myknn_open.o $(LDFLAGS)

myknn_open.o: myknn_open.c func.c
	gcc $(CFLAGS) -fopenmp -c myknn_open.c

idw: idw.o
	gcc -o idw idw.o $(LDFLAGS)

idw.o: idw.c func.c
	gcc $(CFLAGS) -c idw.c

idw_open: idw_open.o
	gcc -o idw_open idw_open.o $(LDFLAGS)

idw_open.o: idw_open.c func.c
	gcc $(CFLAGS) -fopenmp -c idw_open.c

clean:
	rm -f gendata myknn myknn_open idw idw_open *.o
