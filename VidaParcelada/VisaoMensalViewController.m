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

@interface VisaoMensalViewController ()

@end

@implementation VisaoMensalViewController

@synthesize vpDatabase = _vpDatabase;
@synthesize valorFormatter = _valorFormatter;
@synthesize dateFormatter = _dateFormatter;

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
    request.predicate = [NSPredicate predicateWithFormat:@"dataVencimento = %@", vencimento];
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
    NSString *footer = [NSString stringWithFormat:@"%d %@ no total de %@", qtdeDeParcelas, descricaoDaParcela, valor];
    
    // Para customizar o footer da tabela com os dados da soma
    // parcelas e o numero de parcelas
    UIColor *fundo = [UIColor whiteColor];
    UIColor *letra = [UIColor darkGrayColor];
    UIView *myHeader = [[UIView alloc] initWithFrame:CGRectMake(0,60,320,20)];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupFetchedResultsController];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
} 

- (void)viewDidAppear:(BOOL)animated{
    // Esconde a toolbar com uma animação massa!
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.toolbarHidden = YES;
    } completion:^(BOOL finished) {    
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    // Volta o toolbar com uma animação massa.
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.toolbarHidden = NO;
    } completion:^(BOOL finished) {    
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [super viewWillDisappear:animated];
}

@end
