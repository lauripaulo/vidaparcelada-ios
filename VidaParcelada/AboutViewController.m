//
//  AboutViewController.m
//  VidaParcelada
//
//  Created by Lauri P. Laux Jr on 20/08/12.
//
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize btnVoltar;
@synthesize btnWebsite;

- (IBAction)voltarPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)websitePressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.vidaparcelada.com.br"]];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setBtnVoltar:nil];
    [self setBtnWebsite:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
