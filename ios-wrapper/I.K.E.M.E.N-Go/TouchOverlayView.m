//
//  TouchOverlayView.m
//  I.K.E.M.E.N-Go
//
//  Created by Jesuszilla on 8/25/26.
//

#import "TouchOverlayView.h"
#import "AnalogJoystickView.h"
#import "GamepadInputs.h"
#import "SDLWindowFix.h"
#import <Foundation/Foundation.h>
#import <SDL2/SDL.h>

@interface TouchOverlayView ()
@property (nonatomic, assign) GamepadButton activeButtons;
@property (nonatomic, strong) NSMutableSet<UIButton *> *currentlyPressedButtons;
@property (nonatomic, assign) CGSize lastKnownSize;
@property (nonatomic, strong) ArcadePanelView *arcadePanel;
@property (nonatomic, strong) UIButton *arcadeCarrier;
@end

@implementation TouchOverlayView

static int virtualJoystickIndex = -1;
static SDL_Joystick *virtualJoystick;

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    NSLog(@"TouchOverlayView bounds changed to: %@", NSStringFromCGRect(bounds));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Set ourselves as the control delegates (they should be created by here)
    _leftJoystickView.delegate = self;
    _rightJoystickView.delegate = self;
    _dPadView.delegate = self;
    
    self.vewlixButtonView.multipleTouchEnabled = YES;
    self.vewlixButtonView.userInteractionEnabled = YES;
    
    for (UIButton *btn in self.buttons) {
        btn.exclusiveTouch = NO;
        btn.userInteractionEnabled = NO;
        btn.alpha = 0.75f;
    }
    
    // Reset timer and wake the overlay up when the device rotates
    if (!CGSizeEqualToSize(self.bounds.size, self.lastKnownSize)) {
        self.lastKnownSize = self.bounds.size;
        [self resetHideTimer];
    }

    [self layoutArcadePanel];
}

#pragma mark - Fist of Retribution arcade panel
// Picture on top, arcade panel underneath. The engine is told how far down the picture starts (below the
// status bar / camera cut-out) through the SDL hint FOR_VIEW_TOP, in screen pixels; it draws the 16:9 picture
// across the full width from there, and the panel takes everything below it.
- (void)layoutArcadePanel {
    UIWindow *win = self.window;
    if (win == nil) {
        return;
    }
    // The stock controls are not used in this layout
    self.dPadView.hidden = YES;
    self.leftJoystickView.hidden = YES;
    self.rightJoystickView.hidden = YES;
    self.vewlixButtonView.hidden = YES;
    self.gameFolderButton.hidden = YES;
    self.alpha = 1.0;

    CGSize screen = win.bounds.size;
    UIEdgeInsets safe = win.safeAreaInsets;
    CGFloat scale = win.screen.nativeScale;
    BOOL landscape = screen.width > screen.height * 1.15;
    BOOL full = [[NSUserDefaults standardUserDefaults] boolForKey:@"for_fullscreen"];
    CGRect inWindow;
    CGRect game;   // where the picture goes, in window points

    if (landscape) {
        // Landscape: the picture in the middle, the stick on the left, the buttons on the right, MENU and START
        // under the picture. Full screen: the picture as tall as the screen, see-through controls on top.
        CGFloat H = screen.height, W = screen.width;
        if (full) {
            CGFloat gh = H, gw = floor(gh * 16.0 / 9.0);
            if (gw > W) { gw = W; gh = floor(gw * 9.0 / 16.0); }
            game = CGRectMake(floor((W - gw) / 2.0), floor((H - gh) / 2.0), gw, gh);
        } else {
            CGFloat side = MAX(165.0, W * 0.175);
            CGFloat band = 46.0 + MAX(safe.bottom, 4.0);
            CGFloat gw = W - side * 2.0;
            CGFloat gh = floor(gw * 9.0 / 16.0);
            if (gh > H - band) { gh = H - band; gw = floor(gh * 16.0 / 9.0); }
            game = CGRectMake(floor((W - gw) / 2.0), MAX(safe.top, 0.0), gw, gh);
        }
        inWindow = CGRectMake(0, 0, W, H);
        char rect[64];
        snprintf(rect, sizeof(rect), "%d,%d,%d,%d", (int)lround(game.origin.x * scale), (int)lround(game.origin.y * scale),
                 (int)lround(game.size.width * scale), (int)lround(game.size.height * scale));
        SDL_SetHint("FOR_VIEW_TOP", "");
        SDL_SetHint("FOR_VIEW_RECT", rect);
    } else {
        // Portrait: picture on top (below the status bar / camera cut-out), arcade panel underneath
        CGFloat top = safe.top;
        CGFloat pictureHeight = floor(screen.width * 9.0 / 16.0);
        if (top + pictureHeight > screen.height * 0.7) {
            top = 0;
        }
        char px[16];
        snprintf(px, sizeof(px), "%d", (int)lround(top * scale));
        SDL_SetHint("FOR_VIEW_RECT", "");
        SDL_SetHint("FOR_VIEW_TOP", px);
        CGFloat panelTop = top + pictureHeight;
        // A big, squarer screen is a fold-open phone (or a tablet): keep the panel in the lower half, clear of the fold
        if (screen.width >= 600.0 && panelTop < screen.height * 0.5 + 20.0) {
            panelTop = screen.height * 0.5 + 20.0;
        }
        game = CGRectMake(0, top, screen.width, pictureHeight);
        inWindow = CGRectMake(0, panelTop, screen.width, screen.height - panelTop);
    }
    CGRect frame = [self convertRect:inWindow fromView:nil];

    if (self.arcadePanel == nil) {
        self.arcadePanel = [[ArcadePanelView alloc] initWithFrame:frame];
        self.arcadePanel.overlay = self;
        [self addSubview:self.arcadePanel];
    }
    ArcadePanelView *p = self.arcadePanel;
    CGRect gameInPanel = CGRectOffset(game, -inWindow.origin.x, -inWindow.origin.y);
    BOOL changed = !CGRectEqualToRect(p.frame, frame) || p.landscape != landscape || p.fullScreen != (landscape && full) ||
                   !CGRectEqualToRect(p.gameRect, gameInPanel);
    p.landscape = landscape;
    p.fullScreen = landscape && full;
    p.gameRect = gameInPanel;
    p.sideInsets = safe;
    p.bottomInset = safe.bottom;
    if (changed) {
        p.frame = frame;
        [p relayout];
    }
    [self bringSubviewToFront:p];
}

- (void)toggleFullScreen {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setBool:![d boolForKey:@"for_fullscreen"] forKey:@"for_fullscreen"];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self setNeedsLayout];
}

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    [self setNeedsLayout];
}

- (void)arcadeButton:(NSInteger)tag pressed:(BOOL)pressed {
    if (self.arcadeCarrier == nil) {
        self.arcadeCarrier = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.arcadeCarrier.tag = tag;
    [self handleButtonState:self.arcadeCarrier isPressed:pressed];
}

- (void)arcadeDirection:(DPadDirection)direction {
    [self dPad:self.dPadView didChangeDirection:direction];
    SDL_JoystickUpdate();
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (self.leftJoystickView.delegate != nil || virtualJoystickIndex > -1) {
        return;
    }
    
    [self commonInit];
    [self setupViews];
    
    NSString *title = NSLocalizedString(@"gameFolderStr", @"Game folder selection button");
    [_gameFolderButton setTitle:title forState:UIControlStateNormal];
}

- (void)dealloc {
    if (virtualJoystick != NULL) {
        SDL_JoystickClose(virtualJoystick);
        virtualJoystick = NULL;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self setupViews];
    }
    return self;
}

- (void)commonInit {
    _currentlyPressedButtons = [NSMutableSet set];
    _hitSlop = 12.0;
    _lastKnownSize = CGSizeZero;
}

- (void)setupViews {
    if (virtualJoystickIndex > -1) {
        return;
    }
    
    self.multipleTouchEnabled = YES;
    self.userInteractionEnabled = YES;
    
    // Set the initial hide timer
    [self resetHideTimer];
}

- (void)resetHideTimer {
    // Cancel any previously scheduled hide perform request
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideOverlay) object:nil];
    self.alpha = 1.0;
    
    // Schedule hide overlay to run 5 seconds from now
    [self performSelector:@selector(hideOverlay) withObject:nil afterDelay:5.0];
}

- (void)hideOverlay {
    // Fist of Retribution: the arcade panel is part of the screen, so it never fades out
    self.alpha = 1.0;
}


#pragma mark - Game Folder button
- (IBAction)gameFolderButtonTapped:(id)sender {
    [self.delegate touchOverlayDidTapGameFolder:self];
}

#pragma mark - Multi-touch Behavior
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled) {
        return nil;
    }

    if ([self pointInside:point withEvent:event]) {
        if (self.alpha < 1.0) {
            [self resetHideTimer];
        }

        UIView *hitView = [super hitTest:point withEvent:event];

        if (hitView && hitView != self && hitView != self.superview && hitView != self.vewlixButtonView && hitView != self.contentView) {
            return hitView;
        }
        
        // god this is hacky
        if (hitView == self.vewlixButtonView) {
            CGPoint pointInVewlix = [self convertPoint:point toView:self.vewlixButtonView];
            UIView *deeperHit = [self.vewlixButtonView hitTest:pointInVewlix withEvent:event];
            if (deeperHit && deeperHit != self.vewlixButtonView) {
                return deeperHit;
            }
        }
        return self;
    }
    
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self processTouches:event.allTouches];
    [self resetHideTimer];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self processTouches:event.allTouches];
    [self resetHideTimer];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self processTouches:event.allTouches];
    [self resetHideTimer];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self processTouches:event.allTouches];
    [self resetHideTimer];
}

// This method processes touch events so that multiple button presses (A+B, X+Y, X+A, etc.) work
- (void)processTouches:(NSSet<UITouch *> *)touches {
    NSMutableSet<UIButton *> *newPressedButtons = [NSMutableSet set];
    
    // Evaluate active touch locations across the view
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved || touch.phase == UITouchPhaseStationary) {
            CGPoint loc = [touch locationInView:self];
            CGRect touchRect = CGRectMake(loc.x - _hitSlop, loc.y - _hitSlop, _hitSlop * 2.0, _hitSlop * 2.0);
            
            for (UIButton *button in self.buttons) {
                CGRect buttonFrameInSelf = [self convertRect:button.bounds fromView:button];
                CGRect expandedFrame = CGRectInset(buttonFrameInSelf, -self.hitSlop, -self.hitSlop);
                if (CGRectIntersectsRect(expandedFrame, touchRect)) {
                    [newPressedButtons addObject:button];
                }
            }
        }
    }
    
    // Evaluate transitions for EVERY button explicitly
    for (UIButton *btn in self.buttons) {
        BOOL wasPressed = [self.currentlyPressedButtons containsObject:btn];
        BOOL isPressed = [newPressedButtons containsObject:btn];

        if (isPressed && !wasPressed) {
            // Finger slid onto or tapped the button
            [self handleButtonState:btn isPressed:YES];
            [self.currentlyPressedButtons addObject:btn];
            
        } else if (!isPressed && wasPressed) {
            // Finger slid off the button or lifted
            [self handleButtonState:btn isPressed:NO];
            [self.currentlyPressedButtons removeObject:btn];
        }
        
        btn.alpha = isPressed ? 0.3f : 0.75f;
    }
}

- (void)initVirtualJoystick {
    if (virtualJoystickIndex < 0 && _sdlWasInit) {
        if (SDL_WasInit(SDL_INIT_JOYSTICK) == 0) {
            SDL_InitSubSystem(SDL_INIT_JOYSTICK);
        }
        
        // Force SDL event pump to ensure virtual device subsystem registers
        SDL_PumpEvents();

        virtualJoystickIndex = SDL_JoystickAttachVirtual(SDL_JOYSTICK_TYPE_GAMECONTROLLER, 6, 15, 1);

        if (virtualJoystickIndex >= 0) {
            SDL_PumpEvents();
            virtualJoystick = SDL_JoystickOpen(virtualJoystickIndex);
        }
    }
}

#pragma mark - AnalogJoystickDelegate
- (void)joystick:(AnalogJoystickView *)joystick didMoveX:(CGFloat)x y:(CGFloat)y {
    [self initVirtualJoystick];
    [self resetHideTimer];
    if (virtualJoystick == NULL) {
        return;
    }
    SInt16 sX = 0;
    SInt16 sY = 0;
    // Convert [-1.0,1.0] to [-32768,32767]
    if (x < 0) {
        sX = (SInt16)SDL_clamp((SInt16)(x * 32768.0), -32768, 32767);
    } else {
        sX = (SInt16)SDL_clamp((SInt16)(x * 32767.0), -32768, 32767);
    }
    if (y < 0) {
        sY = (SInt16)SDL_clamp((SInt16)(y * -32767.0), -32768, 32767);
    } else {
        sY = (SInt16)SDL_clamp((SInt16)(y * -32768.0), -32768, 32767);
    }
    // Handle stick movement
    SDL_JoystickSetVirtualAxis(virtualJoystick, (int)joystick.tag, sX);
    SDL_JoystickSetVirtualAxis(virtualJoystick, (int)(joystick.tag+1), sY);
}

#pragma mark - Buttons
- (IBAction)buttonTouchDown:(UIButton *)sender {
    [self handleButtonState:sender isPressed:YES];
}

- (IBAction)buttonTouchUp:(UIButton *)sender {
    [self handleButtonState:sender isPressed:NO];
}

- (void)handleButtonState:(UIButton * )sender isPressed:(BOOL)isPressed {
    [self initVirtualJoystick];
    [self resetHideTimer];
    if (virtualJoystick == NULL) {
        return;
    }
    GamepadButton buttonIndex = (1 << sender.tag);
    SDL_GameControllerButton sdlButton = SDL_CONTROLLER_BUTTON_INVALID;
    SDL_GameControllerAxis sdlAxis = SDL_CONTROLLER_AXIS_INVALID;
    
    switch (buttonIndex) {
        case GamepadButtonA:
            sdlButton = SDL_CONTROLLER_BUTTON_A;
            break;
        case GamepadButtonB:
            sdlButton = SDL_CONTROLLER_BUTTON_B;
            break;
        case GamepadButtonC:
            sdlAxis = SDL_CONTROLLER_AXIS_TRIGGERRIGHT;
            break;
        case GamepadButtonX:
            sdlButton = SDL_CONTROLLER_BUTTON_X;
            break;
        case GamepadButtonY:
            sdlButton = SDL_CONTROLLER_BUTTON_Y;
            break;
        case GamepadButtonZ:
            sdlButton = SDL_CONTROLLER_BUTTON_RIGHTSHOULDER;
            break;
        case GamepadButtonS:
            sdlButton = SDL_CONTROLLER_BUTTON_START;
            break;
        case GamepadButtonM:
            sdlButton = SDL_CONTROLLER_BUTTON_BACK;
            break;
        case GamepadButtonD:
            sdlButton = SDL_CONTROLLER_BUTTON_LEFTSHOULDER;
            break;
        case GamepadButtonW:
            sdlAxis = SDL_CONTROLLER_AXIS_TRIGGERLEFT;
            break;
        case GamepadButtonNone:
        default:
            sdlButton = SDL_CONTROLLER_BUTTON_INVALID;
            sdlAxis = SDL_CONTROLLER_AXIS_INVALID;
            break;
    }
    
    if (sdlButton >= 0) {
        SDL_JoystickSetVirtualButton(virtualJoystick, (int)sdlButton, isPressed ? SDL_PRESSED : SDL_RELEASED);
        SDL_JoystickUpdate();
    }
    if (sdlAxis >= 0) {
        SDL_JoystickSetVirtualAxis(virtualJoystick, sdlAxis, isPressed ? 32767 : 0);
        SDL_JoystickUpdate();
    }
}

#pragma mark - DPadView Delegate
- (void)dPad:(DPadView *)dPad didChangeDirection:(DPadDirection)direction {
    [self initVirtualJoystick];
    if (virtualJoystick == NULL) {
        return;
    }

    // Dispatch as POV Hat 0 (Primary mapping for I.K.E.M.E.N-Go joystick reader)
    Uint8 hatValue = SDL_HAT_CENTERED;
    if (direction & DPadDirectionUp)    hatValue |= SDL_HAT_UP;
    if (direction & DPadDirectionDown)  hatValue |= SDL_HAT_DOWN;
    if (direction & DPadDirectionLeft)  hatValue |= SDL_HAT_LEFT;
    if (direction & DPadDirectionRight) hatValue |= SDL_HAT_RIGHT;
    
    SDL_JoystickSetVirtualHat(virtualJoystick, 0, hatValue);

    // Dispatch as GameController DPad Buttons (Fallback mapping)
    SDL_JoystickSetVirtualButton(virtualJoystick, SDL_CONTROLLER_BUTTON_DPAD_UP,
                                 (direction & DPadDirectionUp) ? SDL_PRESSED : SDL_RELEASED);
    SDL_JoystickSetVirtualButton(virtualJoystick, SDL_CONTROLLER_BUTTON_DPAD_DOWN,
                                 (direction & DPadDirectionDown) ? SDL_PRESSED : SDL_RELEASED);
    SDL_JoystickSetVirtualButton(virtualJoystick, SDL_CONTROLLER_BUTTON_DPAD_LEFT,
                                 (direction & DPadDirectionLeft) ? SDL_PRESSED : SDL_RELEASED);
    SDL_JoystickSetVirtualButton(virtualJoystick, SDL_CONTROLLER_BUTTON_DPAD_RIGHT,
                                 (direction & DPadDirectionRight) ? SDL_PRESSED : SDL_RELEASED);
}

@end


#pragma mark - ArcadePanelView

typedef struct {
    CGPoint center;
    CGFloat radius;
    NSInteger tag;      // virtual pad button (see GamepadInputs.h): 1 a, 2 b, 3 c, 4 x, 5 y, 6 z, 7 start, 8 menu
    BOOL kick;
} ArcadeButton;

@interface ArcadePanelView ()
@property (nonatomic, weak) UITouch *stickTouch;
@property (nonatomic, assign) DPadDirection direction;
@property (nonatomic, assign) uint32_t pressedMask;        // bit per entry of the button table
@property (nonatomic, strong) UIImpactFeedbackGenerator *tick;
@end

@implementation ArcadePanelView {
    ArcadeButton _buttons[6];
    CGPoint _stickCenter;
    CGFloat _stickRadius;
    CGRect _startRect;
    CGRect _menuRect;
    CGRect _viewRect;     // landscape only: switches between side controls and full screen
    CGSize _laidOutFor;
}

- (void)relayout {
    _laidOutFor = CGSizeZero;
    self.opaque = !self.landscape;
    self.backgroundColor = self.landscape ? [UIColor clearColor]
                                          : [UIColor colorWithRed:0.09 green:0.08 blue:0.11 alpha:1.0];
    [self setNeedsDisplay];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.multipleTouchEnabled = YES;
        self.userInteractionEnabled = YES;
        self.opaque = YES;
        self.backgroundColor = [UIColor colorWithRed:0.09 green:0.08 blue:0.11 alpha:1.0];
        self.contentMode = UIViewContentModeRedraw;
        _tick = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    return self;
}

- (void)setBottomInset:(CGFloat)bottomInset {
    if (_bottomInset != bottomInset) {
        _bottomInset = bottomInset;
        _laidOutFor = CGSizeZero;
        [self setNeedsDisplay];
    }
}

// Works out where the stick and buttons go for the current size
- (void)computeLayout {
    CGSize size = self.bounds.size;
    if (CGSizeEqualToSize(size, _laidOutFor)) {
        return;
    }
    _laidOutFor = size;
    if (self.landscape) {
        [self computeLandscapeLayout:size];
        return;
    }
    _viewRect = CGRectZero;
    CGFloat w = size.width;
    CGFloat topPad = 46.0;                          // row for START / MENU
    CGFloat bottom = size.height - MAX(_bottomInset, 10.0);
    CGFloat usable = MAX(bottom - topPad, 60.0);
    BOOL tall = usable > w * 0.9;                   // a tall phone leaves a deep panel; a short one gets a single band
    CGFloat cy = topPad + usable * (tall ? 0.46 : 0.52);

    _stickRadius = MIN(w * 0.20, usable * (tall ? 0.22 : 0.40));
    _stickCenter = CGPointMake(w * 0.25, cy);

    CGFloat colWidth = (w * 0.50) / 3.0;
    CGFloat radius = MIN(colWidth * 0.44, usable * (tall ? 0.115 : 0.21));
    CGFloat x0 = w * 0.485;
    CGFloat rowGap = radius * 1.22;
    // Top row punches (x y z), bottom row kicks (a b c): the same order as the arcade cabinet
    NSInteger tags[6] = {4, 5, 6, 1, 2, 3};
    for (int i = 0; i < 6; i++) {
        int col = i % 3, row = i / 3;
        CGFloat x = x0 + colWidth * (col + 0.5);
        CGFloat y = cy + (row == 0 ? -rowGap : rowGap) - col * radius * 0.22;   // gentle arc, like a real panel
        _buttons[i].center = CGPointMake(x, y);
        _buttons[i].radius = radius;
        _buttons[i].tag = tags[i];
        _buttons[i].kick = (row == 1);
    }
    _startRect = CGRectMake(w - 84.0, 9.0, 72.0, 28.0);
    _menuRect = CGRectMake(w - 84.0 - 80.0, 9.0, 72.0, 28.0);
}

- (void)computeLandscapeLayout:(CGSize)size {
    CGFloat W = size.width, H = size.height;
    CGRect g = self.gameRect;
    UIEdgeInsets si = self.sideInsets;
    CGFloat bottom = H - MAX(self.bottomInset, 8.0);
    NSInteger tags[6] = {4, 5, 6, 1, 2, 3};
    if (self.fullScreen) {
        // see-through controls in the lower corners, over the picture
        _stickRadius = MIN(H * 0.20, 92.0);
        _stickCenter = CGPointMake(MAX(si.left, 12.0) + _stickRadius + 8.0, bottom - _stickRadius - 18.0);
        CGFloat r = MIN(H * 0.068, 31.0);
        CGFloat step = r * 2.25;
        CGFloat x0 = W - MAX(si.right, 12.0) - step * 3.0 + r * 0.2;
        CGFloat cy = bottom - r * 2.6;
        for (int i = 0; i < 6; i++) {
            int col = i % 3, row = i / 3;
            _buttons[i].center = CGPointMake(x0 + step * (col + 0.5) + (row == 1 ? -r * 0.35 : 0), cy + (row == 0 ? -r * 1.2 : r * 1.2) - col * r * 0.25);
            _buttons[i].radius = r;
            _buttons[i].tag = tags[i];
            _buttons[i].kick = (row == 1);
        }
        CGFloat pw = 64.0, ph = 26.0, py = bottom - ph - 2.0, cx = W / 2.0;
        _menuRect = CGRectMake(cx - pw * 1.5 - 8.0, py, pw, ph);
        _startRect = CGRectMake(cx - pw * 0.5, py, pw, ph);
        _viewRect = CGRectMake(cx + pw * 0.5 + 8.0, py, pw, ph);
        return;
    }
    // side controls: stick centred in the left strip, buttons in the right strip, a little below the middle
    CGFloat leftW = g.origin.x, rightX = CGRectGetMaxX(g), rightW = W - rightX;
    CGFloat leftClear = MAX(si.left, 6.0), rightClear = MAX(si.right, 6.0);
    _stickRadius = MIN((leftW - leftClear) * 0.42, H * 0.22);
    _stickCenter = CGPointMake(leftClear + (leftW - leftClear) / 2.0, MIN(H * 0.64, bottom - _stickRadius - 6.0));
    CGFloat usableW = rightW - rightClear - 4.0;
    CGFloat r = MIN(usableW / 3.0 * 0.44, H * 0.075);
    CGFloat step = usableW / 3.0;
    CGFloat cy = _stickCenter.y;
    for (int i = 0; i < 6; i++) {
        int col = i % 3, row = i / 3;
        _buttons[i].center = CGPointMake(rightX + 4.0 + step * (col + 0.5) + (row == 1 ? -r * 0.25 : r * 0.1),
                                         cy + (row == 0 ? -r * 1.25 : r * 1.25) - col * r * 0.22);
        _buttons[i].radius = r;
        _buttons[i].tag = tags[i];
        _buttons[i].kick = (row == 1);
    }
    CGFloat pw = 72.0, ph = 28.0;
    CGFloat py = CGRectGetMaxY(g) + MAX(6.0, (bottom - CGRectGetMaxY(g) - ph) / 2.0);
    CGFloat cx = CGRectGetMidX(g);
    _menuRect = CGRectMake(cx - pw * 1.5 - 10.0, py, pw, ph);
    _startRect = CGRectMake(cx - pw * 0.5, py, pw, ph);
    _viewRect = CGRectMake(cx + pw * 0.5 + 10.0, py, pw, ph);
}

#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    [self computeLayout];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize size = self.bounds.size;

    // Landscape: the panel art around the picture (none at all in full screen), the picture's area left clear
    CGFloat ctlAlpha = 1.0;
    if (self.landscape) {
        CGContextClearRect(ctx, self.bounds);
        if (self.fullScreen) {
            ctlAlpha = 0.55;
        } else {
            CGContextSaveGState(ctx);
            UIBezierPath *around = [UIBezierPath bezierPathWithRect:self.bounds];
            [around appendPath:[UIBezierPath bezierPathWithRect:self.gameRect]];
            around.usesEvenOddFillRule = YES;
            [around addClip];
            UIImage *art = [UIImage imageNamed:@"for_panel"];
            if (art != nil) {
                CGFloat s2 = MAX(size.width / art.size.width, size.height / art.size.height);
                CGSize as = CGSizeMake(art.size.width * s2, art.size.height * s2);
                [art drawInRect:CGRectMake((size.width - as.width) / 2.0, (size.height - as.height) / 2.0, as.width, as.height)];
            } else {
                [[UIColor colorWithRed:0.13 green:0.12 blue:0.15 alpha:1.0] setFill];
                CGContextFillRect(ctx, self.bounds);
            }
            // a soft shadow round the picture
            [[UIColor colorWithWhite:0.0 alpha:0.55] setStroke];
            CGContextSetLineWidth(ctx, 6.0);
            CGContextStrokeRect(ctx, CGRectInset(self.gameRect, -3.0, -3.0));
            CGContextRestoreGState(ctx);
        }
        CGContextBeginTransparencyLayer(ctx, NULL);
        CGContextSetAlpha(ctx, ctlAlpha);
        [self drawControls:ctx];
        CGContextEndTransparencyLayer(ctx);
        return;
    }

    // Panel: dark metal with a slash of orange, or the painted panel when the app carries one
    UIImage *panel = [UIImage imageNamed:@"for_panel"];
    if (panel != nil) {
        CGFloat s = MAX(size.width / panel.size.width, size.height / panel.size.height);
        CGSize ps = CGSizeMake(panel.size.width * s, panel.size.height * s);
        [panel drawInRect:CGRectMake((size.width - ps.width) / 2.0, (size.height - ps.height) / 2.0, ps.width, ps.height)];
    } else {
        [[UIColor colorWithRed:0.13 green:0.12 blue:0.15 alpha:1.0] setFill];
        CGContextFillRect(ctx, self.bounds);
        [[UIColor colorWithRed:0.16 green:0.15 blue:0.19 alpha:1.0] setStroke];
        CGContextSetLineWidth(ctx, 1.0);
        for (CGFloat x = 0; x < size.width; x += 4.0) {
            CGContextMoveToPoint(ctx, x, 0);
            CGContextAddLineToPoint(ctx, x, size.height);
        }
        CGContextStrokePath(ctx);
        UIBezierPath *slash = [UIBezierPath bezierPath];
        [slash moveToPoint:CGPointMake(0, 0)];
        [slash addLineToPoint:CGPointMake(size.width * 0.52, 0)];
        [slash addLineToPoint:CGPointMake(size.width * 0.36, 46.0)];
        [slash addLineToPoint:CGPointMake(0, 46.0)];
        [slash closePath];
        [[UIColor colorWithRed:0.78 green:0.29 blue:0.08 alpha:1.0] setFill];
        [slash fill];
    }
    [[UIColor colorWithWhite:0.0 alpha:0.55] setFill];
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, 2.0));
    [self drawControls:ctx];
}

- (void)drawControls:(CGContextRef)ctx {
    // Stick: base plate, then the ball pushed toward where it is held
    CGFloat R = _stickRadius;
    CGRect base = CGRectMake(_stickCenter.x - R, _stickCenter.y - R, R * 2.0, R * 2.0);
    UIImage *baseImg = [UIImage imageNamed:@"for_stick_base"];
    if (baseImg != nil) {
        [baseImg drawInRect:base];
    } else {
        [[UIColor colorWithWhite:0.05 alpha:1.0] setFill];
        CGContextFillEllipseInRect(ctx, base);
        [[UIColor colorWithWhite:0.32 alpha:1.0] setStroke];
        CGContextSetLineWidth(ctx, 3.0);
        CGContextStrokeEllipseInRect(ctx, CGRectInset(base, 1.5, 1.5));
    }
    CGFloat dx = 0, dy = 0;
    if (_direction & DPadDirectionLeft)  dx -= 1;
    if (_direction & DPadDirectionRight) dx += 1;
    if (_direction & DPadDirectionUp)    dy -= 1;
    if (_direction & DPadDirectionDown)  dy += 1;
    CGFloat len = sqrt(dx * dx + dy * dy);
    if (len > 0) {
        dx = dx / len * R * 0.36;
        dy = dy / len * R * 0.36;
    }
    CGFloat br = R * 0.56;
    CGRect ball = CGRectMake(_stickCenter.x + dx - br, _stickCenter.y + dy - br, br * 2.0, br * 2.0);
    UIImage *ballImg = [UIImage imageNamed:@"for_stick_ball"];
    if (ballImg != nil) {
        [ballImg drawInRect:ball];
    } else {
        [[UIColor colorWithRed:0.80 green:0.12 blue:0.12 alpha:1.0] setFill];
        CGContextFillEllipseInRect(ctx, ball);
        [[UIColor colorWithRed:1.0 green:0.55 blue:0.5 alpha:0.9] setFill];
        CGContextFillEllipseInRect(ctx, CGRectMake(ball.origin.x + br * 0.42, ball.origin.y + br * 0.28, br * 0.5, br * 0.36));
    }

    // Buttons
    static NSString * const names[6] = {@"LP", @"MP", @"HP", @"LK", @"MK", @"HK"};
    for (int i = 0; i < 6; i++) {
        ArcadeButton b = _buttons[i];
        BOOL down = (_pressedMask & (1u << i)) != 0;
        CGFloat r = down ? b.radius * 0.94 : b.radius;
        CGRect box = CGRectMake(b.center.x - r, b.center.y - r, r * 2.0, r * 2.0);
        NSString *imgName = b.kick ? (down ? @"for_btn_kick_on" : @"for_btn_kick") : (down ? @"for_btn_punch_on" : @"for_btn_punch");
        UIImage *img = [UIImage imageNamed:imgName];
        if (img != nil) {
            [img drawInRect:box];
        } else {
            UIColor *fill = b.kick ? [UIColor colorWithRed:0.20 green:0.43 blue:0.92 alpha:1.0]
                                   : [UIColor colorWithRed:0.94 green:0.51 blue:0.12 alpha:1.0];
            if (down) {
                fill = b.kick ? [UIColor colorWithRed:0.55 green:0.75 blue:1.0 alpha:1.0]
                              : [UIColor colorWithRed:1.0 green:0.80 blue:0.45 alpha:1.0];
            }
            [[UIColor colorWithWhite:0.04 alpha:1.0] setFill];
            CGContextFillEllipseInRect(ctx, CGRectInset(box, -4.0, -4.0));
            [fill setFill];
            CGContextFillEllipseInRect(ctx, box);
            [[UIColor colorWithWhite:1.0 alpha:0.85] setStroke];
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokeEllipseInRect(ctx, CGRectInset(box, 1.0, 1.0));
        }
        NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:MAX(11.0, b.radius * 0.62) weight:UIFontWeightHeavy],
                               NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:1.0],
                               NSStrokeColorAttributeName: [UIColor colorWithWhite:0.0 alpha:0.9],
                               NSStrokeWidthAttributeName: @(-3.0)};
        CGSize ts = [names[i] sizeWithAttributes:attr];
        [names[i] drawAtPoint:CGPointMake(b.center.x - ts.width / 2.0, b.center.y - ts.height / 2.0) withAttributes:attr];
    }

    // START and MENU
    [self drawPill:_startRect title:@"START" down:(_pressedMask & (1u << 6)) != 0];
    [self drawPill:_menuRect title:@"MENU" down:(_pressedMask & (1u << 7)) != 0];
    if (!CGRectIsEmpty(_viewRect)) {
        [self drawPill:_viewRect title:(self.fullScreen ? @"PANEL" : @"FULL") down:(_pressedMask & (1u << 8)) != 0];
    }
}

- (void)drawPill:(CGRect)r title:(NSString *)title down:(BOOL)down {
    UIBezierPath *pill = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:r.size.height / 2.0];
    [(down ? [UIColor colorWithWhite:1.0 alpha:1.0] : [UIColor colorWithWhite:0.86 alpha:1.0]) setFill];
    [pill fill];
    NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:12.0 weight:UIFontWeightHeavy],
                           NSForegroundColorAttributeName: [UIColor colorWithWhite:0.1 alpha:1.0]};
    CGSize ts = [title sizeWithAttributes:attr];
    [title drawAtPoint:CGPointMake(CGRectGetMidX(r) - ts.width / 2.0, CGRectGetMidY(r) - ts.height / 2.0) withAttributes:attr];
}

#pragma mark Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self computeLayout];
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        // A finger that lands on the stick side below the top row takes the stick, and keeps it wherever it slides
        BOOL onPill = CGRectContainsPoint(CGRectInset(_startRect, -10, -10), p) || CGRectContainsPoint(CGRectInset(_menuRect, -10, -10), p) ||
                      CGRectContainsPoint(CGRectInset(_viewRect, -10, -10), p);
        BOOL stickSide = self.landscape ? (p.x < self.bounds.size.width * 0.40 && !onPill)
                                        : (p.x < self.bounds.size.width * 0.47 && p.y > 46.0);
        if (self.stickTouch == nil && stickSide) {
            self.stickTouch = t;
        }
    }
    [self update:event.allTouches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self update:event.allTouches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self update:event.allTouches];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self update:event.allTouches];
}

- (void)update:(NSSet<UITouch *> *)touches {
    DPadDirection dir = DPadDirectionNeutral;
    uint32_t mask = 0;
    BOOL stickAlive = NO;
    CGFloat slop = 10.0;

    for (UITouch *t in touches) {
        if (t.phase == UITouchPhaseEnded || t.phase == UITouchPhaseCancelled) {
            continue;
        }
        if (t.view != self) {
            continue;
        }
        CGPoint p = [t locationInView:self];
        if (t == self.stickTouch) {
            stickAlive = YES;
            CGFloat dx = p.x - _stickCenter.x;
            CGFloat dy = p.y - _stickCenter.y;
            CGFloat dist = sqrt(dx * dx + dy * dy);
            if (dist > _stickRadius * 0.24) {
                // eight ways: a component counts once it is more than sin(22.5 degrees) of the pull
                if (dx < -dist * 0.383) dir |= DPadDirectionLeft;
                if (dx >  dist * 0.383) dir |= DPadDirectionRight;
                if (dy < -dist * 0.383) dir |= DPadDirectionUp;
                if (dy >  dist * 0.383) dir |= DPadDirectionDown;
            }
            continue;
        }
        for (int i = 0; i < 6; i++) {
            CGFloat dx = p.x - _buttons[i].center.x;
            CGFloat dy = p.y - _buttons[i].center.y;
            CGFloat reach = _buttons[i].radius + slop;
            if (dx * dx + dy * dy <= reach * reach) {
                mask |= (1u << i);
            }
        }
        if (CGRectContainsPoint(CGRectInset(_startRect, -slop, -slop), p)) mask |= (1u << 6);
        if (CGRectContainsPoint(CGRectInset(_menuRect, -slop, -slop), p))  mask |= (1u << 7);
        if (!CGRectIsEmpty(_viewRect) && CGRectContainsPoint(CGRectInset(_viewRect, -slop, -slop), p)) mask |= (1u << 8);
    }
    if (!stickAlive) {
        self.stickTouch = nil;
    }

    BOOL changed = NO;
    if (dir != _direction) {
        _direction = dir;
        [self.overlay arcadeDirection:dir];
        changed = YES;
    }
    if (mask != _pressedMask) {
        uint32_t diff = mask ^ _pressedMask;
        BOOL anyDown = NO;
        if ((diff & (1u << 8)) && !(mask & (1u << 8))) {
            // FULL / PANEL released: switch layouts (not a game button)
            dispatch_async(dispatch_get_main_queue(), ^{ [self.overlay toggleFullScreen]; });
        }
        for (int i = 0; i < 8; i++) {
            if (diff & (1u << i)) {
                BOOL down = (mask & (1u << i)) != 0;
                NSInteger tag = (i < 6) ? _buttons[i].tag : (i == 6 ? 7 : 8);
                [self.overlay arcadeButton:tag pressed:down];
                anyDown = anyDown || down;
            }
        }
        _pressedMask = mask;
        if (anyDown) {
            [self.tick impactOccurred];
        }
        changed = YES;
    }
    if (changed) {
        [self setNeedsDisplay];
    }
}

@end
