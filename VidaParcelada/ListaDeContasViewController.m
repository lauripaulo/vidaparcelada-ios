//
//  ContasViewController.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 13/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "ListaDeContasViewController.h"
#import "Conta+AddOn.h"
#import "TipoConta+AddOn.h"
#import "VidaParceladaHelper.h"
#import "CadastroDaContaViewController.h"
#import "Parcela+AddOn.h"

@interface ListaDeContasViewController ()

// Define a conta atualmente selecionada que deve ser passada para o 
// CadastroDaContaViewController. Caso seja uma inclusao de conta
// a propriedade deve seguir como nil;
@property (nonatomic, strong) Conta *contaSelecionada;

@end



@implementation ListaDeContasViewController


#pragma mark - Properties


@synthesize vpDatabase = _vpDatabase;
@synthesize btnAdicionarConta = _btnAdicionarConta;
@synthesize contaSelecionada = _contaSelecionada;
@synthesize comprasPresentesAlert = _comprasPresentesAlert;
@synthesize primeiroUsoAlert = _primeiroUsoAlert;

// define o alerta de primeiro uso
- (UIAlertView *) primeiroUsoAlert 
{
    if (!_primeiroUsoAlert) {
        NSString *texto = NSLocalizedString(@"lista.contas.primeira.mensagem", @"Primeira mensagem lista de contas");
        NSString *titulo = NSLocalizedString(@"titulo.bemvindo", @"Bem vindo!");
        _primeiroUsoAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _primeiroUsoAlert;
}

- (UIAlertView *) comprasPresentesAlert
{
    if (!_comprasPresentesAlert) {
        NSString *titulo = NSLocalizedString(@"titulo.atencao", "Atenção!");
        NSString *texto = NSLocalizedString(@"lista.contas.popup.apagar", @"Compras presentes cuidado ao apagar");
        _comprasPresentesAlert = [[UIAlertView alloc] initWithTitle:titulo message:texto delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", nil];
    }
    return _comprasPresentesAlert;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"(>) alertView: %@, %d", alertView, buttonIndex);
    
    // Usuário confirmou que viu o primeiro aviso da tela.
    if (alertView == self.primeiroUsoAlert) {
        // atualiza o estado para exibido
        NSString *nomeDaAba = [NSString stringWithFormat:@"%@", [self class]];
        [VidaParceladaHelper salvaEstadoApresentacaoInicialAba:nomeDaAba exibido:YES];
    }

    // Realmente devemos apagar essa conta?
    if (alertView == self.comprasPresentesAlert) {
        if (buttonIndex > 0) {
            [Conta removeContaTotalmente:self.contaSelecionada inContext:self.vpDatabase.managedObjectContext];
        }
    }
    
    NSLog(@"(<) alertView:");

}

// sobrescreve o setter para o BD do VP
// e inicializa o fetchResultsController
- (void) setVpDatabase:(UIManagedDocument *)mangedDocument
{
    if (_vpDatabase != mangedDocument) {
        _vpDatabase = mangedDocument;
        [self setupFetchedResultsController];
    }
}


#pragma mark - AlteracaoDeContaDelegate


// Quando a conta for alterada durante o cadastro a view recebe
// a notificação e recarrega os valores do banco de dados
- (void)contaFoiAlterada:(Conta *)conta;
{
    [self.tableView reloadData];
}


#pragma mark - TableView


// Temos que passar o banco de dados que abrimos aqui
// no primeiro controller do app para todos
// os outros controllers. Dessa forma todos terao um atributo
// UIManagedDocument *vpDatabase implementado.
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Se for um clique no botão "+" a conta selecionada é nil, senão passamos
    // a conta selecionada que é definida em 'cellForRowAtIndexPath'
    if ([segue.identifier isEqualToString:@"Adicionar Conta"]) {
        self.contaSelecionada = nil;
    }
    // @"Editar Conta"
    
    // ATENÇÃO: Quando utilizamos Segues a celula que dispara o segue
    // é passada como sender, e a única maneira de sabermos qual objeto
    // do fetchedResultsController foi selecionado é passando a cell
    // para a tabela e pedido no indexPath.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        self.contaSelecionada = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }

    // Testamos se o próximo controller responde aos metodos que precisamos passar 
    // como parametro. Se a resposta for SIM setamos o database e a conta selecionada.
    if ([segue.destinationViewController respondsToSelector:@selector(setVpDatabase:)]){
        [segue.destinationViewController setVpDatabase:self.vpDatabase];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setContaSelecionada:)]){
        [segue.destinationViewController setContaSelecionada:self.contaSelecionada];
    }
    
    // Adiciona como delegate
    if ([segue.destinationViewController respondsToSelector:@selector(setContaDelegate:)]){
        [segue.destinationViewController setContaDelegate:self];
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

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"(>) viewWillAppear: %@, View = %@", (animated ? @"YES" : @"NO"), self);

    [super viewWillAppear:animated];
   
    //
    // Chamada a primeira vez que a aba é exibida passando o nome da própria
    // classe, retorna YES se em algum momento esse aviso já foi exibido.
    //
    NSString *nomeDaAba = [NSString stringWithFormat:@"%@", [self class]];
    if (![VidaParceladaHelper retornaEstadoApresentacaoInicialAba:nomeDaAba]) {
        [self.primeiroUsoAlert show];
    }

    NSLog(@"(<) viewWillAppear: ");

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setBtnAdicionarConta:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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
                                                                                   cacheName:@"ListaDeContasCache"];
}


- (void)apagaConta:(Conta *)conta
{
    NSLog(@"(>) apagaConta: %@", conta);
    
    if (conta) {
        // Delete the row from the data source
        NSError *error;
        self.debug = YES;
        
        // Apaga o objeto
        [self.fetchedResultsController.managedObjectContext deleteObject:conta];
        
        [self.fetchedResultsController.managedObjectContext save:&error];
        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];
        
        [self.fetchedResultsController performFetch:&error];
        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];
        
        self.contaSelecionada = nil;
    }
    
    NSLog(@"(<) apagaConta: %@", conta);

}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"(>) tableView:commitEditingStyle:  %@, %d, %@", tableView, editingStyle, indexPath);
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {  
                
        Conta *conta = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([conta.compras count] > 0) {
            self.contaSelecionada = conta;
            [self.comprasPresentesAlert show];
        } else {
            [self apagaConta:conta];
        }
        
    }   
    
    NSLog(@"(<) tableView:commitEditingStyle: ");
}

// Popula a tabela com os dados do CoreData
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Contas Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Conta *conta = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Se a conta tem nome e descrição ele é utilizado, se não possuir
    // utiliza o nome e descrição do tipo do cartão porque temos certeza
    // que toda conta é criada com o primeiro tipo de cartão persistida
    // no banco de dados.
    if (conta.descricao && [conta.descricao length] > 0) { 
        cell.textLabel.text = conta.descricao;
        cell.detailTextLabel.text = conta.empresa;
    } else {
        cell.textLabel.text = conta.tipo.nome;
        cell.detailTextLabel.text = conta.tipo.descricao;
    }
    
    return cell;
    
}

// Quando o usuário seleciona uma conta devemos atualizar a propriedade de conta selecionada
// para que o objeto seja passado corretamente para a próxima view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.contaSelecionada = [self.fetchedResultsController objectAtIndexPath:indexPath];
}



// Quando entra em modo de edição da tabela esse metodo é chamado
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    if (editing) {
        self.btnAdicionarConta.enabled = NO;
    } else {
        self.btnAdicionarConta.enabled = YES;
    }
}

@end
