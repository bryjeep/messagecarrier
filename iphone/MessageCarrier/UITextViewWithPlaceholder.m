#import "UITextViewWithPlaceholder.h"


@implementation UITextViewWithPlaceholder

@synthesize placeholder;
@synthesize placeholderColor;

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame{
    if((self = [super initWithFrame:frame])){
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification{
    if([[self placeholder] length] == 0)
        return;
    if([[self text] length] == 0)
        [[self viewWithTag:999] setAlpha:1];
    else 
        [[self viewWithTag:999] setAlpha:0];
}

- (void)drawRect:(CGRect)rect {
    if( [[self placeholder] length] > 0 ){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 0;
        label.font = self.font;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = self.placeholderColor;
        label.text = self.placeholder;
        label.alpha = 0;
        label.tag = 999;
        [self addSubview:label];
        [label sizeToFit];
        [self sendSubviewToBack:label];
        [label release];
    }
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
        [[self viewWithTag:999] setAlpha:1];
    [super drawRect:rect];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.placeholder = nil;
    self.placeholderColor = nil;
    [super dealloc];
}

@end
