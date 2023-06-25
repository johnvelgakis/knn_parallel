DIM ?= 16
KNN ?= 32
TRA ?= 1048576
QUE ?= 1024

LOW ?=  0
HIGH ?= 2

CFLAGS  = -DPROBDIM=$(DIM) -DNNBS=$(KNN) -DTRAINELEMS=$(TRA) -DQUERYELEMS=$(QUE) -DLB=$(LOW) -DUB=$(HIGH) -g -ggdb -O3
CFLAGS += -DSURROGATES -Wall
CFLAGS += -Xpreprocessor -fopenmp

LDFLAGS += -lm -fopenmp

all: gendata myknn myknn_open

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
	gcc $(CFLAGS) -c myknn_open.c

clean:
	rm -f myknn myknn_open *.o gendata
