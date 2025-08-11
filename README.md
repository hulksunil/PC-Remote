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

## To get official app (non-debug)
`flutter build apk --release`


Then go to build/app/outputs/apk/release and take the release apk

# Client
This is the phone application

Done in flutter (first time)



# Server
This is the PC application

Done in Python with tkinter (high potential to switch to Golang for more efficient and faster processing of data)

