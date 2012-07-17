//
//  RootTabBarController.m
//  VidaParcelada
//
//  Created by Lauri Laux on 10/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootTabBarController.h"
#import "TipoConta+AddOn.h"
#import "Conta+AddOn.h"
#import "VisaoMensalViewController.h"
#import "ListaDeComprasViewController.h"
#import "ListaDeContasViewController.h"
#import "OptionsTableViewController.h"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

@synthesize managedDocument = _managedDocument;
@synthesize managedObjectContext = _managedObjectContext;

//
// Navigation Controller delegate
//
- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
    [viewController viewWillAppear:animated];
}

//
// Navigation Controller delegate
//
- (void)navigationController:(UINavigationController *)navigationController 
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
    [viewController viewDidAppear:animated];
}

// Caso o banco de dados esteja sendo criado agora temos que
// inserir os dados iniciais para que o app esteja com um 
// estado satisfatório para o primeiro uso.
-(void)insertDefaultDbData:(UIManagedDocument *)document
{
    NSLog (@"(>) insertDefaultDbData: %@", document);
    
    // Temos que inserir os tipos de conta padrão, o usuário
    // na versão 1.0 não podera incluir tipos de conta.
    TipoConta *cartao = [TipoConta contaComNome:@"Cartão de crédito" eDescricao:@"Cartão com data de vencimento" identificadorDeTipo:1 inContext:document.managedObjectContext];
    TipoConta *crediario = [TipoConta contaComNome:@"Outros" eDescricao:@"Outras formas de parcelamento" identificadorDeTipo:2 inContext:document.managedObjectContext];
    
    NSLog (@"(!) Criado tipos de conta inciais: %@, %@", cartao, crediario);
    
    NSLog (@"(<) insertDefaultDbData: ");
    
}

-(void)openDatabase
{    
    NSLog (@"(>) openDatabase: ");
           
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.managedDocument.fileURL path]]){
        // O banco de dados não existe.
        NSLog(@"(!) openDatabase: Banco de dados não encontrado. Criando...");
        [self.managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self insertDefaultDbData:self.managedDocument];
            [self databaseAbertoComSucesso:success];
        }];
    } else if (self.managedDocument.documentState == UIDocumentStateClosed) {
        // O banco de dados existe, vamos abri-lo
        NSLog(@"(!) openDatabase: Banco de dados encontrado como estao FECHADO. Abrindo...");
        [self.managedDocument openWithCompletionHandler:^(BOOL success) {
            [self databaseAbertoComSucesso:success];
        }];
    } else if (self.managedDocument.documentState == UIDocumentStateNormal) {
        // o banco de dados já está aberto
        NSLog(@"(!) openDatabase: Banco de dados encontrado e aberto!");
        [self databaseAbertoComSucesso:YES];
    }
    
    NSLog (@"(<) openDatabase: ");

}

- (void)databaseAbertoComSucesso:(BOOL) success
{
    NSLog (@"(>) databaseAbertoComSucesso: %@", (success ? @"YES" : @"NO"));
    
    if (success) {
        // o banco de dados foi aberto com sucesso, então temos que passar
        // a informação do ManagedDocument para todos os controllers
        // que fazem parte do tab view.
        NSArray *viewController = [self viewControllers];
        
        // Esconde tab bar para abrir espaço.
        self.hidesBottomBarWhenPushed = YES;	
        
        // O primeiro TAB é o Previsão
        UINavigationController *nvPrevisao = (UINavigationController *) [viewController objectAtIndex:0];
        VisaoMensalViewController *previsao = (VisaoMensalViewController *) [[nvPrevisao viewControllers] objectAtIndex:0];
        previsao.vpDatabase = self.managedDocument;
        previsao.navigationController.delegate = self;
        
        // O segundo TAB é o Compras
        UINavigationController *nvCompras = (UINavigationController *) [viewController objectAtIndex:1];
        ListaDeComprasViewController *compras = (ListaDeComprasViewController *) [[nvCompras viewControllers] objectAtIndex:0];
        compras.vpDatabase = self.managedDocument;
        compras.navigationController.delegate = self;
        
        // O terceiro TAB é o Contas
        UINavigationController *nvContas = (UINavigationController *) [viewController objectAtIndex:2];
        ListaDeContasViewController *contas = (ListaDeContasViewController *) [[nvContas viewControllers] objectAtIndex:0];
        contas.vpDatabase = self.managedDocument;
        contas.navigationController.delegate = self;
        
        // O quarto TAB é o de Opções
        UINavigationController *nvOptions = (UINavigationController *) [viewController objectAtIndex:3];
        OptionsTableViewController *options = (OptionsTableViewController *) [[nvOptions viewControllers] objectAtIndex:0];
        options.vpDatabase = self.managedDocument;
        options.navigationController.delegate = self;

        // Qualquer outro tab entraria aqui...
    } else {
        // Algo de muito errado aconteceu...
        // temos que logar e tentar recuperar o BD
        // ou mostrar uma tela de erro pedindo para o 
        // usuário re-instalar o app.
        NSLog(@"(!) databaseAbertoComSucesso: Erro fatal abrindo BD!!!");
        
    }
    
    NSLog (@"(<) databaseAbertoComSucesso: ");
 
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    
    // Nosso banco de dados está aberto???
    if (!self.managedDocument) {
        
        // Para abrir/criar o banco de dados do VP temos que pegar a pasta do usuário
        // que o app pode escrever.
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        // depois de termos o diretorio vamos colocar o nome do bd na url
        url = [url URLByAppendingPathComponent:@"Vida Parcelada DB"];
        
        // inicializando o DB
        self.managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    [self openDatabase];
        
    // Set the current Core Data DB and Context
    self.managedObjectContext = self.managedDocument.managedObjectContext;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
