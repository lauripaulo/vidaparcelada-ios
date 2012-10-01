//
//  OptionsTableViewController.m
//  VidaParcelada
//
//  Created by Lauri Laux on 24/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsTableViewController.h"
#import "VidaParceladaHelper.h"
#import "MKStoreManager.h"
#import "WaitView.h"

@interface OptionsTableViewController ()

// mantem referência para o último UITextFiled ativo
// utilizado para posicionar o teclado virtual
@property UITextView *activeField;

@property (retain) NSNumberFormatter *percentFormatter;
@property (retain) NSNumberFormatter *valorFormatter;

@property (nonatomic, strong)  WaitView *waitView;

@end


@implementation OptionsTableViewController

@synthesize activeField = _activeField;
@synthesize percentFormatter = _percentFormatter;
@synthesize valorFormatter = _valorFormatter;
@synthesize vpDatabase = _vpDatabase;
@synthesize tfObjetivoMensal = _tfObjetivoMensal;
@synthesize tfQtdeParcelas = _tfQtdeParcelas;
@synthesize stepperQtdeParcelas = _stepperQtdeParcelas;
@synthesize cellMostrarTutorialNovamente = _cellMostrarTutorialNovamente;
@synthesize cellSobre = _cellSobre;
@synthesize cellComprarPremium = _cellComprarPremium;
@synthesize waitView = _waitView;

-(UIView *) waitView
{
    if (!_waitView) {
        //CGRect screenFrame = CGRectMake(0, 0, 320, 480);
        _waitView = [[[NSBundle mainBundle] loadNibNamed:@"WaitView" owner:self options:nil] objectAtIndex:0];
        CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
        _waitView.frame = screenFrame;
        _waitView.message.text = @"Aguardando iTunes store...";
    }
    return _waitView;
}


//
// Codigo de gerenciamento do teclado
//

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)stepperQtdeParcelasValueChanged:(UIStepper *)sender {
    NSNumber *valor = [NSDecimalNumber numberWithDouble:sender.value];
    self.tfQtdeParcelas.text = [NSString stringWithFormat:@"%2.0f", sender.value];
    [VidaParceladaHelper salvaNumeroDeParcelasPadrao:valor];
}

// Outlet para avisar quando a edição do objetivo terminar e para
// que o teclado seja dispensado e o valor salvo no NSUserDefaults
- (IBAction)tfObjetivoMensalEditingDidEnd:(UITextField *)sender {
    [VidaParceladaHelper salvaLimiteDeGastoGlobalStr:sender.text];
}

//This method comes from UITextFieldDelegate 
//and this is the most important piece of mask
//functionality.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = YES;
    
    if (textField == self.tfObjetivoMensal) {
        
        [VidaParceladaHelper formataValor:textField 
                               novoDigito:string 
                                 comRange:range 
                          usandoFormatter:self.valorFormatter
                           eQtdeDeDigitos:8];
        result = NO;
        
    } 
    
    return result;
}

// sobrescreve o setter para o BD do VP
// e inicializa o fetchResultsController
- (void) setVpDatabase:(UIManagedDocument *)mangedDocument
{
    if (_vpDatabase != mangedDocument) {
        _vpDatabase = mangedDocument;
        //
        // Inicializações adicionais
        //
    }
}

- (void)updatePremiumCell
{
    self.cellComprarPremium.textLabel.text = @"Você comprou a versão premium.";
    self.cellComprarPremium.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) viewWillAppear:(BOOL)animated
{
    //NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);

    [super viewWillAppear:animated];
    
    // Ja comprei a versão premium? Altera botão de compra.
    if ([MKStoreManager isFeaturePurchased:@"VPPREMIUM"]) {
        [self updatePremiumCell];
    }
    //NSLog(@"(<) viewWillAppear: ");
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.tfObjetivoMensal.text = [VidaParceladaHelper retornaLimiteDeGastoGlobalStr];
    
    // steeper de parcelas
    double qtdeParcelas = [[VidaParceladaHelper retornaNumeroDeParcelasPadrao] doubleValue];
    self.stepperQtdeParcelas.value = qtdeParcelas;
    self.tfQtdeParcelas.text = [NSString stringWithFormat:@"%2.0f", qtdeParcelas];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setTfObjetivoMensal:nil];
    [self setTfQtdeParcelas:nil];
    [self setStepperQtdeParcelas:nil];
    [self setCellMostrarTutorialNovamente:nil];
    [self setCellSobre:nil];
    [self setCellComprarPremium:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (cell == self.cellMostrarTutorialNovamente) {
        [VidaParceladaHelper resetaTodosOsEstadosApresentacaoInicialAba];
    } else if (cell == self.cellComprarPremium) {

        // Ja comprei? Ignora compra
        if ([MKStoreManager isFeaturePurchased:@"VPPREMIUM"]) {
            UIAlertView *alertView;
            alertView = [[UIAlertView alloc] initWithTitle:@"Compra" message:@"Obrigado por comprar a versão premium!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        
        // Ainda não comprou? Realiza compra!
        // Adiciona relógio a abertura
        [self.tabBarController.view addSubview:self.waitView];
        [self.waitView.acitivity startAnimating];
        
        [[MKStoreManager sharedManager] buyFeature:@"VPPREMIUM"
            onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads)
         {
             NSLog(@"Purchased: %@", purchasedFeature);
             [self updatePremiumCell];
             UIAlertView *alertView;
             alertView = [[UIAlertView alloc] initWithTitle:@"Compra" message:@"Obrigado por comprar a versão premium!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
             [alertView show];
         }
            onCancelled:^
         {
             UIAlertView *alertView;
             alertView = [[UIAlertView alloc] initWithTitle:@"Compra" message:@"Não foi possível realizar a compra, tente novamente mais tarde." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
             [alertView show];
         }];
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Libera o app para uso
    [self.waitView removeFromSuperview];
}
@end
