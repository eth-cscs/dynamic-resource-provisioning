# Introduction
s3-benchmark is a performance testing tool provided by Wasabi for capturing performance of S3 operations (PUT, GET, and DELETE) for objects. Besides the bucket configuration, the object size and number of threads can be varied for different tests.

# History
This project is a fork of upstream https://github.com/wasabi-tech/s3-benchmark, which is in-turn loosely based on the Nasuni (http://www6.nasuni.com/rs/nasuni/images/Nasuni-2015-State-of-Cloud-Storage-Report.pdf) performance benchmarking methodologies used to test the performance of different cloud storage providers

Two main changes which diverge from https://github.com/wasabi-tech/s3-benchmark are as shown below

- Deprecate calculating `Content-Md5` to speed up numbers on NVMe/flash based storage
- JSON formated output
- Rawspeed output support

# Prerequisites
To leverage this tool, the following prerequisites apply:
* Git development environment
* Ubuntu Linux shell programming skills
* Access to a Go 1.13 development system (only if the OS is not Ubuntu Linux 16.04)
* Access to the appropriate object storage servers to test.

# Building the Program
Obtain a local copy of the repository using the following git command with any directory that is convenient:

```
git clone https://github.com/minio/s3-benchmark.git
cd s3-benchmark; CGO_ENABLED=0 go install
```

You should see the following files in the s3-benchmark directory.
```
LICENSE	README.md s3-benchmark.go go.mod go.sum
```

If the test is being run on Ubuntu version 16.04 LTS (the current long term release), the binary
executable `s3-benchmark` will run the benchmark testing without having to build the executable.

Otherwise, to build the s3-benchmark executable, you must issue this following command:
```
CGO_ENABLED=0 go build --ldflags "-s -w"
```

# Command Line Arguments
Below are the command line arguments to the program (which can be displayed using -help):

```
  -a string (default "Q3AM3UQ867SPQQA43P2F")
        Access key
  -s string
        Secret key (default "zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG")
  -b string
        Bucket for testing (default "s3-benchmark")
  -d int
        Duration of each test in seconds (default 60)
  -l int
        Number of times to repeat test (default 1)
  -t int
        Number of threads to run (default 1)
  -u string
        URL for host with method prefix (default "https://play.min.io")
  -z string
        Size of objects in bytes with postfix K, M, and G (default "1M")
```

# Example Benchmark
Below is an example run of the benchmark for 10 threads with the default 1MB object size.  The benchmark reports
for each operation PUT, GET and DELETE the results in terms of data speed and operations per second.  The program
writes all results to the log file benchmark.log.

```
./s3-benchmark -a Q3AM3UQ867SPQQA43P2F -s zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG -b s3-benchmark -t 10
S3 benchmark program v2.0
Parameters: url=https://play.min.io, bucket=s3-benchmark, duration=60, threads=10, loops=1, size=1M
Loop 1: PUT time 60.8 secs, objects = 1086, speed = 17.8MB/sec, 17.8 operations/sec.
Loop 1: GET time 60.8 secs, objects = 804, speed = 13.2MB/sec, 13.2 operations/sec.
Loop 1: DELETE time 3.1 secs, 354.7 deletes/sec.
Benchmark completed.
```

# Note
Your performance testing benchmark results may vary most often because of limitations of your network connection to the cloud storage provider.  For more information, contact us at https://slack.min.io
