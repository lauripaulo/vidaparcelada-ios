//
//  CadastroDeCompraViewController.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior Laux on 22/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conta+AddOn.h"
#import "TipoConta+AddOn.h"
#import "Compra+AddOn.h"
#import "Conta+AddOn.h"
#import "TipoConta+AddOn.h"
#import "VidaParceladaHelper.h"

@interface CadastroDeCompraViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>

// aqui definimos nosso banco de dados global
// que todos os controllers irão utilizar
// para mostrar dados do nosso aplicativo
@property (nonatomic, strong) UIManagedDocument *vpDatabase;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellConta;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDataDaCompra;
@property (weak, nonatomic) IBOutlet UITextField *tfDescricao;
@property (weak, nonatomic) IBOutlet UITextField *tfQtdeDeParcelas;
@property (weak, nonatomic) IBOutlet UIStepper *stepperQtdeDeParcelas;
@property (weak, nonatomic) IBOutlet UITextField *tfValorTotal;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btSave;

@property (nonatomic, strong) Compra *compraSelecionada;
@property (nonatomic, strong) NSNumberFormatter *valorFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) Conta *contaSelecionada;
@property (nonatomic, strong) NSDate *dataSelecionada;

// Delegate que recebe notificação quando uma conta é alterada
@property (assign) id <AlteracaoDeCompraDelegate> compraDelegate;

@end
