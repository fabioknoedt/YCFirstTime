FKFirstTime
===========

A light-weight library to execute Objective-C codes only once in app life or version life. Execute code/blocks only for the first time the app runs, for example.

Usage
------------

Run a snippet of code only once per app installation.
Use this option, for example, to run a welcome dialog or create a initial database.

	[[YCFirstTime shared] executeOnce:^{
      
		/// Some code that should run only ONCE per app installation.
  
	} forKey:@"CHOOSE_AN_UNIQUE_KEY_FOR_THIS_SNIPPET"];

If you want to run a snippet of code every new version:
You could use this to show new features of a new version to the user.

	[[YCFirstTime shared] executeOncePerVersion:^{
      
		/// Some code that should run only ONCE per app version.
		/// This code will run in your version 1.0 and as well in the 1.1
                                
	} forKey:@"CHOOSE_AN_UNIQUE_KEY_FOR_THIS_SNIPPET"];
  
You also have the option to execute a snippet of code in the first time and then run another snippet of code from the second time on. This useful when you need to highlight some element for the first time but from this time on, you want to execute another code.

	[[YCFirstTime shared] executeOnce:^{
            
		/// Some code that should run only ONCE per app installation.
            
	} executeAfterFirstTime:^{
            
		/// Another piece of code to run from the SECOND time on.
            
	} forKey:@"CHOOSE_AN_UNIQUE_KEY_FOR_THIS_SNIPPET"];

And, finally, you can use the feature above with the version checker as well.

	[[YCFirstTime shared] executeOncePerVersion:^{
            
		/// Some code that should run only ONCE per app installation.
            
	} executeAfterFirstTime:^{
            
		/// Another piece of code to run from the SECOND time on.
            
	} forKey:@"CHOOSE_AN_UNIQUE_KEY_FOR_THIS_SNIPPET"];

Support
------------	
	
Runs fine in iOS6+ and requires ARC.
	
Contributors
------------

* Fabio Knoedt
