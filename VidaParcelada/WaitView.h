//
//  WaitView.h
//  VidaParcelada
//
//  Created by Lauri P. Laux Jr on 04/09/12.
//
//

#import <UIKit/UIKit.h>

@interface WaitView : UIView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *acitivity;

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *message;

@end
