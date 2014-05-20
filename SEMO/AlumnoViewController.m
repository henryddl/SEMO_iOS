//
//  AlumnoViewController.m
//  SEMO
//
//  Created by PDM-115 on 20/05/14.
//  Copyright (c) 2014 Grupo19. All rights reserved.
//

#import "AlumnoViewController.h"

@interface AlumnoViewController ()
{
    NSMutableArray *arrayAlumno;
    sqlite3 *alumnoDB;
    NSString *dbPathString;
}

@end



@implementation AlumnoViewController

-(void) crearOabrirDB{
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docPath=[path objectAtIndex:0];
    dbPathString=[docPath stringByAppendingPathComponent:@"semo.db"];
    char *error;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPathString]){
        const char *dbPath = [dbPathString UTF8String];
        //crear BD
        if(sqlite3_open(dbPath, &alumnoDB)==SQLITE_OK){
            const char *sql_stmt="create table ALUMNO(CARNET VARCHAR2(10) not null,USERNAME VARCHAR2(10),NOMBRE_ALUMNO VARCHAR2(100) not null,APELLIDO_ALUMNO VARCHAR2(100) not null,constraint PK_ALUMNO primary key (CARNET) constraint FK_ALUMNO_LOGIN FOREIGN KEY (USERNAME) REFERENCES USUARIO(USERNAME) ON DELETE RESTRICT);";
            sqlite3_exec(alumnoDB,sql_stmt,NULL,NULL,&error);
            sqlite3_close(alumnoDB);
        }
    }
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
	arrayAlumno=[[NSMutableArray alloc]init];
    [[self AlumnosTableView]setDelegate:self];
    [[self AlumnosTableView]setDataSource:self];
    [self crearOabrirDB];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [arrayAlumno count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier=@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Alumno *aAlumno=[arrayAlumno objectAtIndex:indexPath.row];
    cell.textLabel.text=aAlumno.carnet;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@",aAlumno.nombre,aAlumno.apellido];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)insertarAlumnoButton:(id)sender {
    char *error;
    if (sqlite3_open([dbPathString UTF8String],&alumnoDB)==SQLITE_OK){
        NSString *insert_Stmt=[NSString stringWithFormat:@"INSERT INTO ALUMNO(carnet,username,nombre_alumno,apellido_alumno) values ('%s','%s','%s','%s')",[self.carnetField.text UTF8String],[self.carnetField.text UTF8String],[self.nombreAlumnoField.text UTF8String],[self.apellidoAlumnoField.text UTF8String]];
        const char *insert_stmt=[insert_Stmt UTF8String];
        
        if (sqlite3_exec(alumnoDB, insert_stmt, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"Alumno Insertado correctamente");
            Alumno *alumno=[[Alumno alloc]init];
            [alumno setCarnet:self.carnetField.text];
            [alumno setUsername:self.carnetField.text];
            [alumno setNombre:self.nombreAlumnoField.text];
            [alumno setApellido:self.apellidoAlumnoField.text];
            [arrayAlumno addObject:alumno];
        }
        else {
            NSLog(@"Alumno no Insertado!");
        }
        sqlite3_close(alumnoDB);
    }
}

- (IBAction)ActualizarAlumnoButton:(id)sender {
}

- (IBAction)consultarAlumnoButton:(id)sender {
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPathString UTF8String], &alumnoDB)==SQLITE_OK){
        [arrayAlumno removeAllObjects];
        NSString *querySql=[NSString stringWithFormat:@"SELECT * FROM ALUMNO"];
        const char *querysql=[querySql UTF8String];
        
        if (sqlite3_prepare(alumnoDB, querysql, -1, &statement, NULL)==SQLITE_OK){
            while (sqlite3_step(statement)==SQLITE_ROW){
                NSString *carnet1 = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                NSString *nombre1 = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *apellido1 = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                Alumno *aAlumno=[[Alumno alloc]init];
                [aAlumno setCarnet:self.carnetField.text];
                [aAlumno setUsername:self.carnetField.text];
                [aAlumno setNombre:self.nombreAlumnoField.text];
                [aAlumno setApellido:self.apellidoAlumnoField.text];
                [arrayAlumno addObject:aAlumno];
                
            }
        }
        else{
            NSLog(@"Lista vacia");
        }
        sqlite3_close(alumnoDB);
    }
    [[self AlumnosTableView]reloadData];
}

- (IBAction)borrarAlumnoButton:(id)sender {
}
@end
