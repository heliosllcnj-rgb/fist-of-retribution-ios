//
//  TouchOverlayView.h
//  I.K.E.M.E.N-Go
//
//  Created by Jesuszilla on 8/25/26.
//

#import "AnalogJoystickView.h"
#import "DPadView.h"
#import <UIKit/UIKit.h>

@class TouchOverlayView;

@protocol GameFolderButtonDelegate <NSObject>
- (void)touchOverlayDidTapGameFolder:(TouchOverlayView *)view;
@end

@interface TouchOverlayView : UIView <AnalogJoystickDelegate, DPadDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<GameFolderButtonDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIButton *gameFolderButton;
@property (nonatomic, strong) IBOutlet UIView *vewlixButtonView;
@property (nonatomic, strong) IBOutlet DPadView *dPadView;
@property (nonatomic, strong) IBOutlet AnalogJoystickView *leftJoystickView;
@property (nonatomic, strong) IBOutlet AnalogJoystickView *rightJoystickView;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray<UIButton *> *buttons;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGFloat hitSlop;
@property (atomic, assign) BOOL sdlWasInit;
- (void)resetHideTimer;

// Fist of Retribution arcade panel: the panel reports presses here and they go out through the same virtual pad
- (void)arcadeButton:(NSInteger)tag pressed:(BOOL)pressed;
- (void)arcadeDirection:(DPadDirection)direction;

- (void)toggleFullScreen;
@end

// The arcade stick and buttons drawn under the game picture (portrait phones, and a folded-open phone stood up
// like a small cabinet). Everything is sized from the space it is given, so it fits any screen.
@interface ArcadePanelView : UIView
@property (nonatomic, weak) TouchOverlayView *overlay;
@property (nonatomic, assign) CGFloat bottomInset;   // home-indicator space to keep clear
// Landscape: the panel covers the whole screen and leaves gameRect (its own coordinates) clear for the picture.
// fullScreen: the picture fills the height and the controls are drawn see-through on top of it.
@property (nonatomic, assign) BOOL landscape;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, assign) CGRect gameRect;
@property (nonatomic, assign) UIEdgeInsets sideInsets; // safe-area insets (camera cut-out side)
- (void)relayout;
@end
