#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

//Something something to add here.
@protocol LibLockscreen
-(UIView *)initWithFrame:(CGRect)frame;
-(float)liblsVersion; //In case there are updates to liblockscreen, I can provide legacy support for your plugin if I know the version.
@optional

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


@class SBAwayController;
@interface LibLSController : NSObject
+(LibLSController *)sharedLibLSController; //Shared instance is everything. It's a tweak, I'm allowed to do that.
-(void)unlock;  //Hard to guess what this does, right?
-(void)showPasscodeScreen:(BOOL)show; //So you can call it off if you only wanted to show some animation or whatever. Could be useful down the road.
-(UIImage *)backgroundImage; //Returns the lockscreen background image of the device.
-(void)configureAndPositionNotificationList;
@end


@interface SBAwayController (LibLockscreen)
+(LibLSController *)sharedLibLSController; //Gets rid of errors on compiling...

@end