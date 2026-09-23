# vivo 微信截图试验模块

从 LuckyTool 的 `DisableFlagSecure` 功能拆出的 **微信单应用试验版**。原项目面向 ColorOS，在 vivo X200 Ultra / Android 15 上调用 `com.oplus.os.OplusBuild` 会崩溃。本项目不调用任何 Oplus 类，也不加载原项目的其他功能。

仅在 LSPosed 的 `com.tencent.mm` 作用域内拦截微信设置窗口 `FLAG_SECURE` 的几条常见路径。不会修改微信安装包或账号；也不会注入 `android`、系统界面、截图服务。**未在真机验证**；若限制来自 OriginOS 的其他策略或不经这些窗口方法设置的安全层，仍可能不能截图。

## 构建

JDK 17+、Android SDK 35。运行 `./gradlew :app:assembleDebug`，APK 位于 `app/build/outputs/apk/debug/`。也可把此完整目录上传 GitHub，执行 Actions 的 `Build APK` 工作流下载 APK。

### Windows 一键上传到你的仓库

1. 将整个 ZIP 解压到文件夹，安装 [Git for Windows](https://git-scm.com/download/win)。
2. 双击根目录的 **`一键上传到GitHub.cmd`**，按 Git 的提示通过浏览器登录 GitHub。脚本的目标仓库固定为 `https://github.com/3030606794/LuckyTool.git`，不会强制推送。
3. 上传完成后打开 GitHub 的 **Actions → Build APK**。如工作流没有自动开始，点击 **Run workflow**。编译成功后在该运行记录的 **Artifacts** 下载 APK。

脚本每次会先克隆现有仓库，再把这份源码同步进去，因此解压新版 ZIP 到新文件夹后也能正常更新；没有变更时不会新建提交。若推送时远端发生新的变更，Git 会拒绝覆盖。不要把 GitHub 密码或令牌写入脚本。

## 使用

1. 在 LSPosed 中开启模块，作用域**只选微信**（`com.tencent.mm`）。不要选“系统框架”。
2. 重启微信进程；如仍不生效，重启手机。
3. 在主微信普通聊天列表用系统组合键截图。如果有截图，再检查 Jev 的本地 OCR。
4. 若截图仍提示“由于‘微信’等多个应用限制”，记录 LSPosed 日志中的 `VivoScreenshot` 和截图提示；说明当前拦截路径不足以判断具体限制来源。

停用时在 LSPosed 中关闭模块并重启微信。此版仅供排查；微信更新可能改变内部行为。

本项目保留原 LuckyTool 的 GPL-3.0 授权，见 `LICENSE.txt`。原项目作者与仓库信息见 `UPSTREAM.md`。
