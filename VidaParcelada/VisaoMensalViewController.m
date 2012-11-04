//
//  VisaoMensalViewController.m
//  VidaParcelada
//
//  Created by Lauri Laux on 28/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VisaoMensalViewController.h"
#import "Parcela+AddOn.h"
#import "Compra+AddOn.h"
#import "VidaParceladaHelper.h"
#import "Conta+AddOn.h"
#import "CadastroDeCompraViewController.h"
#import "CadastroDeParcelaViewController.h" 
#import "VidaParceladaAppDelegate.h"

@interface VisaoMensalViewController ()

@end

@implementation VisaoMensalViewController

@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;
@synthesize objetivoMensal = _objetivoMensal;
@synthesize compraSelecionada = _compraSelecionada;
@synthesize parcelaSelecionada = _parcelaSelecionada;
@synthesize topBar = _topBar;
@synthesize btnFaturas = _btnPagar;
@synthesize primeiroUsoAlert = _primeiroUsoAlert;
@synthesize vencimentosAlert = _vencimentosAlert;
@synthesize banner = _banner;

// define o alerta de primeiro uso
- (UIAlertView *) primeiroUsoAlert 
{
    if (!_primeiroUsoAlert) {
        NSString *titulo = NSLocalizedString(@"titulo.bemvindo", @"Bem vindo!");
        NSString *texto = NSLocalizedString(@"lista.previsao.primeiro.uso", @"Primeiro uso previsão");;
        _primeiroUsoAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _primeiroUsoAlert;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Usuário confirmou que viu o primeiro aviso da tela.
    if (alertView == self.primeiroUsoAlert) {
        // atualiza o estado para exibido
        NSString *nomeDaAba = [NSString stringWithFormat:@"%@", [self class]];
        [VidaParceladaHelper salvaEstadoApresentacaoInicialAba:nomeDaAba exibido:YES];
    }
    
}

- (void)compraFoiAlterada:(Compra *)compra;
{
    [self.tableView reloadData];
}


-(void)verificaVencimentos
{
    // Verifica se existem cartões que vencem hoje ou que tem melhor dia hoje.
    NSDate *hoje = [[NSDate alloc] init];
    NSArray *contas = [Conta verificaDataRetornandoContas:hoje
                                     comparandoVencimento:YES
                                      comparandoMelhorDia:NO];
    
    // Sem contas não é necessário mostrar nenhum evento.
    if (!contas || [contas count] == 0) {
        return;
    }

    NSString *descricaoContas = @"";
    for (Conta *c in contas) {
        descricaoContas = [descricaoContas stringByAppendingString:c.descricao];
        descricaoContas = [descricaoContas stringByAppendingString:@" - "];
        descricaoContas = [descricaoContas stringByAppendingString:c.empresa];
        descricaoContas = [descricaoContas stringByAppendingString:@". \n"];
    }
    
    NSString *txtVal = NSLocalizedString(@"lista.previsao.vencimento.cartao", @"Dia de vencimento do cartão");
    NSString *texto = [NSString stringWithFormat:txtVal, descricaoContas];
    _vencimentosAlert = [[UIAlertView alloc] initWithTitle:@"Vencimento!" message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [self.vencimentosAlert show];

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [self setTopBar:nil];
    [self setBtnFaturas:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

// define a query que irá popular a tabela atual
-(void)setupFetchedResultsController
{   
    self.debug = NO;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Parcela"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"estado <> %@", PARCELA_PAGA];
    
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"dataVencimento" ascending:YES 
                                                              selector:@selector(compare:)]];
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    //[NSFetchedResultsController deleteCacheWithName:@"VisaoMensalCache"];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:appDelegate.defaultContext
                                                                          sectionNameKeyPath:@"tMesAno" 
                                                                                   cacheName:@"VisaoMensalCache"];
    
}

// Popula a tabela com os dados do CoreData
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ParcelaAgrupadaCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Parcela *parcela = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *valor = [self.valorFormatter stringFromNumber:parcela.valor];
    
//    NSString *vencimento = [self.dateFormatter stringFromDate:parcela.dataVencimento];    
//    NSString *detail = [NSString stringWithFormat:@"%@ - %@ - %@", vencimento, parcela.descricao, valor];
    
    NSString *detail = [NSString stringWithFormat:@"%@ - Parcela: %@/%@ - %@", valor, parcela.numeroDaParcela, parcela.compra.qtdeTotalDeParcelas, parcela.compra.origem.descricao];
    
    cell.textLabel.text = parcela.compra.descricao;
    cell.detailTextLabel.text = detail;
    
    return cell;
    
}

//
// Aqui é a chave para exibir o valor total por mês!
//
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section 
{
    
    // vamos calcular o valor da soma das parcelas da section
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSDecimalNumber *valorMes = [[NSDecimalNumber alloc] initWithInteger:0];
    // Array de objetos dessa section
    NSArray *parcelas = [sectionInfo objects];
    if (parcelas) {
        for (Parcela *p in parcelas) {
            valorMes = [valorMes decimalNumberByAdding:p.valor];
        }
    }
    NSString *descricaoDaParcela = @"parcela";
    NSString *valor = [self.valorFormatter stringFromNumber:valorMes];
    int qtdeDeParcelas = [sectionInfo numberOfObjects];
    if (qtdeDeParcelas > 1) {
        descricaoDaParcela = @"parcelas";
    }
    NSString *textoInformativo = NSLocalizedString(@"lista.previsao.texto.informativo", @"Compras no periodo");
    NSString *noTotal = NSLocalizedString(@"lista.previsao.texto.nototalde", @"no total de");
    
    NSString *textoValorTotal = [NSString stringWithFormat:@" %d %@ %@ %@ ", qtdeDeParcelas, descricaoDaParcela, noTotal, valor];
    
    // Para customizar o footer da tabela com os dados da soma
    // parcelas e o numero de parcelas
    UIColor *fundo = [UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:0.8]; /*#b5b5b5*/
    UIColor *letra = [UIColor darkGrayColor];
    
    // Verifica se o valor do mês ultrapassa o objetivo mensal estabelecido pelo usuário
    if ([valorMes compare:self.objetivoMensal] == NSOrderedDescending) {
        // A comparação acima mostsa que o valorMes é maior que o
        // objetivo mensal. Sintaxe estranha, mas descrita melhore em:
        // http://www.innerexception.com/2011/02/how-to-compare-nsdecimalnumbers-in.html
        //
        letra = [UIColor colorWithRed:0.545 green:0 blue:0 alpha:1]; /*#8b0000*/
        textoInformativo = NSLocalizedString(@"lista.previsao.texto.estouromensal", @"Previsao aviso estouro mensal");
        //
        // Calcula a diferença entre o que foi gasto e o previsto
        NSDecimalNumber *diferenca = [valorMes decimalNumberBySubtracting:self.objetivoMensal];
        NSString *diferencaStr = [self.valorFormatter stringFromNumber:diferenca];
        textoInformativo = [textoInformativo stringByAppendingFormat:@"%@ ", diferencaStr];
    }
    
    
    UIView *myHeader = [[UIView alloc] initWithFrame:CGRectMake(0,60,320,40)];
    myHeader.backgroundColor = fundo;
    
    // Label superior
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,20)] ;
    firstLabel.font = [UIFont systemFontOfSize:13.0];
    firstLabel.textColor = letra;
    firstLabel.backgroundColor = fundo;
    firstLabel.text = textoInformativo;
    firstLabel.textAlignment = UITextAlignmentRight;
    
    // Label inferior
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,20,320,20)] ;
    secondLabel.font = [UIFont boldSystemFontOfSize:13.0];
    secondLabel.textColor = letra;
    secondLabel.backgroundColor = fundo;
    secondLabel.text = textoValorTotal;
    secondLabel.textAlignment = UITextAlignmentRight;
    
    [myHeader addSubview:firstLabel];
    [myHeader addSubview:secondLabel];
    return myHeader;
}

// Não quero que as letras de indice apareçam do lado direito da table
// portanto vamos retornar sempre vazio.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *index = [[NSMutableArray alloc] init];
	return index;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    // Remove o botão editar
    UINavigationBar *morenavbar = self.navigationController.navigationBar;
    UINavigationItem *morenavitem = morenavbar.topItem;
    morenavitem.rightBarButtonItem = nil;
    
    self.debug = NO;
    
    // Registra para receber notificações de quando o banco de dados abrir
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onDatabaseAvailable:) name:@"VpDatabaseOpenComplete" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)onDatabaseAvailable:(NSNotification *)note
{
    // extrai algumas informações da notificação.
    id poster = [note object];
    NSString *name = [note name];
    NSDictionary *extraInfo = [note userInfo];
    
    NSLog (@"(!) onDatabaseAvailable - Poster: %@ / name=%@ / extraInfo:%@", poster, name, extraInfo);
    
    // Se o DB está OK podemos configurar nosso fetchresults
    [self setupFetchedResultsController];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{
    return 25.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section 
{
    return 40.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (void) viewWillAppear:(BOOL)animated
{
    //NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);

    // Display banners
    self.displayAds = YES;
    [super viewWillAppear:animated];
    
    self.objetivoMensal = [VidaParceladaHelper retornaLimiteDeGastoGlobal];
    [[self tableView] reloadData];
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    if (appDelegate.defaultDatabase) {
        [self verificaVencimentos];
    }

    //
    // Chamada a primeira vez que a aba é exibida passando o nome da própria
    // classe, retorna YES se em algum momento esse aviso já foi exibido.
    //
    NSString *nomeDaAba = [NSString stringWithFormat:@"%@", [self class]];
    if (![VidaParceladaHelper retornaEstadoApresentacaoInicialAba:nomeDaAba]) {
        [self.primeiroUsoAlert show];
    }
    
    //NSLog(@"(<) viewWillAppear: ");
}

// Não permite edição das celulas
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

//
// Delegate para avisar que uma parcela foi alterada
// e a tabela precisa recarregar os seus dados
//
- (void)parcelaFoiAlterada:(Parcela *)parcela
{
    //NSLog(@"(>) parcelaFoiAlterada: %@", parcela);
    
    [self.tableView reloadData];
    
    //NSLog(@"(<) parcelaFoiAlterada: ");
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Parcela *parcela = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.compraSelecionada != parcela.compra) {
        self.compraSelecionada = parcela.compra;
    } 
    if (self.parcelaSelecionada != parcela) {
        self.parcelaSelecionada = parcela;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // ATENÇÃO: Quando utilizamos Segues a celula que dispara o segue
    // é passada como sender, e a única maneira de sabermos qual objeto
    // do fetchedResultsController foi selecionado é passando a cell
    // para a tabela e pedido no indexPath.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Parcela *parcela = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.compraSelecionada = parcela.compra;
        self.parcelaSelecionada = parcela;
    }
    
    // primeiro informa a compra porque a pesquisa das parcelas precisa da compra.
    if ([segue.destinationViewController respondsToSelector:@selector(setCompraSelecionada:)]){
        [segue.destinationViewController setCompraSelecionada:self.compraSelecionada];
    }
    
    // passa a parcela atualmente selectionada.
    if ([segue.destinationViewController respondsToSelector:@selector(setParcelaSelecionada:)]) {
        [segue.destinationViewController setParcelaSelecionada:self.parcelaSelecionada];
    }
    
    // Adiciona como delegate
    if ([segue.destinationViewController respondsToSelector:@selector(setCompraDelegate:)]){
        [segue.destinationViewController setCompraDelegate:self];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setParcelaDelegate:)]) {
        [segue.destinationViewController setParcelaDelegate:self];
    }
}

// quando você aperta o botão de detalhes, aquele botão azul, na célula da tabela
// ele dispara esse método. Basta pegar o que foi escolhido e pedir para o navigation
// controller realizar o 'segue' que você precisa.
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"editarCompra" sender:self];
    
}

@end
