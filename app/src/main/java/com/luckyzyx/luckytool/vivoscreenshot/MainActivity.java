package com.luckyzyx.luckytool.vivoscreenshot;

import android.app.Activity;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.TextView;

public final class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(48, 64, 48, 48);
        TextView title = new TextView(this);
        title.setText("微信截图试验模块");
        title.setTextSize(23);
        title.setGravity(Gravity.CENTER_HORIZONTAL);
        layout.addView(title);
        TextView instructions = new TextView(this);
        instructions.setText("1. 在 LSPosed 中启用此模块，作用域只选微信（com.tencent.mm）。\n\n"
                + "2. 重启微信进程；必要时重启手机。\n\n"
                + "3. 在主微信普通聊天列表测试系统按键截图。\n\n"
                + "本模块只处理微信窗口的 FLAG_SECURE。如果限制由 vivo 系统策略或其他窗口产生，截图仍可能失败。"
                + "关闭方法：在 LSPosed 中停用模块，再重启微信。");
        instructions.setTextSize(16);
        instructions.setPadding(0, 40, 0, 0);
        layout.addView(instructions);
        setContentView(layout);
    }
}
