# PennMobile Challenge
A single-page dining app using api.pennlabs.org

## Installing

Since both the .xcworkspace and Pods files are uploaded, the project should be able to compile.

In case it can't import some of the modules, run the following command using terminal. 

```
pod install
```
NOTE: This command requires CocoaPods to work correctly. Please make sure to always open the .xcworkspace file.

## Features

* TableView of dining halls - picture, name, operating hours
* WebKitView or the dining hall that loads when the corresponding cell is pressed
* Shows alert when no network connection

##
### Notes

* Did not use the MVC pattern since the project was simple enough.
* There is an existing bug regarding the network connectivity - when the user turns the internet back on after initially running the app without internet, the app doesn't have enough time to fetch data again and refresh. (Is solved by forcing a delay on the WebKitView, but that makes the app clunky) 
