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
	case "LEFT":
		robotgo.KeyTap("left")
	case "RIGHT":
		robotgo.KeyTap("right")
	case "SPACE":
		robotgo.KeyTap("space")
	case "F":
		robotgo.KeyTap("f")
	case "M":
		robotgo.KeyTap("m")
	case "N":
		robotgo.KeyTap("n")
	case "S":
		robotgo.KeyTap("s")
	default:
		log.Printf("Unknown special key: %s", key)
	}
}
