//+build !go1.12

package main

// This file is here to give a better hint in the error message
// when this project is built with a too old version of Go.

var _ = ThisProjectRequiresGo1·2OrHigher
