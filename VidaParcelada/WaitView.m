//
//  WaitView.m
//  VidaParcelada
//
//  Created by Lauri P. Laux Jr on 04/09/12.
//
//

#import "WaitView.h"

@implementation WaitView
@synthesize acitivity;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.acitivity startAnimating];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
