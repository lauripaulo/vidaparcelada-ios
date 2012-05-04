//
//  CadastroDeCompraViewController.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior Laux on 22/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CadastroDeCompraViewController.h"

@interface CadastroDeCompraViewController ()

@end

@implementation CadastroDeCompraViewController


#pragma mark - Atributos

@synthesize vpDatabase = _vpDatabase;
@synthesize cellConta = _cellConta;
@synthesize cellDataDaCompra = _cellDataDaCompra;
@synthesize tfDescricao = _tfDescricao;
@synthesize tfQtdeDeParcelas = _tfQtdeDeParcelas;
@synthesize stepperQtdeDeParcelas = _stepperQtdeDeParcelas;
@synthesize tfValorTotal = _tfValorTotal;
@synthesize btSave = _btSave;
@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;
@synthesize compraSelecionada = _compraSelecionada;

#pragma mark - AlteracaoDeContaDelegate

@synthesize compraDelegate = _compraDelegate;

#pragma mark - Table View
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)atualizarCamposNaTela
{
    self.tfDescricao.text = self.compraSelecionada.descricao;

    // Mostra os dados da conta. Se a conta não tem descriçao usa os dados
    // do tipo da conta no seu lugar.
    if (self.compraSelecionada.origem.descricao) {
        self.cellConta.textLabel.text = self.compraSelecionada.origem.descricao;
        self.cellConta.detailTextLabel.text = self.compraSelecionada.origem.empresa;
    } else {
        self.cellConta.textLabel.text = self.compraSelecionada.origem.tipo.nome;
        self.cellConta.detailTextLabel.text = self.compraSelecionada.origem.tipo.descricao;
    }

//    self.cellDataDaCompra.textLabel.text = @"";
    self.cellDataDaCompra.detailTextLabel.text = [self.dateFormatter stringFromDate:self.compraSelecionada.dataDaCompra];
    
    // Stepper de parcela
    self.stepperQtdeDeParcelas.value = [self.compraSelecionada.qtdeTotalDeParcelas doubleValue];
    self.tfQtdeDeParcelas.text = [NSString stringWithFormat:@"%2.0f", [self.compraSelecionada.qtdeTotalDeParcelas doubleValue]];

    self.tfValorTotal = _tfValorTotal;
}

- (void)criarNovaCompra
{
    NSDate *hoje = [[NSDate alloc] init];
    self.compraSelecionada = [Compra compraComDescricao:@"Nova compra" 
                                           dataDaCompra:hoje 
                                              comEstado:COMPRA_PENDENTE_PAGAMENTO 
                                         qtdeDeParcelas:[NSNumber numberWithInt:3] 
                                             valorTotal:[NSDecimalNumber decimalNumberWithString:@"0.00"]
                                              inContext:self.vpDatabase.managedObjectContext];
    [self atualizarCamposNaTela];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
        
    // Se o controller receber uma conta selecionada temos que atualizar os campos
    // com os dados dessa conta.
    if (self.compraSelecionada) {
        [self atualizarCamposNaTela];
    } else {
        [self criarNovaCompra];
    }

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setCellConta:nil];
    [self setCellConta:nil];
    [self setCellDataDaCompra:nil];
    [self setTfDescricao:nil];
    [self setTfQtdeDeParcelas:nil];
    [self setStepperQtdeDeParcelas:nil];
    [self setTfValorTotal:nil];
    [self setBtSave:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Eventos

- (IBAction)stepperQtdeDeParcelasValueChanged:(UIStepper *)sender {
    self.tfQtdeDeParcelas.text = [NSString stringWithFormat:@"%2.0f",sender.value];
    self.compraSelecionada.qtdeTotalDeParcelas = [NSNumber numberWithDouble:sender.value];
    // Notifica o delegate que a compra mudou
    [self.compraDelegate compraFoiAlterada:self.compraSelecionada];
    // Log da Operação
    NSLog(@"self.compraSelecionada.qtdeTotalDeParcelas - valor: %@", self.compraSelecionada.qtdeTotalDeParcelas);
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

@end
