//
//  RootTabBarController.h
//  VidaParcelada
//
//  Created by Lauri Laux on 10/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitView.h"

@interface RootTabBarController : UITabBarController <UINavigationControllerDelegate>

@property (nonatomic, strong)  WaitView *waitView;

@end
