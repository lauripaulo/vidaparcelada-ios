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

@interface CadastroDeParcelaViewController ()

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
}

- (IBAction)onCancelarPressionado:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        if ([self.parcelaSelecionada.estado isEqualToString:PARCELA_PAGA]) {
            
        } else if ([self.parcelaSelecionada.estado isEqualToString:PARCELA_PENDENTE_PAGAMENTO]) {
        
        } else if ([self.parcelaSelecionada.estado isEqualToString:PARCELA_VENCIDA]) {
        }
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);
    
    [super viewWillAppear: animated];
    
    NSLog(@"(<) viewWillAppear: ");
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
