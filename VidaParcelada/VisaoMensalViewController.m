	//
//  VisaoMensalViewController.m
//  VidaParcelada
//
//  Created by Lauri Laux on 28/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VisaoMensalViewController.h"
#import "Parcela+AddOn.h"

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
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Parcela"];
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
    
    NSString *detail = [NSString stringWithFormat:@"%@  %@  %@", valor, vencimento, parcela.estado];
    
    cell.textLabel.text = parcela.descricao;
    cell.detailTextLabel.text = detail;
    
    return cell;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupFetchedResultsController];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.valorFormatter = [[NSNumberFormatter alloc] init];
    [self.valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}


@end
