//
//  VidaParceladaAppDelegate.h
//  VidaParcelada
//
//  Created by L. P. Laux on 09/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VidaParceladaAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Agora o contexto do Core Data vai ficar em apenas um lugar que
// todos os controllers e objetos podem acessar de forma
// simples chamando:
//
//    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
//    algumaCoida = appDelegate.defaultContext;
// 
@property (strong, nonatomic) NSManagedObjectContext *defaultContext;
@property (strong, nonatomic) UIManagedDocument *defaultDatabase;

@end
