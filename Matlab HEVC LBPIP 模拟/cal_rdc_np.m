% 新分块方法下，当前层的 rdcost 可能会涉及到底层的 rdcost
% e.g. 0111 模式下，当前层的 rdcost = 左上角处底层的 rdcost + 剩下 3/4 区域残差编码体积 + 当前层模式信息体积
function [rdc, res_part_bits] = cal_rdc_np(res, mode_bits, pred_range, rdc_deep_layer, rdc_ind, mask, rdc_deep_layer_res_part)
    res_order = res(pred_range);
    res_bits = huffman_testsize(res_order);

    switch mask
        case 1111
            rdc_deep_layer_m = 0;
            rdc_deep_layer_res_part_m = 0;
        case 0111
            rdc_deep_layer_m = rdc_deep_layer(rdc_ind * 4 - 3 + 0);
            rdc_deep_layer_res_part_m = rdc_deep_layer_res_part(rdc_ind * 4 - 3 + 0);

        case 1011
            rdc_deep_layer_m = rdc_deep_layer(rdc_ind * 4 - 3 + 1);
            rdc_deep_layer_res_part_m = rdc_deep_layer_res_part(rdc_ind * 4 - 3 + 1);

        case 1101
            rdc_deep_layer_m = rdc_deep_layer(rdc_ind * 4 - 3 + 2);
            rdc_deep_layer_res_part_m = rdc_deep_layer_res_part(rdc_ind * 4 - 3 + 2);

        case 1110
            rdc_deep_layer_m = rdc_deep_layer(rdc_ind * 4 - 3 + 3);
            rdc_deep_layer_res_part_m = rdc_deep_layer_res_part(rdc_ind * 4 - 3 + 3);
    end

    res_part_bits = res_bits + rdc_deep_layer_res_part_m;
    rdc = res_bits + mode_bits + rdc_deep_layer_m;
end
