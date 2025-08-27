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
	case "CTRL":
		robotgo.KeyToggle("ctrl", "down")
	case "CTRL_RELEASE":
		robotgo.KeyToggle("ctrl", "up")
	default:
		log.Printf("Unknown special key: %s", key)
	}
}