# 运维过程中找不到win7-32位的支持版本，于是创建此仓库留档运维使用。其余全为AI创建


Sysmon 13.34 for Windows 7 (32-bit + notes)
================================================

内容
----
Sysmon.exe      32 位（x86）主程序，版本 13.34，微软原厂数字签名
sysmonconfig-win7.xml   适用于 Win7 的基础配置（schema 4.81）
安装.bat → install.bat / 卸载.bat → uninstall.bat   安装与卸载脚本（右键“以管理员身份运行”）
（文件名统一用英文，避免跨机器拷贝时中文名编码出问题；内容全是中文说明。）

为什么是这个版本
----------------
微软从 v14.0 起把最低系统要求提到 Windows 8.1，最新 v15.22 已要求 Win11；
官方最后一条支持 Windows 7 的主线是 13.x，13.34 是 13.x 的最终版本。
安全厂商（如 Nozomi）给 Win7 / Server 2008 R2 下发的 “Sysmon Legacy” 就是 13.34。
包里仍然带 32 位 Sysmon.exe，所以 Win7 x86 可用。

校验值（与 web.archive.org 上 live.sysinternals.com 的历史文件一致）
--------------------------------------------------------------------
文件        Sysmon.exe
版本        13.34
SHA1        9039e2b4fa6296a1e818afc006cc119850a43fe6
SHA256      19d93882aa93efe443bc184e3c350e5cb4118e2ef6f3f3efb535e08880184919
签名        Microsoft Corporation，Authenticode 状态 Valid（带时间戳）

在部署机上核对（可选）
    certutil -hashfile Sysmon.exe SHA1
    powershell -c "(Get-AuthenticodeSignature .\Sysmon.exe).Status"

前置条件（很重要）
------------------
1. 必须是 Windows 7 SP1。
2. 必须已安装 SHA-2 代码签名支持补丁：KB4474419、KB4490628。
   没装的表现：安装时驱动加载失败 ——
       SysmonDrv installed
       Start Service failed for SysmonDrv
       Failed to start the driver
3. 32 位系统只用 Sysmon.exe，不要用 Sysmon64.exe。

安装
----
把整个文件夹拷到目标机器，右键“安装.bat”→“以管理员身份运行”。
脚本等价于（在文件夹内以管理员身份执行）：

    Sysmon.exe -accepteula -i sysmonconfig-win7.xml

安装不需要重启。装完可在
    事件查看器 → 应用程序和服务日志 → Microsoft → Windows → Sysmon → Operational
看到事件。

检查 / 改配置 / 卸载
--------------------
    Sysmon.exe -c                      查看当前生效配置
    Sysmon.exe -c sysmonconfig-win7.xml  改配置（不用重装）
    Sysmon.exe -u force                卸载

Win7 上采不到的事件
-------------------
事件 22（DNS 查询）：遥测依赖 Win8.1 才有的接口，Win7 上没有。
事件 24（剪贴板）：Win8 起才有。
事件 25（进程篡改）：Win8.1+ 才有完整支持。
因此配置里没有放这几个标签，规则设计时不要依赖它们。

安全提示
--------
1. CVE-2022-44704（Sysmon 本地提权）在 14.13 才修复，13.x 全系带此问题。
   Win7 本身已停止支持，这套组合只适合“能用就行”的采集场景，
   不要放在高价值或可被低权限用户交互的机器上当作安全边界。
2. 13.34 之后不会再有官方更新；如需更安全，只能在 Win8.1+ 上用 14.16 以上版本。

配置调优
--------
sysmonconfig-win7.xml 是保守基线：
  记录 进程创建、网络连接、驱动加载、远程线程、raw disk 读取、lsass 访问、
        关键目录文件落地、Run/Services 等自启动注册表项、命名管道、WMI 持久化；
  关闭 进程结束、映像加载、文件创建时间修改、全量文件创建（避免刷爆日志）。
Win7 机器多或日志量大时，重点收紧 NetworkConnect 和 PipeEvent 的排除规则。
