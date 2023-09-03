module utils
using DataFrames
using MLBase
using MLDataUtils

function data_split(df::Union{DataFrame,Matrix}, split_rate=0.7)

    train_idx, test_idx = splitobs(shuffleobs(1:nrow(df)), at=split_rate) # 70% 训练，30% 测试

    # 获取训练和测试数据
    train_data = df[train_idx, :]
    test_data = df[test_idx, :]

    # 分别获取模式（pattern）和目标（target）
    train_pattern = train_data[:, 1:end-1]
    train_target = train_data[:, end]

    test_pattern = test_data[:, 1:end-1]
    test_target = test_data[:, end]

    return train_pattern, train_target, test_pattern, test_target

end
end