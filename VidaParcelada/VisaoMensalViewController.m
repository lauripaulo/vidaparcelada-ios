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

@interface VisaoMensalViewController ()

@end

@implementation VisaoMensalViewController

@synthesize vpDatabase = _vpDatabase;
@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;

// sobrescreve o setter para o BD do VP
// e inicializa o fetchResultsController
- (void) setVpDatabase:(UIManagedDocument *)mangedDocument
{
    if (_vpDatabase != mangedDocument) {
        _vpDatabase = mangedDocument;
        [self setupFetchedResultsController];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// define a query que irá popular a tabela atual
-(void)setupFetchedResultsController
{   
    self.debug = YES;
    
    // mostrar as compras que vão vencer apenas a partir do dia primeiro 
    // do mês atual.
    NSDate *hoje = [[NSDate alloc] init];
    NSCalendar *calendario = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *hojeComps = [calendario components:unitFlags fromDate:hoje];
    
    NSDateComponents *dataDeVencimentoComps = [[NSDateComponents alloc] init];
    [dataDeVencimentoComps setDay:1];
    [dataDeVencimentoComps setMonth:hojeComps.month -1];
    [dataDeVencimentoComps setYear:hojeComps.year];        
    
    NSDate *vencimento = [calendario dateFromComponents:dataDeVencimentoComps];
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Parcela"];
    request.predicate = [NSPredicate predicateWithFormat:@"dataVencimento >= %@", vencimento];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"dataVencimento" ascending:YES 
                                                              selector:@selector(compare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.vpDatabase.managedObjectContext 
                                                                          sectionNameKeyPath:@"tMesAno" 
                                                                                   cacheName:nil]; 
    
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
    NSString *vencimento = [self.dateFormatter stringFromDate:parcela.dataVencimento];
    
    NSString *detail = [NSString stringWithFormat:@"%@ - %@ - %@", vencimento, parcela.descricao, valor];
    
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
    NSString *descricaoDaParcela = @"compra";
    NSString *valor = [self.valorFormatter stringFromNumber:valorMes];
    int qtdeDeParcelas = [sectionInfo numberOfObjects];
    if (qtdeDeParcelas > 1) {
        descricaoDaParcela = @"compras";
    }
    NSString *footer = [NSString stringWithFormat:@" %d %@ no total de %@ ", qtdeDeParcelas, descricaoDaParcela, valor];
    
    
    // Para customizar o footer da tabela com os dados da soma
    // parcelas e o numero de parcelas
    UIColor *fundo = [UIColor lightGrayColor];
    UIColor *letra = [UIColor darkGrayColor];
    
    // Verifica se o valor do mês ultrapassa o objetivo mensal estabelecido pelo usuário
    NSDecimalNumber *objetivo = [VidaParceladaHelper retornaLimiteDeGastoGlobal];
    if ([valorMes compare:objetivo] == NSOrderedDescending) {
        // A comparação acima mostsa que o valorMes é maior que o
        // objetivo mensal. Sintaxe estranha, mas descrita melhore em:
        // http://www.innerexception.com/2011/02/how-to-compare-nsdecimalnumbers-in.html
        //
        fundo = [UIColor redColor];
        letra = [UIColor blackColor];
        footer = [NSString stringWithFormat:@"(Atenção) %d %@ no total de %@ ", qtdeDeParcelas, descricaoDaParcela, valor];
    }
    
    
    UIView *myHeader = [[UIView alloc] initWithFrame:CGRectMake(0,60,320,40)];
    myHeader.backgroundColor = fundo;
    UILabel *myLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,20)] ;
    myLabel1.font = [UIFont boldSystemFontOfSize:14.0];
    myLabel1.textColor = letra;
    myLabel1.backgroundColor = fundo;
    myLabel1.text = footer;
    myLabel1.textAlignment = UITextAlignmentRight;
    [myHeader addSubview:myLabel1];
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{
    return 40.0f;
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
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

// Não permite edição das celulas
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

@end
