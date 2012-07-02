//
//  OptionsTableViewController.h
//  VidaParcelada
//
//  Created by Lauri Laux on 24/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) UIManagedDocument *vpDatabase;
@property (weak, nonatomic) IBOutlet UITextField *tfObjetivoMensal;

@property (weak, nonatomic) IBOutlet UITextField *tfQtdeParcelas;
@property (weak, nonatomic) IBOutlet UIStepper *stepperQtdeParcelas;

@end
