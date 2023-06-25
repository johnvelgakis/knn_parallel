DIM ?= 16
KNN ?= 32
TRA ?= 1048576
QUE ?= 1024

LOW ?= 0
HIGH ?= 2

CC = gcc
CFLAGS  = -DPROBDIM=$(DIM) -DNNBS=$(KNN) -DTRAINELEMS=$(TRA) -DQUERYELEMS=$(QUE) -DLB=$(LOW) -DUB=$(HIGH) -g -ggdb -O3
CFLAGS += -Wall
LDFLAGS += -lm

ifeq ($(CC), clang)
	CFLAGS += -Xpreprocessor -fopenmp
	LDFLAGS += -lomp
else
	CFLAGS += -fopenmp
	LDFLAGS += -fopenmp
endif

all: gendata myknn myknn_open idw idw_open

gendata: gendata.o
	$(CC) -o gendata gendata.o $(LDFLAGS)

gendata.o: gendata.c func.c
	$(CC) $(CFLAGS) -c gendata.c

myknn: myknn.o
	$(CC) -o myknn myknn.o $(LDFLAGS)

myknn.o: myknn.c func.c
	$(CC) $(CFLAGS) -c myknn.c

myknn_open: myknn_open.o
	$(CC) -o myknn_open myknn_open.o $(LDFLAGS)

myknn_open.o: myknn_open.c func.c
	$(CC) $(CFLAGS) -c myknn_open.c

idw: idw.o
	$(CC) -o idw idw.o $(LDFLAGS)

idw.o: idw.c func.c
	$(CC) $(CFLAGS) -c idw.c

idw_open: idw_open.o
	$(CC) -o idw_open idw_open.o $(LDFLAGS)

idw_open.o: idw_open.c func.c
	$(CC) $(CFLAGS) -c idw_open.c

clean:
	rm -f gendata myknn myknn_open idw idw_open *.o
