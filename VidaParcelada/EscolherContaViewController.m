//
//  EscolherContaViewController.m
//  VidaParcelada
//
//  Created by Lauri Laux on 08/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EscolherContaViewController.h"
#import "TipoConta+AddOn.h"

@interface EscolherContaViewController ()

@end

@implementation EscolherContaViewController

@synthesize contaDelegate = _contaDelegate;
@synthesize contaSelecionada = _contaSelecionada;
@synthesize vpDatabase = _vpDatabase;


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
    NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);
    
    [super viewWillAppear:animated];
    NSIndexPath *catIndex = [self.fetchedResultsController indexPathForObject:self.contaSelecionada];
    UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:catIndex];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSLog(@"(<) viewWillAppear: ");
    
}
#pragma mark TableView

// Define se a tela rotaciona
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Table view data source


// define a query que irá popular a tabela atual
-(void)setupFetchedResultsController
{
    self.debug = YES;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.vpDatabase.managedObjectContext 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil]; 
    
    // Celula com marcação
    NSIndexPath *index = [self.fetchedResultsController indexPathForObject:self.contaSelecionada];
    if (index) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
}

// Este método que, dado um indexPath da tabela, retorna a célula com o titulo e subtitulo
// preenchidos corretamente.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Conta Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Conta *conta = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (conta.descricao && [conta.descricao length] > 0) {
        cell.textLabel.text = conta.descricao;
        cell.detailTextLabel.text = conta.empresa;
    } else {
        cell.textLabel.text = conta.tipo.nome;
        cell.detailTextLabel.text = conta.tipo.descricao;
    }
    
    return cell;
}

// Recebe um evento de seleção e controla o estado do checkmark de forma que apenas uma linha/objeto
// esteja selecionada em um determinado momento.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger catIndex = [self.fetchedResultsController indexPathForObject:self.contaSelecionada].row;
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
    NSIndexPath *oldIndexPath = [self.fetchedResultsController indexPathForObject:self.contaSelecionada];
    
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
        self.contaSelecionada = [self.fetchedResultsController objectAtIndexPath:indexPath];    
        [self.contaDelegate contaEscolhida:self.contaSelecionada];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}



@end
