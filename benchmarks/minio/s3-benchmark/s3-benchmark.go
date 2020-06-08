// s3-benchmark.go
// Copyright (c) 2017 Wasabi Technology, Inc.
// Forked and maintained by MinIO, Inc.

package main

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha1"
	"crypto/tls"
	"encoding/base64"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"math/rand"
	"net"
	"net/http"
	"os"
	"sort"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"code.cloudfoundry.org/bytefmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

// Global variables
var accessKey, secretKey, urlHost, bucket, region string
var durationSecs, threads, loops int
var objectSize uint64
var objectData []byte
var runningThreads, uploadCount, downloadCount, deleteCount, uploadSlowdownCount, downloadSlowdownCount, deleteSlowdownCount int64
var endtime, uploadFinish, downloadFinish, deleteFinish time.Time
var jsonPrint bool

type logMessage struct {
	LogTime       time.Time `json:"time"`
	Method        string    `json:"method"`
	Loop          int       `json:"loop"`
	Time          float64   `json:"timeTaken"`
	Objects       int64     `json:"totalObjects"`
	Speed         string    `json:"avgSpeed"`
	RawSpeed      uint64    `json:"rawSpeed"`
	Operations    float64   `json:"totalOperations"`
	SlowDownCount int64     `json:"slowDownCount"`
}

func (l logMessage) String() string {
	if l.Speed != "" {
		return fmt.Sprintf("%s Loop %d: %s time %.1f secs, objects = %d, speed = %sB/sec, %.1f operations/sec.",
			l.LogTime.Format(http.TimeFormat), l.Loop, l.Method, l.Time, l.Objects, l.Speed, l.Operations)
	}
	return fmt.Sprintf("%s Loop %d: %s time %.1f secs, %.1f operations/sec.",
		l.LogTime.Format(http.TimeFormat), l.Loop, l.Method, l.Time, l.Operations)
}

func (l logMessage) JSON() string {
	data, err := json.Marshal(&l)
	if err != nil {
		panic(err)
	}
	return string(data)
}

var logfile *os.File

func init() {
	logfile, _ = os.OpenFile("benchmark.log", os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0666)
}

func logit(l logMessage) {
	var msg string
	if jsonPrint {
		msg = l.JSON()
	} else {
		msg = l.String()
	}
	fmt.Println(msg)
	if logfile != nil {
		logfile.WriteString(msg + "\n")
	}
}

// HTTPTransport - Our HTTP transport used for the roundtripper below
var HTTPTransport http.RoundTripper = &http.Transport{
	Proxy: http.ProxyFromEnvironment,
	Dial: (&net.Dialer{
		Timeout:   30 * time.Second,
		KeepAlive: 30 * time.Second,
	}).Dial,
	TLSHandshakeTimeout:   10 * time.Second,
	ExpectContinueTimeout: 0,
	// Allow an unlimited number of idle connections
	MaxIdleConnsPerHost: 4096,
	MaxIdleConns:        0,
	// But limit their idle time
	IdleConnTimeout: time.Minute,
	// Ignore TLS errors
	TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
}

var httpClient = &http.Client{Transport: HTTPTransport}

func getS3Client() *s3.S3 {
	// Build our config
	creds := credentials.NewStaticCredentials(accessKey, secretKey, "")
	loglevel := aws.LogOff
	// Build the rest of the configuration
	awsConfig := &aws.Config{
		Region:               aws.String(region),
		Endpoint:             aws.String(urlHost),
		Credentials:          creds,
		LogLevel:             &loglevel,
		S3ForcePathStyle:     aws.Bool(true),
		S3Disable100Continue: aws.Bool(true),
		// Comment following to use default transport
		HTTPClient: &http.Client{Transport: HTTPTransport},
	}
	session := session.New(awsConfig)
	client := s3.New(session)
	if client == nil {
		log.Fatalf("FATAL: Unable to create new client.")
	}
	// Return success
	return client
}

func createBucket(ignore_errors bool) {
	// Get a client
	client := getS3Client()
	// Create our bucket (may already exist without error)
	in := &s3.CreateBucketInput{Bucket: aws.String(bucket)}
	if _, err := client.CreateBucket(in); err != nil {
		if awsErr, ok := err.(awserr.Error); ok {
			switch awsErr.Code() {
			case "BucketAlreadyOwnedByYou":
				fallthrough
			case "BucketAlreadyExists":
				return
			}
		}
		log.Fatalf("FATAL: Unable to create bucket %s (is your access and secret correct?): %v", bucket, err)
	}
}

func deleteAllObjects() {
	// Get a client
	client := getS3Client()
	// Use multiple routines to do the actual delete
	var doneDeletes sync.WaitGroup
	// Loop deleting reading as big a list as we can
	var keyMarker *string
	var err error
	for loop := 1; ; loop++ {
		// Delete all the existing objects and versions in the bucket
		in := &s3.ListObjectsInput{Bucket: aws.String(bucket), Marker: keyMarker, MaxKeys: aws.Int64(1000)}
		if listObjects, listErr := client.ListObjects(in); listErr == nil {
			delete := &s3.Delete{Quiet: aws.Bool(true)}
			for _, version := range listObjects.Contents {
				delete.Objects = append(delete.Objects, &s3.ObjectIdentifier{Key: version.Key})
			}
			if len(delete.Objects) > 0 {
				// Start a delete routine
				doDelete := func(bucket string, delete *s3.Delete) {
					if _, e := client.DeleteObjects(
						&s3.DeleteObjectsInput{
							Bucket: aws.String(bucket),
							Delete: delete,
						}); e != nil {
						err = fmt.Errorf("DeleteObjects unexpected failure: %s", e.Error())
					}
					doneDeletes.Done()
				}
				doneDeletes.Add(1)
				go doDelete(bucket, delete)
			}
			// Advance to next versions
			if listObjects.IsTruncated == nil || !*listObjects.IsTruncated {
				break
			}
			keyMarker = listObjects.NextMarker
		} else {
			// The bucket may not exist, just ignore in that case
			if strings.HasPrefix(listErr.Error(), "NoSuchBucket") {
				return
			}
			err = fmt.Errorf("ListObjectVersions unexpected failure: %v", listErr)
			break
		}
	}
	// Wait for deletes to finish
	doneDeletes.Wait()
	// If error, it is fatal
	if err != nil {
		log.Fatalf("FATAL: Unable to delete objects from bucket: %v", err)
	}
}

// canonicalAmzHeaders -- return the x-amz headers canonicalized
func canonicalAmzHeaders(req *http.Request) string {
	// Parse out all x-amz headers
	var headers []string
	for header := range req.Header {
		norm := strings.ToLower(strings.TrimSpace(header))
		if strings.HasPrefix(norm, "x-amz") {
			headers = append(headers, norm)
		}
	}
	// Put them in sorted order
	sort.Strings(headers)
	// Now add back the values
	for n, header := range headers {
		headers[n] = header + ":" + strings.Replace(req.Header.Get(header), "\n", " ", -1)
	}
	// Finally, put them back together
	if len(headers) > 0 {
		return strings.Join(headers, "\n") + "\n"
	}
	return ""
}

func hmacSHA1(key []byte, content string) []byte {
	mac := hmac.New(sha1.New, key)
	mac.Write([]byte(content))
	return mac.Sum(nil)
}

func setSignature(req *http.Request) {
	// Setup default parameters
	dateHdr := time.Now().UTC().Format(time.RFC1123)
	req.Header.Set("X-Amz-Date", dateHdr)
	// Get the canonical resource and header
	canonicalResource := req.URL.EscapedPath()
	canonicalHeaders := canonicalAmzHeaders(req)
	stringToSign := req.Method + "\n" + req.Header.Get("Content-MD5") + "\n" + req.Header.Get("Content-Type") + "\n\n" +
		canonicalHeaders + canonicalResource
	hash := hmacSHA1([]byte(secretKey), stringToSign)
	signature := base64.StdEncoding.EncodeToString(hash)
	req.Header.Set("Authorization", fmt.Sprintf("AWS %s:%s", accessKey, signature))
}

func runUpload(threadNum int) {
	for time.Now().Before(endtime) {
		objnum := atomic.AddInt64(&uploadCount, 1)
		fileobj := bytes.NewReader(objectData)
		prefix := fmt.Sprintf("%s/%s/Object-%d", urlHost, bucket, objnum)
		req, _ := http.NewRequest(http.MethodPut, prefix, fileobj)
		req.Header.Set("Content-Length", strconv.FormatUint(objectSize, 10))
		setSignature(req)
		if resp, err := httpClient.Do(req); err != nil {
			log.Fatalf("FATAL: Error uploading object %s: %v", prefix, err)
		} else if resp != nil && resp.StatusCode != http.StatusOK {
			if resp.StatusCode == http.StatusServiceUnavailable {
				atomic.AddInt64(&uploadSlowdownCount, 1)
				atomic.AddInt64(&uploadCount, -1)
			} else {
				fmt.Printf("Upload status %s: resp: %+v\n", resp.Status, resp)
				if resp.Body != nil {
					body, _ := ioutil.ReadAll(resp.Body)
					fmt.Printf("Body: %s\n", string(body))
				}
			}
		}
	}
	// Remember last done time
	uploadFinish = time.Now()
	// One less thread
	atomic.AddInt64(&runningThreads, -1)
}

func runDownload(threadNum int) {
	for time.Now().Before(endtime) {
		atomic.AddInt64(&downloadCount, 1)
		objnum := rand.Int63n(uploadCount) + 1
		prefix := fmt.Sprintf("%s/%s/Object-%d", urlHost, bucket, objnum)
		req, _ := http.NewRequest(http.MethodGet, prefix, nil)
		setSignature(req)
		if resp, err := httpClient.Do(req); err != nil {
			log.Fatalf("FATAL: Error downloading object %s: %v", prefix, err)
		} else if resp != nil && resp.Body != nil {
			if resp.StatusCode == http.StatusServiceUnavailable {
				atomic.AddInt64(&downloadSlowdownCount, 1)
				atomic.AddInt64(&downloadCount, -1)
			} else {
				io.Copy(ioutil.Discard, resp.Body)
			}
		}
	}
	// Remember last done time
	downloadFinish = time.Now()
	// One less thread
	atomic.AddInt64(&runningThreads, -1)
}

func runDelete(threadNum int) {
	for {
		objnum := atomic.AddInt64(&deleteCount, 1)
		if objnum > uploadCount {
			break
		}
		prefix := fmt.Sprintf("%s/%s/Object-%d", urlHost, bucket, objnum)
		req, _ := http.NewRequest(http.MethodDelete, prefix, nil)
		setSignature(req)
		if resp, err := httpClient.Do(req); err != nil {
			log.Fatalf("FATAL: Error deleting object %s: %v", prefix, err)
		} else if resp != nil && resp.StatusCode == http.StatusServiceUnavailable {
			atomic.AddInt64(&deleteSlowdownCount, 1)
			atomic.AddInt64(&deleteCount, -1)
		}
	}
	// Remember last done time
	deleteFinish = time.Now()
	// One less thread
	atomic.AddInt64(&runningThreads, -1)
}

func main() {
	// Parse command line
	myflag := flag.NewFlagSet("myflag", flag.ExitOnError)
	myflag.BoolVar(&jsonPrint, "j", false, "Log output in JSON format")
	myflag.StringVar(&accessKey, "a", "Q3AM3UQ867SPQQA43P2F", "Access key")
	myflag.StringVar(&secretKey, "s", "zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG", "Secret key")
	myflag.StringVar(&urlHost, "u", "https://play.min.io", "URL for host with method prefix")
	myflag.StringVar(&bucket, "b", "s3-benchmark", "Bucket for testing")
	myflag.StringVar(&region, "r", "us-east-1", "Region for testing")
	myflag.IntVar(&durationSecs, "d", 60, "Duration of each test in seconds")
	myflag.IntVar(&threads, "t", 1, "Number of threads to run")
	myflag.IntVar(&loops, "l", 1, "Number of times to repeat test")
	var sizeArg string
	myflag.StringVar(&sizeArg, "z", "1M", "Size of objects in bytes with postfix K, M, and G")
	if err := myflag.Parse(os.Args[1:]); err != nil {
		os.Exit(1)
	}

	// Hello
	if !jsonPrint {
		fmt.Println("S3 benchmark program v3.0")
	}

	// Check the arguments
	if accessKey == "" {
		log.Fatal("Missing argument -a for access key.")
	}
	if secretKey == "" {
		log.Fatal("Missing argument -s for secret key.")
	}
	var err error
	if objectSize, err = bytefmt.ToBytes(sizeArg); err != nil {
		log.Fatalf("Invalid -z argument for object size: %v", err)
	}

	type parameters struct {
		URLHost  string `json:"urlHost"`
		Bucket   string `json:"bucket"`
		Duration int    `json:"duration"`
		Threads  int    `json:"threads"`
		Loops    int    `json:"loops"`
		Size     string `json:"sizeArg"`
	}

	// Echo the parameters
	if !jsonPrint {
		fmt.Println(fmt.Sprintf("Parameters: url=%s, bucket=%s, duration=%d, threads=%d, loops=%d, size=%s",
			urlHost, bucket, durationSecs, threads, loops, sizeArg))
	} else {
		data, err := json.Marshal(parameters{
			URLHost:  urlHost,
			Bucket:   bucket,
			Duration: durationSecs,
			Threads:  threads,
			Loops:    loops,
			Size:     sizeArg,
		})
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(string(data))
	}

	// Initialize data for the bucket
	objectData = make([]byte, objectSize)
	rand.Read(objectData)

	// Create the bucket and delete all the objects
	createBucket(true)
	deleteAllObjects()

	// Loop running the tests
	for loop := 1; loop <= loops; loop++ {
		// reset counters
		uploadCount = 0
		uploadSlowdownCount = 0
		downloadCount = 0
		downloadSlowdownCount = 0
		deleteCount = 0
		deleteSlowdownCount = 0

		// Run the upload case
		runningThreads = int64(threads)
		starttime := time.Now()
		endtime = starttime.Add(time.Second * time.Duration(durationSecs))
		for n := 1; n <= threads; n++ {
			go runUpload(n)
		}

		// Wait for it to finish
		for atomic.LoadInt64(&runningThreads) > 0 {
			time.Sleep(time.Millisecond)
		}
		uploadTime := uploadFinish.Sub(starttime).Seconds()

		bps := float64(uint64(uploadCount)*objectSize) / uploadTime
		logit(logMessage{
			LogTime:       time.Now(),
			Loop:          loop,
			Method:        http.MethodPut,
			Time:          uploadTime,
			Objects:       uploadCount,
			Speed:         bytefmt.ByteSize(uint64(bps)),
			RawSpeed:      uint64(bps),
			Operations:    (float64(uploadCount) / uploadTime),
			SlowDownCount: uploadSlowdownCount,
		})

		// Run the download case
		runningThreads = int64(threads)
		starttime = time.Now()
		endtime = starttime.Add(time.Second * time.Duration(durationSecs))
		for n := 1; n <= threads; n++ {
			go runDownload(n)
		}

		// Wait for it to finish
		for atomic.LoadInt64(&runningThreads) > 0 {
			time.Sleep(time.Millisecond)
		}
		downloadTime := downloadFinish.Sub(starttime).Seconds()

		bps = float64(uint64(downloadCount)*objectSize) / downloadTime
		logit(logMessage{
			LogTime:       time.Now(),
			Loop:          loop,
			Method:        http.MethodGet,
			Time:          downloadTime,
			Objects:       downloadCount,
			Speed:         bytefmt.ByteSize(uint64(bps)),
			Operations:    (float64(downloadCount) / downloadTime),
			RawSpeed:      uint64(bps),
			SlowDownCount: downloadSlowdownCount,
		})

		// Run the delete case
		runningThreads = int64(threads)
		starttime = time.Now()
		endtime = starttime.Add(time.Second * time.Duration(durationSecs))
		for n := 1; n <= threads; n++ {
			go runDelete(n)
		}

		// Wait for it to finish
		for atomic.LoadInt64(&runningThreads) > 0 {
			time.Sleep(time.Millisecond)
		}
		deleteTime := deleteFinish.Sub(starttime).Seconds()

		logit(logMessage{
			LogTime:       time.Now(),
			Loop:          loop,
			Method:        http.MethodDelete,
			Time:          deleteTime,
			Operations:    (float64(uploadCount) / deleteTime),
			SlowDownCount: deleteSlowdownCount,
		})
	}

	// All done
	if !jsonPrint {
		fmt.Println("Benchmark completed.")
	}
	logfile.Close()
}
