//
//  CadastroDeCompraViewController.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 22/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
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
@synthesize contaSelecionada = _contaSelecionada;
@synthesize dataSelecionada = _dataSelecionada;
@synthesize algumCampoFoiAlterado = _algumCampoFoiAlterado;

- (void)algumCampoFoiAlterado:(BOOL)val
{
    if (_algumCampoFoiAlterado != val) {
        _algumCampoFoiAlterado = val;
    }
}

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

    self.cellDataDaCompra.textLabel.text = @"Data da compra";
    self.cellDataDaCompra.detailTextLabel.text = [self.dateFormatter stringFromDate:self.compraSelecionada.dataDaCompra];
    
    // Stepper de parcela
    self.stepperQtdeDeParcelas.value = [self.compraSelecionada.qtdeTotalDeParcelas doubleValue];
    self.tfQtdeDeParcelas.text = [NSString stringWithFormat:@"%2.0f", [self.compraSelecionada.qtdeTotalDeParcelas doubleValue]];

    self.tfValorTotal.text = [self.valorFormatter stringFromNumber:self.compraSelecionada.valorTotal];
}

- (void)inicializarTela
{
    NSDate *hoje = [[NSDate alloc] init];

    self.dataSelecionada = hoje;
    self.contaSelecionada = [Compra retornaContaDefaultNoContexto:self.vpDatabase.managedObjectContext];
    
    self.tfDescricao.text = @"";
    self.stepperQtdeDeParcelas.value = 3;
    self.tfQtdeDeParcelas.text = @"3";
    self.tfValorTotal.text = [self.valorFormatter stringFromNumber:0];
    self.cellDataDaCompra.textLabel.text = @"Data da compra";
    self.cellDataDaCompra.detailTextLabel.text = [self.dateFormatter stringFromDate:self.dataSelecionada];
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
        [self inicializarTela];
    }

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    [self setValorFormatter:nil];
    [self setDateFormatter:nil];
    [self setCompraSelecionada:nil];
    [self setContaSelecionada:nil];
    [self setDataSelecionada:nil];
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
    }
}

#pragma mark - Eventos

- (void)criarNovaCompra {
    // Qual o numero de parcelas que foi escolhido pelo usuario?
    NSNumber *qtdeParcelas = [NSNumber numberWithDouble:self.stepperQtdeDeParcelas.value];
    NSNumber *valor;
    
    // Se o usuário não informar o valor da campra vamos
    // assumir que é zero nesse primeiro momento para evitar erros
    if (self.tfValorTotal.text) {
        valor = [self.valorFormatter numberFromString:self.tfValorTotal.text];
    } else {
        valor = [NSNumber numberWithInt:0];
    }
    
    self.compraSelecionada = [Compra compraComDescricao:self.tfDescricao.text
                                           dataDaCompra:self.dataSelecionada 
                                              comEstado:COMPRA_PENDENTE_PAGAMENTO 
                                         qtdeDeParcelas:qtdeParcelas
                                             valorTotal:[NSDecimalNumber decimalNumberWithString:[valor stringValue]]
                                               comConta:self.contaSelecionada
                                              inContext:self.vpDatabase.managedObjectContext];
    NSLog(@"Criado nova compra: %@", self.compraSelecionada);
}

- (void)atualizarCompraAtual {
    // Se a compra existir temos que recriar as parcelas, isso significa apagar as atuais
    // e recriar
    [Compra apagarParcelasDaCompra:self.compraSelecionada inContext:self.vpDatabase.managedObjectContext];
    
    // recriar parcelas
    [Compra criarParcelasDaCompra:self.compraSelecionada inContext:self.vpDatabase.managedObjectContext];
}

- (IBAction)onSalvarPressionado:(id)sender {
    
    
    // cria apenas se não existir
    if (!self.compraSelecionada) {
        [self criarNovaCompra];
    } else {
        [self atualizarCompraAtual];
    }
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction)onCancelarPressionado:(id)sender {
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

//
// Codigo de gerenciamento do teclado
//

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//This method comes from UITextFieldDelegate 
//and this is the most important piece of mask
//functionality.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = YES;
    
    if (textField == self.tfValorTotal) {
        
        self.algumCampoFoiAlterado = YES;
        
        [VidaParceladaHelper formataValor:textField 
                               novoDigito:string 
                                 comRange:range 
                          usandoFormatter:self.valorFormatter
                           eQtdeDeDigitos:8];
        result = NO;
        
    } 
    
    return result;
}

- (IBAction)stepperQtdeDeParcelasValueChanged:(UIStepper *)sender {
    self.algumCampoFoiAlterado = YES;
    self.tfQtdeDeParcelas.text = [NSString stringWithFormat:@"%2.0f",sender.value];
    // somente atualiza se a conta já tiver sido criada.
    if (self.compraSelecionada) {
        self.compraSelecionada.qtdeTotalDeParcelas = [NSNumber numberWithDouble:sender.value];
        // Notifica o delegate que a compra mudou
        [self.compraDelegate compraFoiAlterada:self.compraSelecionada];
        // Log da Operação
        NSLog(@"self.compraSelecionada.qtdeTotalDeParcelas - valor: %@", self.compraSelecionada.qtdeTotalDeParcelas);
    }
}

- (IBAction)tfDescricaoEditingDidEnd:(UITextField *)sender {
    self.algumCampoFoiAlterado = YES;
    self.compraSelecionada.descricao = self.tfDescricao.text;
    // somente atualiza se a conta já tiver sido criada.
    if (self.compraSelecionada) {
        // Notifica o delegate da alteração
        [self.compraDelegate compraFoiAlterada:self.compraSelecionada];
        [sender resignFirstResponder];
        // Log da operação
        NSLog(@" self.compraSelecionada.descricao - valor: %@",  self.compraSelecionada.descricao);
    }
}

- (IBAction)tfValorTotalEditingDidEnd:(UITextField *)sender {
    self.algumCampoFoiAlterado = YES;
    // somente atualiza se a conta já tiver sido criada.
    if (self.compraSelecionada) {
        if ([sender.text length] > 0) {
            NSNumber *valor;
            valor = [self.valorFormatter numberFromString:sender.text];
            self.compraSelecionada.valorTotal = [NSDecimalNumber decimalNumberWithString:[valor stringValue]];
            // Notifica o delegate da alteração
            [self.compraDelegate compraFoiAlterada:self.compraSelecionada];
            [sender resignFirstResponder];
            // Log da operação  
            NSLog(@"self.contaSelecionada.limiteUsuario - valor: %@", self.compraSelecionada.valorTotal);
        }
    }
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
