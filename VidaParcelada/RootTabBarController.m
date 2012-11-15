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
#import "Compra+AddOn.h"
#import "VisaoMensalViewController.h"
#import "ListaDeComprasViewController.h"
#import "ListaDeContasViewController.h"
#import "OptionsTableViewController.h"
#import "VidaParceladaHelper.h"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

@synthesize waitView = _waitView;

-(UIView *) waitView
{
    if (!_waitView) {
        //CGRect screenFrame = CGRectMake(0, 0, 320, 480);
        _waitView = [[[NSBundle mainBundle] loadNibNamed:@"WaitView" owner:self options:nil] objectAtIndex:0];
        CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
        _waitView.frame = screenFrame;
    }
    return _waitView;
}

//
// Navigation Controller delegate
//
- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
    //[viewController viewWillAppear:animated];
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
    
    // Tipo Conta principal.
    NSString *contaNome = NSLocalizedString (@"cartao.exemplo1.nome", @"Cartão de crédito");
    NSString *tipoContaDescricao = NSLocalizedString (@"cartao.exemplo1.descricao", @"Cartão com data de vencimento");
    TipoConta *cartao = [TipoConta contaComNome:contaNome eDescricao:tipoContaDescricao identificadorDeTipo:1];
    
    // Tipo conta para englobar todas as outras contas.
    contaNome = NSLocalizedString (@"cartao.exemplo2.nome", @"Outros");
    tipoContaDescricao = NSLocalizedString (@"cartao.exemplo2.descricao", @"Outras formas de parcelamento");
    [TipoConta contaComNome:contaNome eDescricao:tipoContaDescricao identificadorDeTipo:2];
    
    // Cria a conta padrão de exemplo para preencher o produto
    Conta *conta;
    NSString *contaDescricao = NSLocalizedString(@"conta.exemplo.cadastro.nome", @"Descrição da compra de exemplo");
    NSString *empresaDescricao = NSLocalizedString(@"conta.exemplo.cadastro.empresa", @"Empresa da compra de exemplo");
    NSNumber *vencimento = [NSNumber numberWithInt:15];
    NSDecimalNumber *jurosMes = [NSDecimalNumber decimalNumberWithString:@"12"];
    NSDecimalNumber *limiteTotal = [NSDecimalNumber decimalNumberWithString:@"1000"];
    NSNumber *melhorDia = [NSNumber numberWithInt:3];
    conta = [Conta contaComDescricao:contaDescricao daEmpresa:empresaDescricao comVencimentoNoDia:vencimento eJurosMes:jurosMes comLimiteTotal:limiteTotal comMelhorDiaDeCompra:melhorDia cartaoPreferencial:NO comTipoConta:cartao];
    
    // E criamos uma compra de exemplo
    Compra *compra;
    NSString *descricaoCompra = NSLocalizedString(@"compra.exemplo.cadastro.descricao", @"Descrição compra de exemplo");
    NSString *detalhesCompra = NSLocalizedString(@"compra.exemplo.cadastro.detalhes", @"Detalhes compra de exemplo");
    NSDate *hoje = [[NSDate alloc] init];
    NSNumber *parcelas = [NSNumber numberWithInt:5];
    NSDecimalNumber *valorTotal = [NSDecimalNumber decimalNumberWithString:@"899"];
    compra = [Compra compraComDescricao:descricaoCompra comDetalhes:detalhesCompra dataDaCompra:hoje comEstado:COMPRA_PENDENTE_PAGAMENTO qtdeDeParcelas:parcelas valorTotal:valorTotal comConta:conta assumirAnterioresComoPagas:YES];
                      
    NSLog (@"(!) Criado: %@, %@, %@", cartao, conta, compra);
    
    NSError *error;
    [document.managedObjectContext save:(&error)];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    NSLog (@"(<) insertDefaultDbData: ");
    
}

-(void)openDatabase
{    
    NSLog (@"(>) openDatabase: ");

    // Adiciona relógio a abertura
    [self.view addSubview:self.waitView];
    [self.waitView.acitivity startAnimating];
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    // realiza tarefas lentas
    if (![[NSFileManager defaultManager] fileExistsAtPath:[appDelegate.defaultDatabase.fileURL path]]){
        // O banco de dados não existe.
        NSLog(@"(!) openDatabase: Banco de dados não encontrado. Criando...");
        [appDelegate.defaultDatabase saveToURL:appDelegate.defaultDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self insertDefaultDbData:appDelegate.defaultDatabase];
            [self databaseAbertoComSucesso:success];
        }];
    } else if (appDelegate.defaultDatabase.documentState == UIDocumentStateClosed) {
        // O banco de dados existe, vamos abri-lo
        NSLog(@"(!) openDatabase: Banco de dados encontrado como estao FECHADO. Abrindo...");
        [appDelegate.defaultDatabase openWithCompletionHandler:^(BOOL success) {
            [self databaseAbertoComSucesso:success];
        }];
    } else if (appDelegate.defaultDatabase.documentState == UIDocumentStateNormal) {
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
        
        // Delegate com o defaultContext e defaultDatabase
        VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

        // Notifica o app que o banco de dados está aberto e está OK
        NSDictionary *extraInfo = [NSDictionary dictionaryWithObject:appDelegate.defaultContext forKey:@"defaultContext"];
        NSNotification *note = [NSNotification notificationWithName:@"VpDatabaseOpenComplete" object:self userInfo:extraInfo];
        
        NSLog (@"(!) databaseAbertoComSucesso - About to send notification - name=%@ / extraInfo:%@", note.name, note.userInfo);
        
        [[NSNotificationCenter defaultCenter] postNotification:note];
        
        // Libera o app para uso
        [self.waitView removeFromSuperview];
        
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

    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    // Nosso banco de dados está aberto???
    if (!appDelegate.defaultDatabase) {
        
        // Para abrir/criar o banco de dados do VP temos que pegar a pasta do usuário
        // que o app pode escrever.
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        // depois de termos o diretorio vamos colocar o nome do bd na url
        url = [url URLByAppendingPathComponent:@"Vida Parcelada DB"];
        
        // inicializando o DB
        appDelegate.defaultDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    [self openDatabase];

    // o banco de dados foi aberto com sucesso, então temos que passar
    // a informação do ManagedDocument para todos os controllers
    // que fazem parte do tab view.
    NSArray *viewController = [self viewControllers];
    
    // Esconde tab bar para abrir espaço.
    self.hidesBottomBarWhenPushed = YES;
    
    // O primeiro TAB é o Previsão
    UINavigationController *nvPrevisao = (UINavigationController *) [viewController objectAtIndex:0];
    VisaoMensalViewController *previsao = (VisaoMensalViewController *) [[nvPrevisao viewControllers] objectAtIndex:0];
    previsao.navigationController.delegate = self;
    
    // O segundo TAB é o Compras
    UINavigationController *nvCompras = (UINavigationController *) [viewController objectAtIndex:1];
    ListaDeComprasViewController *compras = (ListaDeComprasViewController *) [[nvCompras viewControllers] objectAtIndex:0];
    compras.navigationController.delegate = self;
    
    // O terceiro TAB é o Contas
    UINavigationController *nvContas = (UINavigationController *) [viewController objectAtIndex:2];
    ListaDeContasViewController *contas = (ListaDeContasViewController *) [[nvContas viewControllers] objectAtIndex:0];
    contas.navigationController.delegate = self;
    
    // O quarto TAB é o de Opções
    UINavigationController *nvOptions = (UINavigationController *) [viewController objectAtIndex:3];
    OptionsTableViewController *options = (OptionsTableViewController *) [[nvOptions viewControllers] objectAtIndex:0];
    options.navigationController.delegate = self;
    
    // Qualquer outro tab entraria aqui...

    // Set the current Core Data DB and Context
    appDelegate.defaultContext = appDelegate.defaultDatabase.managedObjectContext;
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
