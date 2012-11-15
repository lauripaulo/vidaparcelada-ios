//
//  CadastroDeParcelaViewController.h
//  VidaParcelada
//
//  Created by Lauri Laux on 30/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parcela+AddOn.h"
#import "BannerTableViewController.h"

@interface CadastroDeParcelaViewController : BannerTableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfDescricao;
@property (weak, nonatomic) IBOutlet UITextField *tfValor;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellParcelaPaga;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellParcelaVencida;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellParcelaPendente;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btSalvar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btCancelar;

@property (strong, nonatomic) Parcela *parcelaSelecionada;

// Delegate que recebe notificação quando uma conta é alterada
@property (assign) id <AlteracaoDeParcelaDelegate> parcelaDelegate;

@property (nonatomic, retain) NSNumberFormatter *valorFormatter;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

// Se algum campo foi alterado para o salvar ter contexto para acontecer
@property (nonatomic) BOOL algumCampoFoiAlterado;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellVencimento;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDetalhesCompra;

@end
