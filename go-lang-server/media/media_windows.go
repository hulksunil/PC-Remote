//go:build windows
// +build windows

package media

import "golang.org/x/sys/windows"

// Import user32.dll functions
var (
    user32         = windows.NewLazySystemDLL("user32.dll")
    procKeybdEvent = user32.NewProc("keybd_event")
)

// Virtual-Key Codes (same as your Python constants)
const (
    KEYEVENTF_KEYUP    = 0x0002
    MEDIA_PLAY_PAUSE   = 0xB3
    MEDIA_NEXT_TRACK   = 0xB0
    MEDIA_PREV_TRACK   = 0xB1
    VK_VOLUME_MUTE     = 0xAD
    VK_VOLUME_DOWN     = 0xAE
    VK_VOLUME_UP       = 0xAF
)

// helper to simulate key press
func keybdEvent(bVk byte, bScan byte, dwFlags uint32, dwExtraInfo uintptr) {
    procKeybdEvent.Call(
        uintptr(bVk),
        uintptr(bScan),
        uintptr(dwFlags),
        dwExtraInfo,
    )
}

// Media control functions
func PlayPause() {
    keybdEvent(MEDIA_PLAY_PAUSE, 0, 0, 0)              // key down
    keybdEvent(MEDIA_PLAY_PAUSE, 0, KEYEVENTF_KEYUP, 0) // key up
}

func NextTrack() {
    keybdEvent(MEDIA_NEXT_TRACK, 0, 0, 0)
    keybdEvent(MEDIA_NEXT_TRACK, 0, KEYEVENTF_KEYUP, 0)
}

func PreviousTrack() {
    keybdEvent(MEDIA_PREV_TRACK, 0, 0, 0)
    keybdEvent(MEDIA_PREV_TRACK, 0, KEYEVENTF_KEYUP, 0)
}

func VolumeUp() {
    keybdEvent(VK_VOLUME_UP, 0, 0, 0)
    keybdEvent(VK_VOLUME_UP, 0, KEYEVENTF_KEYUP, 0)
}

func VolumeDown() {
    keybdEvent(VK_VOLUME_DOWN, 0, 0, 0)
    keybdEvent(VK_VOLUME_DOWN, 0, KEYEVENTF_KEYUP, 0)
}

func Mute() {
    keybdEvent(VK_VOLUME_MUTE, 0, 0, 0)
    keybdEvent(VK_VOLUME_MUTE, 0, KEYEVENTF_KEYUP, 0)
}

func GetVolume() int {
    return 50
}
