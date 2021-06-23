function [img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc, rdc_res_part, rb_loop_reuse] = get_rdc32_np(x, y, img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_deep_layer, rdc_ind, rdc_deep_layer_res_part, rb_loop_reuse_deep_layer)
    PU = 32; %4 8 16 32 64
    mask_mat = [1111, 0111, 1011, 1101, 1110];
    for i = 1:5
        mask{i} = mask_mat(i);
        pred_range{i} = get_pred_range(PU, mask{i});
    end

    % loop 部分
    reuse_part = nan;
    for i = 1:5
        [prederr_blk_loop_m{i}, pred_blk_loop_m{i}, mode_blk_loop_m{i}, reuse_part] = mode_select_loop_np(img_src, img_rebuild, x, y, PU, mask{i}, reuse_part, rb_loop_reuse_deep_layer);
        % img_rebuild_temp_loop = prederr_blk_loop + pred_blk_loop;
        mode_frame_temp_loop_m{i} = fill_blk_np(mode_frame, x, y, PU, mode_blk_loop_m{i}, pred_range{i});
        loop_flag_frame_loop_m{i} = fill_blk_np(loop_flag_frame, x, y, PU, 1, pred_range{i});
        mode_bits_loop = cal_loop_mode_bits_np(mode_blk_loop_m{i}, mode_frame_temp_loop_m{i}, x, y, mask{i});
        [rdc_curr_temp_loop_m(i), rdc_res_part_temp_loop_m(i)] = cal_rdc_np(prederr_blk_loop_m{i}, mode_bits_loop, pred_range{i}, rdc_deep_layer, rdc_ind, mask{i}, rdc_deep_layer_res_part);
    end
    [rdc_curr_temp_loop, mask_loop_ind] = min(rdc_curr_temp_loop_m);
    mode_frame_temp_loop = mode_frame_temp_loop_m{mask_loop_ind};
    loop_flag_frame_loop = loop_flag_frame_loop_m{mask_loop_ind};
    pred_range_rdo_loop = pred_range{mask_loop_ind};
    rdc_res_part_loop = rdc_res_part_temp_loop_m(mask_loop_ind);
    % 新分块方法下，分块信息记录有些不同
    % e.g. 新分块方法下，在分块信息记录中用 9 填充一个 16*16 块的 L 形区域，表示该区域属于 16*16 的范围，剩下的 1/4 保留底层分块模式
    if mask_loop_ind ~= 1
        split_fill_loop = PU / 2 + 1;
    else
        split_fill_loop = PU;
    end
    % loop 部分

    % blk 部分
    [pred_all35, pred_target] = mode_select_blk_np_step1(img_src, img_rebuild, x, y, PU);
    for i = 1:5
        [prederr_blk_m{i}, pred_blk_m{i}, ~, mode_blk_m{i}] = mode_select_blk_np_step2(pred_all35, pred_target, pred_range{i});
        % img_rebuild_temp_blk = prederr_blk + pred_blk;
        mode_frame_temp_blk_m{i} = fill_blk_np(mode_frame, x, y, PU, mode_blk_m{i}, pred_range{i});
        loop_flag_frame_blk_m{i} = fill_blk_np(loop_flag_frame, x, y, PU, 0, pred_range{i});
        mode_bits = get_mode_bits_blk_np(0, mode_frame_temp_blk_m{i}, x, y, mask{i}, PU);
        [rdc_curr_temp_blk_m(i), rdc_res_part_temp_blk_m(i)] = cal_rdc_np(prederr_blk_m{i}, mode_bits, pred_range{i}, rdc_deep_layer, rdc_ind, mask{i}, rdc_deep_layer_res_part);
    end
    [rdc_curr_temp_blk, mask_blk_ind] = min(rdc_curr_temp_blk_m);
    mode_frame_temp_blk = mode_frame_temp_blk_m{mask_blk_ind};
    loop_flag_frame_blk = loop_flag_frame_blk_m{mask_blk_ind};
    pred_range_rdo_blk = pred_range{mask_blk_ind};
    rdc_res_part_blk = rdc_res_part_temp_blk_m(mask_blk_ind);
    if mask_blk_ind ~= 1
        split_fill_blk = PU / 2 + 1;
    else
        split_fill_blk = PU;
    end
    % blk 部分

    rdc_deep = sum(rdc_deep_layer(rdc_ind * 4 - 3:rdc_ind * 4));
    if (min(rdc_curr_temp_blk, rdc_curr_temp_loop) <= rdc_deep)
        if (rdc_curr_temp_loop <= rdc_curr_temp_blk)
            rdc = rdc_curr_temp_loop;
            mode_frame = mode_frame_temp_loop;
            loop_flag_frame = loop_flag_frame_loop;
            split_frame = fill_blk_np(split_frame, x, y, PU, split_fill_loop, pred_range_rdo_loop);
            rdc_res_part = rdc_res_part_loop;
        else
            rdc = rdc_curr_temp_blk;
            mode_frame = mode_frame_temp_blk;
            loop_flag_frame = loop_flag_frame_blk;
            split_frame = fill_blk_np(split_frame, x, y, PU, split_fill_blk, pred_range_rdo_blk);
            rdc_res_part = rdc_res_part_blk;
        end
    else
        rdc = rdc_deep;
        rdc_res_part = sum(rdc_deep_layer_res_part(rdc_ind * 4 - 3:rdc_ind * 4));
        % mode_frame 保持不变
        % split_frame 保持不变
    end
    %assert(all(img_rebuild_temp_blk == img_rebuild_temp_loop, [1, 2]))
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = img_rebuild_temp_blk;
    rb_loop_reuse.prederr_blk_loop = prederr_blk_loop_m{1};
    rb_loop_reuse.pred_blk_loop = pred_blk_loop_m{1};
    rb_loop_reuse.mode_blk_loop = mode_blk_loop_m{1};
end
