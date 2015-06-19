YCFirstTime
===========
[![Pod Version](http://img.shields.io/cocoapods/v/YCFirstTime.svg?style=flat)](http://cocoadocs.org/docsets/YCFirstTime/)
[![Pod Platform](http://img.shields.io/cocoapods/p/YCFirstTime.svg?style=flat)](http://cocoadocs.org/docsets/YCFirstTime/)
[![Pod License](http://img.shields.io/cocoapods/l/YCFirstTime.svg?style=flat)](https://github.com/yuppiu/YCFirstTime/blob/master/LICENSE)
[![Dependency Status](https://www.versioneye.com/objective-c/YCFirstTime/1.1.2/badge.svg?style=flat)](https://www.versioneye.com/objective-c/YCFirstTime)
[![Reference Status](https://www.versioneye.com/objective-c/YCFirstTime/reference_badge.svg?style=flat)](https://www.versioneye.com/objective-c/YCFirstTime/references)

A light-weight library to execute Objective-C codes only once in app life or version life. Execute code/blocks only for the first time the app runs, for example.

Installation
------------

We recommend you to install this project using CocoaPods:

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like YCFirstTime in your projects.

#### Podfile

```ruby
platform :ios, '6.0'
pod "YCFirstTime"
```

Usage
------------

#### Run a snippet of code only once per app installation.
Use this option, for example, to run a welcome dialog or create a initial database.

	[[YCFirstTime shared] executeOnce:^{
      
		/// Some code that should run only ONCE per app installation.
  
	} forKey:@"CHOOSE_AN_UNIQUE_KEY_FOR_THIS_SNIPPET"];

#### Run a snippet of code every new app version:
You could use this to show new features of a new version to the user.

	[[YCFirstTime shared] executeOncePerVersion:^{
      
		/// Some code that should run only ONCE per app version.
		/// This code will run in your version 1.0 and as well in the 1.1
                                
	} forKey:@"CHOOSE_AN_UNIQUE_KEY_FOR_THIS_SNIPPET"];

#### Run a snippet of code every X days:
* User case 1: ask only one time for GPS approval (Location) every day or every second day.
* User case 2: ask only one time for Push notifications approval every 4 days.
* User case 3: ask to rate your app every 7 days.
* User case 4: ask to buy the PRO version every day.
* User case 5: ask for something else every X days/hours/minutes/seconds. The days parameter is a CGFloat, use like you want.

	
		[[YCFirstTime shared] executeOncePerInterval:^{
      
			/// Some code that should run only ONCE per app version.
			/// This code will run in your version 1.0 and as well in the 1.1
                                
		} forKey:@"CHOOSE_AN_UNIQUE_KEY_FOR_THIS_SNIPPET" withDaysInterval:2.0f];
  
#### Run a snippet of code for the first time and then run another snippet of code from the second time on.
This useful when you need to highlight some element for the first time but from this time on, you want to execute another code.

	[[YCFirstTime shared] executeOnce:^{
            
		/// Some code that should run only ONCE per app installation.
            
	} executeAfterFirstTime:^{
            
		/// Another piece of code to run from the SECOND time on.
            
	} forKey:@"CHOOSE_AN_UNIQUE_KEY_FOR_THIS_SNIPPET"];

#### And, finally, you can use the feature above with the version checker as well.

	[[YCFirstTime shared] executeOncePerVersion:^{
            
		/// Some code that should run only ONCE per app installation.
            
	} executeAfterFirstTime:^{
            
		/// Another piece of code to run from the SECOND time on.
            
	} forKey:@"CHOOSE_AN_UNIQUE_KEY_FOR_THIS_SNIPPET"];

#### Reset all executions

If you want to remove all previous executions and start from zero, you can call:

	[[YCFirstTime shared] reset];

Support
------------	
	
Runs fine in iOS6+ and requires ARC.
	
Contributors
------------

* [Fabio Knoedt](https://github.com/fabioknoedt)
<img align="right" src="https://travis-ci.com/img/made-in-berlin-badge.png" alt="Made in Berlin" />
