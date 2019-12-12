#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <mpi.h>

#define RED     "\x1b[31m"
#define GREEN   "\x1b[32m"
#define BLUE    "\x1b[34m"
#define RESET   "\x1b[0m"

static int64_t num_particles     = 25000;
static int     nodes_per_file    = 1;
static bool    aos               = true;
static bool    independent_IO    = false;
static char    output[1024]      = {0};

static int     parseAgrs  ( int argc, char **argv );
static void    printUsage ();
static int     fileWrite  (MPI_File fh, MPI_Offset offset, const void *buf,
			   int count, MPI_Datatype datatype, MPI_Status *status);
static int     fileRead   (MPI_File fh, MPI_Offset offset, void *buf,
			   int count, MPI_Datatype datatype, MPI_Status *status);
static void    uncachePFS (MPI_File *fh);

int main (int argc, char * argv[])
{
  int world_numtasks, world_myrank, mycolor, mykey, sub_numtasks, sub_myrank, file_id, err;
  int64_t sub_particles, tot_particles, particle_size, file_size, tot_size;
  int64_t scan_size = 0, offset;
  double start_time, end_time, tot_time, max_time;
  double io_bw;
  MPI_Comm sub_comm;
  MPI_File file_handle;
  MPI_Status status;
  char output_file[100];

  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &world_numtasks);
  MPI_Comm_rank(MPI_COMM_WORLD, &world_myrank);

  err = parseAgrs ( argc, argv );
  if ( err < 0 ) {
    if ( world_myrank == 0 ) {
      printUsage ();
    }
    MPI_Finalize ();
    exit (-1);
  }

  mycolor = world_myrank / nodes_per_file;
  mykey = world_myrank;
  
  MPI_Comm_split (MPI_COMM_WORLD, mycolor, mykey, &sub_comm);
  MPI_Comm_size(sub_comm, &sub_numtasks);
  MPI_Comm_rank(sub_comm, &sub_myrank);

  snprintf (output_file, 100, "/HACC-%s-%08d.dat", aos ? "AoS" : "SoA", mycolor);
  strcat (output, output_file);

  /*****************/
  /*     WRITE     */
  /*****************/
  float *xx, *yy, *zz, *vx, *vy, *vz, *phi;
  int64_t* pid;
  uint16_t* mask;

  xx = new float[num_particles];
  yy = new float[num_particles];
  zz = new float[num_particles];
  vx = new float[num_particles];
  vy = new float[num_particles];
  vz = new float[num_particles];
  phi = new float[num_particles];
  pid = new int64_t[num_particles];
  mask = new uint16_t[num_particles];

  for (uint64_t i = 0; i< num_particles; i++)
    {
      xx[i] = (float)i;
      yy[i] = (float)i;
      zz[i] = (float)i;
      vx[i] = (float)i;
      vy[i] = (float)i;
      vz[i] = (float)i;
      phi[i] = (float)i;
      pid[i] =  (int64_t)i;
      mask[i] = (uint16_t)world_myrank;
    }

  MPI_Allreduce(&num_particles, &sub_particles, 1, MPI_LONG_LONG, MPI_SUM, sub_comm);
  MPI_Allreduce(&num_particles, &tot_particles, 1, MPI_LONG_LONG, MPI_SUM, MPI_COMM_WORLD);
  
  particle_size = (7 * sizeof(float)) + sizeof(int64_t) + sizeof(uint16_t);
  file_size = particle_size * sub_particles;
  tot_size = particle_size * tot_particles;

  if (sub_myrank == 0) {
    MPI_File_open(MPI_COMM_SELF, output,
		  MPI_MODE_WRONLY | MPI_MODE_CREATE, MPI_INFO_NULL, &file_handle);
    MPI_File_set_size(file_handle, file_size);
    MPI_File_close (&file_handle);
  }

  MPI_Exscan (&num_particles, &scan_size, 1, MPI_LONG_LONG, MPI_SUM, sub_comm);
    
  if (0 == sub_myrank) {
    fprintf (stdout, GREEN "[INFO]" RESET " [%08d] miniHACC-MPIIO\n", mycolor);
    fprintf (stdout, GREEN "[INFO]" RESET " [%08d] Write output file (%s data layout)\n", mycolor, aos ? "AoS" : "SoA");
    fprintf (stdout, GREEN "[INFO]" RESET " [%08d] --> File: %s\n", mycolor, output);
    fprintf (stdout, GREEN "[INFO]" RESET " [%08d] --> I/O: %s\n", mycolor, independent_IO ? "Independent" : "Collective");
    fprintf (stdout, GREEN "[INFO]" RESET " [%08d] --> %lld particles per rank\n", mycolor, num_particles);
    fprintf (stdout, GREEN "[INFO]" RESET " [%08d] --> File size: %.2f MB (%lld particles)\n", 
	     mycolor, (double)file_size/(1024*1024), sub_particles);
  }

  start_time = MPI_Wtime();

  MPI_File_open(sub_comm, output,
		MPI_MODE_WRONLY, MPI_INFO_NULL, &file_handle);
  
  offset = aos ? scan_size * particle_size : scan_size * sizeof(float);

  fileWrite (file_handle, offset, xx, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  fileWrite (file_handle, offset, yy, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  fileWrite (file_handle, offset, zz, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  fileWrite (file_handle, offset, vx, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  fileWrite (file_handle, offset, vy, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  fileWrite (file_handle, offset, vz, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  fileWrite (file_handle, offset, phi, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(int64_t);

  fileWrite (file_handle, offset, pid, num_particles, MPI_LONG_LONG, &status);
  offset += aos ? num_particles * sizeof(int64_t) : (sub_particles - scan_size) * sizeof(int64_t) + scan_size * sizeof(uint16_t);

  fileWrite (file_handle, offset, mask, num_particles, MPI_UNSIGNED_SHORT, &status);
  
  MPI_File_close (&file_handle);

  end_time = MPI_Wtime();
  tot_time = end_time - start_time;
  MPI_Reduce (&tot_time, &max_time, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  
  if (0 == world_myrank) {
    io_bw = (double)tot_size / max_time / (1024 * 1024);
    fprintf (stdout, BLUE "[TIMING]" RESET " Write I/O bandwidth: %.2f MBps (%.2f MB in %.2f ms)\n",
	     io_bw, (double)tot_size/(1024*1024), max_time * 1000);
  }

  MPI_Barrier (MPI_COMM_WORLD);

  uncachePFS (&file_handle);

  /*****************/
  /*     READ      */
  /*****************/
  float *xx_r, *yy_r, *zz_r, *vx_r, *vy_r, *vz_r, *phi_r;
  int64_t* pid_r;
  uint16_t* mask_r;

  xx_r = new float[num_particles];
  yy_r = new float[num_particles];
  zz_r = new float[num_particles];
  vx_r = new float[num_particles];
  vy_r = new float[num_particles];
  vz_r = new float[num_particles];
  phi_r = new float[num_particles];
  pid_r = new int64_t[num_particles];
  mask_r = new uint16_t[num_particles];

  start_time = MPI_Wtime();

  MPI_File_open(sub_comm, output,
		MPI_MODE_RDONLY, MPI_INFO_NULL, &file_handle);

  if (0 == sub_myrank)
    fprintf (stdout, GREEN "[INFO]" RESET " [%08d] Read input file\n", mycolor);

  offset = aos ? scan_size * particle_size : scan_size * sizeof(float);

  MPI_File_read_at_all (file_handle, offset, xx_r, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  MPI_File_read_at_all (file_handle, offset, yy_r, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  MPI_File_read_at_all (file_handle, offset, zz_r, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  MPI_File_read_at_all (file_handle, offset, vx_r, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  MPI_File_read_at_all (file_handle, offset, vy_r, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  MPI_File_read_at_all (file_handle, offset, vz_r, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(float);

  MPI_File_read_at_all (file_handle, offset, phi_r, num_particles, MPI_FLOAT, &status);
  offset += aos ? num_particles * sizeof(float) : (sub_particles - scan_size) * sizeof(float) + scan_size * sizeof(int64_t);

  MPI_File_read_at_all (file_handle, offset, pid_r, num_particles, MPI_LONG_LONG, &status);
  offset += aos ? num_particles * sizeof(int64_t) : (sub_particles - scan_size) * sizeof(int64_t) + scan_size * sizeof(uint16_t);

  MPI_File_read_at_all (file_handle, offset, mask_r, num_particles, MPI_UNSIGNED_SHORT, &status);
  
  MPI_File_close (&file_handle);

  end_time = MPI_Wtime();
  tot_time = end_time - start_time;
  MPI_Reduce (&tot_time, &max_time, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  
  if (0 == world_myrank) {
    io_bw = (double)tot_size / max_time / (1024 * 1024);
    fprintf (stdout, BLUE "[TIMING]" RESET " Read I/O bandwidth: %.2f MBps (%.2f MB in %.2f ms)\n",
	     io_bw, (double)tot_size/(1024*1024), max_time * 1000);
  }

  /*****************/
  /* VERIFICATION  */
  /*****************/
  for (uint64_t i = 0; i< num_particles; i++) {
    if ((xx[i] != xx_r[i]) || (yy[i] != yy_r[i]) || (zz[i] != zz_r[i])
	|| (vx[i] != vx_r[i]) || (vy[i] != vy_r[i]) || (vz[i] != vz_r[i])
	|| (phi[i] != phi_r[i])|| (pid[i] != pid_r[i]) || (mask[i] != mask_r[i]))
      {
	fprintf (stdout, RED "[ERROR]" RESET " Wrong value for particle %d\n", i);
	MPI_Abort (MPI_COMM_WORLD, -1);
      }
  }

  if (0 == sub_myrank)
    fprintf (stdout, GREEN "[INFO]" RESET " [%08d] Content verified and consistent\n", mycolor);

  /*****************/
  /*      FREE     */
  /*****************/
  delete [] xx;
  delete [] xx_r;
  delete [] yy;
  delete [] yy_r;
  delete [] zz;
  delete [] zz_r;
  delete [] vx;
  delete [] vx_r;
  delete [] vy;
  delete [] vy_r;
  delete [] vz;
  delete [] vz_r;
  delete [] phi;
  delete [] phi_r;
  delete [] pid;
  delete [] pid_r;
  delete [] mask;
  delete [] mask_r;
  
  MPI_Finalize ();
}

static int parseAgrs ( int argc, char **argv ) {
  char flags[] = "p:f:iso:";
  int opt = 0;

  while ( ( opt = getopt ( argc, argv, flags ) ) != EOF ) {
    switch ( opt )
      {
      case('p'):
	sscanf ( optarg, "%lld", &num_particles );
	break;
      case('f'):
	sscanf ( optarg, "%d", &nodes_per_file );
	break;
      case('s'):
	aos = false;
	break;
      case('i'):
	independent_IO = true;
	break;
      case('o'):
	sprintf ( output, "%s", optarg );
	break;
      }
  }
  
  if ( num_particles <= 0 )
    return -1;

  if ( nodes_per_file < 1 )
    return -1;
  
  return 0;
}


void printUsage () {
  fprintf ( stderr, "Usage: ./miniHACC-AoS-MPIIO -p <particles per rank> -s <nodes per file> -s -i -o <output directory>\n" );
  fprintf ( stderr, "  -p : Number of particles per rank (38B/part., 25K part. ~= 1MB)\n" );
  fprintf ( stderr, "  -f : Number of nodes per file. 1=One file per process. #proc=Single shared file\n" );
  fprintf ( stderr, "  -s : Structure of arrays data layout (default: array of structures)\n" );
  fprintf ( stderr, "  -i : Independent I/O. Collective I/O by default\n" );
  fprintf ( stderr, "  -o : Path of the output directory\n" );
}


int fileWrite (MPI_File fh, MPI_Offset offset, const void *buf,
	       int count, MPI_Datatype datatype, MPI_Status *status) {
  int err;
  
  if ( independent_IO )
    err = MPI_File_write_at (fh, offset, buf, count, datatype, status);
  else
    err = MPI_File_write_at_all (fh, offset, buf, count, datatype, status);

  return err;
}


int fileRead (MPI_File fh, MPI_Offset offset, void *buf,
	      int count, MPI_Datatype datatype, MPI_Status *status) {
  int err;
  
  if ( independent_IO )
    err = MPI_File_read_at (fh, offset, buf, count, datatype, status);
  else
    err = MPI_File_read_at_all (fh, offset, buf, count, datatype, status);

  return err;
}


void uncachePFS (MPI_File *fh) {
  float *tmp, *tmp_r;
  int64_t elements = 25000, tot_elements, offset; 
  int i, world_myrank, world_numtasks;
  MPI_Status status;
  char output_file[100];
  char output_tmp[1024];
  
  MPI_Comm_size(MPI_COMM_WORLD, &world_numtasks);
  MPI_Comm_rank(MPI_COMM_WORLD, &world_myrank);

  snprintf (output_file, 100, "/uncachePFS.tmp");
  strcpy (output_tmp, output);
  strcat (output_tmp, output_file);
  
  tmp   = new float[elements];
  tmp_r = new float[elements];
  
  for (i = 0; i< elements; i++)
    tmp[i] = (float)i;
  
  MPI_Allreduce(&elements, &tot_elements, 1, MPI_LONG_LONG, MPI_SUM, MPI_COMM_WORLD);
  MPI_Exscan (&elements, &offset, 1, MPI_LONG_LONG, MPI_SUM, MPI_COMM_WORLD);

  MPI_File_open(MPI_COMM_WORLD, output_tmp, MPI_MODE_WRONLY, MPI_INFO_NULL, fh);

  MPI_File_write_at_all (*fh, offset, tmp, elements, MPI_FLOAT, &status);
  MPI_File_read_at_all (*fh, offset, tmp_r, elements, MPI_FLOAT, &status);

  MPI_File_close (fh);

  MPI_File_delete (output_tmp, MPI_INFO_NULL);

  if ( world_myrank == 0)
    fprintf (stdout, GREEN "[INFO]" RESET " Uncaching PFS while writing temporary file\n");
    
  delete[] tmp;
  delete[] tmp_r;

  MPI_Barrier (MPI_COMM_WORLD);
}
