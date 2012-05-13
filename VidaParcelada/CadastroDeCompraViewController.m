//
//  CadastroDeCompraViewController.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 22/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "CadastroDeCompraViewController.h"

@interface CadastroDeCompraViewController ()

- (void)animateDataPicker:(NSDate *)date;
- (void)animateContaPicker;
- (IBAction)removeDataPickerAnimaed:(id)sender;
- (IBAction)removeContasPickerAnimated:(id)sender;

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
@synthesize datePicker = _datePicker;
@synthesize contasPickerView = _contasPickerView;
@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;
@synthesize compraSelecionada = _compraSelecionada;
@synthesize contaSelecionada = _contaSelecionada;
@synthesize dataSelecionada = _dataSelecionada;
@synthesize algumCampoFoiAlterado = _algumCampoFoiAlterado;
@synthesize topBar = _topBar;
@synthesize btDataOk = _doneButton;
@synthesize btContaOk = _btContaOk;
@synthesize listaDeContas = _listaDeContas;

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

- (UIPickerView *)contasPickerView
{
    if (_contasPickerView == nil) {
        _contasPickerView = [[UIPickerView alloc] init];
    }
    return _contasPickerView;
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
    if (self.contaSelecionada.descricao || [self.contaSelecionada.descricao length] > 0) {
        self.cellConta.textLabel.text = self.contaSelecionada.descricao;
        self.cellConta.detailTextLabel.text = self.contaSelecionada.empresa;
    } else {
        self.cellConta.textLabel.text = self.contaSelecionada.tipo.nome;
        self.cellConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
    }
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
    self.listaDeContas = [Conta contasCadastradasUsandoContext:self.vpDatabase.managedObjectContext];
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

- (void)viewDidAppear:(BOOL)animated{
    // Esconde a toolbar com uma animação massa!
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.toolbarHidden = YES;
    } completion:^(BOOL finished) {    
    }];
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
    [self setTopBar:nil];
    [self setBtDataOk:nil];
    [self setDatePicker:nil];
    [self setBtCancelar:nil];
    [self setContasPickerView:nil];
    [self setBtContaOk:nil];
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

- (void)exitThisController {
    // Volta o toolbar com uma animação massa.
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.toolbarHidden = NO;
    } completion:^(BOOL finished) {    
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)onSalvarPressionado:(id)sender {
    
    
    // cria apenas se não existir
    if (!self.compraSelecionada) {
        [self criarNovaCompra];
    } else {
        [self atualizarCompraAtual];
    }    
    [self exitThisController];    
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"indexPath=%@", indexPath);

    // Verifica se é a cell que tem a data para trazer o date picker
    if (indexPath.section == 1 && indexPath.row == 1) {
        // Data selecionada
        NSDate *date = [self.dateFormatter dateFromString:cell.detailTextLabel.text];
        [self animateDataPicker:date];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        // Conta selecionada
        [self animateContaPicker];
    } else {
        [self removeDataPickerAnimaed:nil];
    }
    
}

- (void)animateDataPicker:(NSDate *)date
{
    self.datePicker.date = date;
    
    // Se o picker de conta estiver ativo temos que manda-lo embora
    if (self.contasPickerView.superview != nil) {
        [self removeContasPickerAnimated:self];
    }
	
	// check if our date picker is already on screen
	if (self.datePicker.superview == nil)
	{
		[self.view.window addSubview: self.datePicker];
		
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
//        CGRect topBarSize = self.navigationController.navigationBar.bounds;
        
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		self.datePicker.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
        
        // Remover botões e adicionar o "pronto"
        self.topBar.leftBarButtonItem = self.btDataOk;
        self.topBar.rightBarButtonItem = nil;
        // Animação retirada do curso da Stanford
        [UIView animateWithDuration:0.3 animations:^{
            self.datePicker.frame = pickerRect;
            
            // shrink the table vertical size to make room for the date picker
            CGRect newFrame = self.tableView.frame;
            newFrame.size.height -= self.datePicker.frame.size.height ;
            self.tableView.frame = newFrame;
        } completion:^(BOOL finished) {
            // Anima a celula selecionada até ser possivel visualizar
            [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }];
		
	}
}

- (void)animateContaPicker
{	
    // Se o picker de data estiver ativo temos que manda-lo embora
    if (self.datePicker.superview != nil) {
        [self removeDataPickerAnimaed:self];
    }
    
	// check if our date picker is already on screen
	if (self.contasPickerView.superview == nil)
	{
		[self.view.window addSubview: self.contasPickerView];
		
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame      
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [self.contasPickerView sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		self.contasPickerView.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
        
        // Remover botões e adicionar o "pronto"
        self.topBar.leftBarButtonItem = self.btContaOk;
        self.topBar.rightBarButtonItem = nil;
        // Animação retirada do curso da Stanford
        [UIView animateWithDuration:0.3 animations:^{
            self.contasPickerView.frame = pickerRect;
            
            // shrink the table vertical size to make room for the date picker
            CGRect newFrame = self.tableView.frame;
            newFrame.size.height -= self.contasPickerView.frame.size.height;
            self.tableView.frame = newFrame;
        }completion:^(BOOL finished) {
            // Anima a celula selecionada até ser possivel visualizar
            [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }];
		
	}
}

- (IBAction)dateAction:(id)sender
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    self.dataSelecionada = self.datePicker.date;
    // Se for uma alteração vamos atualizar o bd.
    if (self.compraSelecionada) {
        self.compraSelecionada.dataDaCompra = self.dataSelecionada;
    }
}


- (IBAction)removeDataPickerAnimaed:(id)sender
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.datePicker.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
		
    // Animação retirada do curso da Stanford
    [UIView animateWithDuration:0.3 animations:^{
        self.datePicker.frame = endFrame;
        // grow the table back again in vertical size to make room for the date picker
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height += self.datePicker.frame.size.height;
        self.tableView.frame = newFrame;
    }completion:^(BOOL finished) {
        // the date picker has finished sliding downwards, so remove it
        [self.datePicker removeFromSuperview];
        // devolve os botões ao nav bar
        self.topBar.rightBarButtonItem = self.btCancelar;    
        self.topBar.leftBarButtonItem = self.btSave;
        // Anima a celula selecionada até ser possivel visualizar
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
	
	// deselect the current table row
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)removeContasPickerAnimated:(id)sender;
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.contasPickerView.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
    
    // Animação retirada do curso da Stanford
    [UIView animateWithDuration:0.3 animations:^{
        self.contasPickerView.frame = endFrame;
        // grow the table back again in vertical size to make room for the date picker
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height += self.contasPickerView.frame.size.height;
        self.tableView.frame = newFrame;
    }completion:^(BOOL finished) {
        // devolve os botões ao nav bar
        self.topBar.rightBarButtonItem = self.btCancelar;    
        self.topBar.leftBarButtonItem = self.btSave;
        // the date picker has finished sliding downwards, so remove it
        [self.contasPickerView removeFromSuperview];
        // Anima a celula selecionada até ser possivel visualizar
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
	
	// deselect the current table row
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIPickerViewDelegate & DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.listaDeContas count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Conta *conta = (Conta *) [self.listaDeContas objectAtIndex:row];
    return [NSString stringWithFormat:@"%@", conta.descricao];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.contaSelecionada = [self.listaDeContas objectAtIndex:row];
    if (self.contaSelecionada.descricao || [self.contaSelecionada.descricao length] > 0) {
        self.cellConta.textLabel.text = self.contaSelecionada.descricao;
        self.cellConta.detailTextLabel.text = self.contaSelecionada.empresa;
    } else {
        self.cellConta.textLabel.text = self.contaSelecionada.tipo.nome;
        self.cellConta.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
    }
    // Se a compra existir vamos atualizar o db
    if (self.compraSelecionada) {
        self.compraSelecionada.origem = self.contaSelecionada;
    }
    
    [self removeContasPickerAnimated:self];
}

- (void)removeAllPickers {
    // check if our date picker is already on screen
    if (self.contasPickerView.superview != nil)
	{
        [self removeContasPickerAnimated:self];
    }
    if (self.datePicker.superview != nil) {
        [self removeDataPickerAnimaed:self];
    }
}


@end
