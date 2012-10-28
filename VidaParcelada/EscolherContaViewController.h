//
//  EscolherContaViewController.h
//  VidaParcelada
//
//  Created by Lauri Laux on 08/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Conta+AddOn.h"

@interface EscolherContaViewController : CoreDataTableViewController

// Tipo selecionado
@property (nonatomic, strong) Conta *contaSelecionada;

// Delegate que recebe notificação quando um tipo conta é escolhido
@property (assign) id <ContaEscolhidaDelegate> contaDelegate;

@end
