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
@synthesize topBar = _topBar;
@synthesize uiSwitchCartaoPreferencial = _uiSwitchCartaoPreferencial;
@synthesize activeField = _activeField;
@synthesize contaSelecionada = _contaSelecionada;
@synthesize contaDelegate = _contaDelegate;
@synthesize btnCancelar = _btnCancelar;
@synthesize btnSalvar = _btnSalvar;
@synthesize valorFormatter = _valorFormatter;
@synthesize percentFormatter = _percentFormatter;
@synthesize tipoContaSelecionada = _tipoContaSelecionada;
@synthesize validacaoAlert = _validacaoAlert;
@synthesize datasAlert = _datasAlert;

- (UIAlertView *)datasAlert
{
    if (!_datasAlert) {
        NSString *texto = NSLocalizedString(@"cadastro.compra.popup.datas", @"Importante datas popup");
        NSString *titulo = NSLocalizedString(@"titulo.atencao", @"Atenção!");
        _datasAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    return _datasAlert;
}

- (void)persiteContaCriandoNova:(BOOL)criarConta {
    NSNumber *vencimento = [NSDecimalNumber numberWithDouble:self.stepperVencimento.value];
    NSNumber *melhorDia = [NSDecimalNumber numberWithDouble:self.stepperMelhorDia.value];
    
    NSNumber *juros = [NSNumber numberWithInt:0];
    if ([self.tfJuros.text length] > 0) {
        juros = [self.percentFormatter numberFromString:self.tfJuros.text];
    }
    NSDecimalNumber *jurosMes = [NSDecimalNumber decimalNumberWithString:[juros stringValue]];
    
    NSNumber *valorNum = [NSNumber numberWithInt:0];;
    if ([self.tfLimiteTotal.text length] > 0) {
        valorNum = [self.valorFormatter numberFromString:self.tfLimiteTotal.text];
    }
    NSDecimalNumber *limiteTotal = [NSDecimalNumber decimalNumberWithString:[valorNum stringValue]];
    
    BOOL preferencial = self.uiSwitchCartaoPreferencial.on;
    
    if (criarConta) {
    self.contaSelecionada = [Conta contaComDescricao:self.tfDescricaoDaConta.text
                                           daEmpresa:self.tfEmpresa.text
                                  comVencimentoNoDia:vencimento
                                           eJurosMes:jurosMes
                                      comLimiteTotal:limiteTotal
                                comMelhorDiaDeCompra:melhorDia
                                  cartaoPreferencial:preferencial
                                        comTipoConta:self.tipoContaSelecionada
                                           inContext:self.vpDatabase.managedObjectContext];
    
    } else {
        self.contaSelecionada.descricao = self.tfDescricaoDaConta.text;
        self.contaSelecionada.empresa = self.tfEmpresa.text;
        self.contaSelecionada.diaDeVencimento = vencimento;
        self.contaSelecionada.limite = limiteTotal;
        self.contaSelecionada.melhorDiaDeCompra = melhorDia;
        self.contaSelecionada.preferencial = [NSNumber numberWithBool:preferencial];
        self.contaSelecionada.tipo = self.tipoContaSelecionada;

        NSError *error = nil;
        [self.vpDatabase.managedObjectContext save:(&error)];
        
        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];
    }
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
}

- (IBAction)onSalvarPressionado:(UIBarButtonItem *)sender {

    BOOL saiDaTela = YES;
    if ([self.tfDescricaoDaConta.text length] == 0 || [self.tfEmpresa.text length] == 0) {
        NSString *texto = NSLocalizedString(@"cadastro.conta.campos.faltando", @"Campos faltando");
        _validacaoAlert = [[UIAlertView alloc] initWithTitle:@"Informação!" message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.validacaoAlert show];
        
        // campos
        if ([self.tfDescricaoDaConta.text length] == 0) {
            self.tfDescricaoDaConta.text = self.tipoContaSelecionada.nome;
        }
        if ([self.tfEmpresa.text length] == 0) {
            self.tfEmpresa.text = self.tipoContaSelecionada.descricao;
        }
        saiDaTela = NO;
    }
    
    // validação
    if (self.contaSelecionada) {
        [self persiteContaCriandoNova:NO];

    } else {
        // tudo certo, manda a tela embora.
        [self persiteContaCriandoNova:YES];
    }

    if (saiDaTela) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Usuário confirmou que viu o primeiro aviso da tela.
    if (alertView == self.validacaoAlert) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    // Usuário confirmou que viu o primeiro aviso da tela.
    if (alertView == self.datasAlert) {
        // atualiza o estado para exibido
        NSString *nomeDaAba = [NSString stringWithFormat:@"%@", [self class]];
        [VidaParceladaHelper salvaEstadoApresentacaoInicialAba:nomeDaAba exibido:YES];
    }
}


// Sai da tela ignorando dados do insert
- (IBAction)onCancelarPressionado:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

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

- (IBAction)bVencimentosDatas:(UIButton *)sender {
    [self.datasAlert show];
}


- (void) viewWillAppear:(BOOL)animated
{
    //NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);
    
    [super viewWillAppear: animated];

    //
    // Chamada a primeira vez que a aba é exibida passando o nome da própria
    // classe, retorna YES se em algum momento esse aviso já foi exibido.
    //
    NSString *nomeDaAba = [NSString stringWithFormat:@"%@", [self class]];
    if (![VidaParceladaHelper retornaEstadoApresentacaoInicialAba:nomeDaAba]) {
        [self.datasAlert show];
    }
    
    //NSLog(@"(<) viewWillAppear: ");

}
- (IBAction)uiSwitchCartaoPreferencialChanged:(UISwitch *)sender {
    //NSLog (@"(>) uiSwitchCartaoPreferencialChanged: %@", sender);
    
    if (self.contaSelecionada) {
        self.contaSelecionada.preferencial = [NSNumber numberWithBool:sender.on];
    }
    
    //NSLog (@"(<) uiSwitchCartaoPreferencialChanged: ");

}

// Atualiza os campos da tela atual com os dados da conta passados
// pelo controller pai.
- (void)atualizarCamposNaTela
{
    if (self.contaSelecionada) {
        //
        // Mostrando dados da conta.
        //
        self.tfDescricaoDaConta.text = self.contaSelecionada.descricao;
        self.tfEmpresa.text = self.contaSelecionada.empresa;
        self.tfLimiteTotal.text = [self.valorFormatter stringFromNumber:self.contaSelecionada.limite];
        self.cellTipoConta.textLabel.text = self.contaSelecionada.tipo.nome;
        self.cellTipoConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
        self.stepperMelhorDia.value = [self.contaSelecionada.melhorDiaDeCompra doubleValue];
        self.tfMelhorDia.text = [NSString stringWithFormat:@"%2.0f", [self.contaSelecionada.melhorDiaDeCompra doubleValue]];
        self.stepperVencimento.value = [self.contaSelecionada.diaDeVencimento doubleValue];
        self.tfDiaVencimento.text = [NSString stringWithFormat:@"%2.0f", [self.contaSelecionada.diaDeVencimento doubleValue]];
        self.uiSwitchCartaoPreferencial.on = [self.contaSelecionada.preferencial boolValue];
        self.tfJuros.text = [self.percentFormatter stringFromNumber:self.contaSelecionada.jurosMes];
        // tipo existente
        self.cellTipoConta.textLabel.text = self.contaSelecionada.tipo.nome;
        self.cellTipoConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
    } else {
        //
        // Conta ainda não foi criada
        //
        self.tfDescricaoDaConta.text = @"";
        self.tfEmpresa.text = @"";
        self.tfLimiteTotal.text = [self.valorFormatter stringFromNumber:0];
        self.tfJuros.text = [self.percentFormatter stringFromNumber:0];
        self.cellTipoConta.textLabel.text = self.contaSelecionada.tipo.nome;
        self.cellTipoConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
        self.stepperMelhorDia.value = [@"01" doubleValue];
        self.tfMelhorDia.text = @"01";
        self.stepperVencimento.value = [@"01" doubleValue];
        self.tfDiaVencimento.text = @"01";
        self.uiSwitchCartaoPreferencial.on = YES;
        // default
        self.cellTipoConta.textLabel.text = self.tipoContaSelecionada.nome;
        self.cellTipoConta.detailTextLabel.text = self.tipoContaSelecionada.descricao;
    }
}


// Atribui o tipo da conta escolhida na conta atual
- (void)tipoContaEscolhido:(TipoConta *)tipoConta
{
    self.cellTipoConta.textLabel.text = tipoConta.nome;
    self.cellTipoConta.detailTextLabel.text = tipoConta.descricao;
    self.tipoContaSelecionada = tipoConta;
    if (self.contaSelecionada) {
        self.contaSelecionada.tipo = self.tipoContaSelecionada;
    }
}

// Chamado quando o valor do stepper de vencimento muda de estado
- (IBAction)stepperVencimentoValueChanged:(UIStepper *)sender {
    self.tfDiaVencimento.text = [NSString stringWithFormat:@"%2.0f", sender.value];
    if (self.contaSelecionada) {
        self.contaSelecionada.diaDeVencimento = [NSDecimalNumber numberWithDouble:sender.value];
    }
}

// Chamado quando o valor do stepper de melhor fia muda de estado
- (IBAction)stepperMelhorDiaValueChanged:(UIStepper *)sender {
    self.tfMelhorDia.text = [NSString stringWithFormat:@"%2.0f", sender.value];
    if (self.contaSelecionada) {
        self.contaSelecionada.melhorDiaDeCompra = [NSDecimalNumber numberWithDouble:sender.value];
    }

}

// Chamado quando a edição no campo descrição da conta termina
- (IBAction)tfDescricaoDaContaEditingDidEnd:(UITextField *)sender {
    if (self.contaSelecionada) {
        self.contaSelecionada.descricao = self.tfDescricaoDaConta.text;
    }
}

// Chamado quando a edição no campo empresa termina
- (IBAction)tfEmpresaEditingDidEnd:(UITextField *)sender {
    if (self.contaSelecionada) {
        self.contaSelecionada.empresa = self.tfEmpresa.text;
    }
}

// Chamado quando a edição no campo limite total inicia
- (IBAction)tfLimiteTotalDidBegin:(UITextField *)sender {
}

// Chamado quando a edição no campo limite total termina
- (IBAction)tfLimiteTotalEditingDidEnd:(UITextField *)sender {
    if (self.contaSelecionada) {
        if ([sender.text length] > 0) {
            NSNumber *valor;
            valor = [self.valorFormatter numberFromString:sender.text];
            self.contaSelecionada.limite = [NSDecimalNumber decimalNumberWithString:[valor stringValue]];
        }
    }
}

// Chamado quando a edição no campo juros inicia
- (IBAction)tfJurosEditingDidBegin:(UITextField *)sender {
}

// Chamado quando a edição no campo juros termina
- (IBAction)tfJurosEditingDidEnd:(UITextField *)sender {
    if (self.contaSelecionada) {
        if ([sender.text length] > 0) {
            NSNumber *juros = [self.percentFormatter numberFromString:sender.text ];
            NSDecimalNumber *jurosMes = [NSDecimalNumber decimalNumberWithString:[juros stringValue]];
           self.contaSelecionada.jurosMes = jurosMes;
        }
    }
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
    if (!self.contaSelecionada) {
        self.tipoContaSelecionada = [Conta retornaTipoContaPadraoNoContexto:self.vpDatabase.managedObjectContext];
    } else {
        self.tipoContaSelecionada = self.contaSelecionada.tipo;
        // Se a conta existir não exite opção de cancelar, apenas salvar.
        self.topBar.rightBarButtonItem = nil;
    }
    [self atualizarCamposNaTela];

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
    [self setContaSelecionada:nil];
    [self setTipoContaSelecionada:nil];
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
    [self setBtnSalvar:nil];
    [self setBtnCancelar:nil];
    [self setTopBar:nil];
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
