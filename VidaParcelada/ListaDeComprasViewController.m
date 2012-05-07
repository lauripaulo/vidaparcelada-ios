//
//  ListaDeComprasViewController.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 14/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "ListaDeComprasViewController.h"
#import "TipoConta+AddOn.h"
#import "Conta+AddOn.h"
#import "CadastroDeCompraViewController.h"

@interface ListaDeComprasViewController ()

@end



@implementation ListaDeComprasViewController

@synthesize vpDatabase = _vpDatabase;
@synthesize compraSelecionada = _compraSelecionada;
@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;

#pragma mark - AlteracaoDeCompraDelegate

-(void)compraFoiAlterada:(Compra *)compra
{
    [self.tableView reloadData];
}

-(void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Compra"];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.vpDatabase.managedObjectContext 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil]; 
}

// Caso o banco de dados esteja sendo criado agora temos que
// inserir os dados iniciais para que o app esteja com um 
// estado satisfatório para o primeiro uso.
-(void)insertDefaultDbData:(UIManagedDocument *)document
{
    // Temos que inserir os tipos de conta padrão, o usuário
    // na versão 1.0 não podera incluir tipos de conta.
    TipoConta *cartao = [TipoConta contaComNome:@"Cartão de crédito" eDescricao:@"Cartão com data de vencimento" inContext:document.managedObjectContext];
    NSLog(@"Criado cartao: %@", cartao);
    TipoConta *cheque = [TipoConta contaComNome:@"Cheque" eDescricao:@"Cheque pré-datado" inContext:document.managedObjectContext];
    NSLog(@"Criado cheque: %@", cheque);
    
    Conta *conta = [Conta contaComDescricao:@"Yahoo VISA" 
                                  daEmpresa:@"Credicard" 
                         comVencimentoNoDia:[NSNumber numberWithInt:17]
                                  eJurosMes:[NSDecimalNumber decimalNumberWithString:@"8.5"]
                             comLimiteTotal:[NSDecimalNumber decimalNumberWithString:@"3000"]
                           eLimiteDoUsuario:[NSDecimalNumber decimalNumberWithString:@"1500"] 
                       comMelhorDiaDeCompra:[NSNumber numberWithInt:4] 
                                  inContext:document.managedObjectContext];
    NSLog(@"Criada conta: %@", conta);

    // Não deve inserir, deve retornar
    TipoConta *cheque2 = [TipoConta contaComNome:@"Cheque" eDescricao:@"Cheque pré-datado" inContext:document.managedObjectContext];
    NSLog(@"Criado cheque: %@", cheque2);

    // Depois de tudo criado temos que continuar inicializado nossa 
    // interface inicial.
    [self setupFetchedResultsController];
}

-(void)openDatabase
{
    self.debug = YES;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.vpDatabase.fileURL path]]){
        // O banco de dados não existe.
        NSLog(@"Banco de dados não encontrado. Criando...");
        [self.vpDatabase saveToURL:self.vpDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self insertDefaultDbData:self.vpDatabase];
        }];
    } else if (self.vpDatabase.documentState == UIDocumentStateClosed) {
        // O banco de dados existe, vamos abri-lo
        NSLog(@"Banco de dados encontrado como estao FECHADO. Abrindo...");
        [self.vpDatabase openWithCompletionHandler:^(BOOL sucess) {
            [self setupFetchedResultsController];
        }];
    } else if (self.vpDatabase.documentState == UIDocumentStateNormal) {
        // o banco de dados já está aberto
        NSLog(@"Banco de dados encontrado e aberto!");
        [self setupFetchedResultsController];
    }
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
        self.compraSelecionada = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }

    if ([segue.destinationViewController respondsToSelector:@selector(setVpDatabase:)]){
        [segue.destinationViewController setVpDatabase:self.vpDatabase];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setCompraSelecionada:)]){
        [segue.destinationViewController setCompraSelecionada:self.compraSelecionada];
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
    self.compraSelecionada = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    // Nosso banco de dados está aberto???
    if (!self.vpDatabase) {
        
        // Para abrir/criar o banco de dados do VP temos que pegar a pasta do usuário
        // que o app pode escrever.
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        // depois de termos o diretorio vamos colocar o nome do bd na url
        url = [url URLByAppendingPathComponent:NOME_VP_DB];
        
        // inicializando o DB
        self.vpDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    [self openDatabase];
    
    // Do any additional setup after loading the view.
    [self.navigationController setToolbarHidden:NO];
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    NSString *subTitulo = [NSString stringWithFormat:@"%@   %@ parcelas   %@", data, compra.qtdeTotalDeParcelas, valor];

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


//#pragma mark - Table view data source
//
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


@end
