//go:build windows || darwin
// +build windows darwin

package keyboard

import (
	"log"

	"github.com/go-vgo/robotgo"
)

func TypeText(text string) {
	robotgo.TypeStr(text)
}

func SpecialKey(key string) {
	switch key {
	case "BACKSPACE":
		robotgo.KeyTap("backspace")
	case "ENTER":
		robotgo.KeyTap("enter")
	case "ESCAPE":
		robotgo.KeyTap("escape")
	case "TAB":
		robotgo.KeyTap("tab")
	case "DELETE":
		robotgo.KeyTap("delete")
	case "CTRL":
		robotgo.KeyToggle("ctrl", "down")
	case "CTRL_RELEASE":
		robotgo.KeyToggle("ctrl", "up")
	case "SEEK_BACK_10":
		robotgo.KeyTap("left")
	case "SEEK_FORWARD_10":
		robotgo.KeyTap("right")
	case "SPACE":
		robotgo.KeyTap("space")
	case "TOGGLE_FULLSCREEN":
		robotgo.KeyTap("f")
	case "STREAM_MUTE":
		robotgo.KeyTap("m")
	case "NEXT_EPISODE":
		robotgo.KeyTap("n")
	case "SKIP_INTRO":
		robotgo.KeyTap("s")
	default:
		log.Printf("Unknown special key: %s", key)
	}
}
