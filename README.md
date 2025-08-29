# PC Remote
Control your PC's mouse and volume using your mobile device

Application done with sockets using TCP and UDP for low-latency and instant feedback

## Requirements
- Golang
- Flutter

## Quick Start
1. cd into client/
2. run `flutter pub get`
3. cd into go-lang-server/
4. run `go run .`


## Client
Phone application done in flutter (first time)

### Quick Start Client
1. `cd client`
2. `flutter clean`
3. `flutter pub get`
4. `flutter build`
5. `flutter run [--profile]`


## Server
PC Application done in Golang (also first time)

### Quick Start Server
1. `cd go-lang-server`
2. `go mod tidy`
3. `go run .`


## To get single file server
### Mac
`go build -o PCRemoteServer main.go`  
Place that binary in PCRemoteServer.app/Contents

### Windows
`go build -ldflags="-H=windowsgui" -o PCRemoteServer.exe main.go`

## To get release app
### android apk
`flutter build apk --release`  
Then go to build/app/outputs/apk/release and take the release apk

### ios
`flutter run --release`
 


## WARNING
You may need to debug wifi settings a couple times. The code is correct trust me 😊  
I've had my devices connected using wifi reserved ip address to help it work. If all else fails, try it out using a hotspot from phone to pc.  
Also, you might need o take off wifi-6 or just go to a really strong wifi connection point to ensure connection.

MY MAIN ISSUE WAS POOR WIFI CONNECTIVITY (It really makes nothing work). It made my phone and my computer keep switching between wifi hidden networks (like 2.4GHz or something)

If device not showing in xcode or flutter, try running flutter devices. Try removing trust from computer using your phone and then trusting it again. Ensure developer options are enabled.

ONE MORE THING  
Ensure that your server network is on discoverable. My windows PC was set on public network meaning it was automatically hiding itself from other devices on the network. Since I was home, I changed its network profile to private network and it worked instantly!
