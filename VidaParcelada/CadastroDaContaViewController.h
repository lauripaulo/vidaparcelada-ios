//
//  CadastroDaContaViewController.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior Laux on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conta+AddOn.h"
#import "TipoConta+AddOn.h"

@interface CadastroDaContaViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate, TipoContaEscolhidoDelegate, UIAlertViewDelegate>

// aqui definimos nosso banco de dados global
// que todos os controllers irão utilizar
// para mostrar dados do nosso aplicativo
@property (nonatomic, strong) UIManagedDocument *vpDatabase;
@property (weak, nonatomic) IBOutlet UITextField *tfDescricaoDaConta;
@property (weak, nonatomic) IBOutlet UITextField *tfEmpresa;
@property (weak, nonatomic) IBOutlet UITextField *tfLimiteTotal;
@property (weak, nonatomic) IBOutlet UITextField *tfJuros;
@property (weak, nonatomic) IBOutlet UITextField *tfDiaVencimento;
@property (weak, nonatomic) IBOutlet UITextField *tfMelhorDia;
@property (weak, nonatomic) IBOutlet UIStepper *stepperVencimento;
@property (weak, nonatomic) IBOutlet UIStepper *stepperMelhorDia;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTipoConta;
@property (weak, nonatomic) IBOutlet UINavigationItem *topBar;

@property (weak, nonatomic) IBOutlet UISwitch *uiSwitchCartaoPreferencial;
@property (nonatomic, strong) Conta *contaSelecionada;
@property (nonatomic, strong) TipoConta *tipoContaSelecionada;

// Delegate que recebe notificação quando uma conta é alterada
@property (assign) id <AlteracaoDeContaDelegate> contaDelegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCancelar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSalvar;


@property (nonatomic, strong) UIAlertView *validacaoAlert;

@end
