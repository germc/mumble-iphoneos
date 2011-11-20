/* Copyright (C) 2009-2010 Mikkel Krautz <mikkel@krautz.dk>

   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.
   - Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation
     and/or other materials provided with the distribution.
   - Neither the name of the Mumble Developers nor the names of its
     contributors may be used to endorse or promote products derived from this
     software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "MUFavouriteServerEditViewController.h"

#import "MUColor.h"
#import "MUDatabase.h"
#import "MUFavouriteServer.h"

// Placeholder text for the edit view fields.
static NSString   *FavouriteServerPlaceholderDisplayName  = @"Mumble Server";
static NSString   *FavouriteServerPlaceholderHostName     = @"Hostname or IP address";
static NSString   *FavouriteServerPlaceholderPort         = @"64738";
static NSString   *FavouriteServerPlaceholderPassword     = @"Optional";

@interface MUFavouriteServerEditViewController () {
    BOOL               _editMode;
    MUFavouriteServer  *_favourite;
    id                 _target;
    SEL                _doneAction;

    UITableViewCell    *_descriptionCell;
    UITextField        *_descriptionField;
    UITableViewCell    *_addressCell;
    UITextField        *_addressField;
    UITableViewCell    *_portCell;
    UITextField        *_portField;
    UITableViewCell    *_usernameCell;
    UITextField        *_usernameField;
    UITableViewCell    *_passwordCell;
    UITextField        *_passwordField;

    UITextField        *_activeTextField;
    UITableViewCell    *_activeCell;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
@end

@implementation MUFavouriteServerEditViewController

#pragma mark -
#pragma mark Initialization

- (id) initInEditMode:(BOOL)editMode withContentOfFavouriteServer:(MUFavouriteServer *)favServ {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        _editMode = editMode;
        if (favServ) {
            _favourite = [favServ copy];
        } else {
            _favourite = [[MUFavouriteServer alloc] init];
        }
        
        _descriptionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MUFavouriteServerDescription"];
        [_descriptionCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[_descriptionCell textLabel] setText:@"Description"];
        _descriptionField = [[UITextField alloc] initWithFrame:CGRectMake(110.0, 10.0, 185.0, 30.0)];
        [_descriptionField setTextColor:[MUColor selectedTextColor]];
        [_descriptionField addTarget:self action:@selector(textFieldBeganEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [_descriptionField addTarget:self action:@selector(textFieldEndedEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_descriptionField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_descriptionField addTarget:self action:@selector(textFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_descriptionField setReturnKeyType:UIReturnKeyNext];
        [_descriptionField setAdjustsFontSizeToFitWidth:NO];
        [_descriptionField setTextAlignment:UITextAlignmentLeft];
        [_descriptionField setPlaceholder:FavouriteServerPlaceholderDisplayName];
        [_descriptionField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [_descriptionField setText:[_favourite displayName]];
        [_descriptionField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [[_descriptionCell contentView] addSubview:_descriptionField];

        _addressCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MUFavouriteServerAddress"];
        [_addressCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[_addressCell textLabel] setText:@"Address"];
        _addressField = [[UITextField alloc] initWithFrame:CGRectMake(110.0, 10.0, 185.0, 30.0)];
        [_addressField setTextColor:[MUColor selectedTextColor]];
        [_addressField addTarget:self action:@selector(textFieldBeganEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [_addressField addTarget:self action:@selector(textFieldEndedEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_addressField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_addressField addTarget:self action:@selector(textFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_addressField setReturnKeyType:UIReturnKeyNext];
        [_addressField setAdjustsFontSizeToFitWidth:NO];
        [_addressField setTextAlignment:UITextAlignmentLeft];
        [_addressField setPlaceholder:FavouriteServerPlaceholderHostName];
        [_addressField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_addressField setKeyboardType:UIKeyboardTypeURL];
        [_addressField setText:[_favourite hostName]];
        [_addressField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [[_addressCell contentView] addSubview:_addressField];

        _portCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MUFavouriteServerPort"];
        [_portCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[_portCell textLabel] setText:@"Port"];
        _portField = [[UITextField alloc] initWithFrame:CGRectMake(110.0, 10.0, 185.0, 30.0)];
        [_portField setTextColor:[MUColor selectedTextColor]];
        [_portField addTarget:self action:@selector(textFieldBeganEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [_portField addTarget:self action:@selector(textFieldEndedEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_portField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_portField addTarget:self action:@selector(textFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_portField setReturnKeyType:UIReturnKeyNext];
        [_portField setAdjustsFontSizeToFitWidth:YES];
        [_portField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [_portField setTextAlignment:UITextAlignmentLeft];
        [_portField setPlaceholder:FavouriteServerPlaceholderPort];
        [_portField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        if ([_favourite port] != 0)
            [_portField setText:[NSString stringWithFormat:@"%u", [_favourite port]]];
        else
            [_portField setText:@""];
        [_portField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [[_portCell contentView] addSubview:_portField];

        _usernameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MUFavouriteServerUsername"];
        [_usernameCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[_usernameCell textLabel] setText:@"Username"];
        _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(110.0, 10.0, 185.0, 30.0)];
        [_usernameField setTextColor:[MUColor selectedTextColor]];
        [_usernameField addTarget:self action:@selector(textFieldBeganEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [_usernameField addTarget:self action:@selector(textFieldEndedEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_usernameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_usernameField addTarget:self action:@selector(textFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_usernameField setReturnKeyType:UIReturnKeyNext];
        [_usernameField setAdjustsFontSizeToFitWidth:NO];
        [_usernameField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [_usernameField setTextAlignment:UITextAlignmentLeft];
        [_usernameField setPlaceholder:[[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultUserName"]];
        [_usernameField setSecureTextEntry:NO];
        [_usernameField setText:[_favourite userName]];
        [_usernameField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [[_usernameCell contentView] addSubview:_usernameField];
        
        _passwordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MUFavouriteServerPassword"];
        [_passwordCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[_passwordCell textLabel] setText:@"Password"];
        _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(110.0, 10.0, 185.0, 30.0)];
        [_passwordField setTextColor:[MUColor selectedTextColor]];
        [_passwordField addTarget:self action:@selector(textFieldBeganEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [_passwordField addTarget:self action:@selector(textFieldEndedEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_passwordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_passwordField addTarget:self action:@selector(textFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_passwordField setReturnKeyType:UIReturnKeyDefault];
        [_passwordField setAdjustsFontSizeToFitWidth:NO];
        [_passwordField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_passwordField setPlaceholder:FavouriteServerPlaceholderPassword];
        [_passwordField setSecureTextEntry:YES];
        [_passwordField setTextAlignment:UITextAlignmentLeft];
        [_passwordField setText:[_favourite password]];
        [_passwordField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [[_passwordCell contentView] addSubview:_passwordField];
        
    }
    return self;
}

- (id) init {
    return [self initInEditMode:NO withContentOfFavouriteServer:nil];
}

- (void) dealloc {
    [_favourite release];

    [_descriptionCell release];
    [_descriptionField release];
    [_addressCell release];
    [_addressField release];
    [_portCell release];
    [_portField release];
    [_usernameCell release];
    [_usernameField release];
    [_passwordCell release];
    [_passwordField release];

    [super dealloc];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    // On iPad, we support all interface orientations.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark View lifecycle

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    // View title
    if (!_editMode) {
        [[self navigationItem] setTitle:@"New Favourite"];
    } else {
        [[self navigationItem] setTitle:@"Edit Favourite"];
    }

    // Cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked:)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    [cancelButton release];

    // Done
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    [doneButton release];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Mumble Server
    if (section == 0) {
        return 5;
    }
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Mumble Server";
    }
    return @"Default";
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            return _descriptionCell;
        } else if ([indexPath row] == 1) {
            return _addressCell;
        } else if ([indexPath row] == 2) {
            return _portCell;
        } else if ([indexPath row] == 3) {
            return _usernameCell;
        } else if ([indexPath row] == 4) {
            return _passwordCell;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark UIBarButton actions

- (void) cancelClicked:(id)sender {
    [[self navigationController] dismissModalViewControllerAnimated:YES];
}

- (void) doneClicked:(id)sender {
    // Perform some basic tidying up. For example, for the port field, we
    // want the default port number to be used if it wasn't filled out.
    if ([_favourite displayName] == nil) {
        [_favourite setDisplayName:FavouriteServerPlaceholderDisplayName];
    }
    if ([_favourite port] == 0) {
        [_favourite setPort:[FavouriteServerPlaceholderPort intValue]];
    }

    // Get rid of oureslves and call back to our target to tell it that
    // we're done.
    [[self navigationController] dismissModalViewControllerAnimated:YES];
    if ([_target respondsToSelector:_doneAction]) {
        [_target performSelector:_doneAction withObject:self];
    }
}

#pragma mark -
#pragma mark Data accessors

- (MUFavouriteServer *) copyFavouriteFromContent {
    return [_favourite copy];
}

#pragma mark -
#pragma mark Target/actions

- (void) setTarget:(id)target {
    _target = target;
}

- (id) target {
    return _target;
}

- (void) setDoneAction:(SEL)action {
    _doneAction = action;
}

- (SEL) doneAction {
    return _doneAction;
}

#pragma mark -
#pragma mark Text field actions

- (void) textFieldBeganEditing:(UITextField *)sender {
    _activeTextField = sender;
    if (sender == _descriptionField) {
        _activeCell = _descriptionCell;
    } else if (sender == _addressField) {
        _activeCell = _addressCell;
    } else if (sender == _portField) {
        _activeCell = _portCell;
    } else if (sender == _usernameField) {
        _activeCell = _usernameCell;
    } else if (sender == _passwordField) {
        _activeCell = _passwordCell;
    }
}

- (void) textFieldEndedEditing:(UITextField *)sender {
    _activeTextField = nil;
}

- (void) textFieldDidChange:(UITextField *)sender {
    if (sender == _descriptionField) {
        [_favourite setDisplayName:[sender text]];
    } else if (sender == _addressField) {
        [_favourite setHostName:[sender text]];
    } else if (sender == _portField) {
        [_favourite setPort:[[sender text] integerValue]];
    } else if (sender == _usernameField) {
        [_favourite setUserName:[sender text]];
    } else if (sender == _passwordField) {
        [_favourite setPassword:[sender text]];
    }
}

- (void) textFieldDidEndOnExit:(UITextField *)sender {
    if (sender == _descriptionField) {
        [_addressField becomeFirstResponder];
        _activeTextField = _addressField;
        _activeCell = _addressCell;
    } else if (sender == _addressField) {
        [_portField becomeFirstResponder];
        _activeTextField = _portField;
        _activeCell = _portCell;
    } else if (sender == _portField) {
        [_usernameField becomeFirstResponder];
        _activeTextField = _usernameField;
        _activeCell = _usernameCell;
    } else if (sender == _usernameField) {
        [_passwordField becomeFirstResponder];
        _activeTextField = _passwordField;
        _activeCell = _passwordCell;
    } else if (sender == _passwordField) {
        [_passwordField resignFirstResponder];
        _activeTextField = nil;
        _activeCell = nil;
    }
    if (_activeCell) {
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:_activeCell]
                              atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void) keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    } completion:^(BOOL finished) {
        if (!finished)
            return;

        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:_activeCell]
                              atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }];
}

- (void) keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.2f animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    } completion:^(BOOL finished) {
        // ...
    }];
}


@end