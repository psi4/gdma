INSTALL_DIR := /usr/local/bin

ifndef COMPILER
  COMPILER := gfortran
endif

FFLAGS := -O2
FC     := ${COMPILER}

gdma:
	cd src; ${MAKE} FFLAGS="${FFLAGS}" FC=${FC}
	mkdir -p bin
	rm -f bin/gdma
	ln src/gdma bin

test, tests:
	cd examples; ./gdma_tests.py

install:
	cp -p bin/gdma ${INSTALL_DIR}

clean:
	cd src; rm -f *.mod *.o

