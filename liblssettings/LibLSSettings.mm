#import <Preferences/Preferences.h>
#import <Foundation/Foundation.h>

@interface LibLSSettingsListController: PSListController {
}
-(NSArray*)lockscreenNames:(id)target;
-(NSArray*)lockscreenValues:(id)target;
@end


#define debug TRUE

@implementation LibLSSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LibLSSettings" target:self] retain];
	}
	return _specifiers;
}

-(NSArray*)lockscreenNames:(id)target{
//Create the initial array to return
NSMutableArray *namesArray = [NSMutableArray array];
	if(debug) NSLog(@"LibLSSettings: Running through directories for liblockscreen to check for lockscreens");
//Loop through the bundle
for(NSString *lsBundle in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/liblockscreen/Lockscreens/" error:nil]){
	//Check if the bundle has an info.plist, if not, probably shouldn't load it up.

	if(debug) NSLog(@"LibLSSettings: Checking %@", lsBundle);
	if(![lsBundle isEqual:@"SetupLS.bundle"]){
	if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/Library/liblockscreen/Lockscreens/%@/Info.plist", lsBundle]]){
		//It has it, grab the info.plist!
		NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/Library/liblockscreen/Lockscreens/%@/Info.plist", lsBundle]];

		//Determine if it has a CFBundleDisplayName, and if so, use that, otherwise use the folder bundle name without the .bundle extension.
		if([info valueForKey:@"CFBundleDisplayName"]){
			[namesArray addObject:[[info valueForKey:@"CFBundleDisplayName"] copy]];
			NSLog(@"LibLSDebug-Settings: Loading up: %@", [info valueForKey:@"CFBundleDisplayName"]);
		}
		else{
			if(debug) NSLog(@"LibLSSettings: No Info.plist found in %@", lsBundle);
			[namesArray addObject:[lsBundle stringByReplacingOccurrencesOfString:@".bundle" withString:@""]];
		}
		[info release];
	}
	else{
		if(debug) NSLog(@"LibLSSettings: Not adding %@ with path /Library/liblockscreen/Lockscreens/%@/Info.plist", lsBundle, lsBundle);
	}
	}
}


return namesArray;
}

-(NSArray*)lockscreenValues:(id)target{

//Create the initial array to return
NSMutableArray *valuesArray = [NSMutableArray array];

//Loop through the bundle
for(NSString *lsBundle in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/liblockscreen/Lockscreens/" error:nil]){
	//Check if the bundle has an info.plist, if not, probably shouldn't load it up.
	if(debug) NSLog(@"LibLSSettings: lockScreenValues: %@", lsBundle);
	if(![lsBundle isEqual:@"SetupLS.bundle"]){
	if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/Library/liblockscreen/Lockscreens/%@/Info.plist", lsBundle]]){
		if(debug) NSLog(@"LibLSSettings: Adding %@", lsBundle);
		[valuesArray addObject:lsBundle];

	}
	else{
		if(debug) NSLog(@"LibLSSettings: Not Adding %@ with path /Library/liblockscreen/Lockscreens/%@/Info.plist", lsBundle, lsBundle);
	}
}
}

return valuesArray;
}

@end

// vim:ft=objc
