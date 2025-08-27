package logger

import (
	"io"
	"log"
	"os"
)

// Init sets up logging to both console and file.
// Call this once at the start of your program.
func Init(logFile string) {
	// Open or create the log file
	file, err := os.OpenFile(logFile, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		log.Fatalf("Failed to open log file: %v", err)
	}

	// MultiWriter sends logs to both stdout and file
	mw := io.MultiWriter(os.Stdout, file)

	// Configure the default logger
	log.SetOutput(mw)
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
}
