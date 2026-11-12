# W7-X EIM 约 5% 固定边界

VMEC 输入平衡的体积平均局域 β 为 **5.12730%**。SIESTA 径向网格为 **99**，谱截断为 $M=10,N=6$。
固定边界采用 `LRESISTIVE=F`，全程为理想迭代。 迭代步数上限为 100，`FTOL=1e-20`。

## 输入与运行

- SIESTA NAMELIST [siesta.jcf](siesta.jcf) 读取 [wout_EIM_5_c_para.nc](wout_EIM_5_c_para.nc)。
- 随附 VMEC 输入 [input.eim_demo_repro](input.eim_demo_repro) 和上游原版线圈 [coils.w7x](coils.w7x)。
- SIESTA 使用历史归档的 WOUT 原件。随附 VMEC 输入用于重建 EIM 平衡。两者的数据来源见 [W7-X 索引](../README.md)。
- SIESTA 固定边界直接使用随附 WOUT。单独复算 VMEC 平衡时，用 [input_xgrid.dat](input_xgrid.dat) 和 [align_mgrid.py](align_mgrid.py) 准备线圈网格。

```sh
/path/to/mgrid input_xgrid.dat
python3 align_mgrid.py wout_EIM_5_c_para.nc
```

可在算例目录的副本中从随附 VMEC 输入复算。以下命令假定所需网格已按上面的说明生成。

```sh
mpirun -np 4 /path/to/xvmec2000 eim_demo_repro
```

用随附 WOUT 复现归档的 SIESTA 启动条件。可在算例目录的副本中执行以下命令。

```sh
OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 OPENBLAS_DEFAULT_NUM_THREADS=1 \
MKL_NUM_THREADS=1 OPENBLAS_CORETYPE=Haswell PARSOLVER=NSCALED mpirun --stdin none --bind-to none -np 10 /path/to/xsiesta
```

## 结果

完成 **100** 步，停止原因为 `iteration_limit`。平方力残差初值为 `1.942000e-06`，最终检查点值为 `8.462638e-10`。本次运行耗时约 333 秒。
压力最低采样值在原生角网格上为 `1.400073e+03 Pa`，在 8 倍加密角网格上为 `1.318480e+03 Pa`。径向均使用原生半网格。

- [最终 NetCDF](results/siesta_w7x_eim_archive_fixed_final.nc) 对应最后提交的状态，[最佳理想步 NetCDF](results/siesta_w7x_eim_archive_fixed.nc) 的平方力残差为 `8.462638e-10`。
- [运行日志](results/run.log) · [压力与磁场剖面](results/siesta_profiles.txt) · [PEST 剖面](results/siesta_profiles_pest.txt)
- [庞加莱截面](figures/poincare.png) · [力残差历史](figures/force_history.png) · [压力二维分布](figures/pressure.png) · [电流二维分布](figures/current.png)
- [力密度二维分布](figures/force_density.png) 使用 SI 单位的独立空间重建。
- [残差逐步记录](results/force_history.csv) · [诊断口径与元数据](results/diagnostics.json) · [文件散列](SHA256SUMS)
