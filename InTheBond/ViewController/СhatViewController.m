//
//  СhatViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/18/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "СhatViewController.h"
#import "ChatMessageTableViewCell.h"
#import "ChatService.h"
#import "TWMessageBarManager.h"
#import "Setting.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, ChatServiceDelegate>{
    IBOutlet UIView *m_view;
}

@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UITableView *messagesTableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (IBAction)sendMessage:(id)sender;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initChat];
}

- (void)initChat
{
    self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getPreviousMessages)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.messagesTableView addSubview:self.refreshControl];
    
    
    // Set title
    if(_dialog.type == QBChatDialogTypePrivate){
        QBUUser *recipient = [ChatService shared].usersAsDictionary[@(_dialog.recipientID)];
        self.title = recipient.login == nil ? recipient.email : recipient.login;
    }else{
        self.title = _dialog.name;
    }
    [self syncMessages:NO];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    [ChatService shared].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [ChatService shared].delegate = nil;
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)getPreviousMessages{
    
    // load more messages here
    //
    [self syncMessages:YES];
}

- (void)syncMessages:(BOOL)loadPrevious{
    NSArray *messages = [[ChatService shared] messagsForDialogId:_dialog.ID];
    NSDate *lastMessageDateSent = nil;
    NSDate *firstMessageDateSent = nil;
    if(messages.count > 0){
        lastMessageDateSent = ((QBChatMessage *)[messages lastObject]).dateSent;
        firstMessageDateSent = ((QBChatMessage *)[messages firstObject]).dateSent;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    if(loadPrevious){
        if(firstMessageDateSent != nil){
            extendedRequest[@"date_sent[lte]"] = @([firstMessageDateSent timeIntervalSince1970]-1);
        }
    }else{
        if(lastMessageDateSent != nil){
            extendedRequest[@"date_sent[gte]"] = @([lastMessageDateSent timeIntervalSince1970]+1);
        }
    }
    extendedRequest[@"sort_desc"] = @"date_sent";
    
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];
    [QBRequest messagesWithDialogID:_dialog.ID
                    extendedRequest:extendedRequest
                            forPage:page
                       successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
        if(messages.count > 0){
            [[ChatService shared] addMessages:messages forDialogId:_dialog.ID];
        }
                           
        if(loadPrevious){
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                                        forKey:NSForegroundColorAttributeName];
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
            weakSelf.refreshControl.attributedTitle = attributedTitle;
            
            [weakSelf.refreshControl endRefreshing];
            
            [weakSelf.messagesTableView reloadData];
        }else{
            [weakSelf.messagesTableView reloadData];
            NSInteger count = [[ChatService shared] messagsForDialogId:_dialog.ID].count;
            if(count > 0){
                [weakSelf.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count-1 inSection:0]
                                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }
    } errorBlock:^(QBResponse *response) {
        
    }];
}

#pragma mark
#pragma mark Actions

- (IBAction)sendMessage:(id)sender{
    NSString *messageText = self.messageTextField.text;
    if(messageText.length == 0){
        return;
    }

    // send a message
    BOOL sent = [[ChatService shared] sendMessage:messageText toDialog:_dialog];
    if(!sent){
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error"
                                                       description:@"Please check your internet connection"
                                                              type:TWMessageBarMessageTypeInfo];
        return;
    }
    
    // reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:_dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:_dialog.ID] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // clean text field
    [self.messageTextField setText:nil];
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[ChatService shared] messagsForDialogId:_dialog.ID] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
    
    ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
    if(cell == nil){
        cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
    }
    
    QBChatMessage *message = [[ChatService shared] messagsForDialogId:_dialog.ID][indexPath.row];
    //
    [cell configureCellWithMessage:message];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatMessage *chatMessage = [[[ChatService shared] messagsForDialogId:_dialog.ID] objectAtIndex:indexPath.row];
    CGFloat cellHeight = [ChatMessageTableViewCell heightForCellWithMessage:chatMessage];
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardDidShow:(NSNotification *)note
{
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect rect = m_view.frame;
    rect.size.height -= kbSize.height;
    [m_view setFrame:rect];
    
    // reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:_dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:_dialog.ID] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect rect = m_view.frame;
    rect.size.height += kbSize.height;
    [m_view setFrame:rect];
}


#pragma mark
#pragma mark ChatServiceDelegate

- (void)chatDidLogin
{
    // sync messages history
    //
    [self syncMessages:NO];
}

- (BOOL)chatDidReceiveMessage:(QBChatMessage *)message
{
    NSString *dialogId = message.dialogID;
    if(![_dialog.ID isEqualToString:dialogId]){
        return NO;
    }
    
    // Reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:_dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:_dialog.ID] count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    return YES;
}

@end
