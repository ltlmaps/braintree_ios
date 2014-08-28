#import "BTPayPalButton.h"

#import "BTUIPaymentMethodView.h"
#import "BTPayPalViewController.h"
#import "BTPayPalHorizontalSignatureWhiteView.h"
#import "BTUI.h"
#import "BTLogger.h"
#import "BTPayPalAppSwitchHandler.h"

#import "BTPayPalAdapter.h"

@interface BTPayPalButton () <BTPayPalButtonViewControllerPresenterDelegate, BTPayPalAdapterDelegate>
@property (nonatomic, strong) BTPayPalHorizontalSignatureWhiteView *payPalHorizontalSignatureView;
@property (nonatomic, strong) BTPayPalViewController *braintreePayPalViewController;

@property (nonatomic, strong) BTPayPalAdapter *adapter;
@end

@implementation BTPayPalButton

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self setupViews];
    }
    return self;
}

- (void)setClient:(BTClient *)client {
    _client = client;
    self.adapter = [[BTPayPalAdapter alloc] initWithClient:client];
    self.adapter.delegate = self;
}

- (void)setupViews {
    self.theme = [BTUI braintreeTheme];
    self.accessibilityLabel = @"PayPal";
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    self.layer.borderWidth = 0.5f;

    self.payPalHorizontalSignatureView = [[BTPayPalHorizontalSignatureWhiteView alloc] init];
    [self.payPalHorizontalSignatureView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.payPalHorizontalSignatureView.userInteractionEnabled = NO;

    [self addSubview:self.payPalHorizontalSignatureView];

    self.backgroundColor = [[BTUI braintreeTheme] payPalButtonBlue];
    self.layer.borderColor = [UIColor clearColor].CGColor;

    [self addConstraints:[self defaultConstraints]];

    [self addTarget:self action:@selector(didReceiveTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveTouch {
    self.userInteractionEnabled = NO;
    [self.adapter initiatePayPalAuth];
}

- (id<BTPayPalButtonViewControllerPresenterDelegate>)presentationDelegate {
    return _presentationDelegate ?: self;
}


#pragma mark State Change Messages

- (void)informDelegateDidCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod {
    if ([self.delegate respondsToSelector:@selector(payPalButton:didCreatePayPalPaymentMethod:)]) {
        [self.delegate payPalButton:self didCreatePayPalPaymentMethod:payPalPaymentMethod];
    }
}
- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(payPalButton:didFailWithError:)]) {
        [self.delegate payPalButton:self didFailWithError:error];
    }
}

- (void)informDelegateWillCreatePayPalPaymentMethod {
    if ([self.delegate respondsToSelector:@selector(payPalButtonWillCreatePayPalPaymentMethod:)]) {
        [self.delegate payPalButtonWillCreatePayPalPaymentMethod:self];
    }
}

- (void)informDelegateDidCancel {
    if ([self.delegate respondsToSelector:@selector(payPalButtonDidCancel:)]) {
        [self.delegate payPalButtonDidCancel:self];
    }
}

#pragma mark Presentation Delegate Messages

- (void)requestDismissalOfViewController:(UIViewController *)viewController {
    if ([self.presentationDelegate respondsToSelector:@selector(payPalButton:requestsDismissalOfViewController:)]) {
        [self.presentationDelegate payPalButton:self requestsDismissalOfViewController:viewController];
    }
}

- (void)requestPresentationOfViewController:(UIViewController *)viewController {
    if ([self.presentationDelegate respondsToSelector:@selector(payPalButton:requestsPresentationOfViewController:)]) {
        [self.presentationDelegate payPalButton:self requestsPresentationOfViewController:viewController];
    }
}

#pragma mark - UIControl methods

- (void)setHighlighted:(BOOL)highlighted {
    [UIView animateWithDuration:0.08f animations:^{
        self.backgroundColor = highlighted ? [[BTUI braintreeTheme]  payPalButtonActiveBlue] : [[BTUI braintreeTheme]  payPalButtonBlue];
    }];
}

#pragma mark - BTPayPalButtonViewControllerPresenterDelegate default implementation

- (void)payPalButton:(__unused BTPayPalButton *)button requestsPresentationOfViewController:(UIViewController *)viewController {
    [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)payPalButton:(__unused BTPayPalButton *)button requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Auto Layout Constraints

- (NSArray *)defaultConstraints {
    CGFloat BTPayPalButtonHorizontalSignatureWidth = 95.0f;
    CGFloat BTPayPalButtonHorizontalSignatureHeight = 23.0f;
    CGFloat BTPayPalButtonMinHeight = [self.theme paymentButtonMinHeight];
    CGFloat BTPayPalButtonMaxHeight = [self.theme paymentButtonMaxHeight];
    CGFloat BTPayPalButtonMinWidth = 240.0f;

    NSDictionary *metrics = @{ @"minHeight": @(BTPayPalButtonMinHeight),
                               @"maxHeight": @(BTPayPalButtonMaxHeight),
                               @"required": @(UILayoutPriorityRequired),
                               @"minWidth": @(BTPayPalButtonMinWidth) };
    NSDictionary *views = @{ @"self": self,
                             @"payPalHorizontalSignatureView": self.payPalHorizontalSignatureView };


    NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:6];
    // Signature centerY
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0f
                                   constant:0.0f]];

    // Signature centerX
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0f
                                   constant:0.0f]];

    // Signature width
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:BTPayPalButtonHorizontalSignatureWidth]];

    // Signature height
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:BTPayPalButtonHorizontalSignatureHeight]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(>=minHeight@required,<=maxHeight@required)]"
                                             options:0
                                             metrics:metrics
                                               views:views]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(>=260@required)]"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    return constraints;
}

#pragma mark PayPal Adapter Delegate Methods

- (void)payPalAdapterWillCreatePayPalPaymentMethod:(__unused BTPayPalAdapter *)payPalAdapter {
    self.userInteractionEnabled = NO;
    [self informDelegateWillCreatePayPalPaymentMethod];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    self.userInteractionEnabled = YES;
    [self informDelegateDidCreatePayPalPaymentMethod:paymentMethod];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter didFailWithError:(NSError *)error {
    self.userInteractionEnabled = YES;

    [self informDelegateDidFailWithError:error];
}

- (void)payPalAdapterDidCancel:(__unused BTPayPalAdapter *)payPalAdapter {
    self.userInteractionEnabled = YES;

    [self informDelegateDidCancel];
}

- (void)payPalAdapterWillAppSwitch:(__unused BTPayPalAdapter *)payPalAdapter {
    self.userInteractionEnabled = YES;
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter requestsPresentationOfViewController:(UIViewController *)viewController {
    [self requestPresentationOfViewController:viewController];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter requestsDismissalOfViewController:(UIViewController *)viewController {
    [self requestDismissalOfViewController:viewController];
}

@end
