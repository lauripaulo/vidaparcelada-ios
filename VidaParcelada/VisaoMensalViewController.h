//
//  VisaoMensalViewController.h
//  VidaParcelada
//
//  Created by Lauri Laux on 28/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Compra+AddOn.h"
#import "Parcela+AddOn.h"

@interface VisaoMensalViewController : CoreDataTableViewController <AlteracaoDeCompraDelegate, AlteracaoDeParcelaDelegate>

@property (nonatomic, strong) NSNumberFormatter *valorFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDecimalNumber *objetivoMensal;
@property (nonatomic, strong) Compra *compraSelecionada;
@property (nonatomic, strong) Parcela *parcelaSelecionada;
@property (weak, nonatomic) IBOutlet UINavigationItem *topBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnFaturas;

// define um alert para ser mostrado no primeiro uso de uma funcionalidade
// ou de uma nova tela.
@property (nonatomic, strong) UIAlertView *primeiroUsoAlert;

// Define um alert basico de eventos relacionados a dia do vencimento
// das suas contas ou melhor dia de compra com um cartão específico.
@property (nonatomic, strong) UIAlertView *vencimentosAlert;

@end
