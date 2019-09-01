INSTALL_DIR := /usr/local/bin

ifndef COMPILER
  COMPILER := gfortran
endif

FFLAGS := -O2
FC     := ${COMPILER}

gdma:
	cd src; ${MAKE} FFLAGS="${FFLAGS}" FC=${FC}
	rm -f bin/gdma
	ln src/gdma bin

test:
	cd examples; ./run.tests

install:
	cp -p bin/gdma ${INSTALL_DIR}

clean:
	cd src; rm -f *.mod *.o

