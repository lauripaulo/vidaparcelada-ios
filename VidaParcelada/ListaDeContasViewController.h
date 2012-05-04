//
//  ContasViewController.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior Laux on 13/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Conta+AddOn.h"

@interface ListaDeContasViewController : CoreDataTableViewController <AlteracaoDeContaDelegate>

// banco de dados atualmente em uso. Precisa ser definido no 
// prepareForSegue do controler que abre o banco de dados.
@property (nonatomic, strong) UIManagedDocument *vpDatabase;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdicionarConta;

@end
