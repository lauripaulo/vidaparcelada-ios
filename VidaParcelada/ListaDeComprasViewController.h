//
//  ListaDeComprasViewController.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 14/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Compra+AddOn.h"

@interface ListaDeComprasViewController : CoreDataTableViewController <AlteracaoDeCompraDelegate>

// aqui definimos nosso banco de dados global
// que todos os controllers irão utilizar
// para mostrar dados do nosso aplicativo
@property (nonatomic, strong) UIManagedDocument *vpDatabase;

// Compra atualmente selecionada na table
@property (nonatomic) Compra *compraSelecionada;

@property (nonatomic, strong) NSNumberFormatter *valorFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end
