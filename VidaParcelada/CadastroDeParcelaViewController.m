//
//  CadastroDeParcelaViewController.m
//  VidaParcelada
//
//  Created by Lauri Laux on 30/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CadastroDeParcelaViewController.h"
#import "VidaParceladaHelper.h"
#import "Parcela+AddOn.h"
#import "Compra+AddOn.h"

@interface CadastroDeParcelaViewController ()

- (void)removeTodosOsChecksDeEstado;

@end

@implementation CadastroDeParcelaViewController

@synthesize tfDescricao;
@synthesize tfValor;
@synthesize cellParcelaPaga;
@synthesize cellParcelaVencida;
@synthesize cellParcelaPendente;
@synthesize btSalvar;
@synthesize btCancelar;
@synthesize parcelaSelecionada = _parcelaSelecionada;
@synthesize vpDatabase = _vpDatabase;
@synthesize parcelaDelegate = _parceladDelegate;
@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;
@synthesize algumCampoFoiAlterado = _algumCampoFoiAlterado;
@synthesize cellVencimento;
@synthesize cellDetalhesCompra;

//This method comes from UITextFieldDelegate 
//and this is the most important piece of mask
//functionality.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = YES;
    
    if (textField == self.tfValor) {
        
        self.algumCampoFoiAlterado = YES;
        
        [VidaParceladaHelper formataValor:textField 
                               novoDigito:string 
                                 comRange:range 
                          usandoFormatter:self.valorFormatter
                           eQtdeDeDigitos:8];
        result = NO;
                
    } else if (textField == self.tfValor) {
        
        self.algumCampoFoiAlterado = YES;
        
    }
    
    return result;
}

- (IBAction)onSalvarPressionado:(UIBarButtonItem *)sender {
    //NSLog(@"(>) onSalvarPressionado: %@ ", sender);
    
    // Se algo foi alterado salva e avisa o delegate.
    if (self.algumCampoFoiAlterado && self.parcelaSelecionada) {
        NSNumber *valorTmp= [self.valorFormatter numberFromString:self.tfValor.text];
        self.parcelaSelecionada.descricao = self.tfDescricao.text;
        self.parcelaSelecionada.valor = [NSDecimalNumber decimalNumberWithString:[valorTmp stringValue]];
        
        // Qual o estado da compra
        if (self.cellParcelaPaga.accessoryType == UITableViewCellAccessoryCheckmark) {
            self.parcelaSelecionada.estado = PARCELA_PAGA;
        } else if (self.cellParcelaPendente.accessoryType == UITableViewCellAccessoryCheckmark) {
            self.parcelaSelecionada.estado = PARCELA_PENDENTE_PAGAMENTO;
        } else if (self.cellParcelaVencida.accessoryType == UITableViewCellAccessoryCheckmark) {
            self.parcelaSelecionada.estado = PARCELA_VENCIDA;
        }
        //NSLog(@"(!) onSalvarPressionado: parcela = %@", self.parcelaSelecionada);
        
        // Persiste no coredata - talvez isso devesse sair do controller...
        NSError *erro = nil;
        [self.vpDatabase.managedObjectContext save:&erro];
        [VidaParceladaHelper trataErro:erro];
    }
    
    // Volta para a tela anterior
    [self.navigationController popViewControllerAnimated:YES];

    //NSLog(@"(<) onSalvarPressionado: ");
}

- (IBAction)onCancelarPressionado:(UIBarButtonItem *)sender {
    //NSLog(@"(>) onCancelarPressionado: %@ ", sender);
    [self.navigationController popViewControllerAnimated:YES];
    //NSLog(@"(<) onCancelarPressionado: ");
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    if (self.parcelaSelecionada) {
        self.algumCampoFoiAlterado = NO;
        self.tfDescricao.text = self.parcelaSelecionada.descricao;
        self.tfValor.text = [self.valorFormatter stringFromNumber:self.parcelaSelecionada.valor];
        
        self.cellVencimento.detailTextLabel.text = [self.dateFormatter stringFromDate:self.parcelaSelecionada.dataVencimento];
        self.cellDetalhesCompra.detailTextLabel.text = self.parcelaSelecionada.compra.descricao;
        
        // atualiza o estado da parcela
        [self removeTodosOsChecksDeEstado];
        if ([self.parcelaSelecionada.estado isEqualToString:PARCELA_PAGA]) {
            self.cellParcelaPaga.accessoryType = UITableViewCellAccessoryCheckmark;
        } else if ([self.parcelaSelecionada.estado isEqualToString:PARCELA_PENDENTE_PAGAMENTO]) {
            self.cellParcelaPendente.accessoryType = UITableViewCellAccessoryCheckmark;
        } else if ([self.parcelaSelecionada.estado isEqualToString:PARCELA_VENCIDA]) {
            self.cellParcelaVencida.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);
    
    [super viewWillAppear: animated];
    
    //NSLog(@"(<) viewWillAppear: ");
}

- (void)viewDidUnload
{
    [self setTfDescricao:nil];
    [self setTfValor:nil];
    [self setCellParcelaPaga:nil];
    [self setCellParcelaVencida:nil];
    [self setCellParcelaPendente:nil];
    [self setBtSalvar:nil];
    [self setBtCancelar:nil];
    [self setCellVencimento:nil];
    [self setCellDetalhesCompra:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // somente avalia toques na parte de baixo.
    //
    if (indexPath.section > 0) {
        // remove todos os checks atuais.
        [self removeTodosOsChecksDeEstado];
        
        // colocar o check no escolhido
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        // Avisa que o campo foi alterado.
        self.algumCampoFoiAlterado = YES;
    }
    
}

- (void)removeTodosOsChecksDeEstado
{
    self.cellParcelaPaga.accessoryType = UITableViewCellAccessoryNone;
    self.cellParcelaPendente.accessoryType = UITableViewCellAccessoryNone;
    self.cellParcelaVencida.accessoryType = UITableViewCellAccessoryNone;
}

@end
