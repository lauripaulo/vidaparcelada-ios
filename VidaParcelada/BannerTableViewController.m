//
//  BannerTableViewController.m
//  VidaParcelada
//
//  Created by Lauri P. Laux Jr on 28/09/12.
//
//

#import "BannerTableViewController.h"
#import "MKStoreManager.h"

@interface BannerTableViewController ()

@end

@implementation BannerTableViewController

@synthesize banner = _banner;
@synthesize displayAds = _displayAds;
@synthesize bannerWasDisplayed = _bannerWasDisplayed;

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Do we have to create and call a banner?
    if (self.displayAds) {
        // Check to see if we have a premium user
        if ([MKStoreManager isFeaturePurchased:@"VPPREMIUM"]) {
            NSLog (@"VidaParcelada PREMIUM user.");
        } else {
            // Regular user
            [self createDefaultBanner];
            [self getBannerFromAdMob];
        }
    } else {
        NSLog (@"No Ads will be displayed for the %@ view controller.", self);
        return;
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.banner removeFromSuperview];
}

-(void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog (@"adViewDidReceiveAd");
    
    // resize
//    [UIView beginAnimations:@"resize" context:nil];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationDelay:1.0];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    // Move banner
    CGRect bannerFrame = bannerView.viewForBaselineLayout.frame;
    CGFloat screenSize = self.navigationController.view.frame.size.height;
    CGFloat tabBarSize = self.tabBarController.tabBar.frame.size.height;
    CGFloat bannerOrigin = screenSize - tabBarSize;
    //NSLog (@"bannerOrigin: %f", bannerOrigin);
    bannerFrame.origin.y = bannerOrigin;
    bannerView.viewForBaselineLayout.frame = bannerFrame;
    
    CGRect tableFrame = self.navigationController.visibleViewController.view.frame;
    tableFrame.size.height = tableFrame.size.height - GAD_SIZE_320x50.height;
    self.navigationController.visibleViewController.view.frame = tableFrame;
    
//    [UIView commitAnimations];
    
    self.bannerWasDisplayed = YES;
}

-(void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
    NSLog (@"adViewWillDismissScreen");
    [bannerView removeFromSuperview];
}

-(void)adViewDidDismissScreen:(GADBannerView *)adView
{
    NSLog (@"adViewDidDismissScreen");
}

-(void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    NSLog (@"adViewWillLeaveApplication");
}

-(void)adViewWillPresentScreen:(GADBannerView *)adView
{
    NSLog (@"adViewWillPresentScreen");
}

-(void)createDefaultBanner
{
    NSLog (@"adViewWillPresentScreen");
    
    // Criar uma visualização do tamanho padrão na parte inferior da tela, escondido.
    self.banner = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0.0,
                                            self.tabBarController.view.frame.size.height,
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
    self.banner.delegate = self;
    
    // Especificar o "identificador do bloco de anúncios". Este é seu ID de editor da AdMob.
    self.banner.adUnitID = @"a1506257e9c0f7c";
    
    // Permitir que o tempo de execução saiba qual UIViewController deve ser restaurado depois de levar
    // o usuário para onde quer que o anúncio vá e adicioná-lo à hierarquia de visualização.
    
    GADRequest *request = [GADRequest request];
    
    request.testDevices = [NSArray arrayWithObjects:
                           GAD_SIMULATOR_ID,                               // Simulador
                           @"5af091a2670105b56394789825ffc4ed699994e3",    // iPhone Junior
                           @"bbc3e191c3a7b478d93cdb3d1e51107c7956aa58",    // iPad Paula
                           @"fa97af875a365c09c1a2543a1951dbf0f929060b",    // iPhone Paula
                           nil];
    
    // Put the banner into play
    self.banner.rootViewController = self;
    [self.tabBarController.view addSubview:self.banner];
}

-(void)getBannerFromAdMob
{
    NSLog (@"getBannerFromAdMob");

    // Iniciar uma solicitação genérica para carregá-la com um anúncio.
    [self.banner loadRequest:[GADRequest request]];
}

@end
