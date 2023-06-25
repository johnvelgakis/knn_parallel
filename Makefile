DIM ?= 16
KNN ?= 32
TRA ?= 1048576
QUE ?= 1024

LOW ?=  0
HIGH ?= 2


CFLAGS  = -DPROBDIM=$(DIM) -DNNBS=$(KNN) -DTRAINELEMS=$(TRA) -DQUERYELEMS=$(QUE) -DLB=$(LOW) -DUB=$(HIGH) -g -ggdb -O3
CFLAGS += -DSURROGATES -Wall
LDFLAGS += -lm

all: gendata myknn idw

gendata: gendata.o
	gcc -o gendata gendata.o $(LDFLAGS)

gendata.o: gendata.c func.c
	gcc $(CFLAGS) -c gendata.c

myknn: myknn.o
	gcc -o myknn myknn.o $(LDFLAGS)

myknn.o: myknn.c func.c
	gcc $(CFLAGS) -c myknn.c

idw: idw.o
	gcc -o idw idw.o $(LDFLAGS)

idw.o: idw.c func.c
	gcc $(CFLAGS) -c idw.c

clean:
	rm -f myknn *.o gendata
