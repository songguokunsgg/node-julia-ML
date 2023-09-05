module Logistic # 修改为更符合Julia约定的模块名

using DataFrames, MLJ
using StatsModels
using MLJLinearModels
using Logging  # 用于日志记录
using CategoricalArrays
using Random
using JSON
include("../utils.jl")

export logistic_run  # 导出这两个函数以便在模块外部使用

"""
使用逻辑回归模型进行分类，并计算准确度和平均绝对误差。

参数：
- `train`：训练数据集
- `test`：测试数据集

返回：
- `classification_accuracy`：分类准确度
- `mean_absolute_error`：平均绝对误差

在`MultinomialClassifier`模型中，各个参数具有特定的作用，通常涉及正则化、优化求解等。这里是一些关键参数的解释：

1. **lambda（λ）**：这是正则化项的强度。正则化是用来防止模型过拟合的一种技术。更高的λ值会导致更强的正则化，可能导致模型欠拟合。更低的λ值则可能导致模型过拟合。通常，λ的值需要通过交叉验证来选择。

2. **gamma（γ）**：这是另一个与正则化相关的参数。在一些正则化方案中，例如弹性网正则化，λ和γ同时用于混合L1和L2惩罚。

3. **penalty**：指定使用哪种类型的正则化。`l1`、`l2`和`elasticnet`（如果支持）是常见的选项。L1正则化导致稀疏模型，而L2正则化则不会。

4. **fit_intercept**：是否应该拟合截距项。如果你的数据已经中心化，或者你出于其他原因不希望拟合截距，可以设置为`false`。

5. **penalize_intercept**：是否应在正则化过程中对截距项进行惩罚。通常，不惩罚截距可能是一个好主意，因为这样可以保证模型更容易解释。

6. **scale_penalty_with_samples**：是否应该将正则化惩罚与样本数量成比例地进行缩放。这在处理不平衡类别时可能是有用的。

7. **solver**：用于优化问题的求解器。这通常是一些数值算法，如梯度下降、坐标下降等。不同的求解器有不同的优缺点，并可能在某些问题上表现得更好。

了解这些参数能帮助你更好地调整模型以适应你的特定问题。参数的最优值通常需要通过交叉验证或其他模型选择技术来确定。在一些情况下，使用默认值可能就已经足够好，但在复杂或不平衡的问题上，调整这些参数可能会大有裨益。
"""
function logistic_run(df; ratio=0.7, json_data=Dict())

    if json_data == Dict()
        return -1, -1
    end

    lambda = parse(Float64, json_data["lambda"])
    gamma = parse(Float64, json_data["gamma"])
    penalty = json_data["penalty"]
    fit_intercept = json_data["fit_intercept"]
    penalize_intercept = json_data["penalize_intercept"]
    scale_penalty_with_samples = json_data["scale_penalty_with_samples"]

    # csv文件是否存在 header 行
    isFirstRowHeader = json_data["isFirstRowHeader"]

    @info "Executing logistic algorithm"
    train, test = utils.data_split(df, ratio)
    CA, MAE = logistic(train, test,
        lambda=lambda,
        gamma=gamma,
        penalty=penalty,
        fit_intercept=fit_intercept,
        penalize_intercept=penalize_intercept,
        scale_penalty_with_samples=scale_penalty_with_samples,
        solver=nothing)
    return CA, MAE

end

function logistic(train, test;
    lambda=2.220446049250313e-16, gamma=0.0, penalty=:l2,
    fit_intercept=true, penalize_intercept=false,
    scale_penalty_with_samples=true, solver=nothing)

    # 准备训练和测试数据
    train_features = MLJ.table(Matrix(train[:, 1:end-1]))
    test_features = MLJ.table(Matrix(test[:, 1:end-1]))

    # 加载模型并初始化
    @load MultinomialClassifier pkg = "MLJLinearModels" verbosity = 0
    model = MultinomialClassifier(
        lambda=lambda,
        gamma=gamma,
        penalty=penalty,
        fit_intercept=fit_intercept,
        penalize_intercept=penalize_intercept,
        scale_penalty_with_samples=scale_penalty_with_samples,
        solver=solver)

    # 准备目标变量
    train_target = CategoricalArray(train[:, end])

    # 创建并训练机器
    mach = machine(model, train_features, train_target)
    fit!(mach)

    # 进行预测
    predicted_probabilities = predict(mach, test_features)
    predicted_labels = mode.(predicted_probabilities)

    # 计算评估指标
    classification_accuracy = sum(predicted_labels .== test[:, end]) / length(predicted_labels)
    mean_absolute_error = sum(abs.(predicted_labels.refs .- test[:, end])) / length(predicted_labels)

    return classification_accuracy, mean_absolute_error
end

end  # 结束模块