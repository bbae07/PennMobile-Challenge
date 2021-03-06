# PennMobile Challenge
A single-page dining app using api.pennlabs.org

## Installing

Since both the .xcworkspace and Pods are uploaded, the project should be able to compile.

In case it can't import some of the modules, run the following command using terminal. 

```
pod install
```
NOTE: This command requires CocoaPods to work correctly. Please make sure to always open the .xcworkspace file.

## Requirements
* iOS 11.0+ (WebView is deprecated - use of WebKitView in Storyboard requires iOS 11.0+)

## Features

* TableView of dining halls - picture, name, operating hours
* WebKitView of the dining hall that loads when the corresponding cell is pressed
* Shows alert when no network connection

## Screenshots
<img src="https://i.imgur.com/Dkiqo22.jpg" width="250">        <img src="https://i.imgur.com/oal19mU.png" width="250">        <img src="https://i.imgur.com/R8icYM7.png" width="250">

##
### Notes

* Did not use the MVC pattern since the project was simple enough.
* There is a bug regarding the network connectivity - when the user turns the internet back on after initially running the app without internet, the app doesn't have enough time to fetch data again and refresh when the user presses on the cell. (Is solved by forcing a delay on the WebKitView, but that makes the app clunky :crying_cat_face:) As for now, as long as the user loaded the data once, the data is cached and the alert works fine.
* Tested on iPhone 6, 8, X, iPad Air 2 simulators to check for scaling issues
