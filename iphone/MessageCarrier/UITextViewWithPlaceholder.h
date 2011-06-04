#import <UIKit/UIKit.h>


@interface UITextViewWithPlaceholder : UITextView  {
    NSString *placeholder;
    UIColor *placeholderColor;
}

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;
@end