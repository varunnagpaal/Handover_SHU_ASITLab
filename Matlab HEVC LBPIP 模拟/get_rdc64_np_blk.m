% 应用新分块方法编码一个 8x8 块
function [img_rebuild, split_frame, mode_frame, rdc, rdc_res_part] = get_rdc64_np_blk(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_deep_layer, rdc_ind, rdc_deep_layer_res_part)
    PU = 64; %4 8 16 32 64
    mask_mat = [1111, 0111, 1011, 1101, 1110];
    for i = 1:5
        mask{i} = mask_mat(i);
        pred_range{i} = get_pred_range(PU, mask{i});
    end

    % blk 部分
    [pred_all35, pred_target] = mode_select_blk_np_step1(img_src, img_rebuild, x, y, PU);
    for i = 1:5
        [prederr_blk_m{i}, pred_blk_m{i}, ~, mode_blk_m{i}] = mode_select_blk_np_step2(pred_all35, pred_target, pred_range{i});
        % img_rebuild_temp_blk = prederr_blk + pred_blk;
        mode_frame_temp_blk_m{i} = fill_blk_np(mode_frame, x, y, PU, mode_blk_m{i}, pred_range{i});
        mode_bits = get_mode_bits_blk_np(0, mode_frame_temp_blk_m{i}, x, y, mask{i}, PU);
        [rdc_curr_temp_blk_m(i), rdc_res_part_temp_blk_m(i)] = cal_rdc_np(prederr_blk_m{i}, mode_bits, pred_range{i}, rdc_deep_layer, rdc_ind, mask{i}, rdc_deep_layer_res_part);
    end
    [rdc_curr_temp_blk, mask_blk_ind] = min(rdc_curr_temp_blk_m);
    mode_frame_temp_blk = mode_frame_temp_blk_m{mask_blk_ind};
    pred_range_rdo_blk = pred_range{mask_blk_ind};
    rdc_res_part_blk = rdc_res_part_temp_blk_m(mask_blk_ind);
    if mask_blk_ind ~= 1
        split_fill_blk = PU / 2 + 1;
    else
        split_fill_blk = PU;
    end
    % blk 部分

    rdc_deep = sum(rdc_deep_layer(rdc_ind * 4 - 3:rdc_ind * 4));
    if (rdc_curr_temp_blk <= rdc_deep)
        rdc = rdc_curr_temp_blk;
        mode_frame = mode_frame_temp_blk;
        split_frame = fill_blk_np(split_frame, x, y, PU, split_fill_blk, pred_range_rdo_blk);
        rdc_res_part = rdc_res_part_blk;
    else
        rdc = rdc_deep;
        rdc_res_part = sum(rdc_deep_layer_res_part(rdc_ind * 4 - 3:rdc_ind * 4));
        % mode_frame 保持不变
        % split_frame 保持不变
    end
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = img_rebuild_temp_blk;
end
