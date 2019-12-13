## Client

```shell
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
mc config host add minio http://148.187.92.53:9000 BLABLABLA BLABLABLA
mc admin info server minio
```

Run the S3-benchmark

```shell
git clone https://github.com/minio/s3-benchmark.git
cd s3-benchmark/
mc mb minio/s3-benchmark-bucket
srun -n1 ./s3-benchmark -a BLABLABLA -s BLABLABLA -b s3-benchmark-bucket -d 300 -l 1 -t 8 -u http://148.187.92.53:9000 -z 1G
```

Output should look like:

```
Parameters: url=http://148.187.92.53:9000, bucket=s3-benchmark-bucket, duration=300, threads=8, loops=10, size=1G
Thu, 21 Nov 2019 10:10:48 GMT Loop 1: PUT time 302.7 secs, objects = 473, speed = 1.6GB/sec, 1.6 operations/sec.
Thu, 21 Nov 2019 10:15:48 GMT Loop 1: GET time 300.9 secs, objects = 1270, speed = 4.2GB/sec, 4.2 operations/sec.
Thu, 21 Nov 2019 10:15:50 GMT Loop 1: DELETE time 1.3 secs, 363.7 operations/sec.
```
