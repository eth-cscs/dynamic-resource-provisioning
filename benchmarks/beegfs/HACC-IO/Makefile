MPICXX      = CC
MPI_CFLAGS  = -g -O3
MPI_LDFLAGS =

all: miniHACC-MPIIO

miniHACC-MPIIO:miniHACC-MPIIO.cpp
	$(MPICXX) $(MPI_CFLAGS) $? -o $@ $(MPI_LDFLAGS)

clean:
	rm miniHACC-MPIIO

