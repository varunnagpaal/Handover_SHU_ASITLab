% 新分块方法下，块状预测一个块
% step2: 根据不同的保留方式，确定最优预测模式及结果
function [prederr, pred, sae, mode] = mode_select_blk_np_step2(pred_pixels, dst, pred_range)
    for m = 1:35
        prederr_all{m} = dst - pred_pixels{m};

        prederr_for_cal_sae = prederr_all{m};
        % 并不是所有的预测点都参与 SAE 计算
        sae_all(m) = sum(abs(prederr_for_cal_sae(pred_range)));
    end
    [sae, mode] = min(sae_all);
    prederr = prederr_all{mode};
    pred = pred_pixels{mode};
end
