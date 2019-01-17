INSTALL_DIR := /usr/local/bin

FFLAGS := -O2
FC     := gfortran

gdma:
	cd src; ${MAKE} FFLAGS=${FFLAGS} FC=${FC}
	rm -f bin/gdma
	ln src/gdma bin

test:
	cd examples; ./run.tests

install:
	cp -p bin/gdma ${INSTALL_DIR}

