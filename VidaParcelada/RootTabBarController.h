//
//  RootTabBarController.h
//  VidaParcelada
//
//  Created by Lauri Laux on 10/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootTabBarController : UITabBarController

// aqui definimos nosso banco de dados global
// que todos os controllers irão utilizar
// para mostrar dados do nosso aplicativo
@property (nonatomic, strong) UIManagedDocument *managedDocument;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
