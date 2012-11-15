//
//  TipoDaContaViewController.h
//  VidaParcelada
//
//  Created by L. P. Laux on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "TipoConta+AddOn.h"

@interface TipoDaContaViewController : CoreDataTableViewController

// Tipo selecionado
@property (nonatomic, strong) TipoConta *tipoSelecionado;

// Delegate que recebe notificação quando um tipo conta é escolhido
@property (assign) id <TipoContaEscolhidoDelegate> tipoContaDelegate;
@end
