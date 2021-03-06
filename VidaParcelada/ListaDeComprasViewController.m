//
//  ListaDeComprasViewController.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 14/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
//

#import "ListaDeComprasViewController.h"
#import "TipoConta+AddOn.h"
#import "Conta+AddOn.h"
#import "CadastroDeCompraViewController.h"
#import "RootTabBarController.h"
#import "Parcela+AddOn.h"
#import "CadastroDaContaViewController.h"
#import "VidaParceladaAppDelegate.h"

@interface ListaDeComprasViewController ()

@end

@implementation ListaDeComprasViewController

@synthesize compraSelecionada = _compraSelecionada;
@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;
@synthesize semContasCadastradasAlert = _semContasCadastradasAlert;
@synthesize primeiroUsoAlert = _primeiroUsoAlert;
@synthesize vencimentosAlert = _vencimentosAlert;

// sobreescreve o setter
// - @synthesize primeiroUsoAlert = _primeiroUsoAlert;
// - @property (nonatomic, strong) UIAlertView *primeiroUsoAlert;
- (UIAlertView *) primeiroUsoAlert 
{
    if (!_primeiroUsoAlert) {
        NSString *texto = NSLocalizedString(@"lista.compras.primeira.mensagem", @"Primeira mensagem lista de compras");
        NSString *titulo = NSLocalizedString(@"titulo.bemvindo", @"Bem vindo!");
        _primeiroUsoAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _primeiroUsoAlert;
}

// sobrescreve o setter
- (UIAlertView *) semContasCadastradasAlert
{
    if (!_semContasCadastradasAlert) {
        NSString *texto = NSLocalizedString(@"lista.compras.popup.semcontas", @"Sem contas cadastradas popup");
        NSString *titulo = NSLocalizedString(@"titulo.atencao", @"Atenção!");
        _semContasCadastradasAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    return _semContasCadastradasAlert;    
}

-(void)verificaVencimentos
{
    // Verifica se existem cartões que vencem hoje ou que tem melhor dia hoje.
    NSDate *hoje = [[NSDate alloc] init];
    NSArray *contas = [Conta verificaDataRetornandoContas:hoje
                                     comparandoVencimento:NO
                                      comparandoMelhorDia:YES];
    
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
    
    NSString *txtVal = NSLocalizedString(@"lista.compras.popup.melhordia", @"Aviso de melhor dia de compras");
    NSString *titulo = NSLocalizedString(@"titulo.melhordia", @"Melhor dia!");
    NSString *texto = [NSString stringWithFormat:txtVal, descricaoContas];
    _vencimentosAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [self.vencimentosAlert show];
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"(>) alertView: %@, %d", alertView, buttonIndex);
    
    if (alertView == self.semContasCadastradasAlert) {
        [self performSegueWithIdentifier:@"SemContasCadastradasSegue" sender:self];
    }
    
    // Usuário confirmou que viu o primeiro aviso da tela.
    if (alertView == self.primeiroUsoAlert) {
        // atualiza o estado para exibido
        NSString *nomeDaAba = [NSString stringWithFormat:@"%@", [self class]];
        [VidaParceladaHelper salvaEstadoApresentacaoInicialAba:nomeDaAba exibido:YES];
        // Verifica se precisa exibir a mensagem de cadastro de contas
        if ([Conta quantidadeDeContas] == 0) {
            [self.semContasCadastradasAlert show];
        }
    }
    
    //NSLog(@"(<) alertView:");
    
}

#pragma mark - AlteracaoDeCompraDelegate

-(void)compraFoiAlterada:(Compra *)compra
{
    [self.tableView reloadData];
}

-(void)setupFetchedResultsController
{
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    self.debug = NO;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Compra"];
    
    // Mostra apenas as compras que possuem alguma parcela pendente ou vencida

    request.predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(parcelas, $x, $x.estado <> %@).@count > 0", PARCELA_PAGA];
    
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"dataDaCompra" ascending:NO ]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:appDelegate.defaultContext
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:@"ListaDeComprasCache"]; // @"ListaDeComprasCache"
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // ATENÇÃO: Quando utilizamos Segues a celula que dispara o segue
    // é passada como sender, e a única maneira de sabermos qual objeto
    // do fetchedResultsController foi selecionado é passando a cell
    // para a tabela e pedido no indexPath.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        self.compraSelecionada = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }

    // primeiro informa a compra porque a pesquisa das parcelas precisa da compra.
    if ([segue.destinationViewController respondsToSelector:@selector(setCompraSelecionada:)]){
        [segue.destinationViewController setCompraSelecionada:self.compraSelecionada];
    }

    // Adiciona como delegate
    if ([segue.destinationViewController respondsToSelector:@selector(setCompraDelegate:)]){
        [segue.destinationViewController setCompraDelegate:self];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);
    
    self.displayAds = YES;
    self.bannerId = @"a150a94b770074b";
    [super viewWillAppear:animated];
    
    self.compraSelecionada = nil;

    //
    // Chamada a primeira vez que a aba é exibida passando o nome da própria
    // classe, retorna YES se em algum momento esse aviso já foi exibido.
    //
    NSString *nomeDaAba = [NSString stringWithFormat:@"%@", [self class]];
    if (![VidaParceladaHelper retornaEstadoApresentacaoInicialAba:nomeDaAba]) {
        [self.primeiroUsoAlert show];
    } else {
        [self.tableView reloadData];
        if ([Conta quantidadeDeContas] == 0) {
            [self.semContasCadastradasAlert show];
        } else {
            // verifica se estamos no melhor dia para compra.
            [self verificaVencimentos];
        }
    }
    
    //NSLog(@"(<) viewWillAppear: ");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // Habilita o botão de edição
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupFetchedResultsController];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CompraCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Compra *compra = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *data = [self.dateFormatter stringFromDate:compra.dataDaCompra];
    NSString *valor = [self.valorFormatter stringFromNumber:compra.valorTotal];
    
    NSString *subTitulo = [NSString stringWithFormat:@"%@ - %@x - %@", data, compra.qtdeTotalDeParcelas, valor];

    cell.textLabel.text = compra.descricao;
    cell.detailTextLabel.text = subTitulo;
    
    return cell;

}


// quando você aperta o botão de detalhes, aquele botão azul, na célula da tabela
// ele dispara esse método. Basta pegar o que foi escolhido e pedir para o navigation
// controller realizar o 'segue' que você precisa.
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Compra *compra = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.compraSelecionada = compra;

    [self performSegueWithIdentifier:@"NovaCompra" sender:self];
        
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Compra *selecionada = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.compraSelecionada != selecionada) {
        self.compraSelecionada = selecionada;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {  
        // Delete the row from the data source
        NSError *error;
        self.debug = NO;
        Compra *compra = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:compra];
        
        [self.fetchedResultsController.managedObjectContext save:&error];        
        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];

        [self.fetchedResultsController performFetch:&error];
        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];
    }   
}

@end
