package com.luckyzyx.luckytool.vivoscreenshot;

import android.view.Window;
import android.view.WindowManager;

import de.robv.android.xposed.IXposedHookLoadPackage;
import de.robv.android.xposed.XC_MethodHook;
import de.robv.android.xposed.XposedBridge;
import de.robv.android.xposed.callbacks.XC_LoadPackage;

/**
 * A small, WeChat-scoped adaptation of LuckyTool's DisableFlagSecure feature.
 * It does not touch system_server, SurfaceFlinger, screenshot services, or other apps.
 */
public final class WeChatSecureHook implements IXposedHookLoadPackage {
    private static final int SECURE = WindowManager.LayoutParams.FLAG_SECURE;

    @Override
    public void handleLoadPackage(XC_LoadPackage.LoadPackageParam packageInfo) {
        if (!"com.tencent.mm".equals(packageInfo.packageName)) return;

        XC_MethodHook clearWindowFlags = new XC_MethodHook() {
            @Override
            protected void beforeHookedMethod(MethodHookParam param) {
                int flags = (Integer) param.args[0];
                int mask = (Integer) param.args[1];
                if ((flags & SECURE) != 0) {
                    param.args[0] = flags & ~SECURE;
                    // Keep SECURE in the mask so an already-set bit is cleared.
                    param.args[1] = mask | SECURE;
                }
            }
        };

        XC_MethodHook clearAttributes = new XC_MethodHook() {
            @Override
            protected void beforeHookedMethod(MethodHookParam param) {
                for (Object arg : param.args) {
                    if (arg instanceof WindowManager.LayoutParams) {
                        WindowManager.LayoutParams attrs = (WindowManager.LayoutParams) arg;
                        attrs.flags &= ~SECURE;
                    }
                }
            }
        };

        try {
            XposedBridge.hookAllMethods(Window.class, "setFlags", clearWindowFlags);
            XposedBridge.hookAllMethods(Window.class, "setAttributes", clearAttributes);
            Class<?> global = Class.forName("android.view.WindowManagerGlobal", false, packageInfo.classLoader);
            XposedBridge.hookAllMethods(global, "addView", clearAttributes);
            XposedBridge.hookAllMethods(global, "updateViewLayout", clearAttributes);
            XposedBridge.log("VivoScreenshot: WeChat window hooks installed in " + packageInfo.processName);
        } catch (Throwable error) {
            XposedBridge.log("VivoScreenshot: WeChat hook failed: " + error);
        }
    }
}
