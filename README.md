# HomeKit Sensor Test

An IOS app with basic features similar to the official Apple Home app.

Basic features such as:
-	Selecting, adding and removing a home and room. 
-	Adding and removing an accessory from a room.
-	Controlling basic functions of an accessory (e.g., turning on lights, motion detection duration, etc.)

Development was aided with Apple’s HomeKit Catalog app: 
-	https://github.com/ooper-shlab/HMCatalog-Swift3

App Notes:
- Importing provisioning profile might be necessary to build and run the project
- The app was developed primarily for an iPad interface.
- HomeKit Accessory Simulator is available for Xcode using an apple id account.
- Focus was later shifted to record the data received from the accessories and send them to a database on Sheridan’s server. 
  When a data is received from an accessory it is first stored in a local database using SQLite and then it is sent to the Sheridan server. 
  To upload data to the database use url: http://smarthome.fast.sheridanc.on.ca/HomeKitTest/uploadAccessoryData.php/post
- To send data to a server exception domains must be added/edited in the info.plist.

HomeKit Framework Notes:
- To use the HomeKit framework on a project make sure to enable it in the capabilities section.
- To access HomeKit Data on the users device privacy HomeKit usage description must be set in the info.plist.