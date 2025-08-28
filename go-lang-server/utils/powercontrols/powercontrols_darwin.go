//go:build darwin
// +build darwin

// Package powercontrols provides functions to control power settings on different platforms.
package powercontrols

import (
	"log"
	"os/exec"
)

// Sleep puts the computer to sleep.
func SleepPC() {
	log.Println("Putting computer to sleep...")
	exec.Command("pmset", "sleepnow").Run()
}

// Lock locks the computer.
func LockPC() {
	log.Println("Locking computer...")
	exec.Command("osascript", "-e", `tell application "System Events" to keystroke "q" using {control down, command down}`).Run()

}

// Shutdown shuts down the computer.
// NOTE: This will immediately shut down the computer without any confirmation.
// NOTE 2: This only works if run with sudo privileges.
func ShutdownPC() {
	log.Println("Shutting down computer...")
	exec.Command("shutdown", "-h", "now").Run()
}

// ShowBlackScreen shows a black screen.
func ShowBlackScreen() {
	log.Println("Showing black screen (stub)...")
	// exec.Command("pmset", "displaysleepnow").Run()
}

// CloseBlackScreen closes the black screen.
func CloseBlackScreen() {
	log.Println("Closing black screen (stub)...")
	// exec.Command("pmset", "displaysleepnow").Run()
}
