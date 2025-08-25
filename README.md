# PC Remote
Control your PC's mouse and volume using your mobile device

Application done with sockets using TCP and UDP for low-latency and instant feedback

## Quick Start
1. cd into client/
2. run `flutter pub get`
3. cd into server/
4. run `py server.py`

### If ios build not working, try this
flutter clean  
flutter pub get 
flutter build ios 

## To get single file server  
`pyinstaller --noconsole --onefile server.py --name pc_remote_server`  

run dist/server.exe

## To get release app(android apk)
`flutter build apk --release`

Then go to build/app/outputs/apk/release and take the release apk

## To get release app (ios)
flutter run --release

## To make ios build work when not plugged into usb debugging
flutter run --profile
 


# Client
This is the phone application

Done in flutter (first time)



# Server
This is the PC application

Done in Python with tkinter (high potential to switch to Golang for more efficient and faster processing of data)



## WARNING
You may need to debug wifi settings a couple times. The code is correct trust me 😊  
I've had my devices connected using wifi reserved ip address to help it work. If all else fails, try it out using a hotspot from phone to pc.  
Also, you might need o take off wifi-6 or just go to a really strong wifi connection point to ensure connection.

MY MAIN ISSUE WAS POOR WIFI CONNECTIVITY (It really makes nothing work). It made my phone and my computer keep switching between wifi hidden networks (like 2.4GHz or something)

If device not showing in xcode or flutter, try running flutter devices. Try removing trust from computer using your phone and then trusting it again. Ensure developer options are enabled.

ONE MORE THING  
Ensure that your server network is on discoverable. My windows PC was set on public network meaning it was automatically hiding itself from other devices on the network. Since I was home, I changed its network profile to private network and it worked instantly!
