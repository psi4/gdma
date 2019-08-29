
gdma: gdma.o dma.o atom_grids.o input.o timing.o version.o
	${FC} ${FFLAGS} $^ -o gdma

%.o: %.f90 ${FRC}
	${FC} ${FFLAGS} -c $<

%.o: %.F90 ${FRC}
	${FC} ${FFLAGS} -c $<

gdma.o: dma.o atom_grids.o input.o timing.o version.mod
dma.o: atom_grids.o input.o

version.mod:  force
	./version.py ../VERSION version.f90 ${FC}
	$(FC) -c ./version.f90

force:
