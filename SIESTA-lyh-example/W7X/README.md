# W7-X EIM 平衡算例

四组示例均用本仓库的 SIESTA-lyh Release 构建运行，使用同一份公开线圈文件。表中 β 是输入 VMEC 平衡的体积平均局域量 $\langle 2\mu_0p/B^2\rangle_V$。约 5% 组的归档 WOUT 另报 VMEC `betatotal=4.9664\%`。固定和自由边界指 SIESTA 的计算模式。

| 算例 | 输入 VMEC β | SIESTA 径向点 | 实际步数 | 最终 $F^2$ | 停止原因 |
| --- | ---: | ---: | ---: | ---: | --- |
| [0.8% 固定边界](beta008-fixed/README.md) | 0.79999% | 49 | 100 | `2.140343e-11` | `iteration_limit` |
| [0.8% 自由边界](beta008-free/README.md) | 0.79999% | 230+33 | 100 | `2.066690e-07` | `iteration_limit` |
| [约 5% 固定边界](beta5-fixed/README.md) | 5.12730% | 99 | 100 | `8.462638e-10` | `iteration_limit` |
| [约 5% 自由边界](beta5-free/README.md) | 5.12730% | 230+33 | 100 | `4.177912e-06` | `iteration_limit` |

## 输入数据来源

- **0.8%**。使用 EIM 线圈和 $p(s)=38.8824\ \mathrm{kPa}\,(1-s)$ 生成的 VMEC 平衡，$s$ 为归一化环向磁通。自由边界 VMEC 计算给出 LCFS，固定边界 VMEC 计算沿用该 LCFS。随附两次计算实际使用的 VMEC 输入和 WOUT。
- **约 5%**。两组逐字节使用历史 W7-X EIM 示例归档的 `wout_EIM_5_c_para.nc`，其 VMEC 版本为 8.52，`ier_flag=0`。SHA-256 为 `63ca2b3fd80bb8bcfa21b2bc024d324cd66331de281dfa19a5ff8d9591f5c09e`。固定边界 SIESTA 固定这份自由边界 VMEC WOUT 的 LCFS。自由边界 SIESTA 的外场由随附线圈重新生成的 BMW 网格提供。`input.eim_demo_repro` 是依据归档 WOUT 重建的 VMEC 输入，使用已核验的 BMW 网格复算该 EIM 配置。其生成文件名为 `wout_eim_demo_repro.nc`。SIESTA 示例使用随附的归档 WOUT。历史来源为 HINT-docs 提交 `6462b9e8e05e7a443d337b6d419aa6e2d12bde34` 的 W7-X EIM 归档。[本仓库逐字节副本](beta5-fixed/wout_EIM_5_c_para.nc)
- **线圈与计算壁**。`coils.w7x` 保留上游文件字节与 MIT 许可。自由边界两组使用同一个外扩计算壁系数文件 `vessel_w7x_eim.dat`，它由 EIM LCFS 外偏移并作 Fourier 表示。物理真空室几何用于核查包络，实际计算域由 SIESTA 的网格映射确定。[上游线圈文件](https://github.com/proximafusion/vmecpp_large_cpp_tests/blob/394a09a6b264057ad08e28c22fa84517e4a96d8d/test_data/coils.w7x) · [线圈许可](LICENSE-coils.txt)

## 运行

进入相应算例目录。固定边界 SIESTA 直接读取随附的 `wout_*.nc`。自由边界需要先用随附的 `coils.w7x` 和 `input_xgrid.dat` 运行 MAKEGRID，再生成 `siesta.jcf` 指定的 BMW 线圈网格。各算例 README 列出文件名与命令。Stellarator-Tools 构建中的 MAKEGRID 可执行文件位于 `_deps/makegrid-build/mgrid`。网格转换使用 Python 3、NumPy 和 SciPy。

同一构建下重新生成的原始 MGRID 和 BMW 网格已分别与运行前存档逐字节核对。BMW 转换同时恢复线圈匝数并对齐 WOUT 的磁场方向。

四组统一使用 `NITER=100`、`MPOLIN=10`、`NTORIN=6` 和一个 OpenMP 线程。固定边界关闭人工电阻。自由边界初始 `ETA_FACTOR=0.003`，使用程序原有的电阻调用与接受条件。`LADD_PERT=F`。运行构建对应求解器源码 `3c903aa6e0e51adfa3cd9edc871e26b7e9444ec7`，本次 Release 二进制 SHA-256 为 `08e89df0819517191e8fd24419598c13135cd77c009eec85d08a6bb6b276eadd`。

## 结果与读图

各算例的 `results/` 保存最终 NetCDF 检查点、程序日志和剖面。图中的 VMEC LCFS 和磁轴用于参照，虚线为计算边界。压力和电流图按截面重建，单位及取样口径见图和诊断记录。力残差历史使用 SIESTA 的归一化平方力残差 `F2(MHD)`，自由边界的电阻更新另有记录。各目录的 `SHA256SUMS` 可用 `sha256sum -c SHA256SUMS` 核验。

这些算例用于展示实际计算流程与终态。停止原因见表和检查点。定向源码修复验证见 [验证范围](../../Source-Code/docs-data/README.md#verification)。
