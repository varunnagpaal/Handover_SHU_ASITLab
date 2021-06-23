% 新分块方法下，根据模式，提取出需要在当前层预测的点的索引值
% 按 ↓↓↓ 的方式排序（TODO: 是否合理？）
function pred_range = get_pred_range(PU, mask)
    all_range_1d = 1:PU^2;
    switch mask
        case 1111
            pred_range = all_range_1d;
        case 0111
            all_range = reshape(1:PU^2, PU, PU);
            lb_ind = all_range(PU / 2 + 1:PU, 1:PU / 2);
            r_ind = all_range(1:PU, PU / 2 + 1:PU);
            pred_range = all_range_1d([lb_ind(:); r_ind(:)]);
        case 1011
            all_range = reshape(1:PU^2, PU, PU);
            l_ind = all_range(1:PU, 1:PU / 2);
            rb_ind = all_range(PU / 2 + 1:PU, PU / 2 + 1:PU);
            pred_range = all_range_1d([l_ind(:); rb_ind(:)]);
        case 1101
            all_range = reshape(1:PU^2, PU, PU);
            lt_ind = all_range(1:PU / 2, 1:PU / 2);
            r_ind = all_range(1:PU, PU / 2 + 1:PU);
            pred_range = all_range_1d([lt_ind(:); r_ind(:)]);
        case 1110
            all_range = reshape(1:PU^2, PU, PU);
            l_ind = all_range(1:PU, 1:PU / 2);
            rt_ind = all_range(1:PU / 2, PU / 2 + 1:PU);
            pred_range = all_range_1d([l_ind(:); rt_ind(:)]);
    end
    % pred_range = pred_range(:);
end
