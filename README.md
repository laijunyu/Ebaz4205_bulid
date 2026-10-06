# EBAZ4205 Buildroot Linux

这是一个面向 EBAZ4205（Zynq-7000）的 Buildroot 外部树构建交付包。

## 基线与构建结论

上游社区工程 `embed-me/ebaz4205_buildroot` 的 README 明确要求 Buildroot `2020.11.x`，其 defconfig 当前使用 Linux 4.19、Dropbear，并已有 `eth0` DHCP 的 overlay。这里保持该兼容基线，并将 `BR2_SYSTEM_DHCP="eth0"` 显式写入 defconfig，使 DHCP 配置不仅存在于 overlay，也在 Buildroot 配置中可见。

推荐使用 Buildroot 2020.11.4 作为 `2020.11.x` 系列的最后一个 bugfix 版本；该系列已经 EOL，但与社区 EBAZ4205 BSP 的版本约束保持一致。

## 文件

- `configs/zynq_ebaz4205_defconfig`：可复现 Buildroot 配置。
- `ebaz4205/fs-overlay/etc/network/interfaces`：`eth0` DHCP 配置。
- `.github/workflows/build-ebaz4205.yml`：Ubuntu 22.04 GitHub Actions 自动构建。
- `build.sh`：本地构建脚本。

## 构建

### 本地

```bash
chmod +x build.sh
./build.sh
```

构建产物位于：

```text
buildroot-2020.11.4/output/images/
```

### GitHub Actions

推送到 GitHub 后，Actions workflow `build-ebaz4205` 会：

1. 使用 Ubuntu 22.04。
2. 安装 Buildroot 主机构建依赖。
3. 下载 Buildroot 2020.11.4。
4. 应用 `zynq_ebaz4205_defconfig`。
5. 执行并行构建。
6. 将 `output/images/` 上传为 artifact。

## 软件侧配置

### DHCP

Buildroot 配置：

```text
BR2_SYSTEM_DHCP="eth0"
```

overlay 同时保留：

```text
auto eth0
iface eth0 inet dhcp
```

### SSH

使用 Dropbear。社区 defconfig 已启用：

```text
BR2_PACKAGE_DROPBEAR=y
```

root 密码为：

```text
root
```

SSH 服务的实际启动、端口监听以及 DHCP 获取地址均必须由用户在真实 EBAZ4205 板上验证。

## SD 卡文件

社区工程 README 指定 FAT 格式、带 boot flag 的 SD 卡启动分区需要这些文件：

```text
boot.bin
u-boot.bin
u-boot.img
uEnv.txt
uImage
ebaz4205-zynq7.dtb
rootfs.cpio.uboot
ebaz4205_top.bin
```

其中 `ebaz4205_top.bin` 不是 Buildroot 本身生成的文件，而应来自对应 Vivado FPGA 工程的 bitstream 导出结果；不要把缺少该 PL bitstream 的 Buildroot 构建宣称为完整的 EBAZ4205 硬件启动镜像。

将 Buildroot `output/images/` 中生成的文件，以及对应 Vivado 工程生成的 `ebaz4205_top.bin`，复制到 FAT32 启动分区根目录即可。不要直接依赖“文件存在”来判断硬件已经能启动，真实验证仍由用户完成。

## 硬件前提（必须由用户确认）

PL 设计必须满足项目既定约束，包括：

1. PS ENET0 经 EMIO 引出，并使用 GMII-to-MII 转换逻辑。
2. FCLK3 输出 25 MHz 给 PHY。
3. R2548、R2577 已按用户现有硬件修改，启动模式设为 SD 卡。
4. SD 卡存在 FAT32 启动分区，并放入上述启动文件。
5. 串口参数：115200，8N1。

本项目的软件构建不会、也不能证明这些硬件前提已经成立。

## 用户硬件验证步骤

以下步骤仅供用户上板后执行：

1. 将启动文件复制到 FAT32 分区根目录。
2. 插入 SD 卡并上电。
3. 串口使用 `115200 8N1`，登录：

```text
root
```

默认密码：

```text
root
```

4. 检查网卡：

```bash
ip addr show eth0
```

5. 测试网络：

```bash
ping -c 3 192.168.1.1
```

6. 使用获得的地址测试 SSH：

```bash
ssh root@<板子IP>
```

## 可选 XVC

本交付包默认不内置 XVC server，以避免在没有目标运行环境和真实硬件的情况下把第三方 `xvcserver` 交叉编译结果误标为已验证功能。

后续可以增加一个 Buildroot package 或自定义 rootfs 程序，例如安装：

```text
/usr/bin/xvcserver
```

并创建开机服务，使其监听 TCP `2542`。Vivado Hardware Manager 的实际连通性、调试核发现以及 JTAG/XVC 工作状态必须由用户在真实硬件上验证。

## 不能由本软件构建自动证明的事项

本项目不宣称以下事项已验证：

- SD 卡能否在目标 EBAZ4205 上成功启动。
- 串口是否能进入 Linux。
- `eth0` 是否实际获得 DHCP 地址。
- SSH 是否可以从网络侧登录。
- PHY、FCLK3、EMIO、GMII-to-MII 是否实际工作。
- Vivado 是否可以通过 XVC 连接板卡。

## 来源

社区基线：

https://github.com/embed-me/ebaz4205_buildroot

该社区工程 README 明确列出 Buildroot `2020.11.x` 依赖、EBAZ4205 启动文件以及默认 `root/root` 与 Dropbear SSH 配置。
