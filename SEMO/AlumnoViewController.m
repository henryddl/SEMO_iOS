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
    static sqlite3_stmt *statement=nil;
    if (sqlite3_open([dbPathString UTF8String], &alumnoDB)==SQLITE_OK){
        char *update_Stmt="UPDATE ALUMNO SET nombre_alumno=?, apellido_alumno=?, username=?";
        if (sqlite3_prepare_v2(alumnoDB, update_Stmt, -1, &statement, NULL)==SQLITE_OK){
            sqlite3_bind_text(statement,2,[self.nombreAlumnoField.text UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(statement,3,[self.apellidoAlumnoField.text UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(statement,1,[self.carnetField.text UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            Alumno *alumno=[[Alumno alloc]init];
            [alumno setCarnet:self.carnetField.text];
            [alumno setUsername:self.carnetField.text];
            [alumno setNombre:self.nombreAlumnoField.text];
            [alumno setApellido:self.apellidoAlumnoField.text];
            [arrayAlumno addObject:alumno];
            NSLog(@"Alumno Modificado");

        }
        else{
            NSLog(@"Alumno no modificado");
        }
        sqlite3_close(alumnoDB);
    
    }
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
    [[self AlumnosTableView]setEditing:!self.AlumnosTableView.editing animated:YES];
}

-(void)deleteData:(NSString *)deleteQuery{
    char *error;
    if (sqlite_open([dbPathString UTF8String], &alumnoDB)==SQLITE_OK){
        if (sqlite3_exec(alumnoDB, [deleteQuery UTF8String], NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"Alumno Eliminado");
        }
        else{
            NSLog(@"Alumno no Eliminado");
        }
        sqlite3_close(alumnoDB);
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle==UITableViewCellEditingStyleDelete){
        Alumno *alum=[arrayAlumno objectAtIndex:indexPath.row];
        [self deleteData:[NSString stringWithFormat:@"DELETE FROM ALUMNO WHERE CARNET IS '%s'",[alum.carnet UTF8String]]];
        [arrayAlumno removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [[self nombreAlumnoField]resignFirstResponder];
    [[self apellidoAlumnoField]resignFirstResponder];
    [[self carnetField]resignFirstResponder];
}
@end
