//
//  PonteViewController.m
//  VidaParcelada
//
//  Created by Lauri Laux on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PonteViewController.h"
#import "Compra.h"

@interface PonteViewController ()

// aqui definimos nosso banco de dados global
// que todos os controllers irão utilizar
// para mostrar dados do nosso aplicativo
@property (nonatomic, strong) UIManagedDocument *vpDatabase;

// Compra atualmente selecionada na table
@property (nonatomic) Compra *compraSelecionada;

@end

@implementation PonteViewController

@synthesize vpDatabase = _vpDatabase;
@synthesize compraSelecionada = _compraSelecionada;

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController respondsToSelector:@selector(setVpDatabase:)]){
        [segue.destinationViewController setVpDatabase:self.vpDatabase];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setCompraSelecionada:)]){
        [segue.destinationViewController setCompraSelecionada:self.compraSelecionada];
    }
}

@end
