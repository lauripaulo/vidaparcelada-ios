//
//  TipoDaContaViewController.m
//  VidaParcelada
//
//  Created by L. P. Laux on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TipoDaContaViewController.h"

@interface TipoDaContaViewController ()
@end

@implementation TipoDaContaViewController

@synthesize vpDatabase = _vpDatabase;
@synthesize tipoSelecionado = _tipoSelecionado;
@synthesize tipoContaDelegate = _tipoContaDelegate;

// sobrescreve o setter para o BD do VP
// e inicializa o fetchResultsController
- (void) setVpDatabase:(UIManagedDocument *)mangedDocument
{
    if (_vpDatabase != mangedDocument) {
        _vpDatabase = mangedDocument;
        [self setupFetchedResultsController];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    //NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);

    [super viewWillAppear:animated];
    NSIndexPath *catIndex = [self.fetchedResultsController indexPathForObject:self.tipoSelecionado];
    UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:catIndex];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    //NSLog(@"(<) viewWillAppear: ");

}
#pragma mark TableView

// Define se a tela rotaciona
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}


#pragma mark - Table view data source


// define a query que irá popular a tabela atual
-(void)setupFetchedResultsController
{
    self.debug = YES;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TipoConta"];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"nome" ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.vpDatabase.managedObjectContext 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:@"ListaDeTipoDeContaCache"];
    
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
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Neste caso não é necessário remover o checkmark da celula selecionada anteriormente
    // caso a gente tenha uma linha já selecionada
    if (catIndex == indexPath.row) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.navigationController popViewControllerAnimated:YES];
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
    
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        // Atualiza o selecionado e avisa o delegate
        self.tipoSelecionado = [self.fetchedResultsController objectAtIndexPath:indexPath];    
        [self.tipoContaDelegate tipoContaEscolhido:self.tipoSelecionado];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
