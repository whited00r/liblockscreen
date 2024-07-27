#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
//#import <sys/sysctl.h>
#import "NSData+Base64.h"

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIGraphics.h>
#import <IOSurface/IOSurface.h>
#import <QuartzCore/QuartzCore2.h>
#import <objc/runtime.h>
#import <QuartzCore/CAAnimation.h>
#import <GraphicsServices/GSEvent.h>
#import <SpringBoard/SpringBoard.h> //Why can I not import this? 


//#import "LibLockscreen.h"


#define lsBundlePath @"/Library/liblockscreen/Lockscreens"
#define lsPrefsPath @"/var/mobile/Library/Preferences/com.grayd00r.liblockscreen.plist"
#define debug TRUE

#define libLSVersion 0.1f

#define KNORMAL  "\x1B[0m"
#define KRED  "\x1B[31m"
 
#define REDLog(fmt, ...) NSLog((@"%s" fmt @"%s"),KRED,##__VA_ARGS__,KNORMAL)

@interface BannerClass
@property(copy, nonatomic) NSString *section;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *subtitle;
@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *sectionDisplayName;
@property(copy, nonatomic) NSString *publisherBulletinID;
@property(copy, nonatomic) NSString *recordID;
@property(copy, nonatomic) NSString *sectionID;
@end


@interface SBAwayBulletinListController


@end

static NSString *lockscreenName = @"SetupLS/SetupLS.bundle";
static BOOL enabled = TRUE;



static inline BOOL isSlothSleeping(){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSData* fileData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.installerInfo.plist"];
NSData* signatureData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.installerInfo.plist.sig"];
//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIC6jCCAdICCQC2Zs0BWO+dxzANBgkqhkiG9w0BAQsFADA3MQswCQYDVQQGEwJV",
@"UzERMA8GA1UECgwIR3JheWQwMHIxFTATBgNVBAMMDGdyYXlkMDByLmNvbTAeFw0x",
@"NTEwMjQyMzEzNTNaFw0yMTA0MTUyMzEzNTNaMDcxCzAJBgNVBAYTAlVTMREwDwYD",
@"VQQKDAhHcmF5ZDAwcjEVMBMGA1UEAwwMZ3JheWQwMHIuY29tMIIBIjANBgkqhkiG",
@"9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsWSkvU26FQlb/IOE/QWKSyt3L5ekj+uvdVQq",
@"Eljo35THov9qKSqTMhdgMGkWDCVnqHsgf0+LjHZcFfz+cI1++1bsHCxvhJvytvYx",
@"uRQmjh0+yAA28729dDCKhawQ5YLHbVC+4tHoyHhvK+Ww0mx+g7Y8bVh+qc1EBf6h",
@"VOrspUvoGHLQYAa15Wbca8mmXVpxuZVfviLskqffKtsPVe7EIx8WwzrI+v9GOXNi",
@"dR/rBJDU91u1AQc5BT9zAOFlLZq4VJLdNNWCs4w58f6260xDiUjMEAKzILhSjmN/",
@"Dys9McYE9Iu3lGPvFn2HCfOOgTg1sv3Hz/mogL5sbjvCCtQnrwIDAQABMA0GCSqG",
@"SIb3DQEBCwUAA4IBAQBLQ+66GOyKY4Bxn9ODiVf+263iLTyThhppHMRguIukRieK",
@"sVvngMd6BQU4N4b0T+RdkZGScpAe3fdre/Ty9KIt/9E0Xqak+Cv+x7xCzEbee8W+",
@"sAV+DViZVes67XXV65zNdl5Nf7rqGqPSBLwuwB/M2mwmDREMJC90VRJBFj4QK14k",
@"FuwtTpNW44NUSQRUIxiZM/iSwy9rqekRRAKWo1s5BOLM3o7ph002BDyFPYmK5UAN",
@"EM/aKFGVMMwhAUHjgej5iEPxPuks+lGY1cKUAgoxbvXJakybosgmDFfSN+DMT7ZU",
@"HbUgWDsLySwU8/+C4vDP0pmMqJFgrna9Wto49JNz"]];//[NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer"];  

//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);

if(fileData && signatureData && certificateData){


SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);


//ONLY iOS6+ supports SHA256! >:(
uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1([fileData bytes], [fileData length], (unsigned char*)sha1HashDigest);

OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1,  (const uint8_t *)sha1HashDigest, (size_t)CC_SHA1_DIGEST_LENGTH,  (const uint8_t *)[signatureData bytes], (size_t)[signatureData length]);
CFRelease(publicKey);
CFRelease(trust);
CFRelease(secPolicy);
CFRelease(certificateFromFile);
[pool drain];
if (verficationResult == errSecSuccess){
	return TRUE;
}
else{
	return FALSE;
}



}
[pool drain];
return false;
}

//static OSStatus SecKeyRawVerify;
static inline BOOL isSlothAlive(){

if(!isSlothSleeping()){ //Don't want to pass this off as valid if the user didn't actually install via the grayd00r installer from the website.
	return FALSE;
}

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//Go from NSString to NSData
NSData *udidData = [[NSString stringWithFormat:@"%@-%@-%c%c%c%@-%@%c%c%@%@%c",[[UIDevice currentDevice] uniqueIdentifier],@"I",'l','i','k',@"e",@"s",'l','o',@"t",@"h",'s'] dataUsingEncoding:NSUTF8StringEncoding];
uint8_t digest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1(udidData.bytes, udidData.length, digest);
NSMutableString *hashedUDID = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
//To NSMutableString to calculate hash

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [hashedUDID appendFormat:@"%02x", digest[i]];
    }

//Then back to NSData for use in verification. -__-. I probably could skip a couple steps here...
NSData *hashedUDIDData = [hashedUDID dataUsingEncoding:NSUTF8StringEncoding];
NSData* signatureData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.activationKey"];

//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIDJzCCAg+gAwIBAgIJAPyR9ASSBbF9MA0GCSqGSIb3DQEBCwUAMCoxETAPBgNV",
@"BAoMCEdyYXlkMDByMRUwEwYDVQQDDAxncmF5ZDAwci5jb20wHhcNMTUxMDI4MDEy",
@"MjQyWhcNMjUxMDI1MDEyMjQyWjAqMREwDwYDVQQKDAhHcmF5ZDAwcjEVMBMGA1UE",
@"AwwMZ3JheWQwMHIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA",
@"94OZ2u2gJfdWgqWKV7yDY5pJXLZuRho6RO2OJtK04Xg3gUk46GBkYLo+/Z33rOvs",
@"XA041oAINRmdaiTDRa5VbGitQMYfObMz8m0lHQeb4/wwOasRMgAT2WCcKVulwpCG",
@"C7PiotF3F85VAuqJsbu1gxjJaQGIgR2L35LTR/fQq3N5+2+bsc0wUbPcLk7uhyYJ",
@"tna+CYRc+3qGRsv/t8MYF0T7LU2xwCcGV0phmr3er5ocAj9X57i92zYGMPlz8kMZ",
@"HfXqMova0prF9vuN7mo54kY+SF2rp/G/v+u5MicONpXwY6adJ0eIuXFjqsUjKTi6",
@"4Bjzhvf+Z6O5TARJzdVMqwIDAQABo1AwTjAdBgNVHQ4EFgQUDBxB98iHJnBsonVM",
@"LHF5WVXvhqgwHwYDVR0jBBgwFoAUDBxB98iHJnBsonVMLHF5WVXvhqgwDAYDVR0T",
@"BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEA4tyP/hMMJBYVFhRmdjAj9wnCr31N",
@"7tmyksLR76gqfLJL3obPDW+PIFPjdhBWNjcjNuw/qmWUXcEkqu5q9w9uMs5Nw0Z/",
@"prTbIIW861cZVck5dBlTkzQXySqgPwirXUKP/l/KrUYYV++tzLJb/ete2HHYwAyA",
@"2kl72gIxdqcXsChdO5sVB+Fsy5vZ2pw9Qan6TGkSIDuizTLIvbFuWw53MCBibdDn",
@"Y+CY2JrcX0/YYs4BSk5P6w/VInU5pn6afYew4XO7jRrGyIIPRJyR3faULqOLkenG",
@"Z+VNoXdO4+FShkEEfHb+Y8ie7E+bB0GBPb9toH/iH4cVS8ddaV3KiLkkJg=="]];//[NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer"];  

//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);

if(hashedUDIDData && signatureData && certificateData){


SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);


//ONLY iOS6+ supports SHA256! >:(
uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1([hashedUDIDData bytes], [hashedUDIDData length], (unsigned char*)sha1HashDigest);

OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1, (const uint8_t*)sha1HashDigest, (size_t)CC_SHA1_DIGEST_LENGTH,  (const uint8_t *)[signatureData bytes], (size_t)[signatureData length]);
CFRelease(publicKey);
CFRelease(trust);
CFRelease(secPolicy);
CFRelease(certificateFromFile);
[pool drain];

if (verficationResult == errSecSuccess){

	return TRUE;
}
else{
	return FALSE;
}



}
[pool drain];
return false;
}




static inline BOOL shouldShowActivationLS(){
	if(!isSlothAlive()){
		return TRUE;
	}

	//NSLog(@"Should show for update check");
	if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/Info.plist"]){
		NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/Info.plist"];
			//NSLog(@"Should for for update - found file...");
			if([prefs objectForKey:@"showForUpgrade"]){
				//NSLog(@"Should show for udpate - found key %i", [[prefs objectForKey:@"showForUpgrade"] boolValue]);
				BOOL returnValue = [[prefs objectForKey:@"showForUpgrade"] boolValue];
				[prefs release];
				return returnValue; //Why does this work.
				
			} 

		[prefs release];
	}



	return FALSE;
}

static inline BOOL setupLSBundleValid(){
	//We have to make sure the lockscreen we are loading is actually the right one!

	if(![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle"]){ //Don't even have the bloody lockscreen there. Why bother trying to load it.
		return FALSE;
	}
	
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSData* fileData = [NSData dataWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/SetupLS"];
NSData* signatureData = [NSData dataWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/SetupLS.sig"]; //Come at me bro. 
//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIC6jCCAdICCQC2Zs0BWO+dxzANBgkqhkiG9w0BAQsFADA3MQswCQYDVQQGEwJV",
@"UzERMA8GA1UECgwIR3JheWQwMHIxFTATBgNVBAMMDGdyYXlkMDByLmNvbTAeFw0x",
@"NTEwMjQyMzEzNTNaFw0yMTA0MTUyMzEzNTNaMDcxCzAJBgNVBAYTAlVTMREwDwYD",
@"VQQKDAhHcmF5ZDAwcjEVMBMGA1UEAwwMZ3JheWQwMHIuY29tMIIBIjANBgkqhkiG",
@"9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsWSkvU26FQlb/IOE/QWKSyt3L5ekj+uvdVQq",
@"Eljo35THov9qKSqTMhdgMGkWDCVnqHsgf0+LjHZcFfz+cI1++1bsHCxvhJvytvYx",
@"uRQmjh0+yAA28729dDCKhawQ5YLHbVC+4tHoyHhvK+Ww0mx+g7Y8bVh+qc1EBf6h",
@"VOrspUvoGHLQYAa15Wbca8mmXVpxuZVfviLskqffKtsPVe7EIx8WwzrI+v9GOXNi",
@"dR/rBJDU91u1AQc5BT9zAOFlLZq4VJLdNNWCs4w58f6260xDiUjMEAKzILhSjmN/",
@"Dys9McYE9Iu3lGPvFn2HCfOOgTg1sv3Hz/mogL5sbjvCCtQnrwIDAQABMA0GCSqG",
@"SIb3DQEBCwUAA4IBAQBLQ+66GOyKY4Bxn9ODiVf+263iLTyThhppHMRguIukRieK",
@"sVvngMd6BQU4N4b0T+RdkZGScpAe3fdre/Ty9KIt/9E0Xqak+Cv+x7xCzEbee8W+",
@"sAV+DViZVes67XXV65zNdl5Nf7rqGqPSBLwuwB/M2mwmDREMJC90VRJBFj4QK14k",
@"FuwtTpNW44NUSQRUIxiZM/iSwy9rqekRRAKWo1s5BOLM3o7ph002BDyFPYmK5UAN",
@"EM/aKFGVMMwhAUHjgej5iEPxPuks+lGY1cKUAgoxbvXJakybosgmDFfSN+DMT7ZU",
@"HbUgWDsLySwU8/+C4vDP0pmMqJFgrna9Wto49JNz"]];//[NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer"];  

//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);

if(fileData && signatureData && certificateData){


SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);


//ONLY iOS6+ supports SHA256! >:(
uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1([fileData bytes], [fileData length], (unsigned char*)sha1HashDigest);

OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1,  (const uint8_t *)sha1HashDigest, (size_t)CC_SHA1_DIGEST_LENGTH,  (const uint8_t *)[signatureData bytes], (size_t)[signatureData length]);
CFRelease(publicKey);
CFRelease(trust);
CFRelease(secPolicy);
CFRelease(certificateFromFile);
[pool drain];
if (verficationResult == errSecSuccess){
	return TRUE;
}
else{
	return FALSE;
}



}
[pool drain];
return false;
}

/*
@interface SBAwayView : UIView

@end

@interface SBApplication

@end

@interface SBApplicationController

@end
*/
/*
--------To add:----------
Bypass of lockscreen if all goes horribly wrong.  Disable and then respring pretty much, so it goes to the stock lockscreen.
Load up default hidden lockscreen for tweak activation. This is checked by signed file verifification, and also make sure the tweak itself or lockscreen
has not been modified/hooked into, and disable debugging loading on them.


--------To FIXME:----------
Make sure the device actually unloads the lockscreen on unlock. No need to keep it around then.


------Methods/code concepts/ideas to add-------
-receivedNotification:(LockscreenNotification*)notification{
	
}

-(void)loadCustomLockscreen{
	NSString *lockscreenBundleName = [prefs objectForKey:@"LockscreenBundle"];
	NSBundle *lsBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"/Library/liblockscreen/Lockscreens/%@", lockscreenBundleName]];
}

-(UIView*)initWithFrame:(CGRect)frame{
	
}


*/

@interface LockscreenNotification : NSObject{
NSMutableDictionary *notificationInfo;
}

@property (nonatomic, retain) NSMutableDictionary *notificationInfo;

@end


@implementation LockscreenNotification
@synthesize notificationInfo;

@end



@interface LibLockscreen : NSObject
@property (nonatomic, assign) UIView *view;
-(UIView *)initWithController:(id)controller;
-(float)liblsVersion;

//-----Passcode related stuff
-(void)passcodeFailed;
-(void)passcodeAccepted;
-(void)showPasscodeScreen:(BOOL)show; //Will be true for showing, will be false for hiding. 

//-----Clock methods
-(void)updateClockWithTime:(NSString*)time andDate:(NSString*) date; //Called when the time changes. (I think)

//----Media information is good right?
-(void)showMediaControls:(BOOL)show;
-(void)setArtist:(NSString *)artist;
-(void)setAlbum:(NSString *)album;

//-----Call related things
-(void)receivingCall;
-(void)makeEmergencyCall:(BOOL)call;
-(void)receivedNotification:(NSMutableDictionary *)notification;
-(void)unlockedDevice;
-(void)showBulletinView;
-(void)insertBulletinView;

-(BOOL)usesStockNotificationList;
-(void)configureAndPositionNotificationList;
@end


@protocol LibLockscreen
-(UIView *)initWithController:(id)controller;
-(float)liblsVersion; //In case there are updates to liblockscreen, I can provide legacy support for your plugin if I know the version.
@optional
@property (nonatomic, assign) UIView *view;
//-----Passcode related stuff
-(void)passcodeFailed;
-(void)passcodeAccepted;
-(void)showLockKeypad:(BOOL)show; //Will be true for showing, will be false for hiding. 
-(void)unlockedDevice; //Called after the device unlocks
//-----Clock methods
-(void)updateClockWithTime:(NSString*)time andDate:(NSString*)date; //Called when the time changes.

//----Media information is good right?
-(void)showMediaControls:(BOOL)show;
-(void)nowPlayingInfoChanged;

//-----Call related things
-(void)receivingCall;
-(void)makeEmergencyCall:(BOOL)call;


//-----Notification related things
-(void)receivedNotification:(NSMutableDictionary *)notification;
-(BOOL)usesStockNotificationList;
-(void)showBulletinView; //Both called when the bulletin view should be shown/added I guess?
-(void)insertBulletinView;
@end


//Going to be needing this....
static LibLockscreen *lockscreen = nil;
static Class LockscreenClass;
static NSBundle *lockscreenBundle;
static BOOL lockscreenLoaded = false;
	static id _instance;
@interface LibLSController : NSObject{

}
+(LibLSController *)sharedInstance;
-(NSString *)alertText;
-(void)unlock;
-(SBAwayBulletinListController*)bulletinController;
@end

@implementation LibLSController

+(LibLSController*)sharedInstance{
  if(!_instance){
    return [[LibLSController alloc] init];
  }
  return _instance;
}
-(id)init{
    if (_instance == nil)
    {
        _instance = [super init];
    }
    return _instance;
}

-(NSString *)alertText{
  return [NSString stringWithFormat:@"Hi"];
}


-(void)resetLockscreenToNil{
	lockscreen = nil;
}

-(void)unlock{

	if(lockscreen == nil){
		return;
	}

	if([[%c(SBDeviceLockController) sharedController] isPasswordProtected]){
		NSLog(@"LIBLSDEBUG: Device is passcode protected!");
		if([lockscreen respondsToSelector:@selector(showPasscodeScreen:)]){
			[lockscreen showPasscodeScreen:TRUE];
		}
		else{
			//Uhm.
			[self showPasscodeScreen:TRUE];
		}
	}
	else{
//This isn't on 5.1.1!		
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
  [[%c(SBAwayController) sharedAwayController] unlockWithSound:TRUE bypassPinLock:TRUE];
#elif __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
  [[%c(SBAwayController) sharedAwayController] unlockWithSound:TRUE];
#endif
	}

}

-(void)unlockedDevice{
	if(lockscreen == nil){
		return;
	}
	if(debug) REDLog(@"LIBLSDEBUG: UnlockedDevice triggered, sending out to actual lockscreen");
	if((!lockscreen == NULL) && [lockscreen respondsToSelector:@selector(unlockedDevice)]){
		if(debug) REDLog(@"LIBLSDEBUG: UnlockedDevice triggered, lockscreen isn't null, so executing...");
		[lockscreen unlockedDevice];
	}
}

-(void)showPasscodeScreen:(BOOL)show{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if(show){
	//UIView *awayView = [[%c(SBAwayController) sharedAwayController] awayView];

	//[awayView sendSubviewToBack:lockscreen.view]; //might not be needed, but whatever.
	  [UIView animateWithDuration:0.5
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     lockscreen.view.alpha = 0.0f;
                      
                 }
                 completion:^(BOOL finished){
                  lockscreen.view.userInteractionEnabled = FALSE;
                 }];
	[[%c(SBAwayController) sharedAwayController] unlockWithSound:TRUE];
	}
	else{
	  [UIView animateWithDuration:0.5
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     lockscreen.view.alpha = 1.0f;
                      
                 }
                 completion:^(BOOL finished){
                  lockscreen.view.userInteractionEnabled = TRUE;
                 }];
	}
}

-(void)updateClockWithTime:(NSString*)time andDate:(NSString *)date{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if([lockscreen respondsToSelector:@selector(updateClockWithTime:andDate:)]){
		[lockscreen updateClockWithTime:time andDate:date]; //Maybe I should have it pass the time lables...
	}
}

-(void)showMediaControls:(BOOL)show{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if([lockscreen respondsToSelector:@selector(showMediaControls:)]){
		[lockscreen showMediaControls:show];
	}
}


-(void)makeEmergencyCall:(BOOL)call{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if([lockscreen respondsToSelector:@selector(makeEmergencyCall:)]){
		[lockscreen makeEmergencyCall:call];
	}
}

-(void)receivingCall{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if([lockscreen respondsToSelector:@selector(receivingCall)]){
		[lockscreen receivingCall];
	}
}

-(void)receivedNotification:(NSMutableDictionary *)notification{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	      
		//[[[%c(SBAwayController) sharedAwayController] valueForKey:@"savedBulletinController"] clearViewsAndHibernate];
	
		
	if((!lockscreen == NULL) && [lockscreen respondsToSelector:@selector(receivedNotification:)]){
		[lockscreen receivedNotification:notification];
	}
}

-(void)showBulletinView{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if((!lockscreen == NULL) && [lockscreen respondsToSelector:@selector(showBulletinView)]){
		[lockscreen showBulletinView];
	}
}

-(void)insertBulletinView{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if((!lockscreen == NULL) && [lockscreen respondsToSelector:@selector(insertBulletinView)]){
		[lockscreen insertBulletinView];
	}
}

-(BOOL)usesStockNotificationList{
	if(lockscreen == nil){
		return FALSE;
	}

	if((!lockscreen == NULL) && [lockscreen respondsToSelector:@selector(usesStockNotificationList)]){
		return [lockscreen usesStockNotificationList];
	}
}

-(void)animateLockKeyPadIn{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if([lockscreen respondsToSelector:@selector(animateLockKeyPadIn)]){
		[lockscreen animateLockKeyPadIn];
	}
}


-(void)animateLockKeyPadOut{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if([lockscreen respondsToSelector:@selector(animateLockKeyPadOut)]){
		[lockscreen animateLockKeyPadOut];
	}
}

-(void)dimScreen{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if([lockscreen respondsToSelector:@selector(dimScreen)]){
		[lockscreen dimScreen];
	}
}

-(void)undimScreen{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if([lockscreen respondsToSelector:@selector(undimScreen)]){
		[lockscreen undimScreen];
	}
}

-(void)animateLockKeyPadOutForCancel{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if([lockscreen respondsToSelector:@selector(animateLockKeyPadOutForCancel)]){
		[lockscreen animateLockKeyPadOutForCancel];
	}
}

-(void)configureAndPositionNotificationList{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if((!lockscreen == nil) && [lockscreen respondsToSelector:@selector(configureAndPositionNotificationList)]){
		[lockscreen configureAndPositionNotificationList];
	}
}

-(void)homeButtonTapped{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if((!lockscreen == nil) && [lockscreen respondsToSelector:@selector(homeButtonTapped)]){
		[lockscreen homeButtonTapped];
	}	
}

-(void)nowPlayingInfoChanged{
	if(debug) REDLog(@"LIBLSDEBUG: nowPlayingInfoChanged");
	if(lockscreen == nil){
		if(debug) REDLog(@"LIBLSDEBUG: nowPlayingInfoChanged - lockscreen is nil");
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		if(debug) REDLog(@"LIBLSDEBUG: nowPlayingInfoChanged - device isn't locked");
		return;
	}
	if((!lockscreen == nil) && [lockscreen respondsToSelector:@selector(nowPlayingInfoChanged)]){
		if(debug) REDLog(@"LIBLSDEBUG: nowPlayingInfoChanged - sending command to lockscreen.");
		[lockscreen performSelector:@selector(nowPlayingInfoChanged) withObject:nil afterDelay:1.0]; //So it hopefully has time to change tracks
		
	}	
}


-(void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if((!lockscreen == nil) && [lockscreen respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]){
		[lockscreen willRotateToInterfaceOrientation:interfaceOrientation duration:duration];
	}
}

-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if((!lockscreen == nil) && [lockscreen respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)]){
		[lockscreen willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	}
}

-(void)didRotateFromInterfaceOrientation:(int)interfaceOrientation{
	if(lockscreen == nil){
		return;
	}
	if(![[%c(SBAwayController) sharedAwayController] isLocked]){
		return;
	}
	if((!lockscreen == nil) && [lockscreen respondsToSelector:@selector(didRotateFromInterfaceOrientation:)]){
		[lockscreen didRotateFromInterfaceOrientation:interfaceOrientation];
	}
}


-(UIImage *)backgroundImage{
if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"]){
	return [UIImage imageWithContentsOfCPBitmapFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap" flags:nil]; //Flags?
}
else{
	return [UIImage imageWithContentsOfCPBitmapFile:@"/var/mobile/Library/SpringBoard/HomeBackground.cpbitmap" flags:nil]; //Flags?
}
}



-(SBAwayBulletinListController*)bulletinController{
	if(![%c(SBAwayController) sharedAwayController] == nil){
		if(![[%c(SBAwayController) sharedAwayController] awayView] == nil){
			if(![[[%c(SBAwayController) sharedAwayController] awayView] bulletinController] == nil){
				return [[[%c(SBAwayController) sharedAwayController] awayView] bulletinController];
			}
		}
	}
	return nil;
}
@end



//-----Notifications----------



%hook SBAwayBulletinListController



 //FIXME: Works, but crashes on lock/unlock/relock sometimes. Almost every second time, if not every time.

-(void)observer:(id)observer addBulletin:(BannerClass*)banner forFeed:(unsigned)feed{

	if(debug) REDLog(@"LIBLSDEBUG: SBAwayBulletinListController observer:addBulletin:forFeed: %@", banner);
%orig(observer, banner, feed);


if(enabled && lockscreenLoaded && [[%c(SBAwayController) sharedAwayController] isLocked]){
NSMutableDictionary *alertInfo = [[NSMutableDictionary alloc] init];
if(banner.title) [alertInfo setObject:banner.title forKey:@"title"];
if(banner.message) [alertInfo setObject:banner.message forKey:@"message"];
if(banner.subtitle) [alertInfo setObject:banner.subtitle forKey:@"subtitle"];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
if(banner.section){
 [alertInfo setObject:banner.section forKey:@"bundleID"];  //Phew, that was close. Thought I would have trouble with that.
 //[alertInfo setObject:[UIImage imageWithContentsOfFile:[[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:banner.section] pathForIcon]] forKey:@"icon"]; //yayyyy icons.
}
if(banner.sectionDisplayName){
	[alertInfo setObject:banner.sectionDisplayName forKey:@"appName"];
}

#elif __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0

if(banner.sectionID){
 [alertInfo setObject:banner.sectionID forKey:@"bundleID"];  //Phew, that was close. Thought I would have trouble with that.
 //[alertInfo setObject:[UIImage imageWithContentsOfFile:[[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:banner.section] pathForIcon]] forKey:@"icon"]; //yayyyy icons.
}
if(banner.recordID){
	[alertInfo setObject:banner.recordID forKey:@"appName"];
}
#endif

[alertInfo setObject:banner forKey:@"originalAlert"];

[[LibLSController sharedInstance] receivedNotification:alertInfo];
[alertInfo release];

}


}


-(void)_configureAndPositionView{
%orig;
if(debug) REDLog(@"SBAwayBulletinListController _configureAndPositionView called");
if(enabled && lockscreenLoaded){
	//[[LibLSController sharedInstance] configureAndPositionNotificationList];
	if([[LibLSController sharedInstance] usesStockNotificationList]){
		
			[[LibLSController sharedInstance] showBulletinView];
		}
		else{
		
			//[[[[LibLSController sharedInstance] bulletinController] valueForKey:@"_view"] setHidden:TRUE];
			//[[[[LibLSController sharedInstance] bulletinController] valueForKey:@"_view"] removeFromSuperview];
		}
}
}

%end

%hook SBAwayView
- (id)initWithFrame:(CGRect)frame{
self = %orig;

//Blahhhhhh probably a wayyyy better way of doing this.


//Checking if this is even enabled.
if(enabled || shouldShowActivationLS()){ //Show this if the device needs to re-activate.

	//Loading up the custom lockscreen, which hopefully doesn't break the device.
	//Class LibLockscreen;
	lockscreen = nil;
	if(debug) REDLog(@"Attempting to load up lockscreen for bundle %@", lockscreenName);
	if(!shouldShowActivationLS()){
		if(lockscreenName == nil || lockscreenName == ""){
			if(debug) REDLog(@"LIBLSDEBUG: lockscreen to load is not set, unable to load (obviously).");
    		UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"LibLockscreen Error"
                                       message: @"No lockscreen set, please set one in the settings or disable the lockscreen loader."
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            [alert release];
    		lockscreenLoaded = FALSE;
    		return self;
		}

		if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/Library/liblockscreen/Lockscreens/%@", lockscreenName]]){
			if(debug) REDLog(@"LIBLSDEBUG: unable to find lockscreen bundle.");
    		UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"LibLockscreen Error"
                                       message: [NSString stringWithFormat:@"The bundle for %@ does not exist in /Library/liblockscreen/Lockscreens", lockscreenName]
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            [alert release];
    		lockscreenLoaded = FALSE;
    		return self;

		}
		//NSLog(@"We shouldn't show the activation LS");
    	lockscreenBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"/Library/liblockscreen/Lockscreens/%@", lockscreenName]];
	}
	else{
		//NSLog(@"We should try and show the activation LS");
		if(setupLSBundleValid()){
			//NSLog(@"SEtup LS is... valid?");
			lockscreenBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle"]];
		}
		else{
			if(debug) REDLog(@"LIBLSDEBUG: setupLS not valid, unable to load.");
    		UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Grayd00r Error"
                                       message: @"Your acitvation key for Grayd00r is invalid.\n\nIt also seems as though your re-activtion lockscreen is also invalid.\n\nNone of the features of Grayd00r will function until this is resolved.\nPlease re-install Grayd00r using the latest version of the installter from\nhttp://grayd00r.com."
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            [alert release];
    		lockscreenLoaded = FALSE;
    		return self;
    		//[lockscreenBundle unload];
    		//[lockscreenBundle release], lockscreenBundle = nil;
		}
	}

    NSError *err;
    if(![lockscreenBundle loadAndReturnError:&err]) {
    	if(debug) REDLog(@"LIBLSDEBUG: unable to load up lockscreen %@", err);
        	UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"LibLockscreen Error"
                                       message: [NSString stringWithFormat:@"%@ seems not to load up properly", lockscreenName]
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            [alert release];
            lockscreenLoaded = false;
    } else {
        // bundle loaded

        LockscreenClass = [lockscreenBundle principalClass]; 
        if([LockscreenClass conformsToProtocol:@protocol(LibLockscreen)]){ //Checking that the lockscreen is actually properly implimenting the protocol of a lockscreen. Otherwise crashes will occur.
        // here is where you need your principal class!
        // OR...
        //Class someClass = [bundle classNamed:@"KillerAppController"];

    	if(debug) REDLog(@"LIBLSDEBUG: lockscreen seems to implement protocol...");

        //if([[LockscreenClass class] respondsToSelector:@selector(initWithController:)]){
        	if(debug) REDLog(@"LIBLSDEBUG: lockscreen seems to respond to initWithController");
        lockscreen = [[LockscreenClass alloc] initWithController:[LibLSController sharedInstance]];
        if([lockscreen liblsVersion] < libLSVersion){
    		UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"LibLockscreen Error"
                                       message: [NSString stringWithFormat:@"%@ is using an incompatible version of the LibLockscreen API.", lockscreenName]
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            [alert release];
    		lockscreenLoaded = FALSE;
    		[lockscreenBundle unload];
    		[lockscreenBundle release], lockscreenBundle = nil;
        }else{

        for(UIView *view in self.subviews){
		view.hidden = TRUE; 
		/*
			Okay, so, yes.   I hid all the subviews rather than stop them from ever loading.  This isn't so bad though.
			The reasoning for doing this is so that everything still behaves as it should, and nothing crashes because the views and such don't exist (as they would if I overrided them even loading).
			This way, I can still call original methods and whatnot because they still exist, and the system can still interact with it, the user just doesn't see it.
			I hook the important stuff, and the minor things still go on about their work.
		*/
		}
        [self addSubview:lockscreen.view];
        //[lockscreen release];
        lockscreenLoaded = TRUE;
   		}
   //	}
   	//else{
   		/*
   		if(debug) REDLog(@"LIBLSDEBUG: lockscreen does not respond to initWithController");
    		UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"LibLockscreen Error"
                                       message: [NSString stringWithFormat:@"%@ seems not to correctly impliment the LibLocksreen class.", lockscreenName]
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            [alert release];
    		lockscreenLoaded = FALSE;
    		[lockscreenBundle unload];
    		[lockscreenBundle release], lockscreenBundle = nil;
    		*/
   	//}
    	}
    	else{
    		if(debug) REDLog(@"LIBLSDEBUG: lockscreen does not conform to libLSProtocol");
    		UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"LibLockscreen Error"
                                       message: [NSString stringWithFormat:@"%@ seems not to correctly impliment the LibLocksreen class.", lockscreenName]
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            [alert release];
    		lockscreenLoaded = FALSE;
    		[lockscreenBundle unload];
    		[lockscreenBundle release], lockscreenBundle = nil;
    	}
    	}


}



return self;
}


-(void)showBulletinView{
	if(debug) REDLog(@"LIBLSDEBUG: showBulletinView");
	if(!enabled){
		%orig;
	}
	else{
		if([[LibLSController sharedInstance] usesStockNotificationList]){
			
			%orig;
			[[LibLSController sharedInstance] showBulletinView];
		}
		else{
			//%orig;
			//[[[[LibLSController sharedInstance] bulletinController] valueForKey:@"_view"] setHidden:TRUE];
			//[[[[LibLSController sharedInstance] bulletinController] valueForKey:@"_view"] removeFromSuperview];
		}
	}
}

-(void)_insertBulletinView{
	if(debug) REDLog(@"LIBLSDEBUG: _insertBulletinView");
	if(!enabled){
		%orig;
	}
	else{
		if([[LibLSController sharedInstance] usesStockNotificationList]){
			
			%orig;
			[[LibLSController sharedInstance] insertBulletinView];
		}
		else{
			//%orig;
			//[[[[LibLSController sharedInstance] bulletinController] valueForKey:@"_view"] setHidden:TRUE];
			//[[[[LibLSController sharedInstance] bulletinController] valueForKey:@"_view"] removeFromSuperview];
		}
	}
}


-(void)animateToShowingDeviceLock:(BOOL)showingDeviceLock duration:(float)duration{
	%orig;
	if(enabled && lockscreenLoaded){
		if(showingDeviceLock){
			[[LibLSController sharedInstance] animateLockKeyPadIn];
		}
		else{
			[[LibLSController sharedInstance] animateLockKeyPadOut];
		}
	}
}



-(void)deviceUnlockCanceled{
	//if(debug) REDLog(@"LIBLSDEBUG: Dismissing passcode screen");
	%orig;
	if(enabled && lockscreenLoaded){
		[[LibLSController sharedInstance] animateLockKeyPadOutForCancel];
	}
}


-(void)setDimmed:(BOOL)dimmed{
	%orig;
	//if(debug) REDLog(@"LIBLSDEBUG: setDimmed: %@", dimmed);
	if(enabled && lockscreenLoaded){
	if(dimmed){
		if(debug) REDLog(@"LIBLSDEBUG: setDimmed: TRUE");
		[[LibLSController sharedInstance] dimScreen];
	}
	else{
    	SBTelephonyManager *telephonyManager = (SBTelephonyManager *)[%c(SBTelephonyManager) sharedTelephonyManager];


	    if ([telephonyManager incomingCallExists])
	    {
	    	[[LibLSController sharedInstance] receivingCall];
	    }

	    [[LibLSController sharedInstance] undimScreen];
		if(debug) REDLog(@"LIBLSDEBUG: setDimmed: FALSE");
	}
}

}

-(void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration{
	%orig;
	if(enabled && lockscreenLoaded){
		[[LibLSController sharedInstance] willRotateToInterfaceOrientation:interfaceOrientation duration:duration];
	}
}

-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration{
	%orig;
	if(enabled && lockscreenLoaded){
		[[LibLSController sharedInstance] willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	}
}

-(void)didRotateFromInterfaceOrientation:(int)interfaceOrientation{
	%orig;
	if(enabled && lockscreenLoaded){
		[[LibLSController sharedInstance] didRotateFromInterfaceOrientation:interfaceOrientation];
	}
}


%end


//Just hooking this to add in something so even the plugins can access the methods and "talk" to the tweak. Also other things needed....
%hook SBAwayController
%new(@:@)
+(LibLSController*)sharedLibLSController{
  return [LibLSController sharedInstance];
}

-(void)makeEmergencyCall
{
    %orig;
    if(enabled && lockscreenLoaded){
    	[[LibLSController sharedInstance] makeEmergencyCall:TRUE];
	}
}

-(void)emergencyCallWasRemoved
{
    %orig;
    if(enabled && lockscreenLoaded){
    	[[LibLSController sharedInstance] makeEmergencyCall:FALSE];
    }
}





-(void)_finishedUnlockAttemptWithStatus:(BOOL)status{
	%orig;
	if(status && lockscreenLoaded){
		
		[[LibLSController sharedInstance] unlockedDevice];
		[[LibLSController sharedInstance] resetLockscreenToNil];

		//Unloading the plugin for memory purposes. Maybe a bad place?
		[LockscreenClass release], LockscreenClass = nil;
    	[lockscreenBundle unload];
    	[lockscreenBundle release], lockscreenBundle = nil;
    	[lockscreen release], lockscreen = nil;
	}
}

-(BOOL)handleMenuButtonTap{
	if(enabled && lockscreenLoaded){
		if(debug) REDLog(@"LIBLSDEBUG: handleMenuButtonTap called");

		[[LibLSController sharedInstance] homeButtonTapped];
	}
	return %orig;
}

%end

%hook SBAwayDateView //Clock things
- (void)updateClock{

%orig;
if(enabled && lockscreenLoaded){
	[[LibLSController sharedInstance] updateClockWithTime: [[self valueForKey:@"_timeLabel"] valueForKey:@"_text"] andDate: [[self valueForKey:@"_dateAndTetheringLabel"] valueForKey:@"_text"]];
}
}




- (void)setIsShowingControls:(BOOL)arg1{
	%orig;
	if(enabled && lockscreenLoaded){
		[[LibLSController sharedInstance] showMediaControls:arg1]; //Because well, you know, lazy.
	}
}



%end

%hook SBMediaController
-(void)_nowPlayingInfoChanged{
	%orig;
	if(enabled && lockscreenLoaded){
		[[LibLSController sharedInstance] nowPlayingInfoChanged];
	}
}

%end


//Because how else will you choose the custom lockscreen?
%ctor{

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
if([[NSFileManager defaultManager] fileExistsAtPath:lsPrefsPath]){
NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:lsPrefsPath];
if([prefs objectForKey:@"lockscreenName"]) lockscreenName = [[prefs objectForKey:@"lockscreenName"] copy];
if([prefs objectForKey:@"enabled"]) enabled = [[prefs objectForKey:@"enabled"] boolValue];

[prefs release];
}
else{
NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
[prefs setObject:@"SetupLS" forKey:@"lockscreenName"];
[prefs setObject:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];


[prefs writeToFile:lsPrefsPath atomically:YES];
[prefs release];
}


[pool drain];
}






