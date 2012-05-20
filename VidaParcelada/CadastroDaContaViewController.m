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
@synthesize tfObjetivoMensal = _tfObjetivoMensal;
@synthesize tfJuros = _tfJuros;
@synthesize tfDiaVencimento = _tfDiaVencimento;
@synthesize tfMelhorDia = _tfMelhorDia;
@synthesize stepperVencimento = _stepperVencimento;
@synthesize stepperMelhorDia = _stepperMelhorDia;
@synthesize cellTipoConta = _cellTipoConta;
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
        
    } else if (textField == self.tfObjetivoMensal) {
        
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

// Atualiza os campos da tela atual com os dados da conta passados
// pelo controller pai.
- (void)atualizarCamposNaTela
{
    ;
        
    self.tfDescricaoDaConta.text = self.contaSelecionada.descricao;
    self.tfEmpresa.text = self.contaSelecionada.empresa;
    self.tfLimiteTotal.text = [self.valorFormatter stringFromNumber:self.contaSelecionada.limite];
    self.tfObjetivoMensal.text = [self.valorFormatter stringFromNumber:self.contaSelecionada.limiteUsuario];
    self.tfJuros.text = [self.contaSelecionada.jurosMes stringValue];
    self.tfDiaVencimento.text = [self.contaSelecionada.diaDeVencimento stringValue];
    self.tfMelhorDia.text = [self.contaSelecionada.melhorDiaDeCompra stringValue];
    self.cellTipoConta.textLabel.text = self.contaSelecionada.tipo.nome;
    self.cellTipoConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
    
    self.stepperMelhorDia.value = [self.contaSelecionada.melhorDiaDeCompra doubleValue];
    self.tfMelhorDia.text = [NSString stringWithFormat:@"%2.0f", [self.contaSelecionada.melhorDiaDeCompra doubleValue]];
    
    self.stepperVencimento.value = [self.contaSelecionada.diaDeVencimento doubleValue];
    self.tfDiaVencimento.text = [NSString stringWithFormat:@"%2.0f", [self.contaSelecionada.diaDeVencimento doubleValue]];
    
    // Formatando valores 
    self.tfJuros.text = [self.percentFormatter stringFromNumber:self.contaSelecionada.jurosMes];
    
}


// Atribui o tipo da conta escolhida na conta atual
- (void)tipoContaEscolhido:(TipoConta *)tipoConta
{
    self.contaSelecionada.tipo = tipoConta;
    self.cellTipoConta.textLabel.text = self.contaSelecionada.tipo.nome;
    self.cellTipoConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
}

// Chamado quando o valor do stepper de vencimento muda de estado
- (IBAction)stepperVencimentoValueChanged:(UIStepper *)sender {
    self.tfDiaVencimento.text = [NSString stringWithFormat:@"%2.0f", sender.value];
    self.contaSelecionada.diaDeVencimento = [NSDecimalNumber numberWithDouble:sender.value];
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
    // Log da operação
    NSLog(@"self.contaSelecionada.diaDeVencimento - valor: %@", self.contaSelecionada.diaDeVencimento);
}

// Chamado quando o valor do stepper de melhor fia muda de estado
- (IBAction)stepperMelhorDiaValueChanged:(UIStepper *)sender {
    self.tfMelhorDia.text = [NSString stringWithFormat:@"%2.0f", sender.value];
    self.contaSelecionada.melhorDiaDeCompra = [NSDecimalNumber numberWithDouble:sender.value];
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
    // Log da operação
    NSLog(@"self.contaSelecionada.melhorDiaDeCompra - valor: %@", self.contaSelecionada.melhorDiaDeCompra);

}

// Chamado quando a edição no campo descrição da conta termina
- (IBAction)tfDescricaoDaContaEditingDidEnd:(UITextField *)sender {
    self.contaSelecionada.descricao = self.tfDescricaoDaConta.text;
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
    // Log da operação
    NSLog(@"self.contaSelecionada.descricao - valor: %@", self.contaSelecionada.descricao);
}

// Chamado quando a edição no campo empresa termina
- (IBAction)tfEmpresaEditingDidEnd:(UITextField *)sender {
    self.contaSelecionada.empresa = self.tfEmpresa.text;
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
    // Log da operação
    NSLog(@"elf.contaSelecionada.empresa - valor: %@", self.contaSelecionada.empresa);
}

// Chamado quando a edição no campo limite total inicia
- (IBAction)tfLimiteTotalDidBegin:(UITextField *)sender {
    NSLog(@"tfLimiteTotalDidBegin - valor: %@", sender.text);

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
    // Log da operação
    NSLog(@"self.contaSelecionada.limite - valor: %@", self.contaSelecionada.limite);
}

// Chamado quando a edição no campo limite total inicia
- (IBAction)tfObjetivoMensalDidBegin:(UITextField *)sender {
    NSLog(@"tfObjetivoMensalDidBegin - valor: %@", sender.text);
    
}

// Chamado quando a edição no campo objetivo mensal termina
- (IBAction)tfObjetivoMensalEditingDidEnd:(UITextField *)sender {    
    if ([sender.text length] > 0) {
        NSNumber *valor;
        valor = [self.valorFormatter numberFromString:sender.text];
        self.contaSelecionada.limiteUsuario = [NSDecimalNumber decimalNumberWithString:[valor stringValue]];
        // Notifica o delegate da alteração
        [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
    }
    // Log da operação
    NSLog(@"self.contaSelecionada.limiteUsuario - valor: %@", self.contaSelecionada.limiteUsuario);
}

// Chamado quando a edição no campo juros inicia
- (IBAction)tfJurosEditingDidBegin:(UITextField *)sender {
    NSLog(@"tfJurosEditingDidBegin - valor: %@", sender.text);
}

// Chamado quando a edição no campo juros termina
- (IBAction)tfJurosEditingDidEnd:(UITextField *)sender {
    if ([sender.text length] > 0) {
        self.contaSelecionada.jurosMes = [NSDecimalNumber decimalNumberWithString:sender.text];;
        // Notifica o delegate da alteração
        [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
    } 
    // Log da operação
    NSLog(@"self.contaSelecionada.jurosMes - valor: %@", self.contaSelecionada.jurosMes);
}

// para criar uma conta nos criamos o objeto CoreData com os campos vazios
// também associamos ao primeiro TipoConta que encontramos no banco de dados
- (void)criarNovaConta
{
    self.contaSelecionada = [Conta contaComDescricao:@"" 
                                           daEmpresa:@"" 
                                  comVencimentoNoDia:[NSNumber numberWithInt:1]
                                           eJurosMes:[NSDecimalNumber decimalNumberWithString:@"0"]
                                      comLimiteTotal:[NSDecimalNumber decimalNumberWithString:@"0"]
                                    eLimiteDoUsuario:[NSDecimalNumber decimalNumberWithString:@"0"] 
                                comMelhorDiaDeCompra:[NSNumber numberWithInt:1] 
                                           inContext:self.vpDatabase.managedObjectContext];
    
    [self atualizarCamposNaTela];
    // Notifica o delegate da alteração
    [self.contaDelegate contaFoiAlterada:self.contaSelecionada];
    // Log da operação
    NSLog(@"Criada conta: %@", self.contaSelecionada);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Esconde a toolbar com uma animação massa!
    [UIView animateWithDuration:0.1 animations:^{
        self.navigationController.toolbarHidden = YES;
    } completion:^(BOOL finished) {    
    }];

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

/*
 * Exemplo de popup e retorno
 *
- (IBAction)clickBotaoSalvar:(UIBarButtonItem *)sender {
    // Se a conta que acabamos de criar estiver com descrição vazia devemos perguntar ao usuário e
    // apagar a conta se ele não quiser manter os dados.
    if (!self.contaSelecionada.descricao || [self.contaSelecionada.descricao length] == 0) {
        // Avisar o usuário
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Atenção" 
                                           message:@"Uma conta precisa de uma descrição para ser válida. Informar uma descrição agora?" 
                                          delegate:self 
                                 cancelButtonTitle:@"Sim" 
                                 otherButtonTitles:@"Não", nil];
        [alert show];
    } else {
        // Todos os dados já foram salvos durante a edição
        // de cada campo. Basta voltar a tela anterior
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)clickBotaoCancelar:(UIBarButtonItem *)sender {
    // Se o usuário não quer informar a descrição vamos informar por ele :)
    self.contaSelecionada.empresa = @"Conta sem descrição";
    // E voltar a tela anterior
    [self.navigationController popViewControllerAnimated:YES];
}

// Evento do UIAlertView
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 0)
    {
        NSLog(@"Sim");
        // Seta o "foco" no campo descrição
        [self.tfDescricaoDaConta becomeFirstResponder];
    } else {
        NSLog(@"Não");
        // É o mesmo que cancelar a o cadastro
        [self clickBotaoCancelar:nil];
    }

}
*/

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidUnload
{
    [self setTfDescricaoDaConta:nil];
    [self setTfEmpresa:nil];
    [self setTfLimiteTotal:nil];
    [self setTfObjetivoMensal:nil];
    [self setTfJuros:nil];
    [self setTfDiaVencimento:nil];
    [self setTfMelhorDia:nil];
    [self setStepperVencimento:nil];
    [self setStepperMelhorDia:nil];
    [self setCellTipoConta:nil];
    [self setTableView:nil];
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

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

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
