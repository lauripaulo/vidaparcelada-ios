//
//  ListaDeComprasViewController.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 14/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Compra+AddOn.h"

@interface ListaDeComprasViewController : CoreDataTableViewController <AlteracaoDeCompraDelegate, UIAlertViewDelegate>

// aqui definimos nosso banco de dados global
// que todos os controllers irão utilizar
// para mostrar dados do nosso aplicativo
@property (nonatomic, strong) UIManagedDocument *vpDatabase;

// Compra atualmente selecionada na table
@property (nonatomic) Compra *compraSelecionada;

@property (nonatomic, strong) NSNumberFormatter *valorFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UIAlertView *semContasCadastradasAlert;

// define um alert para ser mostrado no primeiro uso de uma funcionalidade
// ou de uma nova tela.
@property (nonatomic, strong) UIAlertView *primeiroUsoAlert;

// Define um alert basico de eventos relacionados a dia do vencimento
// das suas contas ou melhor dia de compra com um cartão específico.
@property (nonatomic, strong) UIAlertView *vencimentosAlert;

@end
