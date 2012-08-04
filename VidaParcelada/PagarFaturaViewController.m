//
//  PagarFaturaViewController.m
//  VidaParcelada
//
//  Created by Lauri P. Laux Jr on 01/08/12.
//
//

#import "PagarFaturaViewController.h"
#import "VidaParceladaHelper.h"

@interface PagarFaturaViewController ()

@property (retain) NSNumberFormatter *percentFormatter;
@property (retain) NSNumberFormatter *valorFormatter;

@property (nonatomic, strong) UIAlertView *semNenhumaParcelaPendenteAlert;
@property (nonatomic, strong) UIAlertView *semParcelasPendentesNaContaAlert;
@property (nonatomic, strong) UIAlertView *parcelaPagasComSucessoAlert;
@property (nonatomic, strong) UIAlertView *parcelaPagasAMaiorAlert;
@property (nonatomic, strong) UIAlertView *parcelaPagasAMenorAlert;

- (BOOL)temPacelasPendentes:(Conta *)conta data:(NSDate *)hoje;
- (void)escolheContaParaPagamento;
- (void)atualizaDadosNaTela;
- (void)calculaDiferencaDeValores;

@end

@implementation PagarFaturaViewController
@synthesize cellCartao;
@synthesize cellMesDaFatura;
@synthesize cellTotal;
@synthesize tfValorPago;
@synthesize cellDiferenca;
@synthesize cellPagarFatura;

@synthesize contaSelecionada = _contaSelecionada;
@synthesize vpDatabase = _vpDatabase;
@synthesize mesAtual = _mesAtual;
@synthesize valorFormatter = _valorFormatter;
@synthesize valorTotal = _valorTotal;
@synthesize parcelasParaPagamento = _parcelasParaPagamento;
@synthesize semNenhumaParcelaPendenteAlert = _semNenhumaParcelaPendenteAlert;
@synthesize semParcelasPendentesNaContaAlert = _semParcelasPendentesNaContaAlert;
@synthesize diferencaDeValor = _diferencaDeValor;
@synthesize hoje = _hoje;
@synthesize valorPagamento = _valorPagamento;
@synthesize parcelaPagasComSucessoAlert = _parcelaPagasComSucessoAlert;
@synthesize parcelaPagasAMaiorAlert = _parcelaPagasAMaiorAlert;
@synthesize parcelaPagasAMenorAlert = _parcelaPagasAMenorAlert;

- (NSDate *)hoje
{
    if (!_hoje) {
        _hoje = [[NSDate alloc] init];
    }
    return _hoje;
}


- (NSDecimalNumber *)diferencaDeValor
{
    if (!_diferencaDeValor) {
        _diferencaDeValor = [[NSDecimalNumber alloc] initWithInt:0];
    }
    return _diferencaDeValor;
}

- (NSDecimalNumber *)valorTotal
{
    if (!_valorTotal) {
        _valorTotal = [[NSDecimalNumber alloc] initWithInt:0];
    }
    return _valorTotal;
}

- (NSDecimalNumber *)valorPagamento
{
    if (!_valorPagamento) {
        _valorPagamento = [[NSDecimalNumber alloc] initWithInt:0];
    }
    return _valorPagamento;
}


- (UIAlertView *) semNenhumaParcelaPendenteAlert
{
    if (!_semNenhumaParcelaPendenteAlert) {
        NSString *texto = @"Você não possue parcelas pendentes de pagamente para o mês atual em nenhuma das suas contas. Você pode pagar suas parcelas apenas no mês do seu vencimento.";
        _semNenhumaParcelaPendenteAlert = [[UIAlertView alloc] initWithTitle:@"Pagamento" message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _semNenhumaParcelaPendenteAlert;
}

- (UIAlertView *) semParcelasPendentesNaContaAlert
{
    if (!_semParcelasPendentesNaContaAlert) {
        NSString *texto = @"A conta escolhida não possui parcelas pendentes de pagamente para o mês atual. Você pode pagar suas parcelas apenas no mês do seu vencimento.";
        _semParcelasPendentesNaContaAlert = [[UIAlertView alloc] initWithTitle:@"Pagamento!" message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _semParcelasPendentesNaContaAlert;
}

- (UIAlertView *) parcelaPagasComSucessoAlert
{
    if (!_parcelaPagasComSucessoAlert) {
        NSString *texto = @"Pagamento efetuado.";
        _parcelaPagasComSucessoAlert = [[UIAlertView alloc] initWithTitle:@"Pagamento!" message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _parcelaPagasComSucessoAlert;
}

- (UIAlertView *) parcelaPagasAMaiorAlert
{
    if (!_parcelaPagasAMaiorAlert) {
        NSString *texto = @"Você pagou um valor maior que o total pendente. O valor será descontado da previsão de gastos do próximo mês.";
        _parcelaPagasAMaiorAlert = [[UIAlertView alloc] initWithTitle:@"Pagamento!" message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _parcelaPagasAMaiorAlert;
}

- (UIAlertView *) parcelaPagasAMenorAlert
{
    if (!_parcelaPagasAMenorAlert) {
        NSString *texto = @"Você pagou um valor menor que o total pendente. O valor sera acrescido de juros do cartão e adicionado na previsão do próximo mês.";
        _parcelaPagasAMenorAlert = [[UIAlertView alloc] initWithTitle:@"Pagamento!" message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _parcelaPagasAMenorAlert;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"(>) alertView: %@, %d", alertView, buttonIndex);
    
    if (alertView == self.semNenhumaParcelaPendenteAlert) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView == self.semParcelasPendentesNaContaAlert) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView == self.parcelaPagasComSucessoAlert) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSLog(@"(<) alertView: ");
}

//This method comes from UITextFieldDelegate
//and this is the most important piece of mask
//functionality.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = YES;
    
    if (textField == self.tfValorPago) {
        
        [VidaParceladaHelper formataValor:textField
                               novoDigito:string
                                 comRange:range
                          usandoFormatter:self.valorFormatter
                           eQtdeDeDigitos:8];
        result = NO;
        
        [self calculaDiferencaDeValores];
    }
        
    return result;
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
    
    [self escolheContaParaPagamento];
    [self atualizaDadosNaTela];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)escolheContaParaPagamento
{
    NSLog (@"(>) escolheContaParaPagamento: ");
        
    if (!self.contaSelecionada) {
        // vamos listar todas as contas, independente se tem ou não parcelas.
        NSArray * listaDeContas = [Conta contasCadastradasUsandoContext:self.vpDatabase.managedObjectContext];
        
        // iterando nas contas e pesquisando cada uma por parcelas pendentes para o mes atual
        // se a conta tiver, para o processo e inicia o processo de pagamento
        for (Conta *conta in listaDeContas) {
            if ([self temPacelasPendentes:conta data:self.hoje]) {
                break;
            }
        }
        
        // Se a lista de parcelas pendentes estiver nil é porque não temos nenhuma.
        if (!self.parcelasParaPagamento || [self.parcelasParaPagamento count] == 0) {
            NSLog (@"(!) escolheContaParaPagamento: Nenhuma parcela para pagar em nenhuma conta!");
            [self.semNenhumaParcelaPendenteAlert show];
        }
    } else {
        // Se temos uma conta vamos utiliza-la, se ela não tiver parcelas pendentes
        // vamos avisar o usuário e sair.
        // Se a lista de parcelas pendentes estiver nil é porque não temos nenhuma.
        if (![self temPacelasPendentes:self.contaSelecionada data:self.hoje]) {
            NSLog (@"(!) escolheContaParaPagamento: Nenhuma parcela para pagar nessa conta!");
            [self.semParcelasPendentesNaContaAlert show];
        }
    }

    NSLog (@"(<) escolheContaParaPagamento: ");
}


- (BOOL)temPacelasPendentes:(Conta *)conta data:(NSDate *)hoje
{
    NSLog (@"(>) temPacelasPendentes: %@, %@", conta.descricao, hoje);
    
    BOOL temParcelas = NO;
    
    // Quantas parcelas pendentes existem?
    NSArray *parcelasPendentes = [Parcela parcelasPendentesDoMes:hoje eDaConta:conta inContext:self.vpDatabase.managedObjectContext];
    
    // Temos alguma?
    if (parcelasPendentes && [parcelasPendentes count] > 0) {
        
        // Calculamos o total e colocamos na property espelho, atualizamos a tela
        self.valorTotal = [Parcela calculaValorTotalDasParcelas:parcelasPendentes];
        self.cellTotal.detailTextLabel.text = [self.valorFormatter stringFromNumber:self.valorTotal];
        
        // colocamos a conta encontrada como conta selecionada
        self.contaSelecionada = conta;
        
        // e colocamos a lista de parcelas pendentes na propriedade local
        self.parcelasParaPagamento = parcelasPendentes;
        
        temParcelas = YES;
    }
    
    NSLog (@"(>) temPacelasPendentes: return = %@", (temParcelas ? @"YES" : @"NO"));
    
    return temParcelas;
}

- (void)atualizaDadosNaTela
{
    NSLog(@"(>) atualizaDadosNaTela: ");
    
    if (self.contaSelecionada) {
        // Texto
        if (self.contaSelecionada.descricao && [self.contaSelecionada.descricao length] > 0) {
            self.cellCartao.textLabel.text = self.contaSelecionada.descricao;
        } else {
            self.cellCartao.textLabel.text = self.contaSelecionada.tipo.nome;
        }
        
        // Detalhes
        if (self.contaSelecionada.empresa) {
            self.cellCartao.detailTextLabel.text = self.contaSelecionada.empresa;
        } else {
            self.cellCartao.detailTextLabel.text = self.contaSelecionada.tipo.descricao;
        }
    }
    
    self.cellDiferenca.detailTextLabel.text = [self.valorFormatter stringFromNumber:self.diferencaDeValor];
    self.cellMesDaFatura.detailTextLabel.text = [VidaParceladaHelper formataApenasMesCompleto:self.hoje];
    
    NSLog(@"(<) atualizaDadosNaTela: ");
}

- (void)calculaDiferencaDeValores
{
    NSLog(@"(>) calculaDiferencaDeValores: ");

    NSNumber *valorTmp;
    valorTmp = [self.valorFormatter numberFromString:self.tfValorPago.text];
    self.valorPagamento = [NSDecimalNumber decimalNumberWithString:[valorTmp stringValue]];
    self.diferencaDeValor = [self.valorTotal decimalNumberBySubtracting:self.valorPagamento];
    
    // atualiza tela
    self.cellDiferenca.detailTextLabel.text = [self.valorFormatter stringFromNumber:self.diferencaDeValor];
    
    NSLog(@"(<) calculaDiferencaDeValores: ");
}

- (void)viewDidUnload
{
    [self setCellCartao:nil];
    [self setCellMesDaFatura:nil];
    [self setCellTotal:nil];
    [self setTfValorPago:nil];
    [self setCellDiferenca:nil];
    [self setCellPagarFatura:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // colocar o check no escolhido
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.cellPagarFatura == newCell) {
        // Realiza o Pagamento
        [Parcela pagaListaDeParcelas:self.parcelasParaPagamento];
        
        // Avisa o usuário da resolução de valores
        NSNumber *diferenca = [self.valorFormatter numberFromString:self.cellDiferenca.detailTextLabel.text];
        if ([diferenca intValue] == 0) {
            [self.parcelaPagasComSucessoAlert show];
        } else if ([diferenca intValue] > 0) {
            [self.parcelaPagasAMenorAlert show];
        } else {
            [self.parcelaPagasAMaiorAlert show];
        }
    }
    
}

@end
