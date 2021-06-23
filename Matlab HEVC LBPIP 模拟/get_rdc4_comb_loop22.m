function [img_rebuild, split_frame, mode_frame, rdc] = get_rdc4_comb_loop22(x, y, img_src, img_rebuild, split_frame, mode_frame)
    PU = 4; %4 8 16 32 64

    % loop 部分
    [prederr_blk_loop, pred_blk_loop, mode_blk_loop] = mode_select_loop_loop22(img_src, img_rebuild, x, y, PU);
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = prederr_blk_loop + pred_blk_loop;
    img_rebuild_temp_loop = prederr_blk_loop + pred_blk_loop;
    mode_frame_temp_loop = fill_blk(mode_frame, x, y, PU, mode_blk_loop);
    mode_bits_loop = cal_loop_mode_bits_loop22(mode_blk_loop, mode_frame_temp_loop, x, y);
    rdc_curr_temp_loop = cal_rdc(prederr_blk_loop, mode_bits_loop);
    % loop 部分
    % blk 部分
    [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(img_src, img_rebuild, x, y, PU);
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = prederr_blk + pred_blk;
    img_rebuild_temp_blk = prederr_blk + pred_blk;
    mode_frame_temp_blk = fill_blk(mode_frame, x, y, PU, mode_blk);

    mode_bits = get_mode_bits_blk(0, mode_frame_temp_blk, x, y);
    rdc_curr_temp_blk = cal_rdc(prederr_blk, mode_bits);
    % blk 部分

    if (rdc_curr_temp_loop <= rdc_curr_temp_blk)
        rdc = rdc_curr_temp_loop;
        mode_frame = mode_frame_temp_loop;
    else
        rdc = rdc_curr_temp_blk;
        mode_frame = mode_frame_temp_blk;
    end

    split_frame(x:x + PU - 1, y:y + PU - 1) = 4;
    %assert(all(img_rebuild_temp_blk == img_rebuild_temp_loop, [1, 2]))
    img_rebuild(x:x + PU - 1, y:y + PU - 1) = img_rebuild_temp_blk;
end
