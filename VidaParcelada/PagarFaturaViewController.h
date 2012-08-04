//
//  PagarFaturaViewController.h
//  VidaParcelada
//
//  Created by Lauri P. Laux Jr on 01/08/12.
//
//

#import <UIKit/UIKit.h>
#import "Conta+AddOn.h"
#import "Compra+AddOn.h"
#import "Parcela+AddOn.h"
#import "TipoConta+AddOn.h"

@interface PagarFaturaViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *cellCartao;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellMesDaFatura;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTotal;
@property (weak, nonatomic) IBOutlet UITextField *tfValorPago;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDiferenca;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellPagarFatura;

@property (strong, nonatomic) Conta *contaSelecionada;
@property (strong, nonatomic) NSManagedObject *vpDatabase;
@property (strong, nonatomic) NSString *mesAtual;
@property (strong, nonatomic) NSDecimalNumber *valorTotal;
@property (strong, nonatomic) NSDecimalNumber *diferencaDeValor;
@property (strong, nonatomic) NSDecimalNumber *valorPagamento;
@property (strong, nonatomic) NSArray *parcelasParaPagamento;
@property (strong, nonatomic) NSDate *hoje;

@end
