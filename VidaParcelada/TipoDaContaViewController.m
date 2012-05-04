//
//  TipoDaContaViewController.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior Laux on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TipoDaContaViewController.h"

@interface TipoDaContaViewController ()
@end

@implementation TipoDaContaViewController

@synthesize vpDatabase = _vpDatabase;
@synthesize tipoSelecionado = _tipoSelecionado;
@synthesize tipoContaDelegate = _tipoContaDelegate;

#pragma mark TableView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


// quando a view terminar de carregar devemos chamar o resultado do banco de dados.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

// Define se a tela rotaciona
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Table view data source


// define a query que irá popular a tabela atual
-(void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TipoConta"];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"nome" ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.vpDatabase.managedObjectContext 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil]; 
    
    // Celula com marcação
    NSIndexPath *index = [self.fetchedResultsController indexPathForObject:self.tipoSelecionado];
    if (index) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
}

// Este método que, dado um indexPath da tabela, retorna a célula com o titulo e subtitulo
// preenchidos corretamente.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tipo da Conta Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    TipoConta *tipoConta = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = tipoConta.nome;
    cell.detailTextLabel.text = tipoConta.descricao;
    
    return cell;
}

// Recebe um evento de seleção e controla o estado do checkmark de forma que apenas uma linha/objeto
// esteja selecionada em um determinado momento.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger catIndex = [self.fetchedResultsController indexPathForObject:self.tipoSelecionado].row;
    
    // Neste caso não é necessário remover o checkmark da celular selecionada anteriormente
    // caso a gente tenha uma linha já selecionada
    if (catIndex == indexPath.row) {
        return;
    }
    // Procura a linha que tem atualmente o chekmark utilizando o indice do objeto
    // selecionado atualmente.
    NSIndexPath *oldIndexPath = [self.fetchedResultsController indexPathForObject:self.tipoSelecionado];
    
    // Descoberto a linha nos retiramos o checkmark da linha.
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Colocar o checkmark na célula que foi selecionada e atualiza o tipo
    // correspondente na variavel de controle
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        // Atualiza o selecionado e avisa o delegate
        self.tipoSelecionado = [self.fetchedResultsController objectAtIndexPath:indexPath];    
        [self.tipoContaDelegate tipoContaEscolhido:self.tipoSelecionado];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}


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