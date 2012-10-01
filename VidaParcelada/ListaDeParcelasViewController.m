//
//  ListaDeParcelasViewController.m
//  VidaParcelada
//
//  Created by L. P. Laux on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListaDeParcelasViewController.h"
#import "CadastroDeParcelaViewController.h"
#import "VidaParceladaHelper.h"

@interface ListaDeParcelasViewController ()

@end

@implementation ListaDeParcelasViewController

@synthesize vpDatabase = _vpDatabase;
@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;
@synthesize compraSelecionada = _compraSelecionada;
@synthesize parcelaSelecionada = _parcelaSelecionada;
@synthesize primeiroUsoAlert = _primeiroUsoAlert;

// define o alerta de primeiro uso
- (UIAlertView *) primeiroUsoAlert 
{
    if (!_primeiroUsoAlert) {
        NSString *titulo = NSLocalizedString (@"titulo.bemvindo", @"Bem vindo!");
        NSString *texto = NSLocalizedString(@"lista.parcelas.primeiro.uso", @"Primeiro uso parcelas");
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

// sobrescreve o setter para o BD do VP
// e inicializa o fetchResultsController
- (void) setVpDatabase:(UIManagedDocument *)mangedDocument
{
    if (_vpDatabase != mangedDocument) {
        _vpDatabase = mangedDocument;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    //NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);
    
    [super viewWillAppear:animated];
    self.parcelaSelecionada = nil;
    [self setupFetchedResultsController];

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

- (void) setCompraSelecionada:(Compra *)novaCompra
{
    if (_compraSelecionada != novaCompra) {
        _compraSelecionada = novaCompra;
    }
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
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];

    // Remove o botão editar
    UINavigationBar *morenavbar = self.navigationController.navigationBar;
    UINavigationItem *morenavitem = morenavbar.topItem;
    morenavitem.rightBarButtonItem = nil;

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

#pragma mark - Table view data source


// define a query que irá popular a tabela atual
-(void)setupFetchedResultsController
{
    self.debug = YES;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Parcela"];
    request.predicate = [NSPredicate predicateWithFormat:@"compra = %@", self.compraSelecionada];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"dataVencimento" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.vpDatabase.managedObjectContext 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil];
    // !!!! Cache desabilitado devido a um erro infame !!!
    // !!!! @"ListaDeParcelasCache"
    // !!!! voltar quando resolver erro de inconsitencia de cache.
}

// Popula a tabela com os dados do CoreData
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Parcela Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Parcela *parcela = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *valor = [self.valorFormatter stringFromNumber:parcela.valor];
    NSString *vencimento = [self.dateFormatter stringFromDate:parcela.dataVencimento];
    
    NSString *detail = [NSString stringWithFormat:@"%@  %@  %@", valor, vencimento, parcela.estado];
    
    cell.textLabel.text = parcela.descricao;
    cell.detailTextLabel.text = detail;
    
    return cell;
    
}

// Não permite edição das celulas
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

// Temos que passar o banco de dados que abrimos aqui
// no primeiro controller do app para todos
// os outros controllers. Dessa forma todos terao um atributo
// UIManagedDocument *vpDatabase implementado.
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // ATENÇÃO: Quando utilizamos Segues a celula que dispara o segue
    // é passada como sender, e a única maneira de sabermos qual objeto
    // do fetchedResultsController foi selecionado é passando a cell
    // para a tabela e pedido no indexPath.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        self.parcelaSelecionada = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    // primeiro informa a compra porque a pesquisa das parcelas precisa da compra.
    if ([segue.destinationViewController respondsToSelector:@selector(setParcelaSelecionada:)]){
        [segue.destinationViewController setParcelaSelecionada:self.parcelaSelecionada];
    }
    
    // Por último passa o managedDocument
    if ([segue.destinationViewController respondsToSelector:@selector(setVpDatabase:)]){
        [segue.destinationViewController setVpDatabase:self.vpDatabase];
    }
    
    // Se adiciona como delegate
    if ([segue.destinationViewController respondsToSelector:@selector(setParcelaDelegate:)]){
        [segue.destinationViewController setParcelaDelegate:self];
    }
    
}


#pragma mark - Table view data source

@end
