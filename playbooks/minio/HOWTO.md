# MinIO

## Distributed Server

To start one instance of MinIO:

```shell
module load sarus
sarus pull minio/minio
sarus pull minio/mc
```

Then, from the storage nodes that are part of the object store:

```shell
module load sarus
export MINIO_ACCESS_KEY=DRP-CSCS
export MINIO_SECRET_KEY=DRP-CSCS
srun --pack-group=1 sarus run --mount=type=bind,source=/mnt,destination=/mnt minio/minio server http://nid000{52...53}/mnt/nvme{0...2}n1/MinIO-{0...11}
```

## Client

```shell
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
./mc alias set minio http://nid00052:9000 DRP-CSCS DRP-CSCS
./mc ls minio
```

Run the S3-benchmark

```shell
wget -c https://github.com/minio/warp/releases/download/v0.3.45/warp_0.3.45_Linux_x86_64.tar.gz -O - | tar -xz warp
./warp mixed --host=nid000{52...53}:9000 --access-key=DRP-CSCS --secret-key=DRP-CSCS --autoterm
```

Output should look like:

```
Throughput 2514.5MiB/s within 7.500000% for 10.29s. Assuming stability. Terminating benchmark.░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░┃  12.33%
warp: Benchmark data written to "warp-mixed-2021-04-01[164810]-lhfi.csv.zst"                                                                                                                                              
Mixed operations.
Operation: DELETE, 10%, Concurrency: 20, Duration: 36s.
 * Throughput: 58.38 obj/s

Operation: GET, 45%, Concurrency: 20, Duration: 36s.
 * Throughput: 2624.48 MiB/s, 262.45 obj/s

Operation: PUT, 15%, Concurrency: 20, Duration: 36s.
 * Throughput: 875.33 MiB/s, 87.53 obj/s

Operation: STAT, 30%, Concurrency: 20, Duration: 36s.
 * Throughput: 174.96 obj/s

Cluster Total: 3496.87 MiB/s, 583.02 obj/s over 37s.
```
