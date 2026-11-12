# SIESTA-lyh 技术文档

本文汇总当前 [`SIESTA-lyh/`](../SIESTA-lyh/) 相对 [`SIESTA/`](https://github.com/ORNL-Fusion/SIESTA/tree/d9c8311b2dc085b6af511f9040531e0391f2f07d) 原版基线 `d9c8311b2dc085b6af511f9040531e0391f2f07d` 的全部源码改动。两个源码目录具有相同的内部文件路径。固定和自由边界输入、外部依赖及算例结果见 [W7-X 示例](../../SIESTA-lyh-example/W7X/README.md)。

维护此清单时，先按计算对象和受影响的行为查找已有条目。同一功能或同一问题的补充修复、优化和验证并入原条目。新增独立功能或独立修复时，新增一项，并在对应位置更新使用方法和验证范围。

[物理原理](#physics) · [IPO 说明](#ipo) · [改动清单](#改动清单) · [编译与运行](#编译与运行) · [验证范围](#verification)

<a name="physics"></a>

## SIESTA 的物理原理

SIESTA 在给定的三维背景网格上求静态 MHD 平衡。它以 VMEC 平衡为初态，通过理想位移迭代降低力残差，并在启用非理想步骤时允许磁场线重联，因此可以求得含磁岛和随机磁场区的平衡。

### 1. 背景坐标与边界

网格由 VMEC 的几何映射给出，径向采用 $\rho=\sqrt{s}$，其中 $s$ 是 VMEC 的归一化环向磁通。极向角 $u$ 和环向角 $v$ 上作 Fourier 展开，径向用交错的全网格和半网格作差分。几何、位移与力使用全网格，磁场和压强主要在半网格上推进。求解期间背景网格和度规固定，更新后的磁场可以穿过 $\rho=\mathrm{const.}$ 面。因此，$\rho$ 标记的是背景坐标面，最终磁拓扑由求得的磁场决定。

固定边界模式将初始 VMEC 等离子体边界作为计算外边界。自由边界模式把网格延伸到初始等离子体外，并用 BMW/PCHELMS 和线圈数据初始化外部磁场。外层计算边界由壁面几何及网格外扩设置确定，等离子体边缘可在计算域内随平衡改变。 [Hirshman 等，2011，第 III–VII 节](https://doi.org/10.1063/1.3597155) · [Peraza-Rodriguez 等，2017](https://doi.org/10.1063/1.4986447) · [边界输入](#ipo)

自由边界初始化在扩展网格上求解 `∇×∇×A = μ₀J_VMEC`，再用离散旋度得到磁场。计算壁的矢势边值包含等离子体和外线圈贡献。安培方程的电流源按当前 Fourier 表示满足离散相容条件，原 LCFS 外的源为零。该零源条件用于初始化。带衰减压力尾的外区随后的平衡仍可具有有限电流。计算壁固定后，最后一个物理压力半网格仍位于壁内并参与迭代。若把计算壁设为零压且磁力线穿到该壁，静态平衡的 `B·∇p = 0` 要求沿该线压力为零。验证这种拓扑相容性需要实际追踪到计算壁。 [自由边界论文](https://doi.org/10.1063/1.4986447) · [矢势初始化](../SIESTA-lyh/Sources/pchelms.f90)

### 2. 力平衡与能量变分

静态、标量压强的 MHD 模型要求洛伦兹力与压强梯度平衡，同时满足安培定律和磁场无散条件。以下公式采用 SI 单位。当前源码固定 `γ=5/3`。内部磁场乘 `b_factor`，压强先乘 `μ₀` 再乘 `p_factor=b_factor²`，因此内部力算子不显式写出 `μ₀` 与下列 SI 形式相容。[模型常数](../SIESTA-lyh/Sources/island_params.f90) · [初态归一化](../SIESTA-lyh/Sources/quantities.f90)

$$
\mathbf F=\mathbf J\times\mathbf B-\nabla p=\mathbf 0,\quad \mu_0\mathbf J=\nabla\times\mathbf B,\quad \nabla\cdot\mathbf B=0
$$

将磁能和绝热内能相加得到势能 $W$，其中 $\gamma$ 是绝热指数。对满足边界条件的理想位移 $\boldsymbol{\xi}$ 取变分。在边界项消失时，分部积分给出

$$
W=\int_V\left(\frac{B^2}{2\mu_0}+\frac{p}{\gamma-1}\right)\,\mathrm dV
$$

$$
\delta W[\boldsymbol{\xi}]=\int_V\left(\frac{\mathbf B\cdot\delta\mathbf B}{\mu_0}+\frac{\delta p}{\gamma-1}\right)\,\mathrm dV=-\int_V\boldsymbol{\xi}\cdot\mathbf F\,\mathrm dV
$$

因此，对所有允许位移满足 $\delta W=0$ 时，域内的力平衡条件是 $\mathbf F=\mathbf 0$。平衡方程沿磁场投影还给出 $\mathbf B\cdot\nabla p=0$，即压强沿每条磁力线为常数。若磁力线在连通区域内稠密且压强连续，则该区域的压强趋于平坦。 [Hirshman 等，2011，第 II、IV–V 节](https://doi.org/10.1063/1.3597155)

### 3. 理想更新与线性化位移

在当前状态上施加小位移 $\boldsymbol{\xi}$。磁通冻结和绝热压强方程给出 Euler 磁场、压强增量。压强的两项分别来自对流和压缩。

$$
\delta\mathbf B_{\mathrm I}=\nabla\times(\boldsymbol{\xi}\times\mathbf B)
$$

$$
\delta p=-\boldsymbol{\xi}\cdot\nabla p-\gamma p\,\nabla\cdot\boldsymbol{\xi}
$$

将增量代入力残差，保留位移的一阶项，得到线性力算子 $\mathcal L$。

$$
\mathcal L[\boldsymbol{\xi}]=\delta\mathbf F=\frac{\nabla\times\delta\mathbf B_{\mathrm I}}{\mu_0}\times\mathbf B+\mathbf J\times\delta\mathbf B_{\mathrm I}-\nabla\delta p
$$

每轮用预条件求解近似满足 $\mathcal L[\boldsymbol{\xi}]\simeq-\mathbf F$ 的位移。SIESTA-lyh 使用物理预条件和 GMRES 求候选位移，并用更新后的磁场和压强重新评估非线性残差。单步磁场与压强仍使用一阶增量。非线性力残差用更新后的场重新计算，因此包含更新后电流与磁场的完整乘积。 [Hirshman 等，2011，第 V、IX 节](https://doi.org/10.1063/1.3597155) · [位移求解与残差搜索](../SIESTA-lyh/Sources/gmres.f90)

理想步显式重算零位移的基准残差，并在同一力算子设置下检查候选。接受步要求重算的非线性力残差下降，且原生物理半网格的压力满足舍入容差。自由边界在每个角向间隔细分四份的嵌套网格上重构谱压力。根据投影后的压力增量及角向区间内的压力下界，计算所有 MPI 分区共同的保守可行步长区间。当原方向受近零压强径向层限制时，另试满足壁面位移条件的备选方向。没有可接受步时保留当前状态。 [理想步搜索](../SIESTA-lyh/Sources/shared_functions.f90) · [物理压力检查](../SIESTA-lyh/Sources/siesta_force.f90)

### 4. 人工电阻与磁拓扑变化

理想扰动关系来自连续方程的磁通冻结。人工电阻通过 Faraday 定律加入非理想磁场增量，使共振电流层能够扩散并改变磁连接。SIESTA-lyh 的常规扩散分支使用与电流成正比的电场，径向窗口 $w(\rho)$ 控制扩散分布。

$$
\mathbf E_\eta=\eta_{\mathrm{num}}w(\rho)\mathbf J,\qquad\Delta\mathbf B_\eta=-\Delta\tau\,\nabla\times\mathbf E_\eta
$$

开启 `LRESISTIVE` 时，代码在提交理想步后，按预条件阶段和力残差决定是否扩散。触发后将位移置零，执行 10 个显式磁场子步，各子步根据更新后的磁场重算电流，压强在此阶段保持不变。扩散后重算非线性力残差，新的磁场进入下一轮理想位移求解。`ETA_FACTOR` 控制数值扩散强度，$\Delta\tau$ 表示迭代中的伪时间步。 [Faraday 更新](../SIESTA-lyh/Sources/siesta_bfield.f90) · [扩散子步](../SIESTA-lyh/Sources/add_resistivity.f90)

普通磁扩散的连续磁能变化率为 −∫η|J|² dV，边界无切向电场功。显式离散按整组磁能及残差检查并在必要时回退减步。磁场变化后，力残差仍可能升高。 [扩散步控制](../SIESTA-lyh/Sources/add_resistivity.f90)

程序还可通过 `LADD_PERT` 与 `HELPERT` 在背景共振面附近施加局域螺旋种子。对于相位为 $mu+nN_{\mathrm{fp}}v$ 的模态，背景旋转变换满足 $m\iota+nN_{\mathrm{fp}}=0$ 处发生共振。该分支用沿磁场的局域电场产生初始拓扑扰动，按试探能量选择径向宽度。后续平衡由完整迭代得到。 [Hirshman 等，2016，第 3–4 节](https://doi.org/10.1017/S0022377816000143) · [共振种子实现](../SIESTA-lyh/Sources/perturbation.f90)

当前实现以一阶场增量推进有限位移，并使用离散差分与谱截断；因此不能把连续理想方程的磁通冻结理解为有限步数值更新精确保持所有磁拓扑不变量。常规电阻子步只更新磁场，不加入焦耳加热的压力演化；这里的伪时间及人工电阻用于平衡搜索，不能据此解释真实电阻 MHD 的时间演化。[磁场与压力更新](../SIESTA-lyh/Sources/shared_functions.f90) · [电阻子步](../SIESTA-lyh/Sources/add_resistivity.f90)

### 5. 如何判断求得平衡

当前实现用 `F2(MHD)` 衡量力平衡，它是离散、归一化的体积加权力残差平方。程序按 `FTOL` 检查残差，并受 `NITER` 步数上限约束。理想步按非线性残差评估候选，能量变分给出力算子的物理形式，程序同时记录每步能量。逐步 $\delta W<0$ 并非接受条件。达到残差容差表明离散力平衡达到目标精度，理想稳定性还需单独检验能量的二阶变分。 [力残差计算](../SIESTA-lyh/Sources/shared_functions.f90) · [迭代与停止条件](../SIESTA-lyh/Sources/evolution.f90) · [验证范围](#verification)

力残差达到容差后，仍需检验网格与谱截断收敛、磁场无散性、边界和磁通约束，以及磁岛结果对种子幅度和人工电阻的敏感性。已有研究报告磁岛尺寸及位置会随输入扰动幅度改变，故单次力平衡收敛不能证明磁岛宽度唯一或与扰动无关。[Woodbury Saudeau 等，2026](https://doi.org/10.1063/5.0330426)

<a name="ipo"></a>

## IPO 输入、计算与输出

主程序 `xsiesta` 由 Fortran 实现。从算例目录启动时，无参数读取 `siesta.jcf`，运行 `xsiesta case` 则读取 `siesta_case.jcf`。文件相对路径以工作目录为准。[程序入口](../SIESTA-lyh/Sources/siesta.f90)

### 输入

| 运行模式 | NAMELIST 设置 | 所需文件 |
| --- | --- | --- |
| 固定边界初始化 | `LRESTART=F`，`L_VESSEL=F` | 含 `&SIESTA_INFO` 的输入文件和 `WOUT_FILE` 指定的 VMEC `wout_*.nc`。 |
| 自由边界初始化 | `LRESTART=F`，`L_VESSEL=T` | NAMELIST、`WOUT_FILE`、`VESSEL_FILE` 计算外壁和 `MGRID_FILE` 外部线圈网格。BMW 读取网格中的矢势 `ar_###`、`ap_###`、`az_###`，按 VMEC 的 `extcur` 加权。 |
| 从 SIESTA 重启 | `LRESTART=T`，`L_VESSEL` 与检查点对应 | NAMELIST 和 `siesta_<RESTART_EXT>.nc`。自由边界重启的 `NSIN` 须与保存时的等离子体内径向点数相同。 |

`input.*`、`coils.*` 和 `input_xgrid.dat` 用于上游生成所需的 VMEC 和线圈网格文件。重启时，`WOUT_FILE` 仍须填写符合 `wout_*.nc` 命名规则的名称，用于命名日志。固定与自由边界重启均已用仅含 NAMELIST 和主检查点的目录验证。[W7-X 算例](../../SIESTA-lyh-example/W7X/README.md) · [初始化与重启入口](../SIESTA-lyh/Sources/siesta_run.f90)

### 计算

1. 首次运行将 VMEC 初态映射到 SIESTA 网格。自由边界再构造外扩网格并用 BMW/PCHELMS 初始化外部磁场。重启则从检查点恢复网格、几何和场量。
2. 计算离散 MHD 力残差。先进入对角预条件阶段，再按残差和剩余步数进入块预条件阶段。`LADD_PERT` 和 `LRESISTIVE` 分别控制种子扰动和电阻扩散。
3. 用日志中的 `F2(MHD)` 和 `FTOL` 核对离散力平衡，并结合 `NITER` 确认停止原因。仓库的四组 W7-X 示例均设置 `NITER=100`，各例记录实际停止原因。

[输入参数](../SIESTA-lyh/Sources/siesta_namelist.f90) · [迭代控制](../SIESTA-lyh/Sources/evolution.f90)

### 输出

| 文件 | 内容与写出条件 |
| --- | --- |
| `siesta_<RESTART_EXT>.nc` | 理想子步检查点。默认保留力残差最小的理想状态，`L_FORCE_RESTART=T` 时写出每步的理想状态。 |
| `siesta_<RESTART_EXT>_final.nc` | 正常收尾时保存末次完整接受状态，包括已提交的扩散和种子。可用作重启输入。 |
| `output_<算例>_<NSIN>X<MPOLIN>X<NTORIN>.txt` | 运行日志。算例名取 `WOUT_FILE` 去掉 `wout_` 和 `.nc` 后的名称。三个整数依次补零至 4、3、3 位。 |
| `siesta_<RESTART_EXT>_free.nc` | 自由边界初始化写出的 PCHELMS 矢势谱。 |
| `siesta_profiles.txt`、`siesta_profiles_pest.txt` | 从 VMEC 初始化的运行结束时写出，分别为 SIESTA 和 PEST 坐标下的剖面诊断。 |
| `<RESTART_EXT>-pressure-CYL-####.dat`、`<RESTART_EXT>-pressure-FLUX-####.dat` | 柱坐标截面和磁通坐标上的压强图数据，文件名带迭代编号。 |
| `<RESTART_EXT>-bfield_tracing-####.dat` | `L_TRACING=T` 时写出，供 XPOINCARE 做磁场线追踪。 |

从 VMEC 初始化时，图形诊断默认在收尾阶段写出，`L_OUTPUT_ALLITER=T` 可逐步导出。当前重启路径写日志和检查点，跳过剖面及图形导出。[NetCDF 写出](../SIESTA-lyh/Sources/restart_mod.f90) · [剖面诊断](../SIESTA-lyh/Sources/diagnostics_mod.f90) · [图形与追踪输出](../SIESTA-lyh/Sources/dumping_mod.f90)

新检查点含 `checkpoint_role`、`iteration`、`termination_reason`、`converged`、`ftol`。最终文件的 `termination_reason` 区分 `converged`、`iteration_limit` 与 `solver_stalled` 等。退出码 0 表示运行正常收尾，是否达到平衡容差看 `converged` 和末态 `fsq`。从 `siesta_case_final.nc` 重启时设 `LRESTART=T`、`RESTART_INPUT_EXT="case_final"`、`RESTART_EXT="case_resume"`。省略 `RESTART_INPUT_EXT` 时使用 `RESTART_EXT` 作输入名。标记为最终状态的输入文件受到覆盖保护。关闭图形仍生成首次运行的剖面诊断。 [重启入口](../SIESTA-lyh/Sources/siesta_run.f90)

## 改动清单

### 平衡演化与预条件器

- **自由边界人工电阻窗口**。`update_bfield` 在普通外扩网格上使用覆盖全域的非负窗口，避免沿用等离子体归一化后，$\rho>1$ 使 $\rho^2(1-\rho)$ 变为负值。对全网格节点 $j<N_s-1$ 使用 $q_j^2(1-q_j)$，其中 $q_j=(j-1)/\max(1,N_s-2)$。外壁最后两个全网格节点的窗口及电场置零，使末端半网格的电阻旋度增量为零。自由边界螺旋种子保留原有内区窗口，并将壁面旋度模板对应的最后两个全网格节点电场置零。实际磁场更新算子测试中，螺旋种子的壁面三个谱分量增量均为零，代表性环向增量从 `6.095679×10⁻²` 降为零。固定边界及远离壁面的对照切片逐值一致。制造场在实际径向差分下的磁能方向导数由 `+5.626736` 变为 `−0.641580`，外壁磁场增量模由 `7.390625` 降为 `0`。验证覆盖该制造场的离散电阻子步。[siesta_bfield.f90](../SIESTA-lyh/Sources/siesta_bfield.f90)
- **电阻扩散后的残差与步长**。以当前接受态为起点试探十个显式子步，检查整组后的磁能和力残差。接受条件要求磁能在舍入误差内不增加，且 `F²` 至多为扩散前的四倍。试探失败恢复原磁场谱，减半系数后重试，最多 8 次。全部失败则跳过本组并重算恢复态的残差。一次接受后的系数增幅至多 10%，回退后接受的系数沿用到下一组。该控制限制已接受的整组扩散，仍允许有限的力残差升高。 [扩散步控制](../SIESTA-lyh/Sources/add_resistivity.f90)
- **力残差停滞与 LM 阻尼更新**。`init_evolution` 每次初始化时清零 `failed_min_count`，防止连续调用继承停滞计数。连续三次残差未下降时，`evolve` 的高、低残差分支均以 `MIN(3 × 当前值, 上限)` 截断阻尼增长。对照测试覆盖重复初始化和触及上限的情况。初始阻尼 `0.001` 的一次更新从原版的 `10⁹` 修正为 `0.003`。演化提交前检查残差、能量和位移范数，拒绝非有限值。由对角预条件切换至块预条件时，如果下一步正好等于 `NITER`，仍执行最后一步。双 rank 测试覆盖该切换和 NaN 拒绝路径。[evolution.f90](../SIESTA-lyh/Sources/evolution.f90) 阻尼插值仅在目标容差严格小于过渡残差 `10⁻⁶` 时进行，避免合法 `FTOL=10⁻⁶` 使分母为零；更松目标保留输入阻尼，低于严格目标的残差使用最小阻尼。普通区间保留原算术。使用同一检查点与输入，复测确认该容差触发的 `DMINL=NaN` 已消除。 零位移为搜索基准，只有压力可接受且力残差下降的试探才提交，并以选中位移重算谱增量和残差。原例程在全部试探升高残差时曾返回非零位移并报告零位移残差。当前制造反例返回零位移和重算一致的残差。初态和重启同样检查物理压力。初态已达到 `FTOL` 时，跳过为阶段切换预留的第二个对角步。 [步长搜索](../SIESTA-lyh/Sources/shared_functions.f90)
- **自由边界理想步的压强可行性**。原搜索只缩短同一个方向。一个贴壁半网格的压强已接近下限且仍将下降时，整域位移可能连续被拒。自由边界以实际 Fourier 投影后的压力增量与现态计算可行步长区间。以谱系数绝对和约束雅可比加权压力的角向二阶导数，再用双线性插值误差上界扣除样点间余量。在雅可比保向的前提下，检查覆盖整个角向区间并允许舍入尺度的误差，径向仍在物理半网格层验算。若原方向只允许很小的步长，沿限制层局部平滑衰减位移，并试探受限层两侧整网格位移行均为零的备选方向。短步仍受限时，将现态力平滑衰减至原 LCFS 为零，试探该内部方向和其反向。这些操作只用于生成候选，原理想压力、磁场更新算子和外壁位移条件沿用。共轭梯度的候选也经同一搜索验收，只有满足压力检查且降低完整非线性力残差的候选才提交。 [可行区间及备选方向](../SIESTA-lyh/Sources/shared_functions.f90) · [共轭梯度验收](../SIESTA-lyh/Sources/evolution.f90)
- **块三对角预条件器的对角下标**。`FindMinMax_TRI` 在使用 `MAXLOC` 的块内位置访问 `OrigDiagElement` 时加上块偏移 `dcnt`，从当前块读取对角元符号。双块测试的目标修正量从 `−1×10⁻⁵` 恢复为 `+1×10⁻⁵`。[blocktridiagonalsolver_s.f90](../SIESTA-lyh/Sources/blocktridiagonalsolver_s.f90) 求解器初始化时重置列缩放标志，结束时释放 `OrigDiagElement`，使后续计算按自己的预条件配置重建。 NSCALED 与 ScaLAPACK 都按径向块统一判定近零对角和有效对角的符号。MPI 全局归约后，仅同号有效对角进入原有同号 LM 移位。真正混号时，各分区一致报告不满足预条件器假设。 [ScaLAPACK 对角检查](../SIESTA-lyh/Sources/hessian.f90)

### 网格与坐标变换

- **轴上雅可比的 Fourier 模态投影**。`get_origin` 保留指定极向模时，清除其上方的整个模态区间，避免只清除紧邻的一个模而留下更高阶分量。构造轴上雅可比使用该投影的零模。对称和非对称测试均覆盖保留 $m=0,1$，并验证第一个物理半网格切片原值。制造场的最大投影误差由约 1 和 1.94 降至 $128\epsilon$ 以内。[fourier.f90](../SIESTA-lyh/Sources/fourier.f90)
- **固定边界 λ 重算与验算**。求解后在原网格验算保留谱模上的径向电流条件，拒绝非有限解和超过舍入尺度的代数误差。并行重算结束后收集所有物理径向切片，使重启和 PEST 诊断使用同一组 λ。用可信 BLAS 路径时，NCSX 单、双 rank 的 PEST 文本逐字节一致。 [quantities.f90](../SIESTA-lyh/Sources/quantities.f90)

- **螺旋扰动的共振面定位**。用相邻网格的 $m\chi'+nN_{\mathrm{fp}}\Phi'$ 插值定位过零面，扫描游标保留相邻区间中的不同根，连续零点只计一次。仅当整个模态无精确根或过零根时，才按原容差采用近似共振面，避免把已定位根旁的近零点当成另一处共振。单元测试包含非均匀 $\Phi'$、相邻根、零点平台和容差回退。种子宽度搜索从实际有限候选中选择最低能量，消除以 $2W_0$ 作初始最小值时漏选全部候选、使用未赋值宽度的错误。制造能量目标中全部候选均大于 $2W_0$ 时，仍能选出真实最小值，初始或候选能量为非有限值时显式报错。实际 NCSX 的小幅种子对照中，所选宽度及磁场、压力谱逐字节一致。该修复针对施加种子的宽度选择。[perturbation.f90](../SIESTA-lyh/Sources/perturbation.f90) · [SIESTA 共振种子模型，Hirshman 等，JPP 2016](https://www.cambridge.org/core/journals/journal-of-plasma-physics/article/investigation-of-island-formation-due-to-rmps-in-diiid-plasmas-with-the-siesta-resistive-mhd-equilibrium-code/F84744670014734A52CEB7AC570CCD80) 提交螺旋种子后，以零理想位移重新评估当前场的完整非线性残差和能量，再判断是否继续；能量选宽过程本身不刷新力残差。实际 `m=2,n=−1`、`HELPERT=5×10⁻⁴`、`NITER=1` 对照中，旧报告 `F²=1.9081582810763267×10⁻⁴`，当前场独立重算却为 `2.3294945914250855×10⁻⁴`；修复后两者一致，并在主进程日志明确打印种子后的残差。该单步种子测试的三个磁场谱和压力谱各 900 个数在修复前后逐元素相同，确认刷新只重新评估残差，没有再次施加种子或推进压力。制造控制测试同时覆盖对角/块阶段继续迭代与预算耗尽，保留 `NITER` 上限和禁用求解器的停止条件。[演化停止判断](../SIESTA-lyh/Sources/evolution.f90)
- **自由边界网格外扩**。`get_volume` 在 `LASYM=T` 时只补上末角点到首角点的周期闭合边。圆环几何用 256 个角向点时，相对体积误差低于 `5×10⁻⁴`。`grid_extender` 的四处 Fourier 调用统一使用截断后的实际外扩长度 `ns - nsp`，非对称分支采用合法的径向切片，并把 R、Z 系数分别写入 `rmns_i` 和 `zmnc_i`。调用测试覆盖正常外扩，以及请求 99 点、实际仅允许 2 点的情况。[grid_extension.f90](../SIESTA-lyh/Sources/grid_extension.f90) 读取时验证外壁谱记录、所需线圈网格和可解析的外扩层数。外壁缺失、系数非法、体积无效或无法形成外扩层时，在进入 PCHELMS 前报错。壁面正负环向索引均初始化，扩展后释放几何工作区，日志报告实际外扩层数。在将外壁位置转换为整数层号前检查有限性及整数范围，按 `NSIN_EXT` 约束后的实际层数分配和变换外扩数组。NCSX 双 rank 请求两层外扩时，得到 51 层总网格，R/Z 和环向磁场谱与完整工作区实现逐元素一致。 [自由边界初始化](../SIESTA-lyh/Sources/siesta_run.f90)
- **PEST Fourier 变换**。径向插值分别对角映射 `lambda` 和雅可比因子 `dupdu` 平均一次，并保留轴端复制和外边界外推。极向变换在各角点直接计算 `cos(mλ)` 和 `sin(mλ)` 后乘该点雅可比，消除 `m≥2` 时跨角点复用标量递推状态造成的虚假谐波。常量场测试中，对称和非对称模式的最大虚假谐波分别为 `1.80×10⁻¹⁶` 和 `2.40×10⁻¹⁶`。[fourier.f90](../SIESTA-lyh/Sources/fourier.f90)

### 输入、重启与输出

- **自由边界矢势初始化与电流回代**。删除原 LCFS 内对极向非零谐波切向矢势的额外置零约束，使这些自由度与仍参与求解的安培方程相容。插值后的 VMEC 电流在两个奇偶分支中逐 Fourier 模去除离散散度分量。径向源为零时，雅可比加权切向源满足 `m·Ju + n·NFP·Jv = 0`。保留零模总电流、原 LCFS 外零电流源和计算壁矢势边值。写出初始化磁场前，在原离散算子上回代。投影后源非零时，通常要求安培残差的相对 L2 范数不超过 `1e-8`，大型壁面贡献的相消误差使用按初始缺陷缩放的舍入余量。零源时按初始安培缺陷缩放绝对误差。日志另列排除壁面约束行的严格外区残差。 [PCHELMS 求解与回代](../SIESTA-lyh/Sources/pchelms.f90)
- **自由边界磁通与旧重启恢复**。PCHELMS 完成后从全域零谐波矢势计算环向和极向磁通，消除外扩区未写出的 NetCDF 填充值。读取带填充值的旧文件时，按半网格 `JB` 零谐波积分恢复，使用保存的磁场归一化和当前几何方向。NCSX 的新写出和旧文件恢复均与矢势差分核对，壁面磁通为 `Φ=0.8950037047 Wb`、`χ=−0.5142401576 Wb`。 [PCHELMS 磁通](../SIESTA-lyh/Sources/pchelms.f90) · [重启恢复](../SIESTA-lyh/Sources/restart_mod.f90) 同时从重建的半网格磁场更新全网格磁通导数，包含原 LCFS。外壁用最后两个半网格层作半步线性外推，使用当前几何的雅可比方向。共振种子使用更新后的导数。PCHELMS 的 VMEC 电流对照只作一次 μ₀ 转换。 [VMEC 电流诊断](../SIESTA-lyh/Sources/vmec_info.f90)
- **逐步输出与 MPI 分区**。全域输出准备临时使用完整网格，返回时恢复当前 rank 的径向区间，谱写出按实际缓存范围检查。双 rank 受控对照中，仅切换逐步输出开关，最终剖面、PEST 剖面及 restart 逐字节一致。压力截面和磁场线追踪的输出分区允许某些 rank 没有采样点，避免总输出点数少于 MPI rank 数时出现负数组长度或越界。2×2 小型输出网格的 1/8 rank 及普通输出网格的 1/2 rank 对照中，压强、追踪及两种剖面文本逐字节一致，能量归约标量差异不超过 $4.44×10^{-16}$。[诊断采样分区](../SIESTA-lyh/Sources/dumping_mod.f90) [状态准备](../SIESTA-lyh/Sources/siesta_init.f90) · [诊断输出](../SIESTA-lyh/Sources/diagnostics_mod.f90)

- **磁场线追踪输出的归一化**。`L_TRACING=T` 时，在临时输出谱上恢复磁场单位，保留求解器共享磁场缓存的内部归一化。原实现会原地缩放缓存，使随后写出的平行电流等剖面发生变化。NCSX 初始化的开关对照中，主检查点及 SIESTA/PEST 剖面均逐字节一致。[dumping_mod.f90](../SIESTA-lyh/Sources/dumping_mod.f90)
- **剖面文件写出失败报告**。分别检查 `siesta_profiles.txt` 和 `siesta_profiles_pest.txt` 的打开状态，避免第二次成功覆盖第一次失败，随后隐式写入 `fort.*`。目标路径为目录的测试会按文件名明确报错。[diagnostics_mod.f90](../SIESTA-lyh/Sources/diagnostics_mod.f90)
- **诊断文件命名与写入**。压力截面和磁场线追踪文件使用完整 `RESTART_EXT`；编号至少四位并保留更高位，避免 30 字符标签截断或将所有 `iter≥10000` 压成 `9999` 而覆盖文件。实际写出例程测试覆盖两组相同前 30 字符的标签和 `9999/10000` 步，原来仅留下 3 个文件，修复后保留预期的 9 个文件。文件打开失败带具体路径报错，磁场线追踪采用替换写入。[dumping_mod.f90](../SIESTA-lyh/Sources/dumping_mod.f90)
- **NAMELIST 与环向谱输入校验**。读取 NAMELIST 时，在访问固定范围的 `ntor_modes` 数组前检查 `0 ≤ NTORIN ≤ 50`，并修正相关 `LASYM` 报错文字。边界测试确认 `50` 可用，`51` 和 `−1` 被拒绝。[siesta_namelist.f90](../SIESTA-lyh/Sources/siesta_namelist.f90) 每次读入前恢复所有 NAMELIST 变量的声明默认值，同一 MPI 进程中后续算例省略的项目使用默认值。非法 NAMELIST 报出文件及解析错误。稀疏谱检查零模、非重复正模和负模配对，并用实际最大环向模数确定角向网格。无序合法谱 `±4/±2` 的配点数由 10 修正为 16。[角向网格](../SIESTA-lyh/Sources/metrics.f90) 空白或过短的 `WOUT_FILE` 在解析文件名时直接报错，径向缩放宽度按当前网格计算，避免短网格影响后续运行。[初态输入处理](../SIESTA-lyh/Sources/perturbation.f90) `NSIN≥3`、`MPOLIN≥1`、`NITER≥1` 在分配前检查。读取 VMEC 初态时，各 rank 均检查所选 NFP 是 VMEC 场周期数的正约数，并在缺失相应环向模式的诊断中显示物理模数。 [VMEC 输入映射](../SIESTA-lyh/Sources/vmec_info.f90) `FTOL` 和 `ETA_FACTOR` 必须有限且非负，零值仍合法。启用非重启诊断输出时，`NRS/NZS/NSS/NUS/NVS` 均至少为 2，防止间距计算除零；保留 `NPHIS≤0` 或 `NVS≤0` 关闭输出的约定。错误在计算和输出前报告具体参数。
- **重启对称性、网格和谱映射**。`restart_read` 在读取对称文件并切换为 `LASYM=T` 时保留已读入的 `rmnc`，并将新增 `zmnc` 清零。实际读取分支的测试检查了两组系数。[restart_mod.f90](../SIESTA-lyh/Sources/restart_mod.f90) 重采样使用有序的半网格坐标，对每个目标点单独调用标量样条接口，并保留无物理样点的轴端槽。全网格几何、半网格 `JB^s` 与 `JB^u`、`JB^v`、`Jp` 按各自轴反射奇偶性延拓。磁通 $\chi,\Phi$ 以偶反射延拓，关于 $\rho$ 的导数采用奇反射。49→65 层制造线性导数的最大误差由约 $1.32×10^{-3}$ 降到 $5.55×10^{-17}$。必需字段检查 NetCDF 状态、形状、有限性和默认填充值，诊断指出字段名。缺失或 NaN 的压力谱会显式终止，保留旧自由边界磁通恢复及可选 λ 的兼容处理。重启结束时将 VMEC 专用压力剖面与磁通数组分开释放，避免其缺席阻断磁通清理。重启初始化用完临时雅可比后即释放，后续改变径向网格时可重新分配。同一 MPI 进程从 49 层重启后，再执行 65 层重启或重新读取 VMEC，均正常完成。重启时跳过需要 VMEC 参考体积的相对差诊断，避免尚未读入的 `volume_i` 为零或保留前次值，导致除零或错误告警。启用除零陷阱的原生重启对照由 SIGFPE 修正为正常完成。[体积诊断](../SIESTA-lyh/Sources/quantities.f90)[网格对象清理](../SIESTA-lyh/Sources/metrics.f90) 改变环向模式集或 NFP 时按物理谐波 `n×NFP` 匹配。自由边界重启按文件 `nrad` 恢复整个网格，保持保存时的 `NSIN`；新文件用 `plasma_nrad` 验证该值，旧文件从输入取得它。NCSX 新旧重启均恢复实际 64 层，固定边界重采样测试从 49 层增至 65 层。 [重启入口](../SIESTA-lyh/Sources/siesta_run.f90) 含 `plasma_nrad` 的检查点要求 `3≤plasma_nrad≤nrad`，并验证 `L_VESSEL` 与是否存在外扩区一致。原实现将 `nrad=51, plasma_nrad=49` 的自由边界文件按固定边界读取后，会重采样并写成 `49/49`，改变背景径向解释；现在在插值前拒绝。无该字段的旧文件继续使用调用者提供的边界约定。
- **自由边界 NetCDF 矢势输出**。非对称 `_free.nc` 将径向矢势余弦分量写入独立字段 `asubsmncf_m_n_r_`，消除字段重名。写出前先令 `flags=restart_version`，再设置对称性位。使用实际 writer 和 `ezcdf` 读回验证了两种 `LASYM` 的标志和维度，对称 3 个字段、非对称 6 个字段的数值读回误差均为零。[restart_mod.f90](../SIESTA-lyh/Sources/restart_mod.f90) PCHELMS 收集各 rank 施加边界条件后的矢势，由 rank 0 写出共享 NetCDF 文件；边界文本由拥有对应层的进程写出，轴对称算例的诊断模数限制在合法范围。主重启文件按实际径向长度写出 λ，外扩区缺少的系数补零。重启读取可用的 λ 元数据并恢复内部归一化，固定和自由边界读写往返均保留原系数至舍入精度。 [PCHELMS 写出](../SIESTA-lyh/Sources/pchelms.f90) 主 NetCDF 保存理想步最佳或强制写出状态。独立最终文件保存完整末态，含已提交的磁扩散及种子更新、实际迭代数和收敛状态。图形关闭时独立准备剖面全网格数据，图形编号使用实际完成步数，重启跳过剖面时不报告剖面已写。 [结束处理](../SIESTA-lyh/Sources/siesta_run.f90)
- **磁场分量及比值诊断**。`update_state` 给对称诊断传入正确的环向分量 `jbsupvmnch`。`Update_Diagnostics` 在极向分量接近零时写入输出形参 `bsbu_ratio`，防止非对称分支覆盖全局对称结果 `bsbu_ratio_s`。定向测试覆盖仅改变环向分量、以及对称和非对称的比值回退分支。[siesta_state.f90](../SIESTA-lyh/Sources/siesta_state.f90) 非对称 `J·B` 诊断先判断分配状态再取数组尺寸，串行奇分量采用正弦投影。雅可比截断误差以同一半网格上滤波前后的范数计算，NCSX 固定边界结果从错误的 `9.90E-01` 修正为 `2.08E-03`。 [J·B 诊断](../SIESTA-lyh/Sources/diagnostics_mod.f90) · [雅可比诊断](../SIESTA-lyh/Sources/quantities.f90)
- **散度诊断的非对称谱、稀疏模数与零场**。`divb/divdb` 的归一化同时计入两组非对称磁场谱。纯非对称制造场整体加倍时，旧输出由 48 变为 192，修复后归一化值保持不变。`divj` 的环向微分使用实际 `tor_modes(n)×NFP`；存储槽 `n=1` 对应物理模数 4 的制造场，归一化分量由错误的 `±0.5` 恢复为 `±2`。零电流时不做 `0/0` 归一化，输出零值。上述均为诊断修复，不改变力平衡方程或场量推进。[diagnostics_mod.f90](../SIESTA-lyh/Sources/diagnostics_mod.f90)

### CPU 计算与混合并行

- **PCHELMS 状态、GMRES 和工作区**。结束后重置初始化标志，后续调用重建外场工作数组。并行矩阵向量乘法直接填充并交换已清零的 `xc`，避免每次回调分配和复制全长数组。ScaLAPACK 的复制数据路径按单份场计算残差和电流，并跳过未用的块循环工作区。GMRES 的子空间维数受方程数约束，并检查返回状态、解和实际残差的有限性。GMRES 的内部迭代预算增至 250，重启子空间至多 125。达到内部上限的候选须通过实际离散安培残差回代，才能用于初始化。同一个由调用者管理的 MPI 进程连续初始化两次 NCSX 自由边界，外扩区环向场均非零，两次磁场和压力系数逐元素一致。 [pchelms.f90](../SIESTA-lyh/Sources/pchelms.f90)

- **普通三维 Fourier 并行和计时**。正、逆变换的二维计算核接受显式工作区，三维接口按独立径向切片静态分配任务。线程各自使用临时数组，读取共享三角表，写入各自的切片。切片数至少为 4 且 `切片数 × NU × NV ≥ 4096` 时可启用多线程，团队规模最多为切片数的一半。全程计时在并行区外更新。`DIAGONALDONE && INHESSIAN` 路径的子阶段时间计入对应计时项，全程时间只累加一次。单元测试对照 8 个不同切片与串行二维接口，覆盖两种奇偶性、角向一阶和混合导数及累加模式。[fourier.f90](../SIESTA-lyh/Sources/fourier.f90)
- **压力、扰动场与力算子工作区**。压力算子用既有物理空间数组保存半网格速度，顺序复用谱空间工作区，并让径向梯度直接写入目标数组。`IncFields` 将四个顺序使用的谱空间临时数组合为一个。`GetMHDForce` 在角向压力梯度用完后，复用谱数组计算径向梯度。这样减少分配和整数组复制，并保持原有网格转换、边界处理和运算顺序。[siesta_pressure.f90](../SIESTA-lyh/Sources/siesta_pressure.f90) · [siesta_force.f90](../SIESTA-lyh/Sources/siesta_force.f90)
- **平衡 GMRES 候选解与矩阵向量乘法工作区**。候选解与反向通信回调的模块工作数组使用独立存储。以返回候选重新计算实际非线性力残差，涵盖不执行非线性预览的模式。检查输入、输出和残差的有限性，并对非法求解状态报错。Krylov 子空间维数不超过方程数。54 个未知量的三步 Debug 算例在 1、2、4 rank 上给出一致的逐步 $F^2$。并行 `gmres_wrap` 为每次线性求解分配一次全长缓冲区，供本次 `matvec_par` 回调复用。每次回调仍清零缓冲区、填入局部输入并执行原 halo 交换。求解退出时恢复先前指针关联并释放缓冲区。独立回调和尺寸不匹配时使用局部分配。以制造算子和通信替身调用实际例程的测试覆盖 3 次求解、14 次回调，包括地址复用、清零、尺寸变化及指针生命周期。[gmres.f90](../SIESTA-lyh/Sources/gmres.f90) 删除线性矩阵向量乘积的固定绝对截零，使小幅模态参与 Krylov 求解。LIBSTELL 的串行和并行 GMRES 从真实试探残差选择最优候选，收敛进度以乘法比较，避免除零。并行零右端在全部 rank 收到范数后统一返回，含无本地方程的 rank。 [依赖兼容构建](../SIESTA-lyh/Sources/CMakeLists.txt)
- **MPI/OpenMP 初始化、线程配置与编译开关**。程序在 BLACS 初始化前请求 `MPI_THREAD_FUNNELED`，或查询已有 MPI 环境的支持级别。MPI 调用仍由初始化线程执行，外部拥有的 MPI 环境由调用者结束。`MPI_THREAD_SINGLE` 自动退回单线程。`OMP_THREADS` 控制每个 rank 的线程数，程序结合可见 CPU、节点内 rank 数、`/sys/fs/cgroup/cpu.max` 和线程上限设置团队，并输出 `CPU team`。CMake 的 `SIESTA_ENABLE_OPENMP` 默认开启，可用 `OFF` 选择串行 Fourier。编译器缺少 Fortran OpenMP 支持时同样使用串行路径。[prof_mod.f90](../SIESTA-lyh/Sources/prof_mod.f90) · [blocktridiagonalsolver_s.f90](../SIESTA-lyh/Sources/blocktridiagonalsolver_s.f90) · [siesta_namelist.f90](../SIESTA-lyh/Sources/siesta_namelist.f90) · [siesta_run.f90](../SIESTA-lyh/Sources/siesta_run.f90) · [CMakeLists.txt](../SIESTA-lyh/CMakeLists.txt) ScaLAPACK 的三个 BLACS 网格从调用者指定的 MPI 通信器创建。析构逐个释放网格并在所有 rank 清理统计缓冲，调用者已有的 BLACS 网格可继续通信。四个 MPI rank 中使用逆序的双 rank 子通信器，再切换为四 rank，可正常完成。原实现在子通信器调用上挂起。上下文结束时恢复调用者的 OpenMP 线程数和动态团队设置。径向与谱空间映射在每次运行重建；MPI 缓冲先解除挂接再释放，分区合法性由所有 rank 一致检查。量场清理依据各组实际分配状态，避免对称性切换或改变网格后复用旧数组。双 rank 外部 MPI 测试在同一进程内先后初始化 49 层和 53 层 NCSX，验证了映射与线程恢复。 [MPI 映射](../SIESTA-lyh/Sources/nscalingtools.f90) · [量场清理](../SIESTA-lyh/Sources/quantities.f90) 自动资源识别当前读取可见 CPU 和 cgroup v2 根路径 `cpu.max`；未覆盖 cgroup v1 及所有祖先配额。MPI rank 数由启动器决定。用户仍应按调度器分配绑定 CPU；这里不宣称完整求解加速或最优资源选择。

### 测试和诊断工具

- **运行计时与 MPI 统计**。每个运行上下文重置累计计时器及 Fourier 所用的阶段标志。状态更新时间只计一次，跨 rank 最大耗时使用实际测量值，Hessian 非对称性最小值使用最小值归约。双 rank 计时探针验证了清零与极值。 [计时器](../SIESTA-lyh/Sources/timer_mod.f90) · [MPI 统计](../SIESTA-lyh/Sources/nscalingtools.f90) · [状态更新](../SIESTA-lyh/Sources/siesta_state.f90) profiling 栈配对错误或找不到标签时通过已有 MPI-aware 断言失败，避免字符 STOP 返回成功。对实际模块调用 profstart(outer)/profend(wrong)，退出码由 0 修正为 1。
- **Hessian 非对称性与分布式缩放统计**。非对称性指标按完整矩阵的 `‖A−Aᵀ‖F/‖A‖F` 定义，同时计算每对上、下非对角块的贡献。串行、ScaLAPACK 和块循环实现统一修正；制造矩阵 `[[1,3],[1,2]]` 的结果由 `0.5163977795` 恢复为 `sqrt(8/15)=0.7302967433`。零矩阵统一返回未定义指标标记 `−1`，避免除零。ScaLAPACK Hessian 的双元素极值归约包含 `maxeigen`：双 rank 的旧值 `2/20` 统一为 `20/20`；该统计量不作为已验证的谱上界。列缩放数组先读后写，接口改为 `INTENT(INOUT)`，消除读取入口未定义值的 Fortran 契约问题。非单位缩放累乘测试通过，旧 GNU 构建在该测试中也碰巧给出正确数值。[check3d.f90](../SIESTA-lyh/Sources/check3d.f90) · [块循环实现](../SIESTA-lyh/Sources/blocktridiagonalsolver_s.f90) · [Hessian](../SIESTA-lyh/Sources/hessian.f90)

- **回归算例与产物依赖**。CTest fixtures 要求 VMEC 和 SIESTA 的产物生成测试成功后才运行比较器。MPI 套件显式注册 1、2 rank，保留同一目录内先比较再覆盖产物的顺序。预置旧重启后故意使 SIESTA 初始化失败，压力比较被 CTest 标为 `Not Run`。[测试公共配置](../SIESTA-lyh/Testing/CMakeLists.txt) · [初始化](../SIESTA-lyh/Testing/tests/siesta_init_test/CMakeLists.txt) · [非对称](../SIESTA-lyh/Testing/tests/siesta_lasym_test/CMakeLists.txt) · [终态](../SIESTA-lyh/Testing/tests/siesta_final_test/CMakeLists.txt) · [稀疏](../SIESTA-lyh/Testing/tests/siesta_sparse_test/CMakeLists.txt) · [MPI](../SIESTA-lyh/Testing/tests/siesta_mpi_test/CMakeLists.txt) 15 项实际执行磁场比较、却命名为 `jksup*` 的检查改名为 `jbsup*_secondary_test`；比较对象、采样与容差保持原值。这些检查不能用作电流回归证据。把命令直接换成电流后超差，也不足以认定求解器有 bug，因为初始化的表示投影、离散微分及后续理想迭代都可能改变这个对照，原磁场容差从未被验证为电流容差。共振定位单元测试失败时使用非零停止码，避免字符 `STOP` 被 GNU Fortran 记为成功。 100 层标准算例最多使用 8 个 MPI rank，避免主机的默认进程数超出小网格的径向分区能力。专用 MPI 对照按显式的 1、2 rank 运行。
- **回归工具的半网格径向导数**。全网格第 $i$ 点使用两侧半网格的 $[q_{i+1}-q_i]/h$，修正原差分错位一个径向点并读取轴端无效槽的问题。新增 CTest 用 3、9、65 点网格上的二次剖面验证内部导数，轴端槽特意设为 NaN。这个修复作用于结果比较器中的径向导数与磁场散度重构。[grid_quantity.cpp](../SIESTA-lyh/Testing/test_utilities/grid_quantity.cpp) · [制造解回归](../SIESTA-lyh/Testing/test_utilities/siesta_test.cpp) · [注册配置](../SIESTA-lyh/Testing/test_utilities/CMakeLists.txt)
- **回归比较器的输入校验与错误报告**。一维比较器在 `failed at s =` 后输出实际采样坐标。读取 NetCDF 时检查文件、变量、形状和读取状态，比较时拒绝非有限值和默认填充值。两个精确零值的相对误差记为零。未知测试名、缺失参数和缺失数据以非零状态退出，保留有效算例原有采样和容差。实测覆盖上述三种错误以及零电流相对比较。[比较器](../SIESTA-lyh/Testing/test_utilities/siesta_test.cpp) · [命令行解析](../SIESTA-lyh/Testing/test_utilities/commandline_parser.hpp) · [解析入口](../SIESTA-lyh/Testing/test_utilities/commandline_parser.cpp) · [NetCDF 读取](../SIESTA-lyh/Testing/test_utilities/grid_quantity.hpp) · [SIESTA 字段](../SIESTA-lyh/Testing/test_utilities/siesta_quantities.hpp) · [VMEC 字段](../SIESTA-lyh/Testing/test_utilities/vmec_quantities.hpp) 非 dump 比较要求 `-tol` 有限且为正；径向采样必须满足 `0≤-min≤-max≤1`，显式提供的角度必须有限。在 `[2,3]` 采样时，旧插值器将两份数据都截在端点，可能错误报告通过；现在在读取数据前拒绝越界采样。原有有效测试的采样规则和容差不变。

## 编译与运行

在已配置依赖的 Stellarator-Tools 构建中，将 SIESTA 子项目指向 `SIESTA-lyh/`。

需要 CMake 3.19 或更新版本。CMake 从关联的 LIBSTELL 源目标生成 GMRES 和 NetCDF 字符串读取的兼容副本，在构建目录编译这两份副本，原依赖源码无需手工编辑。WOUT 字符串按文件长度和接收缓冲区长度的较小值读取并补空格。已验证的 LIBSTELL 基线为 `cacea89`。无法识别的依赖实现会在配置阶段报告。 [依赖兼容构建](../SIESTA-lyh/Sources/CMakeLists.txt)

```sh
cmake -S /path/to/Stellarator-Tools -B /path/to/build \
  -DBUILD_SIESTA=ON -DCMAKE_BUILD_TYPE=Release -DSIESTA_ENABLE_OPENMP=ON \
  -DFETCHCONTENT_SOURCE_DIR_SIESTA=/absolute/path/SIESTA-websites/Source-Code/SIESTA-lyh
cmake --build /path/to/build --target xsiesta -j 8
```

该路径必须指向修改版源码。审计构建固定依赖版本并停用框架的自动 pull/checkout；替换源码后应清理旧对象重新编译，以免保留的文件时间戳导致旧对象被复用。

从算例目录启动。`xsiesta` 无参数时读取 `siesta.jcf`，`xsiesta case` 读取 `siesta_case.jcf`。相对路径以工作目录为准。`WOUT_FILE` 指向已有 VMEC 输出，文件名使用 `wout_*.nc`。下面命令使用一个 MPI rank 和一个线程。[W7-X 输入、输出与运行说明](../../SIESTA-lyh-example/W7X/README.md)

```sh
cd /path/to/case
OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 OPENBLAS_DEFAULT_NUM_THREADS=1 \
MKL_NUM_THREADS=1 mpirun -np 1 /path/to/build/_deps/siesta-build/xsiesta
```

`OMP_THREADS` 是 `&SIESTA_INFO` 中的非负整数。正值优先指定团队规模。默认 `0` 优先采用 `OMP_NUM_THREADS`，否则按进程可见资源自动选择，最多 4 线程。兼容环境变量 `SIESTA_CPU_THREADS` 可在自动分支中提供候选值，仍受 4 线程上限约束。实际团队受资源限制和 `OMP_THREAD_LIMIT` 约束，小型 Fourier 调用可以使用更少线程。MPI rank 数和核绑定由启动命令或调度器指定。[线程配置实现](../SIESTA-lyh/Sources/siesta_run.f90) · [Open MPI 绑核说明](https://docs.open-mpi.org/en/main/man-openmpi/man1/mpirun.1.html)

<a name="verification"></a>

## 验证范围

本节保留有明确输入、预期结果和通过判据的定向检查。多步演化中的力残差、压力剖面和迭代接受率随初态、物理模型和离散设置共同变化，用于分析算例表现。

- **离散算子与求解器**。在给定位移下，将线性化和非线性力算子及压力扰动分别与基线对照，覆盖对称与非对称场、不同 MPI rank 和 OpenMP 线程。制造测试检查 Fourier 正逆变换、半网格导数、GMRES 精确零残差，以及两种块求解后端对混号对角元的处理。
- **理想步与扩散保护**。用制造反例核对压力不合格时的拒绝路径、零位移返回，以及返回位移与重算残差的一致性。强制触发扩散保护时，核对拒绝后的减半重试与直接使用减半系数的结果，以及全部试探失败后的状态回滚。
- **初始化与重启**。用 `NITER=1` 检查首次位移前的 WOUT 压力读入与网格映射，并检查固定边界 λ 重算。自由边界初始化以实际离散安培方程的回代残差验收，另用受限求解预算核对拒绝路径。重启测试核对场谱、压力、磁通和残差读回，并用已知剖面及模式表检验径向重采样与跨 NFP 谐波映射。
- **输入输出与并行入口**。检查非法网格、缺失文件和字段、非有限值以及空 MPI 输出分区。用成对运行核对输出开关对已保存状态的影响，并检查调用方 MPI 生命周期和 OpenMP 设置恢复。当前验证覆盖 Release、带运行时检查的 Debug 和关闭 OpenMP 的构建。
- **数值库对照**。在同一 49 阶制造矩阵上比较 OpenBLAS `DGETRF` 的分解与求解误差。对 AutoDL OpenBLAS 0.3.20，Cooperlake 内核曾在 `INFO=0` 时返回错误分解。Haswell 内核和独立 Netlib 对照的最大解误差均不超过 `3.33×10⁻¹⁶`。

[单元测试](../SIESTA-lyh/Testing/test_utilities/siesta_unit_tests.f) · [初始化测试](../SIESTA-lyh/Testing/tests/siesta_init_test/CMakeLists.txt) · [测试配置](../SIESTA-lyh/Testing/CMakeLists.txt)
