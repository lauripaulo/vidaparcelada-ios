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

@interface BannerTableViewController : UITableViewController <GADBannerViewDelegate>


@property (nonatomic, strong) GADBannerView *banner;

-(void)createDefaultBanner;

@end
