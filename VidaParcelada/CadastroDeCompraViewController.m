//
//  CadastroDeCompraViewController.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 22/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
//

#import "CadastroDeCompraViewController.h"
#import "VidaParceladaHelper.h"
#import "EscolherContaViewController.h"

@interface CadastroDeCompraViewController ()

- (void)animateDataPicker:(NSDate *)date;
- (IBAction)removeDataPickerAnimaed:(id)sender;
- (BOOL)verificaDataDaCompraAvisaUsuario;
- (void)calculaValorTotal;
- (void)calculaValorDaParcela;
- (void)atualizarCamposNaTela;
- (void)inicializarTela;

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
@synthesize btCancelar = _btCancelar;
@synthesize tfValorDaParcela = _tfValorDaParcela;
@synthesize datePicker = _datePicker;
@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;
@synthesize compraSelecionada = _compraSelecionada;
@synthesize contaSelecionada = _contaSelecionada;
@synthesize dataSelecionada = _dataSelecionada;
@synthesize algumCampoFoiAlterado = _algumCampoFoiAlterado;
@synthesize topBar = _topBar;
@synthesize btDataOk = _doneButton;
@synthesize listaDeContas = _listaDeContas;
@synthesize considerarParcelasAnterioresPagas = _considerarParcelasAnterioresPagas;
@synthesize actionSheetVencimento = _actionSheetVencimento;
@synthesize actionSheetApagarParcelas = _actionSheetApagarParcelas;
@synthesize tfDetalhesDaCompra = _tfDetalhesDaCompra;
@synthesize contaEscolhidaDelegate = _contaEscolhidaDelegate;
@synthesize datasAlert = _datasAlert;
@synthesize contaDeletedAlert = _contaDeletedAlert;

- (UIAlertView *)datasAlert
{
    if (!_datasAlert) {
        NSString *texto = NSLocalizedString(@"cadastro.compra.popup.datacompra", @"Data da compra");
        NSString *titulo = NSLocalizedString(@"titulo.atencao", @"Atenção!");
        _datasAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    return _datasAlert;
}

- (UIAlertView *)contaDeletedAlert
{
    if (!_contaDeletedAlert) {
        NSString *texto = NSLocalizedString(@"cadastro.compra.conta.apagada", @"Conta desta compra foi apagada");
        NSString *titulo = NSLocalizedString(@"titulo.atencao", @"Atenção!");
        _contaDeletedAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    return _contaDeletedAlert;
}

- (IBAction)tfValorDaParcelaDidEndOnExit:(UITextField *)sender {
    self.algumCampoFoiAlterado = YES;
    [sender resignFirstResponder];
    [self calculaValorTotal];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Usuário confirmou que viu o primeiro aviso da tela.
    if (alertView == self.datasAlert) {
        // atualiza o estado para exibido
        NSString *nomeDaAba = [NSString stringWithFormat:@"%@", [self class]];
        [VidaParceladaHelper salvaEstadoApresentacaoInicialAba:nomeDaAba exibido:YES];
    } else if (alertView == self.contaDeletedAlert) {
        // Cancela tudo
        [self exitThisController];
    }
}

- (IBAction)bVencimentosDatas:(UIButton *)sender {
    [self.datasAlert show];
}

- (UIActionSheet *)actionSheetVencimento
{
    if (_actionSheetVencimento == nil) {
        NSString *titulo = NSLocalizedString(@"cadastro.compra.marcar.parcelas", @"Marcar parcelas como");
        _actionSheetVencimento = [[UIActionSheet alloc] initWithTitle:titulo
                                                             delegate:self
                                                    cancelButtonTitle:@"Parcelas já pagas"
                                               destructiveButtonTitle:@"Pendente pagamento"
                                                    otherButtonTitles:nil];
    }
    return _actionSheetVencimento;
}

- (UIActionSheet *)actionSheetApagarParcelas
{
    if (_actionSheetApagarParcelas == nil) {
        NSString *titulo = NSLocalizedString(@"cadastro.compra.apagar.parcelas", @"Ação ao apagar parcelas");
        _actionSheetApagarParcelas = [[UIActionSheet alloc] initWithTitle:titulo
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancelar atualização"
                                                   destructiveButtonTitle:@"Recriar parcelas"
                                                        otherButtonTitles:nil];
    }
    return _actionSheetApagarParcelas;
}


- (NSArray *)listaDeContas
{
    if (_listaDeContas == nil) {
        _listaDeContas = [[NSArray alloc] init];
    }
    return _listaDeContas;
}

- (UIDatePicker *)datePicker
{
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        [_datePicker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

#pragma mark - AlteracaoDeContaDelegate

@synthesize compraDelegate = _compraDelegate;
@synthesize tfDataCompra = _tfDataCompra;

#pragma mark - Table View
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)atualizaDescricaoDaConta
{
    // Mostra os dados da conta. Se a conta não tem descriçao usa os dados
    // do tipo da conta no seu lugar.
    if (self.contaSelecionada.descricao && [self.contaSelecionada.descricao length] > 0) {
        self.cellConta.textLabel.text = self.contaSelecionada.descricao;
        self.cellConta.detailTextLabel.text = self.contaSelecionada.empresa;
    } else {
        self.cellConta.textLabel.text = self.contaSelecionada.tipo.nome;
        self.cellConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
    }
}

- (void)atualizarCamposNaTela
{
    self.algumCampoFoiAlterado = NO;
    
    self.tfDescricao.text = self.compraSelecionada.descricao;
    self.tfDetalhesDaCompra.text = self.compraSelecionada.detalhes;
    self.contaSelecionada = self.compraSelecionada.origem;
    self.dataSelecionada = self.compraSelecionada.dataDaCompra;

    [self atualizaDescricaoDaConta];

    self.tfDataCompra.text = [self.dateFormatter stringFromDate:self.compraSelecionada.dataDaCompra];
    
    // Stepper de parcela
    self.stepperQtdeDeParcelas.value = [self.compraSelecionada.qtdeTotalDeParcelas doubleValue];
    self.tfQtdeDeParcelas.text = [NSString stringWithFormat:@"%2.0f", [self.compraSelecionada.qtdeTotalDeParcelas doubleValue]];

    self.tfValorTotal.text = [self.valorFormatter stringFromNumber:self.compraSelecionada.valorTotal];
    [self calculaValorDaParcela];
}

- (void)inicializarTela
{
    NSDate *hoje = [[NSDate alloc] init];

    self.dataSelecionada = hoje;
    self.contaSelecionada = [Compra retornaContaDefaultNoContexto:self.vpDatabase.managedObjectContext];
    
    self.tfDescricao.text = @"";
    self.tfDetalhesDaCompra.text = @"";
    
    // valor do steeper vem das configurações do aplicativo
    double qtdeParcela = [[VidaParceladaHelper retornaNumeroDeParcelasPadrao] doubleValue];
    self.stepperQtdeDeParcelas.value = qtdeParcela;
    self.tfQtdeDeParcelas.text = [NSString stringWithFormat:@"%2.0f", qtdeParcela];
    
    self.tfValorTotal.text = [self.valorFormatter stringFromNumber:0];
    self.tfValorDaParcela.text = [self.valorFormatter stringFromNumber:0];
    
    self.tfDataCompra.text = [self.dateFormatter stringFromDate:self.dataSelecionada];
    
    [self atualizaDescricaoDaConta];

    [self calculaValorDaParcela];
    
    [self calculaValorTotal];
}

- (void)viewDidLoad
{

    [super viewDidLoad];

    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
    // Se o controller receber uma conta selecionada temos que atualizar os campos
    // com os dados dessa conta.
    self.listaDeContas = [Conta contasCadastradasUsandoContext:self.vpDatabase.managedObjectContext];
    if (self.compraSelecionada) {
        //self.topBar.rightBarButtonItem = nil;
        [self atualizarCamposNaTela];
    } else {
        [self inicializarTela];
    }

    self.tfDataCompra.inputView = self.datePicker;

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);

    // Display banners
    self.displayAds = YES;
    [super viewWillAppear:animated];
    
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

- (void)viewDidUnload
{
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
    [self setTopBar:nil];
    [self setBtDataOk:nil];
    [self setDatePicker:nil];
    [self setBtCancelar:nil];
    [self setActionSheetVencimento:nil];
    [self setActionSheetApagarParcelas:nil];
    [self setTfValorDaParcela:nil];
    [self setTfDetalhesDaCompra:nil];
    [self setTfDataCompra:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

// avisa quando a conta for escolhida com sucesso.
- (void)contaEscolhida:(Conta *)conta
{
    if (self.contaSelecionada != conta) {
        self.algumCampoFoiAlterado = YES;
    }
    self.contaSelecionada = conta;
    [self atualizaDescricaoDaConta];
}

// Temos que passar o banco de dados que abrimos aqui
// no primeiro controller do app para todos
// os outros controllers. Dessa forma todos terao um atributo
// UIManagedDocument *vpDatabase implementado.
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController respondsToSelector:@selector(setVpDatabase:)]){
        [segue.destinationViewController setVpDatabase:self.vpDatabase];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setContaSelecionada:)]){
        [segue.destinationViewController setContaSelecionada:self.contaSelecionada];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setContaDelegate:)]) {
        [segue.destinationViewController setContaDelegate:self];
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
    
    if (!self.tfDescricao.text) self.tfDescricao.text = @"";
    if (!self.tfDetalhesDaCompra.text) self.tfDetalhesDaCompra.text = @"";
    
    Compra *novaCompra = [Compra compraComDescricao:self.tfDescricao.text
                                        comDetalhes:self.tfDetalhesDaCompra.text
                                       dataDaCompra:self.dataSelecionada 
                                          comEstado:COMPRA_PENDENTE_PAGAMENTO 
                                     qtdeDeParcelas:qtdeParcelas
                                         valorTotal:[NSDecimalNumber decimalNumberWithString:[valor stringValue]]
                                           comConta:self.contaSelecionada
                         assumirAnterioresComoPagas:self.considerarParcelasAnterioresPagas
                                          inContext:self.vpDatabase.managedObjectContext];

    // Notifica o delegate que a compra mudou
    self.compraSelecionada = novaCompra;
    [self.compraDelegate compraFoiAlterada:self.compraSelecionada];

}

- (void)atualizarCompraAtual {
    
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
    
    if (!self.tfDescricao.text) self.tfDescricao.text = @"";
    if (!self.tfDetalhesDaCompra.text) self.tfDetalhesDaCompra.text = @"";

    self.compraSelecionada.descricao = self.tfDescricao.text;
    self.compraSelecionada.detalhes = self.tfDetalhesDaCompra.text;
    self.compraSelecionada.dataDaCompra = self.dataSelecionada;
    self.compraSelecionada.estado = COMPRA_PENDENTE_PAGAMENTO;
    self.compraSelecionada.qtdeTotalDeParcelas = qtdeParcelas;
    self.compraSelecionada.valorTotal = [NSDecimalNumber decimalNumberWithString:[valor stringValue]];
    self.compraSelecionada.origem = self.contaSelecionada;
    
    // Se a compra existir temos que recriar as parcelas, isso significa apagar as atuais
    // e recriar
    [Compra apagarParcelasDaCompra:self.compraSelecionada inContext:self.vpDatabase.managedObjectContext];
    
    // recriar parcelas
    [Compra criarParcelasDaCompra:self.compraSelecionada assumirAnterioresComoPagas:self.considerarParcelasAnterioresPagas inContext:self.vpDatabase.managedObjectContext];
    
    [self.compraDelegate compraFoiAlterada:self.compraSelecionada];
}

- (BOOL)verificaDataDaCompraAvisaUsuario
{
    BOOL resposta = NO;
    NSDate *vencimento = [Compra calculaVencimentoDaParcela:self.contaSelecionada dataDaCompra:self.dataSelecionada numDaParcela:1];
    // A parcela deveria já ter sido paga se o vencimento da primeira parcela
    // for menor que a data atual
    NSDate *dataAtual = [[NSDate alloc] init];
    if ([[vencimento earlierDate:dataAtual] isEqualToDate:vencimento]) {
        
        [self.actionSheetVencimento showFromTabBar:self.tabBarController.tabBar];
        resposta = YES;
    }
    return resposta;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Verifica qual action sheet foi chamado
    if (actionSheet == self.actionSheetVencimento) {
        // Action sheet do estado das parcelas
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            // Considerar parcelas anteriores pendentes de pagamento
            self.considerarParcelasAnterioresPagas = NO;
        
            // Mudamos a mensagem então
            NSString *titulo = NSLocalizedString(@"cadastro.compra.apagar.parcelaspendente", @"Ação ao apagar parcelas pendentes");
            _actionSheetApagarParcelas = [[UIActionSheet alloc] initWithTitle:titulo
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancelar atualização"
                                                       destructiveButtonTitle:@"Recriar parcelas"
                                                            otherButtonTitles:nil];

        } else if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // Considerar parcelas anteriores pagas.
            self.considerarParcelasAnterioresPagas = YES;
        }
        // É uma alteração de uma compra existente?
        if (self.algumCampoFoiAlterado && self.compraSelecionada) {
            [self.actionSheetApagarParcelas showFromTabBar:self.tabBarController.tabBar];
        } else {
            [self salvarDados];
        }
    } else if (actionSheet == self.actionSheetApagarParcelas) {
        // Action sheet informando que as parcelas precisam ser recriadas.
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            // Apagar Parcelas.
            [self salvarDados];
        } else if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // Considerar parcelas anteriores pendentes de pagamento
            [self exitThisController];
        }
    }
}


- (void)exitThisController {
    // Se alguma das view estiver na tela remove    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)salvarDados {
    // cria apenas se não existir
    if (!self.compraSelecionada) {
        [self criarNovaCompra];
    } else {
        [self atualizarCompraAtual];
    }    
    [self exitThisController];
}

- (IBAction)onSalvarPressionado:(id)sender {
    
    if (self.compraSelecionada && self.compraSelecionada.origem.managedObjectContext == nil) {
        // A compra foi apagada ou a sua conta, de qualquer forma não faz sentido fazer
        // mais nada com ela
        [self.contaDeletedAlert show];
    } else     
    if (![self verificaDataDaCompraAvisaUsuario]) {
        if (self.algumCampoFoiAlterado && self.compraSelecionada) {
            [self.actionSheetApagarParcelas showFromTabBar:self.tabBarController.tabBar];
        } else {
            [self salvarDados];
        }
    }
    
}

- (IBAction)onCancelarPressionado:(id)sender {   
    [self exitThisController];
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
        
        [VidaParceladaHelper formataValor:textField
                               novoDigito:string 
                                 comRange:range 
                          usandoFormatter:self.valorFormatter
                           eQtdeDeDigitos:8];
        result = NO;
        
        [self calculaValorDaParcela];
        
    } else if (textField == self.tfValorDaParcela) {
        
        [VidaParceladaHelper formataValor:textField
                               novoDigito:string 
                                 comRange:range 
                          usandoFormatter:self.valorFormatter
                           eQtdeDeDigitos:8];
        result = NO;
        
        [self calculaValorTotal];
        
    } else if (textField == self.tfDataCompra) {
        
        result = NO;
        
    }

    
    return result;
}

- (void)calculaValorTotal {
    // calcula o valor total a partir do valor das parcelas dessa compra
    NSNumber *valorTmp;
    valorTmp = [self.valorFormatter numberFromString:self.tfValorDaParcela.text];
    
    if ([valorTmp intValue] > 0 && self.stepperQtdeDeParcelas.value > 0.0) {
        
        NSDecimalNumber *valorParcela = [NSDecimalNumber decimalNumberWithString:[valorTmp stringValue]];
        NSDecimalNumber *qtdeDecimal = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:self.stepperQtdeDeParcelas.value] decimalValue]];
        NSDecimalNumber *valorTotal = [valorParcela decimalNumberByMultiplyingBy:qtdeDecimal];
        self.tfValorTotal.text = [self.valorFormatter stringFromNumber:valorTotal];
                
    } else {
        
        self.tfValorTotal.text =  [self.valorFormatter stringFromNumber:[NSNumber numberWithInt:0]];  
        
    }
}


- (void)calculaValorDaParcela {
    // calcula o valor das parcelas dessa compra
    NSNumber *valorTmp;
    valorTmp = [self.valorFormatter numberFromString:self.tfValorTotal.text];
    if ([valorTmp intValue] > 0 && self.stepperQtdeDeParcelas.value > 0.0) {
        NSDecimalNumber *valorTotal = [NSDecimalNumber decimalNumberWithString:[valorTmp stringValue]];
        NSDecimalNumber *qtdeDecimal = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:self.stepperQtdeDeParcelas.value] decimalValue]];
        NSDecimalNumber *valorParcela = [valorTotal decimalNumberByDividingBy:qtdeDecimal];
        
        // Alteração para entrar com o valor da parcela manualmente.
        self.tfValorDaParcela.text = [self.valorFormatter stringFromNumber:valorParcela];
        
    } else {
        
        // Alteração para entrar com o valor da parcela manualmente.
        self.tfValorDaParcela.text = [self.valorFormatter stringFromNumber:[NSNumber numberWithInt:0]]; 

    }
}

- (IBAction)stepperQtdeDeParcelasValueChanged:(UIStepper *)sender {
    self.algumCampoFoiAlterado = YES;
    self.tfQtdeDeParcelas.text = [NSString stringWithFormat:@"%2.0f",sender.value];    
    
    // verifica em qual campo estamos e reage alterando o
    // total ou o valor da parcela.
    if ([self.tfValorTotal isFirstResponder]) {
        // Se estamos no valorTotal
        [self calculaValorDaParcela];
    } else if ([self.tfValorDaParcela isFirstResponder]) {
        // se estamos no valor da parcela
        [self calculaValorTotal];
    } else {
        // Não estamos em nenhum campo, assume a parcela.
        [self calculaValorDaParcela];
    }
}

- (IBAction)tfDescricaoEditingDidEnd:(UITextField *)sender {
    // somente atualiza se a conta já tiver sido criada.
   [sender resignFirstResponder];
}

- (IBAction)tfValorTotalEditingDidEnd:(UITextField *)sender {
    self.algumCampoFoiAlterado = YES;
    [sender resignFirstResponder];
    [self calculaValorDaParcela];
}

#pragma mark - Table view data source

- (IBAction)tfDataCompraEdit:(UITextField *)sender {
    NSDate *date = [self.dateFormatter dateFromString:self.tfDataCompra.text];        
    [self animateDataPicker:date];

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    // Se o teclado estiver ativo remove
    if (self.tfDescricao.isFirstResponder) {
        [self.tfDescricao resignFirstResponder];
    } else if (self.tfQtdeDeParcelas.isFirstResponder) {
        [self.tfQtdeDeParcelas resignFirstResponder];
    } else if (self.tfValorDaParcela.isFirstResponder) {
        [self.tfValorDaParcela resignFirstResponder];
    } else if (self.tfValorTotal.isFirstResponder) {
        [self.tfValorTotal resignFirstResponder];
    } else if (self.tfDataCompra.isFirstResponder) {
        [self.tfDataCompra resignFirstResponder];
    }
    
    if (cell == self.cellDataDaCompra) {
        // Data selecionada
        NSDate *date = [self.dateFormatter dateFromString:self.tfDataCompra.text];        
        [self animateDataPicker:date];
    }
        
}

- (void)animateDataPicker:(NSDate *)date
{
    self.datePicker.date = date;
    
    [self.tfDataCompra becomeFirstResponder];

    // Remover botões e adicionar o "pronto"
    self.topBar.leftBarButtonItem = self.btDataOk;
    self.topBar.rightBarButtonItem = nil;
}

- (IBAction)dateAction:(id)sender
{
    self.tfDataCompra.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    self.dataSelecionada = self.datePicker.date;
    self.algumCampoFoiAlterado = YES;
}


- (void)putSaveAndCancelButtonsBack
{
    // devolve os botões ao nav bar
    if (self.topBar.rightBarButtonItem != self.btCancelar) {
        self.topBar.rightBarButtonItem = self.btCancelar;
    }
    if (self.topBar.leftBarButtonItem != self.btSave) {
        self.topBar.leftBarButtonItem = self.btSave;        
    }
}

- (IBAction)removeDataPickerAnimaed:(id)sender
{

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    // the date picker has finished sliding downwards, so remove it
    [self.datePicker removeFromSuperview];
    [self putSaveAndCancelButtonsBack];
    
    [self.tfDataCompra resignFirstResponder];
	
}

@end
