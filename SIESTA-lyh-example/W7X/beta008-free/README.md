# W7-X EIM 0.8% 自由边界

VMEC 输入平衡的体积平均局域 β 为 **0.79999%**。SIESTA 径向网格为 **230+33**，谱截断为 $M=10,N=6$。
自由边界采用 `LRESISTIVE=T`、初始 `ETA_FACTOR=0.003`。日志记录 98 次提交的电阻扩散。 迭代步数上限为 100，`FTOL=1e-18`。

## 输入与运行

- SIESTA NAMELIST [siesta.jcf](siesta.jcf) 读取 [wout_w7x_beta008.nc](wout_w7x_beta008.nc)。
- 随附 VMEC 输入 [input.w7x_beta008](input.w7x_beta008) 和上游原版线圈 [coils.w7x](coils.w7x)。
- 计算壁为 [vessel_w7x_eim.dat](vessel_w7x_eim.dat)。使用 [input_xgrid.dat](input_xgrid.dat) 和 [align_mgrid.py](align_mgrid.py) 在运行目录生成 BMW 网格。

```sh
/path/to/mgrid input_xgrid.dat
python3 align_mgrid.py wout_w7x_beta008.nc
```

从 VMEC 输入复算时同样使用转换后的 BMW 网格。用随附 WOUT 确定线圈场方向。

可在算例目录的副本中从随附 VMEC 输入复算。以下命令假定所需网格已按上面的说明生成。

```sh
mpirun -np 4 /path/to/xvmec2000 w7x_beta008
```

用随附 WOUT 复现归档的 SIESTA 启动条件。可在算例目录的副本中执行以下命令。

```sh
OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 OPENBLAS_DEFAULT_NUM_THREADS=1 \
MKL_NUM_THREADS=1 OPENBLAS_CORETYPE=Haswell PARSOLVER=NSCALED mpirun --stdin none --bind-to none -np 12 /path/to/xsiesta
```

## 结果

完成 **100** 步，停止原因为 `iteration_limit`。平方力残差初值为 `1.689000e-07`，最终检查点值为 `2.066690e-07`。本次运行耗时约 748 秒。
压力最低采样值在原生角网格上为 `-0.000000e+00 Pa`，在 8 倍加密角网格上为 `-0.000000e+00 Pa`。径向均使用原生半网格。

- [最终 NetCDF](results/siesta_w7x_beta008_free_final.nc) 对应最后提交的状态，[最佳理想步 NetCDF](results/siesta_w7x_beta008_free.nc) 的平方力残差为 `1.336069e-07`。
- [运行日志](results/run.log) · [压力与磁场剖面](results/siesta_profiles.txt) · [PEST 剖面](results/siesta_profiles_pest.txt)
- [自由边界磁场初始化数据](results/siesta_w7x_beta008_free_free.nc)
- [庞加莱截面](figures/poincare.png) · [力残差历史](figures/force_history.png) · [压力二维分布](figures/pressure.png) · [电流二维分布](figures/current.png)
- [力密度二维分布](figures/force_density.png) 使用 SI 单位的独立空间重建。
- [残差逐步记录](results/force_history.csv) · [诊断口径与元数据](results/diagnostics.json) · [文件散列](SHA256SUMS)
