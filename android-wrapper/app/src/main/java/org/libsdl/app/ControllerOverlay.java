package org.libsdl.app;

import android.content.Context;
import android.view.InputDevice;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import org.ikemen_engine.ikemen_go.R;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class ControllerOverlay extends RelativeLayout {
    private int virtualDeviceId;
    private int hatX, hatY = 0;
    private final Map<Integer, Set<Integer>> pointerStates = new HashMap<>(); // PointerID -> Keycode/Axis
    private boolean isInitialized = false;

    public int getPhysicalJoystickCount() {
        int count = 0;
        int[] deviceIds = InputDevice.getDeviceIds();
        for (int id : deviceIds) {
            InputDevice dev = InputDevice.getDevice(id);
            // Check if the device is a physical joystick or gamepad
            // OLD LOGIC: Checked only flags (Let sensors through)
            // NEW LOGIC: Checks isRealGamepad (Stricter filtering by querying for buttons)
            if (isRealGamepad(dev)) {
                count++;
            }
        }
        return count;
    }

    // Helper to distinguish real controllers from "Ghost" sensors
    private boolean isRealGamepad(InputDevice device) {
        if (device == null) return false;

        int sources = device.getSources();
        boolean isJoystick = ((sources & InputDevice.SOURCE_JOYSTICK) == InputDevice.SOURCE_JOYSTICK) ||
                ((sources & InputDevice.SOURCE_GAMEPAD) == InputDevice.SOURCE_GAMEPAD);

        // Must identify as joystick/gamepad
        if (!isJoystick) return false;

        // Ignore virtual devices (optional, prevents software loopbacks)
        if (device.isVirtual()) return false;

        // Ghost filter, does it have actual buttons?
        // Sensors report as Joysticks but have NO buttons.
        // Real gamepads always have at least one of these.
        int[] keysToCheck = {
                android.view.KeyEvent.KEYCODE_BUTTON_A,
                android.view.KeyEvent.KEYCODE_BUTTON_B,
                android.view.KeyEvent.KEYCODE_BUTTON_X,
                android.view.KeyEvent.KEYCODE_BUTTON_Y,
                android.view.KeyEvent.KEYCODE_BUTTON_START,
                android.view.KeyEvent.KEYCODE_BUTTON_SELECT,
        };

        boolean[] hasKeys = device.hasKeys(keysToCheck);
        for (boolean exists : hasKeys) {
            if (exists) return true; // It has any of these buttons, it's a real gamepad
        }

        return false; // No buttons, its a sensor, ignore it
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        if (!isInitialized) {
            initializeVirtualController();
            isInitialized = true;
        }
        return true;
    }

    private int leftJoyPointerId = -1;
    private int rightJoyPointerId = -1;

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (ARCADE) {
            return arcadeTouch(event);
        }
        int action = event.getActionMasked();
        int index = event.getActionIndex();
        int pId = event.getPointerId(index);

        // Get raw coordinates for global hit detection
        float x = event.getX(index);
        float y = event.getY(index);

        if (action == MotionEvent.ACTION_DOWN || action == MotionEvent.ACTION_POINTER_DOWN) {
            // Check Joysticks first
            if (isViewAtLocation(findViewById(R.id.left_analog), x, y)) {
                leftJoyPointerId = pId;
            } else if (isViewAtLocation(findViewById(R.id.right_analog), x, y)) {
                rightJoyPointerId = pId;
            } else {
                // If not a stick, it's a button/dpad
                updatePointer(pId, getButtonsAt(x, y));
            }
        } else if (action == MotionEvent.ACTION_MOVE) {
            for (int i = 0; i < event.getPointerCount(); i++) {
                int movePId = event.getPointerId(i); // The stable ID

                // Get coordinates specifically for THIS pointer index
                float mx = event.getX(i);
                float my = event.getY(i);

                if (movePId == leftJoyPointerId) {
                    updateJoystickLogic(findViewById(R.id.left_analog), mx, my);
                } else if (movePId == rightJoyPointerId) {
                    updateJoystickLogic(findViewById(R.id.right_analog), mx, my);
                } else {
                    Set<Integer> currentButtons = getButtonsAt(mx, my);
                    Set<Integer> lastButtons = pointerStates.get(movePId);

                    // If the sets are different, update the physical state
                    if (!currentButtons.equals(lastButtons)) {
                        updatePointer(movePId, currentButtons);
                    }
                }
            }
        } else if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_POINTER_UP || action == MotionEvent.ACTION_CANCEL) {
            if (pId == leftJoyPointerId) {
                resetJoystick(findViewById(R.id.left_analog));
                leftJoyPointerId = -1;
            } else if (pId == rightJoyPointerId) {
                resetJoystick(findViewById(R.id.right_analog));
                rightJoyPointerId = -1;
            } else {
                releasePointer(pId);
            }
        }

        updateDpadState(event);
        return true;
    }

    private void updateJoystickLogic(View v, float x, float y) {
        if (!(v instanceof JoystickOverlay)) return;
        JoystickOverlay joy = (JoystickOverlay) v;

        // LOCAL CENTER CALCULATION
        float centerX = v.getLeft() + (v.getWidth() / 2f);
        float centerY = v.getTop() + (v.getHeight() / 2f);
        float radius = v.getWidth() / 3f;

        float dx = x - centerX;
        float dy = y - centerY;
        float distance = (float) Math.sqrt(dx * dx + dy * dy);

        if (distance > radius) {
            dx = (dx / distance) * radius;
            dy = (dy / distance) * radius;
        }

        joy.updateVisualPos((v.getWidth()/2f) + dx, (v.getHeight()/2f) + dy);
        joy.sendToSDL(dx / radius, dy / radius);
    }

    private void resetJoystick(View v) {
        if (!(v instanceof JoystickOverlay)) return;
        JoystickOverlay joy = (JoystickOverlay) v;
        joy.updateVisualPos(v.getWidth()/2f, v.getHeight()/2f);
        joy.sendToSDL(0, 0);
    }

    private void updatePointer(int pointerId, Set<Integer> newCodes) {
        Set<Integer> oldCodes = pointerStates.get(pointerId);
        if (oldCodes == null) oldCodes = new HashSet<>();
        // Find buttons that were RELEASED (in old set, not in new)
        for (Integer oldCode : oldCodes) {
            if (!newCodes.contains(oldCode)) {
                handleInput(oldCode, false);
            }
        }
        // Find buttons that were PRESSED (in new set, not in old)
        for (Integer newCode : newCodes) {
            if (!oldCodes.contains(newCode)) {
                handleInput(newCode, true);
            }
        }
        // Save the new state for this finger
        pointerStates.put(pointerId, newCodes);
    }

    private void releasePointer(int pointerId) {
        Set<Integer> lastCodes = pointerStates.remove(pointerId);
        if (lastCodes != null) {
            for (Integer code : lastCodes) {
                handleInput(code, false);
            }
        }
    }

    private void handleInput(final int code, boolean pressed) {
        if (code == -1) return;

        if (code >= 4000) { // TRIGGERS
            int axis = code - 4000;
            SDLControllerManager.onNativeJoy(virtualDeviceId, axis, pressed ? 1.0f : 0.0f);
        }
        else if (code >= 1000) {
            // D-PAD visuals only (Logic remains in updateDpadState)
        }
        else { // STANDARD BUTTONS
            if (pressed) {
                SDLControllerManager.onNativeHat(virtualDeviceId, 0, hatX, hatY);
                int result = SDLControllerManager.onNativePadDown(virtualDeviceId, code);
                if (result < 0) {
                    android.util.Log.e("SDL", "INPUT FAILURE: Device " + virtualDeviceId + " rejected button " + code);
                }
            } else {
                SDLControllerManager.onNativePadUp(virtualDeviceId, code);
            }
        }

        // Always update visuals
        updateButtonVisual(code, pressed);
    }

    private void updateButtonVisual(int code, boolean pressed) {
        int viewId = -1;
        switch (code) {
            case 96:  viewId = R.id.btn_a; break;
            case 97:  viewId = R.id.btn_b; break;
            case 99:  viewId = R.id.btn_x; break;
            case 100: viewId = R.id.btn_y; break;
            case 102: viewId = R.id.btn_d; break;
            case 103: viewId = R.id.btn_z; break;
            case 108: viewId = R.id.btn_start; break;
            case 109: viewId = R.id.btn_back; break;
            case 1001: viewId = R.id.dp_up; break;
            case 1002: viewId = R.id.dp_down; break;
            case 1003: viewId = R.id.dp_left; break;
            case 1004: viewId = R.id.dp_right; break;
//            case 1005: viewId = R.id.dp_upleft; break;
//            case 1006: viewId = R.id.dp_downright; break;
//            case 1007: viewId = R.id.dp_downleft; break;
//            case 1008: viewId = R.id.dp_upright; break;
            case 4004: viewId = R.id.btn_w; break;
            case 4005: viewId = R.id.btn_c; break;
        }

        if (viewId != -1) {
            View v = findViewById(viewId);
            if (v != null) v.setPressed(pressed);
        }
    }

    private void updateDpadState(MotionEvent event) {
        int newX = 0, newY = 0;
        int action = event.getActionMasked();

        if (action != MotionEvent.ACTION_UP && action != MotionEvent.ACTION_CANCEL) {
            View container = findViewById(R.id.dpad_container);
            if (container == null) return;

            // Use Local coordinates to match event.getX()
            float centerX = container.getLeft() + (container.getWidth() / 2f);
            float centerY = container.getTop() + (container.getHeight() / 2f);
            float radius = container.getWidth() / 2f;

            for (int i = 0; i < event.getPointerCount(); i++) {
                if (action == MotionEvent.ACTION_POINTER_UP && i == event.getActionIndex()) continue;

                float x = event.getX(i);
                float y = event.getY(i);

                // Calculate distance from center (Pythagoras)
                float dx = x - centerX;
                float dy = y - centerY;
                float distance = (float) Math.sqrt(dx * dx + dy * dy);

                // Only process if the finger is actually touching the D-Pad area
                // (with  a small "deadzone" in the middle so neutral is easy to hit)
                if (distance > (radius * 0.2f) && distance < (radius * 1.5f)) {
                    // Calculate angle in degrees (0 to 360)
                    double angle = Math.toDegrees(Math.atan2(dy, dx));
                    if (angle < 0) angle += 360;

                    // Map angle to 8 directions with wider diagonals
                    // Cardinals get 30 degrees, Diagonals get 60 degrees
                    if (angle >= 345 || angle < 15)        newX = 1;  // Right (Narrower)
                    else if (angle >= 15  && angle < 75)   { newX = 1; newY = 1; }   // Down-Right (Wider)
                    else if (angle >= 75  && angle < 105)  newY = 1; // Down
                    else if (angle >= 105 && angle < 165)  { newX = -1; newY = 1; }  // Down-Left
                    else if (angle >= 165 && angle < 195)  newX = -1; // Left
                    else if (angle >= 195 && angle < 255)  { newX = -1; newY = -1; } // Up-Left
                    else if (angle >= 255 && angle < 285)  newY = -1; // Up
                    else if (angle >= 285 && angle < 345)  { newX = 1; newY = -1; }  // Up-Right

                    // Map angle to 8 directions
//                    if (angle >= 337.5 || angle < 22.5)   newX = 1;  // Right
//                    else if (angle >= 22.5  && angle < 67.5)  { newX = 1; newY = 1; }   // Down-Right
//                    else if (angle >= 67.5  && angle < 112.5) newY = 1; // Down
//                    else if (angle >= 112.5 && angle < 157.5) { newX = -1; newY = 1; }  // Down-Left
//                    else if (angle >= 157.5 && angle < 202.5) newX = -1; // Left
//                    else if (angle >= 202.5 && angle < 247.5) { newX = -1; newY = -1; } // Up-Left
//                    else if (angle >= 247.5 && angle < 292.5) newY = -1; // Up
//                    else if (angle >= 292.5 && angle < 337.5) { newX = 1; newY = -1; }  // Up-Right

                    break; // One finger is enough for the D-pad
                }
            }
        }

        if (newX != hatX || newY != hatY) {
            hatX = newX;
            hatY = newY;
            SDLControllerManager.onNativeHat(virtualDeviceId, 0, hatX, hatY);
            updateDpadVisual(hatX, hatY);
        }
    }

    private int dpToPx(int dp) {
        float density = getContext().getResources().getDisplayMetrics().density;
        return Math.round((float) dp * density);
    }

    private Set<Integer> getButtonsAt(float x, float y) {
        Set<Integer> detectedButtons = new HashSet<>();

        // Define a "padding" factor in pixels. This allows the thumb to trigger
        // two buttons if it's in the gap between them.
        int padding = dpToPx(16);

        checkAndAdd(detectedButtons, R.id.btn_a, 96, x, y, padding);
        checkAndAdd(detectedButtons, R.id.btn_b, 97, x, y, padding);
        checkAndAdd(detectedButtons, R.id.btn_x, 99, x, y, padding);
        checkAndAdd(detectedButtons, R.id.btn_y, 100, x, y, padding);
        checkAndAdd(detectedButtons, R.id.btn_d, 102, x,y, padding);
        checkAndAdd(detectedButtons, R.id.btn_z, 103, x,y, padding);
        checkAndAdd(detectedButtons, R.id.btn_w, 4004, x,y, padding);
        checkAndAdd(detectedButtons, R.id.btn_c, 4005, x,y, padding);
        checkAndAdd(detectedButtons, R.id.btn_start, 108, x,y, padding);
        checkAndAdd(detectedButtons, R.id.btn_back, 109, x,y, padding);

        return detectedButtons;
    }

    private void checkAndAdd(Set<Integer> set, int viewId, int code, float x, float y, int pad) {
        View v = findViewById(viewId);
        if (v == null) return;

        int[] loc = new int[2];
        int[] parentLoc = new int[2];
        v.getLocationOnScreen(loc);
        this.getLocationOnScreen(parentLoc);

        // Calculate coordinates with padding
        int left   = loc[0] - parentLoc[0] - pad;
        int top    = loc[1] - parentLoc[1] - pad;
        int right  = left + v.getWidth() + pad*2;
        int bottom = top + v.getHeight() + pad*2;

        // Add if in region + padding
        if (x >= left && x <= right && y >= top && y <= bottom) {
            set.add(code);
        }
    }

    private void updateDpadVisual(int hX, int hY) {
        findViewById(R.id.dp_up).setPressed(hY == -1);
        findViewById(R.id.dp_down).setPressed(hY == 1);
        findViewById(R.id.dp_left).setPressed(hX == -1);
        findViewById(R.id.dp_right).setPressed(hX == 1);
    }

    // Helper to check if a finger is inside a specific button's area
    private boolean isViewAtLocation(View v, float x, float y) {
        if (v == null || v.getVisibility() != View.VISIBLE) return false;

        int[] vLoc = new int[2];
        v.getLocationOnScreen(vLoc); // Global position of button

        int[] parentLoc = new int[2];
        this.getLocationOnScreen(parentLoc); // Global position of the overlay

        // Get the position of the button RELATIVE to the overlay
        int relativeLeft = vLoc[0] - parentLoc[0];
        int relativeTop = vLoc[1] - parentLoc[1];

        return x >= relativeLeft && x <= (relativeLeft + v.getWidth()) &&
                y >= relativeTop && y <= (relativeTop + v.getHeight());
    }

    public ControllerOverlay(Context context) {
        super(context);
        this.setClickable(true);
        this.setFocusable(true);
        this.setEnabled(true);
        this.setMotionEventSplittingEnabled(true);

        // Inflate the buttons
        LayoutInflater inflater = LayoutInflater.from(context);
        View vc = inflater.inflate(R.layout.virtual_controller, this, true);
        disableAllTouches(vc);

        if (ARCADE) {
            // The stock pad stays in the tree (the joystick set-up looks its views up) but is not shown
            for (int i = 0; i < getChildCount(); i++) {
                getChildAt(i).setVisibility(View.INVISIBLE);
            }
            arcadeView = new ArcadeView(context);
            addView(arcadeView, new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }
    }

    // ------------------------------------------------------------------------------------------------
    // Fist of Retribution arcade panel: the game picture sits at the top of the portrait screen and the
    // stick and six buttons fill the space underneath. Everything is sized from the screen it is given.
    // The engine learns how far down the picture starts from FOR_VIEW_TOP (pixels), which it reads each frame.
    // ------------------------------------------------------------------------------------------------
    private static final boolean ARCADE = true;
    private ArcadeView arcadeView;
    private int stickPointer = -1;
    private int arcadeMask = 0;              // bit per entry of ARCADE_CODES
    // LP MP HP (x y z) on the top row, LK MK HK (a b c) on the bottom row, then START and MENU
    private static final int[] ARCADE_CODES = {99, 100, 103, 96, 97, 4005, 108, 109};
    private static final String[] ARCADE_NAMES = {"LP", "MP", "HP", "LK", "MK", "HK"};
    private final float[] btnX = new float[6], btnY = new float[6];
    private float btnR, stickX, stickY, stickR, panelTop, topPad;
    private final android.graphics.RectF startRect = new android.graphics.RectF(), menuRect = new android.graphics.RectF();
    private final android.graphics.RectF viewRect = new android.graphics.RectF();   // landscape: FULL / PANEL switch
    private final android.graphics.RectF gameRect = new android.graphics.RectF();   // landscape: where the picture is
    private boolean landscape = false, fullScreen = false;
    private int laidW = -1, laidH = -1, laidInset = -1;
    private boolean laidFull = false;

    // Touch settings chosen in the game's own menu (Options > Button Config > Touch Controls), written by
    // external/script/options.lua to <game folder>/save/touch.cfg: size (percent), seethrough (percent, full screen),
    // vibration (0 / 1). Checked once a second while the overlay is on screen.
    private float touchScale = 1f;
    private int touchAlpha = 140;
    private boolean touchVibrate = true;
    private long touchCfgStamp = -1;
    private final android.os.Handler touchCfgHandler = new android.os.Handler(android.os.Looper.getMainLooper());
    private final Runnable touchCfgPoll = new Runnable() {
        @Override
        public void run() {
            if (loadTouchSettings()) {
                laidW = -1;
                arcadeLayout();
                if (arcadeView != null) arcadeView.invalidate();
            }
            touchCfgHandler.postDelayed(this, 1000);
        }
    };

    private boolean loadTouchSettings() {
        String base = SDLActivity.getBasePath();
        if (base == null || base.isEmpty()) return false;
        java.io.File f = new java.io.File(base, "save/touch.cfg");
        long stamp = f.exists() ? f.lastModified() : 0;
        if (stamp == touchCfgStamp) return false;
        touchCfgStamp = stamp;
        float scale = 1f;
        int alpha = 140;
        boolean vib = true;
        if (stamp != 0) {
            try (java.io.BufferedReader r = new java.io.BufferedReader(new java.io.FileReader(f))) {
                String line;
                while ((line = r.readLine()) != null) {
                    String[] kv = line.trim().split("=", 2);
                    if (kv.length != 2) continue;
                    int v;
                    try {
                        v = Integer.parseInt(kv[1].trim());
                    } catch (NumberFormatException e) {
                        continue;
                    }
                    String k = kv[0].trim();
                    if (k.equals("size")) scale = clampF(v / 100f, 0.7f, 1.4f);
                    else if (k.equals("seethrough")) alpha = Math.round(clampF(v / 100f, 0.2f, 1f) * 255f);
                    else if (k.equals("vibration")) vib = v != 0;
                }
            } catch (java.io.IOException e) {
                android.util.Log.e("ControllerOverlay", "could not read touch.cfg", e);
            }
        }
        boolean changed = scale != touchScale || alpha != touchAlpha || vib != touchVibrate;
        touchScale = scale;
        touchAlpha = alpha;
        touchVibrate = vib;
        return changed;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        touchCfgHandler.removeCallbacks(touchCfgPoll);
        touchCfgHandler.post(touchCfgPoll);
    }

    @Override
    protected void onDetachedFromWindow() {
        touchCfgHandler.removeCallbacks(touchCfgPoll);
        super.onDetachedFromWindow();
    }

    private android.content.SharedPreferences prefs() {
        return getContext().getSharedPreferences("for_layout", Context.MODE_PRIVATE);
    }

    private void toggleFullScreen() {
        prefs().edit().putBoolean("fullscreen", !prefs().getBoolean("fullscreen", false)).apply();
        laidW = -1;
        arcadeLayout();
        if (arcadeView != null) arcadeView.invalidate();
    }

    private void setEnv(String k, String v) {
        try {
            SDLActivity.nativeSetenv(k, v);
        } catch (Throwable t) {
            android.util.Log.e("ControllerOverlay", "could not pass " + k, t);
        }
    }

    private int[] sideInsetsPx() {
        int l = 0, r = 0, b = 0;
        if (android.os.Build.VERSION.SDK_INT >= 28) {
            android.view.WindowInsets wi = getRootWindowInsets();
            if (wi != null && wi.getDisplayCutout() != null) {
                l = wi.getDisplayCutout().getSafeInsetLeft();
                r = wi.getDisplayCutout().getSafeInsetRight();
                b = wi.getDisplayCutout().getSafeInsetBottom();
            }
        }
        return new int[]{l, r, b};
    }

    // Landscape: picture in the middle, stick on the left, buttons on the right, MENU / START / FULL under the
    // picture. Full screen: the picture as tall as the screen and see-through controls over its lower corners.
    private static float clampF(float v, float lo, float hi) {
        return v < lo ? lo : (v > hi ? hi : v);
    }

    private void landscapeLayout(int w, int h, float dp) {
        int[] si = sideInsetsPx();
        float bottom = h - Math.max(si[2], 8 * dp);
        // half the cut-out inset is enough to keep clear of the camera and the rounded corners
        float leftClear = Math.max(si[0] * 0.5f, 12 * dp), rightClear = Math.max(si[1] * 0.5f, 12 * dp);
        // side-panel sizes: the strips are as wide as the stick and the button block need, the picture gets the rest
        float sideBtnR = clampF(h * 0.066f, 24 * dp, 44 * dp) * touchScale, sideStep = sideBtnR * 2f + 4 * dp;
        float sideStickR = clampF(h * 0.15f, 56 * dp, 96 * dp) * touchScale;
        float stripL = sideStickR * 2f + leftClear + 10 * dp;
        float stripR = sideStep * 3f + sideBtnR * 0.3f + rightClear + 6 * dp;
        float pw = 100 * dp, ph = 40 * dp;
        if (fullScreen) {
            float gh = h, gw = (float) Math.floor(gh * 16.0 / 9.0);
            if (gw > w) { gw = w; gh = (float) Math.floor(gw * 9.0 / 16.0); }
            gameRect.set((w - gw) / 2f, (h - gh) / 2f, (w + gw) / 2f, (h + gh) / 2f);
        } else {
            float band = ph + 12 * dp + Math.max(si[2], 4 * dp);
            float gw = (float) Math.floor(w - stripL - stripR), gh = (float) Math.floor(gw * 9.0 / 16.0);
            if (gh > h - band) { gh = (float) Math.floor(h - band); gw = (float) Math.floor(gh * 16.0 / 9.0); }
            float gx = (float) Math.floor(stripL + (w - stripL - stripR - gw) / 2f);
            gameRect.set(gx, 0, gx + gw, gh);
        }
        setEnv("FOR_VIEW_TOP", "");
        setEnv("FOR_VIEW_RECT", Math.round(gameRect.left) + "," + Math.round(gameRect.top) + "," + Math.round(gameRect.width()) + "," + Math.round(gameRect.height()));
        panelTop = 0; topPad = 0;
        if (fullScreen) {
            // see-through stick and buttons in the lower corners, over the picture
            stickR = clampF(h * 0.20f, 60 * dp, 100 * dp) * touchScale;
            stickX = leftClear + stickR + 6 * dp;
            stickY = bottom - stickR - 14 * dp;
            btnR = clampF(h * 0.075f, 26 * dp, 44 * dp) * touchScale;
            float step = btnR * 2.2f, x0 = w - rightClear - step * 3f + btnR * 0.1f, cy = bottom - btnR * 2.5f;
            for (int i = 0; i < 6; i++) {
                int c = i % 3, r = i / 3;
                btnX[i] = x0 + step * (c + 0.5f) + (r == 1 ? -btnR * 0.3f : 0);
                btnY[i] = cy + (r == 0 ? -btnR * 1.15f : btnR * 1.15f) - c * btnR * 0.22f;
            }
            float barL = gameRect.left, barR = w - gameRect.right;
            if (barL >= 64 * dp && barR >= 64 * dp) {
                // black bars beside the picture: MENU and PANEL in the left one, START in the right one, off the picture
                float bh = 36 * dp, top = 22 * dp;
                float pwL = Math.min(92 * dp, barL - 14 * dp), pwR = Math.min(92 * dp, barR - 14 * dp);
                menuRect.set(barL - pwL - 4 * dp, top, barL - 4 * dp, top + bh);
                viewRect.set(barL - pwL - 4 * dp, top + bh + 10 * dp, barL - 4 * dp, top + bh * 2f + 10 * dp);
                startRect.set(gameRect.right + 4 * dp, top, gameRect.right + 4 * dp + pwR, top + bh);
                return;
            }
            pw = 84 * dp; ph = 34 * dp;
            float py = bottom - ph - 2 * dp, cx = w / 2f, g = 10 * dp;
            menuRect.set(cx - pw * 1.5f - g, py, cx - pw * 0.5f - g, py + ph);
            startRect.set(cx - pw * 0.5f, py, cx + pw * 0.5f, py + ph);
            viewRect.set(cx + pw * 0.5f + g, py, cx + pw * 1.5f + g, py + ph);
            return;
        }
        // side controls: stick centred in the left strip, the button block centred in the right strip
        float leftW = gameRect.left, rightX = gameRect.right;
        stickR = sideStickR;
        stickX = leftClear + (leftW - leftClear) / 2f;
        stickY = Math.min(h * 0.60f, bottom - stickR - 6 * dp);
        btnR = sideBtnR;
        float x0 = rightX + (w - rightClear - rightX - sideStep * 3f - btnR * 0.3f) / 2f + btnR * 0.3f;
        for (int i = 0; i < 6; i++) {
            int c = i % 3, r = i / 3;
            btnX[i] = x0 + sideStep * (c + 0.5f) + (r == 1 ? -btnR * 0.3f : 0);
            btnY[i] = stickY + (r == 0 ? -(btnR + 3 * dp) : (btnR + 3 * dp)) - c * btnR * 0.22f;
        }
        float py = gameRect.bottom + Math.max(6 * dp, (bottom - gameRect.bottom - ph) / 2f);
        float cx = gameRect.centerX(), g = 12 * dp;
        menuRect.set(cx - pw * 1.5f - g, py, cx - pw * 0.5f - g, py + ph);
        startRect.set(cx - pw * 0.5f, py, cx + pw * 0.5f, py + ph);
        viewRect.set(cx + pw * 0.5f + g, py, cx + pw * 1.5f + g, py + ph);
    }

    private int topInsetPx() {
        if (android.os.Build.VERSION.SDK_INT >= 28) {
            android.view.WindowInsets wi = getRootWindowInsets();
            if (wi != null && wi.getDisplayCutout() != null) {
                return wi.getDisplayCutout().getSafeInsetTop();
            }
        }
        return 0;
    }

    private void arcadeLayout() {
        int w = getWidth(), h = getHeight();
        int inset = topInsetPx();
        boolean full = prefs().getBoolean("fullscreen", false);
        if (w <= 0 || h <= 0 || (w == laidW && h == laidH && inset == laidInset && full == laidFull)) {
            return;
        }
        laidW = w; laidH = h; laidInset = inset; laidFull = full;
        float dp = getContext().getResources().getDisplayMetrics().density;
        landscape = w > h * 1.15f;
        fullScreen = landscape && full;
        if (landscape) {
            landscapeLayout(w, h, dp);
            return;
        }
        viewRect.setEmpty();
        setEnv("FOR_VIEW_RECT", "");
        float picture = (float) Math.floor(w * 9.0 / 16.0);
        float top = inset;
        if (top + picture > h * 0.7f) {
            top = 0;
        }
        try {
            SDLActivity.nativeSetenv("FOR_VIEW_TOP", Integer.toString(Math.round(top)));
        } catch (Throwable t) {
            android.util.Log.e("ControllerOverlay", "could not pass FOR_VIEW_TOP", t);
        }
        panelTop = top + picture;
        // A big, squarer screen is a fold-open phone or a tablet: keep the panel in the lower half, clear of the fold
        if (w >= 600 * dp && panelTop < h * 0.5f + 20 * dp) {
            panelTop = h * 0.5f + 20 * dp;
        }
        topPad = 56 * dp;
        float bottom = h - 14 * dp;
        float usable = Math.max(bottom - (panelTop + topPad), 60 * dp);
        boolean tall = usable > w * 0.9f;
        float cy = panelTop + topPad + usable * (tall ? 0.46f : 0.52f);
        stickR = Math.min(w * 0.19f, usable * (tall ? 0.22f : 0.40f)) * touchScale;
        stickX = Math.max(w * 0.215f, stickR + 8 * dp);
        stickY = cy;
        float col = (w * 0.57f) / 3f;
        btnR = Math.min(col * 0.46f, usable * (tall ? 0.13f : 0.22f)) * touchScale;
        float x0 = w * 0.42f, gap = btnR * 1.16f;
        for (int i = 0; i < 6; i++) {
            int c = i % 3, r = i / 3;
            btnX[i] = x0 + col * (c + 0.5f);
            btnY[i] = cy + (r == 0 ? -gap : gap) - c * btnR * 0.22f;
        }
        float ppw = 92 * dp, pph = 36 * dp, ppy = panelTop + (topPad - pph) / 2f;
        startRect.set(w - 12 * dp - ppw, ppy, w - 12 * dp, ppy + pph);
        menuRect.set(w - 20 * dp - ppw * 2f, ppy, w - 20 * dp - ppw, ppy + pph);
    }

    private void arcadeSend(int code, boolean pressed) {
        if (code >= 4000) {
            SDLControllerManager.onNativeJoy(virtualDeviceId, code - 4000, pressed ? 1.0f : 0.0f);
        } else if (pressed) {
            SDLControllerManager.onNativePadDown(virtualDeviceId, code);
        } else {
            SDLControllerManager.onNativePadUp(virtualDeviceId, code);
        }
    }

    private boolean arcadeTouch(MotionEvent event) {
        arcadeLayout();
        float dp = getContext().getResources().getDisplayMetrics().density;
        float slop = 10 * dp;
        int action = event.getActionMasked();
        int index = event.getActionIndex();

        if (action == MotionEvent.ACTION_DOWN || action == MotionEvent.ACTION_POINTER_DOWN) {
            float x = event.getX(index), y = event.getY(index);
            // A finger that lands on the stick side takes the stick, and keeps it wherever it slides
            float sl = 10 * dp;
            boolean onPill = startRect.contains(x, y) || menuRect.contains(x, y) ||
                    (!viewRect.isEmpty() && x >= viewRect.left - sl && x <= viewRect.right + sl && y >= viewRect.top - sl && y <= viewRect.bottom + sl);
            boolean stickSide = landscape ? (x < getWidth() * 0.40f && !onPill) : (x < getWidth() * 0.41f && y > panelTop + topPad);
            if (stickPointer == -1 && stickSide) {
                stickPointer = event.getPointerId(index);
            }
        }
        boolean ending = (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_CANCEL);
        int lifted = (action == MotionEvent.ACTION_POINTER_UP) ? index : -1;

        int hx = 0, hy = 0, mask = 0;
        boolean stickAlive = false;
        if (!ending) {
            for (int i = 0; i < event.getPointerCount(); i++) {
                if (i == lifted) continue;
                float x = event.getX(i), y = event.getY(i);
                if (event.getPointerId(i) == stickPointer) {
                    stickAlive = true;
                    float dx = x - stickX, dy = y - stickY;
                    float dist = (float) Math.sqrt(dx * dx + dy * dy);
                    if (dist > stickR * 0.24f) {
                        // eight ways: a component counts once it is more than sin(22.5 degrees) of the pull
                        if (dx < -dist * 0.383f) hx = -1;
                        if (dx > dist * 0.383f) hx = 1;
                        if (dy < -dist * 0.383f) hy = -1;
                        if (dy > dist * 0.383f) hy = 1;
                    }
                    continue;
                }
                for (int b = 0; b < 6; b++) {
                    float dx = x - btnX[b], dy = y - btnY[b], reach = btnR + slop;
                    if (dx * dx + dy * dy <= reach * reach) mask |= (1 << b);
                }
                if (x >= startRect.left - slop && x <= startRect.right + slop && y >= startRect.top - slop && y <= startRect.bottom + slop) mask |= (1 << 6);
                if (x >= menuRect.left - slop && x <= menuRect.right + slop && y >= menuRect.top - slop && y <= menuRect.bottom + slop) mask |= (1 << 7);
                if (!viewRect.isEmpty() && x >= viewRect.left - slop && x <= viewRect.right + slop && y >= viewRect.top - slop && y <= viewRect.bottom + slop) mask |= (1 << 8);
            }
        }
        if (!stickAlive) {
            stickPointer = -1;
        }

        if (hx != hatX || hy != hatY) {
            hatX = hx;
            hatY = hy;
            SDLControllerManager.onNativeHat(virtualDeviceId, 0, hatX, hatY);
        }
        int diff = mask ^ arcadeMask;
        if ((diff & (1 << 8)) != 0 && (mask & (1 << 8)) == 0) {
            post(this::toggleFullScreen);   // FULL / PANEL released: switch layouts (not a game button)
        }
        if (diff != 0) {
            boolean anyDown = false;
            for (int i = 0; i < 8; i++) {
                if ((diff & (1 << i)) != 0) {
                    boolean down = (mask & (1 << i)) != 0;
                    arcadeSend(ARCADE_CODES[i], down);
                    anyDown = anyDown || down;
                }
            }
            arcadeMask = mask;
            if (anyDown && touchVibrate) {
                performHapticFeedback(android.view.HapticFeedbackConstants.VIRTUAL_KEY);
            }
        }
        if (arcadeView != null) {
            arcadeView.invalidate();
        }
        return true;
    }

    private class ArcadeView extends View {
        private final android.graphics.Paint paint = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
        private final android.graphics.Paint bmpPaint = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG | android.graphics.Paint.FILTER_BITMAP_FLAG);
        private final android.graphics.RectF dst = new android.graphics.RectF();
        private final android.graphics.Rect srcR = new android.graphics.Rect();
        private final java.util.HashMap<String, android.graphics.Bitmap> art = new java.util.HashMap<>();

        // Painted panel art (res/drawable-nodpi/for_*). Missing art falls back to the drawn shapes.
        private android.graphics.Bitmap art(String name) {
            if (!art.containsKey(name)) {
                android.graphics.Bitmap b = null;
                try {
                    int id = getResources().getIdentifier(name, "drawable", getContext().getPackageName());
                    if (id != 0) b = android.graphics.BitmapFactory.decodeResource(getResources(), id);
                } catch (Throwable t) { b = null; }
                art.put(name, b);
            }
            return art.get(name);
        }

        private boolean drawArt(android.graphics.Canvas c, String name, float cx, float cy, float r) {
            android.graphics.Bitmap b = art(name);
            if (b == null) return false;
            dst.set(cx - r, cy - r, cx + r, cy + r);
            c.drawBitmap(b, null, dst, bmpPaint);
            return true;
        }

        private final android.graphics.Path slash = new android.graphics.Path();

        ArcadeView(Context context) {
            super(context);
            setClickable(false);
            setFocusable(false);
        }

        @Override
        protected void onSizeChanged(int w, int h, int oldw, int oldh) {
            super.onSizeChanged(w, h, oldw, oldh);
            arcadeLayout();
        }

        @Override
        protected void onAttachedToWindow() {
            super.onAttachedToWindow();
            post(ControllerOverlay.this::arcadeLayout);
        }

        @Override
        protected void onDraw(android.graphics.Canvas c) {
            arcadeLayout();
            int w = getWidth(), h = getHeight();
            if (w <= 0 || h <= 0) return;
            float dp = getContext().getResources().getDisplayMetrics().density;

            int ctlLayer = -1;
            if (landscape) {
                android.graphics.Bitmap lb = art("for_panel");
                if (!fullScreen) {
                    c.save();
                    if (android.os.Build.VERSION.SDK_INT >= 26) {
                        c.clipOutRect(gameRect);
                    } else {
                        c.clipRect(gameRect, android.graphics.Region.Op.DIFFERENCE);
                    }
                    if (lb != null) {
                        float sc = Math.max(w / (float) lb.getWidth(), h / (float) lb.getHeight());
                        int sw = Math.round(w / sc), sh = Math.round(h / sc);
                        int sx0 = (lb.getWidth() - sw) / 2, sy0 = (lb.getHeight() - sh) / 2;
                        srcR.set(sx0, sy0, sx0 + sw, sy0 + sh);
                        dst.set(0, 0, w, h);
                        c.drawBitmap(lb, srcR, dst, bmpPaint);
                    } else {
                        paint.setStyle(android.graphics.Paint.Style.FILL);
                        paint.setColor(0xFF211F26);
                        c.drawRect(0, 0, w, h, paint);
                    }
                    paint.setStyle(android.graphics.Paint.Style.STROKE);
                    paint.setStrokeWidth(6 * dp);
                    paint.setColor(0x8C000000);
                    c.drawRect(gameRect.left - 3 * dp, gameRect.top - 3 * dp, gameRect.right + 3 * dp, gameRect.bottom + 3 * dp, paint);
                    c.restore();
                } else {
                    ctlLayer = c.saveLayerAlpha(0, 0, w, h, touchAlpha);
                }
            } else {
            // Panel: dark metal with a slash of orange (everything above panelTop is left clear for the game)
            android.graphics.Bitmap pb = art("for_panel");
            if (pb != null) {
                float ph = h - panelTop;
                float sc = Math.max(w / (float) pb.getWidth(), ph / (float) pb.getHeight());
                int sw = Math.round(w / sc), sh = Math.round(ph / sc);
                int sx0 = (pb.getWidth() - sw) / 2, sy0 = (pb.getHeight() - sh) / 2;
                srcR.set(sx0, sy0, sx0 + sw, sy0 + sh);
                dst.set(0, panelTop, w, h);
                c.drawBitmap(pb, srcR, dst, bmpPaint);
            } else {
                paint.setStyle(android.graphics.Paint.Style.FILL);
                paint.setColor(0xFF211F26);
                c.drawRect(0, panelTop, w, h, paint);
                paint.setColor(0xFF29262F);
                paint.setStrokeWidth(1f);
                for (float x = 0; x < w; x += 4 * dp) {
                    c.drawLine(x, panelTop, x, h, paint);
                }
                slash.reset();
                slash.moveTo(0, panelTop);
                slash.lineTo(w * 0.52f, panelTop);
                slash.lineTo(w * 0.36f, panelTop + topPad);
                slash.lineTo(0, panelTop + topPad);
                slash.close();
                paint.setColor(0xFFC74A14);
                c.drawPath(slash, paint);
            }
            }

            // Stick: base plate, then the ball pushed toward where it is held
            paint.setStyle(android.graphics.Paint.Style.FILL);
            if (!drawArt(c, "for_stick_base", stickX, stickY, stickR)) {
                paint.setColor(0xFF0D0D0D);
                c.drawCircle(stickX, stickY, stickR, paint);
                paint.setStyle(android.graphics.Paint.Style.STROKE);
                paint.setStrokeWidth(3 * dp);
                paint.setColor(0xFF525252);
                c.drawCircle(stickX, stickY, stickR - 1.5f * dp, paint);
                paint.setStyle(android.graphics.Paint.Style.FILL);
            }
            float dx = hatX, dy = hatY;
            float len = (float) Math.sqrt(dx * dx + dy * dy);
            if (len > 0) {
                dx = dx / len * stickR * 0.36f;
                dy = dy / len * stickR * 0.36f;
            }
            float ball = stickR * 0.56f;
            if (!drawArt(c, "for_stick_ball", stickX + dx, stickY + dy, ball)) {
                paint.setColor(0xFFCC1F1F);
                c.drawCircle(stickX + dx, stickY + dy, ball, paint);
                paint.setColor(0xE6FF8C80);
                c.drawOval(stickX + dx - ball * 0.58f, stickY + dy - ball * 0.72f, stickX + dx - ball * 0.08f, stickY + dy - ball * 0.36f, paint);
            }

            // Buttons
            paint.setTextAlign(android.graphics.Paint.Align.CENTER);
            paint.setFakeBoldText(true);
            for (int i = 0; i < 6; i++) {
                boolean down = (arcadeMask & (1 << i)) != 0;
                boolean kick = i >= 3;
                float r = down ? btnR * 0.94f : btnR;
                paint.setStyle(android.graphics.Paint.Style.FILL);
                if (!drawArt(c, (kick ? "for_btn_kick" : "for_btn_punch") + (down ? "_on" : ""), btnX[i], btnY[i], r + 3 * dp)) {
                    paint.setColor(0xFF0A0A0A);
                    c.drawCircle(btnX[i], btnY[i], r + 4 * dp, paint);
                    paint.setColor(kick ? (down ? 0xFF8CBFFF : 0xFF336EEB) : (down ? 0xFFFFCC73 : 0xFFF0821F));
                    c.drawCircle(btnX[i], btnY[i], r, paint);
                    paint.setStyle(android.graphics.Paint.Style.STROKE);
                    paint.setStrokeWidth(2 * dp);
                    paint.setColor(0xD9FFFFFF);
                    c.drawCircle(btnX[i], btnY[i], r - dp, paint);
                    paint.setStyle(android.graphics.Paint.Style.FILL);
                }
                paint.setShadowLayer(2 * dp, 0, 0, 0xE6000000);
                paint.setColor(0xFFFFFFFF);
                paint.setTextSize(Math.max(11 * dp, btnR * 0.62f));
                c.drawText(ARCADE_NAMES[i], btnX[i], btnY[i] - (paint.descent() + paint.ascent()) / 2f, paint);
                paint.clearShadowLayer();
            }

            // START and MENU
            drawPill(c, startRect, "START", (arcadeMask & (1 << 6)) != 0, dp);
            drawPill(c, menuRect, "MENU", (arcadeMask & (1 << 7)) != 0, dp);
            if (!viewRect.isEmpty()) {
                drawPill(c, viewRect, fullScreen ? "PANEL" : "FULL", (arcadeMask & (1 << 8)) != 0, dp);
            }
            if (ctlLayer >= 0) {
                c.restoreToCount(ctlLayer);
            }
        }

        private void drawPill(android.graphics.Canvas c, android.graphics.RectF r, String title, boolean down, float dp) {
            paint.setStyle(android.graphics.Paint.Style.FILL);
            paint.setColor(down ? 0xFFFFFFFF : 0xFFDBDBDB);
            c.drawRoundRect(r, r.height() / 2f, r.height() / 2f, paint);
            paint.setColor(0xFF1A1A1A);
            paint.setTextSize(Math.max(12 * dp, r.height() * 0.40f));
            c.drawText(title, r.centerX(), r.centerY() - (paint.descent() + paint.ascent()) / 2f, paint);
        }
    }

    private void disableAllTouches(View v) {
        v.setClickable(false);
        v.setFocusable(false);
        if (v instanceof ViewGroup) {
            ViewGroup vg = (ViewGroup) v;
            for (int i = 0; i < vg.getChildCount(); i++) {
                disableAllTouches(vg.getChildAt(i));
            }
        }
    }

    public void initializeVirtualController() {
        android.util.Log.i("ControllerOverlay", "DEBUG: initializing virtual joystick...");
        virtualDeviceId = getPhysicalJoystickCount();
        pointerStates.clear();
        hatX = 0;
        hatY = 0;
        android.util.Log.i("ControllerOverlay", String.format("DEBUG: virtualDeviceID = %d", virtualDeviceId));
        SDLControllerManager.nativeRemoveJoystick(virtualDeviceId);
        ensureJoystickAlive();
        // Initialize the joysticks
        JoystickOverlay ls = findViewById(R.id.left_analog);
        ls.setAttrs(virtualDeviceId, 0, 1);

        JoystickOverlay rs = findViewById(R.id.right_analog);
        rs.setAttrs(virtualDeviceId, 2, 3);

        for (int i = 0; i < 6; i++) {
            SDLControllerManager.onNativeJoy(virtualDeviceId, i, 0.00390625f);
            SDLControllerManager.onNativeJoy(virtualDeviceId, i, 0.0f);
        }
        SDLControllerManager.onNativeHat(virtualDeviceId, 0, 0, 0);
        android.util.Log.i("ControllerOverlay", "DEBUG: virtual joystick initialized!");
        isInitialized = true;
    }

    private int ensureJoystickAlive() {
        return SDLControllerManager.nativeAddJoystick(virtualDeviceId, "Xbox 360 Controller", "Gamepad", 0x045E, 0x028E, false, 0xFFF, 6, 0x3F, 1, 0);
    }
}
