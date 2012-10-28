//
//  PagarFaturaViewController.m
//  VidaParcelada
//
//  Created by Lauri P. Laux Jr on 01/08/12.
//
//

#import "PagarFaturaViewController.h"
#import "VidaParceladaHelper.h"
#import "VidaParceladaAppDelegate.h"

@interface PagarFaturaViewController ()

@property (retain) NSNumberFormatter *percentFormatter;
@property (retain) NSNumberFormatter *valorFormatter;

@property (nonatomic, strong) UIAlertView *semNenhumaParcelaPendenteAlert;
@property (nonatomic, strong) UIAlertView *semParcelasPendentesNaContaAlert;
@property (nonatomic, strong) UIAlertView *parcelaPagasComSucessoAlert;
@property (nonatomic, strong) UIAlertView *parcelaPagasAMaiorAlert;
@property (nonatomic, strong) UIAlertView *parcelaPagasAMenorAlert;
@property (nonatomic, strong) UIAlertView *parcelaPagasZeradoAlert;

- (BOOL)temPacelasPendentes:(Conta *)conta data:(NSDate *)hoje;
- (void)escolheContaParaPagamento;
- (void)atualizaDadosNaTela;
- (void)calculaDiferencaDeValores;
- (void)executaAjusteDeCompraAMaior;
- (void)calculaJuros;

@end

@implementation PagarFaturaViewController
@synthesize cellCartao;
@synthesize cellMesDaFatura;
@synthesize cellTotal;
@synthesize tfValorPago;
@synthesize cellDiferenca;
@synthesize cellPagarFatura;
@synthesize cellValorJuros = _cellValorJuros;
@synthesize cellCancelarPagamento = _cellCancelarPagamento;

@synthesize contaSelecionada = _contaSelecionada;
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
@synthesize valorJuros = _valorJuros;

- (NSDate *)hoje
{
    if (!_hoje) {
        _hoje = [[NSDate alloc] init];
    }
    return _hoje;
}

- (NSDecimalNumber *)valorJuros
{
    if (!_valorJuros) {
        _valorJuros = [[NSDecimalNumber alloc] initWithInt:0];
    }
    return _valorJuros;
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

- (UIAlertView *) parcelaPagasZeradoAlert
{
    if (!_parcelaPagasZeradoAlert) {
        NSString *titulo = NSLocalizedString(@"titulo.pagamento", @"Pagamento!");
        NSString *texto = NSLocalizedString(@"cadastro.pagamento.conta.valorzerado", @"Confirmação de pagamento zerado");
        _parcelaPagasZeradoAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Não", nil];
    }
    return _parcelaPagasZeradoAlert;
}

- (UIAlertView *) semNenhumaParcelaPendenteAlert
{
    if (!_semNenhumaParcelaPendenteAlert) {
        NSString *titulo = NSLocalizedString(@"titulo.pagamento", @"Pagamento!");
        NSString *texto = NSLocalizedString(@"cadastro.pagamento.semparcelas", @"Sem parcelas em nenhuma conta");
        _semNenhumaParcelaPendenteAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _semNenhumaParcelaPendenteAlert;
}

- (UIAlertView *) semParcelasPendentesNaContaAlert
{
    if (!_semParcelasPendentesNaContaAlert) {
        NSString *titulo = NSLocalizedString(@"titulo.pagamento", @"Pagamento!");
        NSString *texto = NSLocalizedString(@"cadastro.pagamento.conta.semparcelas", @"Sem parcelas na conta escolhida");
        _semParcelasPendentesNaContaAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _semParcelasPendentesNaContaAlert;
}

- (UIAlertView *) parcelaPagasComSucessoAlert
{
    if (!_parcelaPagasComSucessoAlert) {
        NSString *titulo = NSLocalizedString(@"titulo.pagamento", @"Pagamento!");
        NSString *texto = NSLocalizedString(@"cadastro.pagamento.conta.pagamentoefetuado", @"Pagamento efetuado");
        _parcelaPagasComSucessoAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _parcelaPagasComSucessoAlert;
}

- (UIAlertView *) parcelaPagasAMaiorAlert
{
    if (!_parcelaPagasAMaiorAlert) {
        NSString *titulo = NSLocalizedString(@"titulo.pagamento", @"Pagamento!");
        NSString *texto = NSLocalizedString(@"cadastro.pagamento.conta.amaior", @"Pagamento a maior");
        _parcelaPagasAMaiorAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _parcelaPagasAMaiorAlert;
}

- (UIAlertView *) parcelaPagasAMenorAlert
{
    if (!_parcelaPagasAMenorAlert) {
        NSString *titulo = NSLocalizedString(@"titulo.pagamento", @"Pagamento!");
        NSString *texto = NSLocalizedString(@"cadastro.pagamento.conta.amenor", @"Pagamento a menor");
        _parcelaPagasAMenorAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
    //NSLog(@"(>) alertView: %@, %d", alertView, buttonIndex);
    
    if (alertView == self.semNenhumaParcelaPendenteAlert) {
//        [self.navigationController popViewControllerAnimated:YES];
        [self dismissModalViewControllerAnimated:YES];
    } else if (alertView == self.semParcelasPendentesNaContaAlert) {
        //        [self.navigationController popViewControllerAnimated:YES];
        [self dismissModalViewControllerAnimated:YES];
    } else if (alertView == self.parcelaPagasComSucessoAlert) {
        //        [self.navigationController popViewControllerAnimated:YES];
        [self dismissModalViewControllerAnimated:YES];
    } else if (alertView == self.parcelaPagasAMaiorAlert) {
        //        [self.navigationController popViewControllerAnimated:YES];
        [self dismissModalViewControllerAnimated:YES];
    } else if (alertView == self.parcelaPagasAMenorAlert) {
        [self dismissModalViewControllerAnimated:YES];
    } else if (alertView == self.parcelaPagasZeradoAlert) {
        if (buttonIndex == 0) {
            // Pagar mesmo zerado
            [Parcela pagaListaDeParcelas:self.parcelasParaPagamento];
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    
    //NSLog(@"(<) alertView: ");
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
        [self calculaJuros];
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
    //NSLog (@"(>) escolheContaParaPagamento: ");
        
    if (!self.contaSelecionada) {
        // Delegate com o defaultContext e defaultDatabase
        VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        
        // vamos listar todas as contas, independente se tem ou não parcelas.
        NSArray * listaDeContas = [Conta contasCadastradasUsandoContext:appDelegate.defaultContext];
        
        // iterando nas contas e pesquisando cada uma por parcelas pendentes para o mes atual
        // se a conta tiver, para o processo e inicia o processo de pagamento
        for (Conta *conta in listaDeContas) {
            if ([self temPacelasPendentes:conta data:self.hoje]) {
                break;
            }
        }
        
        // Se a lista de parcelas pendentes estiver nil é porque não temos nenhuma.
        if (!self.parcelasParaPagamento || [self.parcelasParaPagamento count] == 0) {
            //NSLog (@"(!) escolheContaParaPagamento: Nenhuma parcela para pagar em nenhuma conta!");
            [self.semNenhumaParcelaPendenteAlert show];
        }
    } else {
        // Se temos uma conta vamos utiliza-la, se ela não tiver parcelas pendentes
        // vamos avisar o usuário e sair.
        // Se a lista de parcelas pendentes estiver nil é porque não temos nenhuma.
        if (![self temPacelasPendentes:self.contaSelecionada data:self.hoje]) {
            //NSLog (@"(!) escolheContaParaPagamento: Nenhuma parcela para pagar nessa conta!");
            [self.semParcelasPendentesNaContaAlert show];
        }
    }

    //NSLog (@"(<) escolheContaParaPagamento: ");
}


- (BOOL)temPacelasPendentes:(Conta *)conta data:(NSDate *)hoje
{
    //NSLog (@"(>) temPacelasPendentes: %@, %@", conta.descricao, hoje);
    
    BOOL temParcelas = NO;
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // Quantas parcelas pendentes existem?
    NSArray *parcelasPendentes = [Parcela parcelasPendentesDoMes:hoje eDaConta:conta inContext:appDelegate.defaultContext];
    
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
    
    //NSLog (@"(>) temPacelasPendentes: return = %@", (temParcelas ? @"YES" : @"NO"));
    
    return temParcelas;
}

- (void)atualizaDadosNaTela
{
    //NSLog(@"(>) atualizaDadosNaTela: ");
    
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
    } else {
        self.cellCartao.textLabel.text = @"Nenhuma conta";
        self.cellCartao.detailTextLabel.text = @"Sem parcelas pendentes.";
    }
    
    self.cellDiferenca.detailTextLabel.text = [self.valorFormatter stringFromNumber:self.diferencaDeValor];
    self.cellValorJuros.detailTextLabel.text = [self.valorFormatter stringFromNumber:self.valorJuros];
    self.cellMesDaFatura.detailTextLabel.text = [VidaParceladaHelper formataApenasMesCompleto:self.hoje];
    self.tfValorPago.text = [self.valorFormatter stringFromNumber:self.valorPagamento];
    
    [self calculaDiferencaDeValores];
    [self calculaJuros];
    
    //NSLog(@"(<) atualizaDadosNaTela: ");
}

- (void)calculaDiferencaDeValores
{
    //NSLog(@"(>) calculaDiferencaDeValores: ");

    NSNumber *valorTmp;
    valorTmp = [self.valorFormatter numberFromString:self.tfValorPago.text];
    self.valorPagamento = [NSDecimalNumber decimalNumberWithString:[valorTmp stringValue]];
    self.diferencaDeValor = [self.valorTotal decimalNumberBySubtracting:self.valorPagamento];
    
    // atualiza tela
    self.cellDiferenca.detailTextLabel.text = [self.valorFormatter stringFromNumber:self.diferencaDeValor];
    
    //NSLog(@"(<) calculaDiferencaDeValores: ");
}

- (void)viewDidUnload
{
    [self setCellCartao:nil];
    [self setCellMesDaFatura:nil];
    [self setCellTotal:nil];
    [self setTfValorPago:nil];
    [self setCellDiferenca:nil];
    [self setCellPagarFatura:nil];
    [self setCellValorJuros:nil];
    [self setCellCancelarPagamento:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // colocar o check no escolhido
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.cellPagarFatura == newCell) {
        
        // Avisa o usuário da resolução de valores
        NSNumber *diferenca = [self.valorFormatter numberFromString:self.cellDiferenca.detailTextLabel.text];
        if (self.valorPagamento.intValue == 0) {
            // Valor a pagar está zerado
            [self.parcelaPagasZeradoAlert show];
        } else if ([diferenca intValue] == 0) {
            // Realiza o Pagamento
            [Parcela pagaListaDeParcelas:self.parcelasParaPagamento];
            [self.parcelaPagasComSucessoAlert show];
        } else if ([diferenca intValue] > 0) {
            // Realiza o Pagamento
            [Parcela pagaListaDeParcelas:self.parcelasParaPagamento];
            [self executaAjusteDeCompraAMaior];
            [self.parcelaPagasAMenorAlert show];
        } else {
            [self.parcelaPagasAMaiorAlert show];
        }
        
    } else if (self.cellCancelarPagamento == newCell) {
        [self dismissModalViewControllerAnimated:YES];
    }
    
}

- (void)executaAjusteDeCompraAMaior
{
    NSNumber *numParcelas = [[NSNumber alloc] initWithInt:1];
    
    [self calculaJuros];
    
    // Mostra a quantidade de juros
    NSString *textoValJuros = [self.valorFormatter stringFromNumber:[self.valorJuros decimalNumberBySubtracting:self.diferencaDeValor]];
    NSString *textoJuros = [NSString stringWithFormat:@"Valor: %@, Juros: %@", [self.valorFormatter stringFromNumber:self.diferencaDeValor], textoValJuros];
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    [Compra compraComDescricao:@"Juros do cartão" comDetalhes:textoJuros dataDaCompra:self.hoje comEstado:COMPRA_PENDENTE_PAGAMENTO qtdeDeParcelas:numParcelas valorTotal:self.valorJuros comConta:self.contaSelecionada assumirAnterioresComoPagas:YES inContext:appDelegate.defaultContext];
    
    //NSLog(@"Ajuste = %@", ajuste);
}

- (void)calculaJuros
{
    //
    // multiplicadorJuros = (juros / 100) +1;
    //
    NSDecimalNumber *um = [NSDecimalNumber decimalNumberWithString:@"1"];
    NSDecimalNumber *cem = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *multiplicadorJuros = self.contaSelecionada.jurosMes;
    multiplicadorJuros = [multiplicadorJuros decimalNumberByDividingBy:cem];
    multiplicadorJuros = [multiplicadorJuros decimalNumberByAdding:um];
    
    NSDecimalNumber *totalComJuros = nil;
    if ([self.diferencaDeValor intValue] > 0) {
        totalComJuros = [self.diferencaDeValor decimalNumberByMultiplyingBy:multiplicadorJuros];
    } else {
        totalComJuros = [[NSDecimalNumber alloc] initWithInt:0];
    }
    
    self.valorJuros = totalComJuros;
    self.cellValorJuros.detailTextLabel.text = [self.valorFormatter stringFromNumber:self.valorJuros];
}

@end
