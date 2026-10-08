# RA4M2 MINI_IOT 开发环境

面向 Windows 10/11 x64。按下面步骤安装后，可导入仓库内的 Blinky 入门工程并编译；安装电脑不需要连接开发板。

## 最快安装

1. 下载本仓库 ZIP 并解压到本地文件夹。
2. 下载两个瑞萨官方 Windows 安装程序，保存到解压目录的 `安装文件` 文件夹（仓库已保留该文件夹）：
   - [e² studio 2025-12、FSP 6.4.0 与 Arm GNU 13.2 安装器（约 2.07 GB）](https://github.com/renesas/fsp/releases/download/v6.4.0/setup_fsp_v6_4_0_e2s_v2025-12.exe)
   - [FSP 5.9.0 安装包（约 171 MB）](https://github.com/renesas/fsp/releases/download/v5.9.0/FSP_Packs_v5.9.0.exe)
3. 在解压目录打开 PowerShell，运行文件校验：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\检查环境.ps1
   ```

   两个文件都显示 `[通过]` 后再安装。脚本会核对 SHA-256 和瑞萨数字签名。
4. 双击 `安装文件\setup_fsp_v6_4_0_e2s_v2025-12.exe`，选择 **Current user → Quick Install**。安装位置由你选择并记下；按需安装调试驱动。首次启动 e² studio 并选择 workspace 后关闭 IDE。
5. 双击 `安装文件\FSP_Packs_v5.9.0.exe`，安装位置选择上一步记下的同一个 e² studio 根目录，然后重新打开 IDE。
6. 导入 `入门工程\RA4M2_MINI_IOT_Blinky`，打开 `configuration.xml` 并点击 **Generate Project Content**，再执行 **Project → Build Project**。

教程全文、详细安装界面说明、检查命令和硬件连接注意事项见 [`教程.docx`](教程.docx)。本示例固定使用 FSP 5.9.0 与 Arm GNU 13.2；不要把示例工程改为 FSP 6.4.0。

> 安装包由瑞萨官方发布并由使用者直接下载；安装时请阅读并接受对应许可。若下载到其他目录，请将两个文件复制到仓库的 `安装文件` 文件夹后再运行校验脚本。
