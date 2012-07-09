//
//  CadastroDaContaViewController.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior Laux on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CadastroDaContaViewController.h"
#import "TipoDaContaViewController.h"
#import "VidaParceladaHelper.h"

@interface CadastroDaContaViewController ()

// mantem referência para o último UITextFiled ativo
// utilizado para posicionar o teclado virtual
@property UITextView *activeField;

@property (retain) NSNumberFormatter *percentFormatter;
@property (retain) NSNumberFormatter *valorFormatter;

@end



@implementation CadastroDaContaViewController

#pragma mark Properties

@synthesize vpDatabase = _vpDatabase;
@synthesize tfDescricaoDaConta = _tfDescricaoDaConta;
@synthesize tfEmpresa = _tfEmpresa;
@synthesize tfLimiteTotal = _tfLimiteTotal;
@synthesize tfJuros = _tfJuros;
@synthesize tfDiaVencimento = _tfDiaVencimento;
@synthesize tfMelhorDia = _tfMelhorDia;
@synthesize stepperVencimento = _stepperVencimento;
@synthesize stepperMelhorDia = _stepperMelhorDia;
@synthesize cellTipoConta = _cellTipoConta;
@synthesize uiSwitchCartaoPreferencial = _uiSwitchCartaoPreferencial;
@synthesize activeField = _activeField;
@synthesize contaSelecionada = _contaSelecionada;
@synthesize contaDelegate = _contaDelegate;
@synthesize valorFormatter = _valorFormatter;
@synthesize percentFormatter = _percentFormatter;


#pragma mark - Metodos de 'negócio'


//This method comes from UITextFieldDelegate 
//and this is the most important piece of mask
//functionality.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = YES;

    if (textField == self.tfLimiteTotal) {
        
        [VidaParceladaHelper formataValor:textField 
                               novoDigito:string 
                                 comRange:range 
                          usandoFormatter:self.valorFormatter
                                 eQtdeDeDigitos:8];
        result = NO;
                
    } else if (textField == self.tfJuros) {
        
        [VidaParceladaHelper formataValor:textField 
                               novoDigito:string 
                                 comRange:range 
                          usandoFormatter:self.percentFormatter
                                 eQtdeDeDigitos:4];
        result = NO;
        
    } 
    
    return result;
}

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);
    
    [super viewWillAppear: animated];

    NSLog(@"(<) viewWillAppear: ");

}
- (IBAction)uiSwitchCartaoPreferencialChanged:(UISwitch *)sender {
    NSLog (@"(>) uiSwitchCartaoPreferencialChanged: %@", sender);
    
    self.contaSelecionada.preferencial = [NSNumber numberWithBool:sender.on]; ;
    
    NSLog (@"(<) uiSwitchCartaoPreferencialChanged: ");

}

// Atualiza os campos da tela atual com os dados da conta passados
// pelo controller pai.
- (void)atualizarCamposNaTela
{
    ;
        
    self.tfDescricaoDaConta.text = self.contaSelecionada.descricao;
    self.tfEmpresa.text = self.contaSelecionada.empresa;
    self.tfLimiteTotal.text = [self.valorFormatter stringFromNumber:self.contaSelecionada.limite];
    self.tfJuros.text = [self.contaSelecionada.jurosMes stringValue];
    self.tfDiaVencimento.text = [self.contaSelecionada.diaDeVencimento stringValue];
    self.tfMelhorDia.text = [self.contaSelecionada.melhorDiaDeCompra stringValue];
    self.cellTipoConta.textLabel.text = self.contaSelecionada.tipo.nome;
    self.cellTipoConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
    
    self.stepperMelhorDia.value = [self.contaSelecionada.melhorDiaDeCompra doubleValue];
    self.tfMelhorDia.text = [NSString stringWithFormat:@"%2.0f", [self.contaSelecionada.melhorDiaDeCompra doubleValue]];
    
    self.stepperVencimento.value = [self.contaSelecionada.diaDeVencimento doubleValue];
    self.tfDiaVencimento.text = [NSString stringWithFormat:@"%2.0f", [self.contaSelecionada.diaDeVencimento doubleValue]];
    
    self.uiSwitchCartaoPreferencial.on = [self.contaSelecionada.preferencial boolValue];
    
    // Formatando valores 
    self.tfJuros.text = [self.percentFormatter stringFromNumber:self.contaSelecionada.jurosMes];
    
}


// Atribui o tipo da conta escolhida na conta atual
- (void)tipoContaEscolhido:(TipoConta *)tipoConta
{
    self.contaSelecionada.tipo = tipoConta;
    self.cellTipoConta.textLabel.text = self.contaSelecionada.tipo.nome;
    self.cellTipoConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
    
    // Se o nome ou a descrição da conta estiver vazias assume o tipo como default.
    if (!self.tfDescricaoDaConta.text || [self.tfDescricaoDaConta.text length] == 0) {
        self.contaSelecionada.descricao = tipoConta.nome;
        self.tfDescricaoDaConta.text = self.contaSelecionada.descricao;
    }
    if (!self.tfEmpresa.text || [self.tfEmpresa.text length] == 0) {
        self.contaSelecionada.empresa = tipoConta.descricao;
        self.tfEmpresa.text = self.contaSelecionada.empresa;
    }
}

// Chamado quando o valor do stepper de vencimento muda de estado
- (IBAction)stepperVencimentoValueChanged:(UIStepper *)sender {
    self.tfDiaVencimento.text = [NSString stringWithFormat:@"%2.0f", sender.value];
    self.contaSelecionada.diaDeVencimento = [NSDecimalNumber numberWithDouble:sender.value];
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
}

// Chamado quando o valor do stepper de melhor fia muda de estado
- (IBAction)stepperMelhorDiaValueChanged:(UIStepper *)sender {
    self.tfMelhorDia.text = [NSString stringWithFormat:@"%2.0f", sender.value];
    self.contaSelecionada.melhorDiaDeCompra = [NSDecimalNumber numberWithDouble:sender.value];
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];

}

// Chamado quando a edição no campo descrição da conta termina
- (IBAction)tfDescricaoDaContaEditingDidEnd:(UITextField *)sender {
    self.contaSelecionada.descricao = self.tfDescricaoDaConta.text;
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
}

// Chamado quando a edição no campo empresa termina
- (IBAction)tfEmpresaEditingDidEnd:(UITextField *)sender {
    self.contaSelecionada.empresa = self.tfEmpresa.text;
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
}

// Chamado quando a edição no campo limite total inicia
- (IBAction)tfLimiteTotalDidBegin:(UITextField *)sender {
}

// Chamado quando a edição no campo limite total termina
- (IBAction)tfLimiteTotalEditingDidEnd:(UITextField *)sender {
    if ([sender.text length] > 0) {
        NSNumber *valor;
        valor = [self.valorFormatter numberFromString:sender.text];
        self.contaSelecionada.limite = [NSDecimalNumber decimalNumberWithString:[valor stringValue]];
        // Notifica o delegate da alteração
        [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
    }
}

// Chamado quando a edição no campo juros inicia
- (IBAction)tfJurosEditingDidBegin:(UITextField *)sender {
}

// Chamado quando a edição no campo juros termina
- (IBAction)tfJurosEditingDidEnd:(UITextField *)sender {
    if ([sender.text length] > 0) {
        self.contaSelecionada.jurosMes = [NSDecimalNumber decimalNumberWithString:sender.text];;
        // Notifica o delegate da alteração
        [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
    } 
}

// para criar uma conta nos criamos o objeto CoreData com os campos vazios
// também associamos ao primeiro TipoConta que encontramos no banco de dados
- (void)criarNovaConta
{
    BOOL preferencial = self.uiSwitchCartaoPreferencial.on;
    
    self.contaSelecionada = [Conta contaComDescricao:@"" 
                                           daEmpresa:@"" 
                                  comVencimentoNoDia:[NSNumber numberWithInt:1]
                                           eJurosMes:[NSDecimalNumber decimalNumberWithString:@"0"]
                                      comLimiteTotal:[NSDecimalNumber decimalNumberWithString:@"0"]
                                comMelhorDiaDeCompra:[NSNumber numberWithInt:1]
                                  cartaoPreferencial:(BOOL)preferencial
                                           inContext:self.vpDatabase.managedObjectContext];
    
    [self atualizarCamposNaTela];
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
}

# pragma mark TableView


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//
// Codigo de gerenciamento do teclado
//

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.percentFormatter = [[NSNumberFormatter alloc] init];
    [self.percentFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.percentFormatter setMinimumFractionDigits:2];
    
    // Se o controller receber uma conta selecionada temos que atualizar os campos
    // com os dados dessa conta.
    if (self.contaSelecionada) {
        [self atualizarCamposNaTela];
    } else {
        [self criarNovaConta];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidUnload
{
    [self setTfDescricaoDaConta:nil];
    [self setTfEmpresa:nil];
    [self setTfLimiteTotal:nil];
    [self setTfJuros:nil];
    [self setTfDiaVencimento:nil];
    [self setTfMelhorDia:nil];
    [self setStepperVencimento:nil];
    [self setStepperMelhorDia:nil];
    [self setCellTipoConta:nil];
    [self setTableView:nil];
    [self setUiSwitchCartaoPreferencial:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Temos que passar o banco de dados que abrimos aqui
// no primeiro controller do app para todos
// os outros controllers. Dessa forma todos terao um atributo
// UIManagedDocument *vpDatabase implementado.
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Tipo da Conta"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setVpDatabase:)]){
            [segue.destinationViewController setVpDatabase:self.vpDatabase];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setTipoContaDelegate:)]){
            [segue.destinationViewController setTipoContaDelegate:self];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setTipoSelecionado:)]){
            [segue.destinationViewController setTipoSelecionado:self.contaSelecionada.tipo];
        }

    }
}

@end
