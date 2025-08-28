//go:build windows
// +build windows

package powercontrols

import (
	"log"
	"os/exec"
)

// Sleep puts the computer to sleep (Windows).
// NOTE: this might make it hibernate instead
func SleepPC() {
	log.Println("Putting computer to sleep...")
	// This uses rundll32 to call Windows API for sleep

	err := exec.Command("rundll32.exe", "powrprof.dll,SetSuspendState", "0,1,0").Run()

	if err != nil {
		log.Printf("Failed to sleep: %v\n", err)
	}
}

// Lock locks the computer (Windows).
func LockPC() {
	log.Println("Locking computer...")
	err := exec.Command("rundll32.exe", "user32.dll,LockWorkStation").Run()
	if err != nil {
		log.Printf("Failed to lock: %v\n", err)
	}
}

// Shutdown shuts down the computer (Windows).
func ShutdownPC() {
	log.Println("Shutting down computer...")
	// /s = shutdown, /f = force, /t 0 = no delay
	err := exec.Command("shutdown", "/s", "/f", "/t", "0").Run()
	if err != nil {
		log.Printf("Failed to shutdown: %v\n", err)
	}
}

// ShowBlackScreen shows a black screen (not natively supported).
func ShowBlackScreen() {
	log.Println("Showing black screen (stub)...")
	// You’d likely need a helper app to overlay a fullscreen window.
}

// CloseBlackScreen closes the black screen (stub).
func CloseBlackScreen() {
	log.Println("Closing black screen (stub)...")
	// Matching helper app would close here.
}
