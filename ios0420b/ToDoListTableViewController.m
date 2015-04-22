//
//  ToDoListTableViewController.m
//  ios0420b
//
//  Created by Timothy Lee on 4/20/15.
//  Copyright (c) 2015 Eatgo. All rights reserved.
//

#import "ToDoListTableViewController.h"
#import "ToDoItem.h"
#import "AddToDoItemViewController.h"

@interface ToDoListTableViewController ()

@property NSMutableArray *toDoItems;

@end

@implementation ToDoListTableViewController

- (void)loadInitialData {
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"]];
//    NSLog(@"dictionary = %@", dictionary);
    NSArray *array = [dictionary objectForKey:@"To-Do Items"];
//    NSLog(@"array = %@", array);
    
    for (NSDictionary *i in array) {
        ToDoItem *item = [[ToDoItem alloc] init:[i objectForKey:@"creationDate"]];
        item.itemName = [i objectForKey:@"itemName"];
        item.completed = [i objectForKey:@"completed"] != 0;

        [self.toDoItems addObject:item];
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    AddToDoItemViewController *source = [segue sourceViewController];
    ToDoItem *item = source.toDoItem;
    
    if (item != nil) {
        [self.toDoItems addObject:item];
        [self.tableView reloadData];
    }
//    NSLog(@"123");
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    //UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = sender.state;
    
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    ToDoItem *item = [self.toDoItems objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:item.creationDate];

//    NSLog(@"%@, %s, %@", item.itemName, item.completed ? "true" : "false", strDate);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:item.itemName message:[NSString stringWithFormat:@"%s\n%@", item.completed ? "true" : "false", strDate] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        NSURL *url = [NSURL URLWithString:@"https://api.hipchat.com/v1/rooms/message"];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        NSString *method = @"POST";
        NSString *content = [NSString stringWithFormat:@"auth_token=fe2993242a6c0651d87b94485a5956&room_id=ios_test&from=ios&message=%@", [NSString stringWithFormat:@"Name: %@<br>Completed: %s<br>Creation Date: %@", item.itemName, item.completed ? "true" : "false", strDate]];
        
        // like urlencode
        content = [content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"%@", content);
        
        [req setHTTPMethod:method];
        [req setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse *res = nil;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];

    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toDoItems = [[NSMutableArray alloc] init];
    [self loadInitialData];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.0;
    [self.tableView addGestureRecognizer:longPress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.toDoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    ToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.itemName;
    if (toDoItem.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.toDoItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }  
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ToDoItem *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    NSString *m = [NSString stringWithFormat:@"%d => %s", indexPath.row, tappedItem.completed ? "true" : "false"];
//    NSLog(@"%@", m);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

@end
