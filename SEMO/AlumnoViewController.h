//
//  AlumnoViewController.h
//  SEMO
//
//  Created by PDM-115 on 20/05/14.
//  Copyright (c) 2014 Grupo19. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlumnoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *carnetField;
@property (weak, nonatomic) IBOutlet UITextField *nombreAlumnoField;
@property (weak, nonatomic) IBOutlet UITextField *apellidoAlumnoField;
@property (weak, nonatomic) IBOutlet UITableView *AlumnosTableView;
- (IBAction)insertarAlumnoButton:(id)sender;
- (IBAction)ActualizarAlumnoButton:(id)sender;
- (IBAction)consultarAlumnoButton:(id)sender;
- (IBAction)borrarAlumnoButton:(id)sender;



@end
