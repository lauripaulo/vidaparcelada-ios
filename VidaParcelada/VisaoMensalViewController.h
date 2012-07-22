//
//  VisaoMensalViewController.h
//  VidaParcelada
//
//  Created by Lauri Laux on 28/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Compra+AddOn.h"
#import "Parcela+AddOn.h"

@interface VisaoMensalViewController : CoreDataTableViewController <AlteracaoDeCompraDelegate, AlteracaoDeParcelaDelegate>

// aqui definimos nosso banco de dados global
// que todos os controllers irão utilizar
// para mostrar dados do nosso aplicativo
@property (nonatomic, strong) UIManagedDocument *vpDatabase;

@property (nonatomic, strong) NSNumberFormatter *valorFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDecimalNumber *objetivoMensal;
@property (nonatomic, strong) Compra *compraSelecionada;
@property (nonatomic, strong) Parcela *parcelaSelecionada;

@end
