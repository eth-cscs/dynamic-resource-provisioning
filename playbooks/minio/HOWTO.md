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
srun --pack-group=1 sarus run --mount=type=bind,source=/mnt,destination=/mnt minio/minio server http://nid000{52...55}/mnt/nvme{0...2}n1/MinIO-{0...1}
```

## Client

```shell
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
./mc alias set mdom http://nid00052:9000 $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
./mc ls minio
```

Run the S3-benchmark

```shell
wget -c https://github.com/minio/warp/releases/download/v0.3.45/warp_0.3.45_Linux_x86_64.tar.gz -O - | tar -xz warp
./warp mixed --host=nid000{52...55}:9000 --access-key=$MINIO_ACCESS_KEY --secret-key=$MINIO_SECRET_KEY --autoterm
```

Output should look like:

```
Throughput 206.3 objects/s within 7.500000% for 10.017s. Assuming stability. Terminating benchmark.░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░┃  12.00%
warp: Benchmark data written to "warp-mixed-2021-04-14[145015]-0rzO.csv.
Mixed operations.
Operation: DELETE, 10%, Concurrency: 20, Duration: 35s.
 * Throughput: 68.10 obj/s

Operation: GET, 45%, Concurrency: 20, Duration: 35s.
 * Throughput: 3076.02 MiB/s, 307.60 obj/s

Operation: PUT, 15%, Concurrency: 20, Duration: 35s.
 * Throughput: 1027.22 MiB/s, 102.72 obj/s

Operation: STAT, 30%, Concurrency: 20, Duration: 35s.
 * Throughput: 205.12 obj/s

Cluster Total: 4101.56 MiB/s, 683.34 obj/s over 36s.
```
