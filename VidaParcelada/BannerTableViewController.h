//
//  BannerTableViewController.h
//  VidaParcelada
//
//  Created by Lauri P. Laux Jr on 28/09/12.
//
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#import "VidaParceladaAppDelegate.h"

@interface BannerTableViewController : UITableViewController <GADBannerViewDelegate>


/*
 
 Implements the banner infra to all TableViews in the application.
 
 */
@property (nonatomic, strong) GADBannerView *banner;

// If YES the current ViewController will display ads.
// You MUST set this property in all TableViewControllers you
// want to display a banner;
@property BOOL displayAds;

// YES if AdMob already gave the app a banner
@property BOOL bannerWasDisplayed;

// The banner ID
@property NSString *bannerId;

// Creates a banner and asks for it in a request
-(void)createDefaultBanner;

@end
