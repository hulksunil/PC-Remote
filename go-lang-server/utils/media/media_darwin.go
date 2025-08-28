//go:build darwin
// +build darwin

package media

import (
	"fmt"
	"os/exec"
	"strconv"
	"strings"
)

// runAppleScript executes an AppleScript command
func runAppleScript(script string) {
	exec.Command("osascript", "-e", script).Run()
}

// getFrontApp returns the name of the frontmost application
func getFrontApp() string {
	out, err := exec.Command("osascript", "-e",
		`tell application "System Events" to get name of first application process whose frontmost is true`).Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}

// Media control functions
// PlayPause toggles play/pause for the frontmost media app or Safari video
func PlayPause() {
	app := getFrontApp()

	print("Front app:", app, "\n")
	switch app {
	case "Music", "iTunes":
		runAppleScript(`tell application "Music" to playpause`)
	case "Spotify":
		runAppleScript(`tell application "Spotify" to playpause`)
	case "Safari":
		// Press spacebar in front window (works for most HTML5 videos)
		runAppleScript(`tell application "Safari" to activate
delay 0.1
tell application "System Events" to keystroke " "`)
	default:
		fmt.Println("Front app is not recognized as a media player:", app)
	}
}

func NextTrack() {
	app := getFrontApp()
	switch app {
	case "Music", "iTunes":
		runAppleScript(`tell application "Music" to next track`)
	case "Spotify":
		runAppleScript(`tell application "Spotify" to next track`)
	default:
		fmt.Println("Front app is not recognized as a media player:", app)
	}
}

func PreviousTrack() {
	app := getFrontApp()
	switch app {
	case "Music", "iTunes":
		runAppleScript(`tell application "Music" to previous track`)
	case "Spotify":
		runAppleScript(`tell application "Spotify" to previous track`)
	default:
		fmt.Println("Front app is not recognized as a media player:", app)
	}
}

// amount to change volume by
var volumeStep = 2

func VolumeUp() {
	script := fmt.Sprintf(`set volume output volume ((output volume of (get volume settings)) + %d) --100 max`, volumeStep)
	runAppleScript(script)
}

func VolumeDown() {
	script := fmt.Sprintf(`set volume output volume ((output volume of (get volume settings)) - %d) --100 min`, volumeStep)
	runAppleScript(script)
}

func Mute() {
	// Check if currently muted
	checkScript := `output muted of (get volume settings)`
	out, err := exec.Command("osascript", "-e", checkScript).Output()
	if err != nil {
		fmt.Println("Error checking mute state:", err)
		return
	}

	state := strings.TrimSpace(string(out))
	if state == "true" {
		// Only unmute if currently muted
		unmuteScript := `set volume without output muted`
		err = exec.Command("osascript", "-e", unmuteScript).Run()
		if err != nil {
			fmt.Println("Error unmuting:", err)
		}
	} else {
		runAppleScript(`set volume with output muted`)
	}
}

func GetVolume() int {
	out, err := exec.Command("osascript", "-e", `output volume of (get volume settings)`).Output()
	if err != nil {
		return -1 // or handle error as needed
	}

	vol, err := strconv.Atoi(strings.TrimSpace(string(out)))
	if err != nil {
		return -1
	}

	return vol
}
