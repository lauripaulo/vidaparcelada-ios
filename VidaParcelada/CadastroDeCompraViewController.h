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
#import "BannerTableViewController.h"

@interface CadastroDeCompraViewController : BannerTableViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, ContaEscolhidaDelegate>

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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btSave;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btCancelar;
@property (weak, nonatomic) IBOutlet UITextField *tfValorDaParcela;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
//@property (strong, nonatomic) IBOutlet UIPickerView *contasPickerView;
@property (nonatomic, retain) NSNumberFormatter *valorFormatter;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UINavigationItem *topBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btDataOk;

@property (nonatomic, retain) Compra *compraSelecionada;

@property (nonatomic, retain) Conta *contaSelecionada;
@property (nonatomic, retain) NSDate *dataSelecionada;
@property (nonatomic, retain) NSArray *listaDeContas;
@property (nonatomic) BOOL algumCampoFoiAlterado;
@property (nonatomic) BOOL considerarParcelasAnterioresPagas;
@property (strong, nonatomic) UIActionSheet *actionSheetVencimento;
@property (strong, nonatomic) UIActionSheet *actionSheetApagarParcelas;

@property (weak, nonatomic) IBOutlet UITextField *tfDetalhesDaCompra;

// Delegate que recebe notificação quando uma conta é alterada
@property (assign) id <AlteracaoDeCompraDelegate> compraDelegate;

@property (weak, nonatomic) IBOutlet UITextField *tfDataCompra;

// Delegate que recebe notificação quando uma conta é selecionada
@property (assign) id <ContaEscolhidaDelegate> contaEscolhidaDelegate;

// Define um alert basico para informar sobre as datas de
// vencimento e melhor dia.
@property (nonatomic, strong) UIAlertView *datasAlert;

// Se a conta da compra for apagada quando a compra estiver sendo
// atualizado temos que avisar o usuário e cancelar a edição.
@property (nonatomic, strong) UIAlertView *contaDeletedAlert;

@end
