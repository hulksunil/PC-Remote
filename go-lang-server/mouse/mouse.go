//go:build windows || darwin
// +build windows darwin

package mouse

import (
	"github.com/go-vgo/robotgo"
)

// Mouse
func MoveMouse(dx, dy int) {
	x, y := robotgo.Location()
	robotgo.Move(x+dx, y+dy)
}
func Scroll(dy int) {
	if dy < 0 {
		robotgo.ScrollDir(-dy, "down")
	} else {
		robotgo.ScrollDir(dy, "up")
	}
}
func MouseClick(left bool) {
    if left {
        robotgo.Click("left")
    } else {
        robotgo.Click("right")
    }
}
func MouseDown() {
    robotgo.Toggle("left", "down")
}
func MouseUp() {
    robotgo.Toggle("left", "up")
}