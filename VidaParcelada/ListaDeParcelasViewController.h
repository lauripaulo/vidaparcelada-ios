//
//  ListaDeParcelasViewController.h
//  VidaParcelada
//
//  Created by L. P. Laux on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Parcela+AddOn.h"
#import "Compra+AddOn.h"
#import "Conta+AddOn.h"
#import "TipoConta+AddOn.h"

@interface ListaDeParcelasViewController : CoreDataTableViewController <AlteracaoDeParcelaDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSNumberFormatter *valorFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// Compra atualmente selecionada na table
@property (nonatomic) Compra *compraSelecionada;

@property (nonatomic) Parcela *parcelaSelecionada;

// define um alert para ser mostrado no primeiro uso de uma funcionalidade
// ou de uma nova tela.
@property (nonatomic, strong) UIAlertView *primeiroUsoAlert;

@end
