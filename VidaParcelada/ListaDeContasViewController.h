//
//  ContasViewController.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 13/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Conta+AddOn.h"

@interface ListaDeContasViewController : CoreDataTableViewController <AlteracaoDeContaDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdicionarConta;

@property (nonatomic, strong) UIAlertView *comprasPresentesAlert;

// define um alert para ser mostrado no primeiro uso de uma funcionalidade
// ou de uma nova tela.
@property (nonatomic, strong) UIAlertView *primeiroUsoAlert;

@property (nonatomic, strong) NSNumberFormatter *valorFormatter;

@property (nonatomic, strong) NSDecimalNumber *totalGeral;

@end
