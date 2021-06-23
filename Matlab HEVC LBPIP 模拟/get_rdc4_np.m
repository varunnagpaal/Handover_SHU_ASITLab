% 应用新分块方法编码一个 4x4 块
% 新分块方法在 4x4 层没有体现
% 环状做到 3x3
function [img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc, rdc_res_part, rb_loop_reuse] = get_rdc4_np(x, y, img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame)
    PU = 4; %4 8 16 32 64

    % loop 部分
    [prederr_blk_loop, pred_blk_loop, mode_blk_loop] = mode_select_loop_loop23(img_src, img_rebuild, x, y, PU);
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = prederr_blk_loop + pred_blk_loop;
    img_rebuild_temp_loop = prederr_blk_loop + pred_blk_loop;
    mode_frame_temp_loop = fill_blk(mode_frame, x, y, PU, mode_blk_loop);
    loop_flag_frame_loop = fill_blk(loop_flag_frame, x, y, PU, 1);
    mode_bits_loop = cal_loop_mode_bits_loop23(mode_blk_loop, mode_frame_temp_loop, x, y);
    [rdc_curr_temp_loop, res_part_loop] = cal_rdc_np(prederr_blk_loop, mode_bits_loop, 1:PU^2, 0, 0, 1111);
    % loop 部分
    % blk 部分
    [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(img_src, img_rebuild, x, y, PU);
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = prederr_blk + pred_blk;
    img_rebuild_temp_blk = prederr_blk + pred_blk;
    mode_frame_temp_blk = fill_blk(mode_frame, x, y, PU, mode_blk);
    loop_flag_frame_blk = fill_blk(loop_flag_frame, x, y, PU, 0);
    mode_bits = get_mode_bits_blk_np(0, mode_frame_temp_blk, x, y, 1111, PU);
    [rdc_curr_temp_blk, res_part_blk] = cal_rdc_np(prederr_blk, mode_bits, 1:PU^2, 0, 0, 1111);
    % blk 部分

    if (rdc_curr_temp_loop <= rdc_curr_temp_blk)
        rdc = rdc_curr_temp_loop;
        mode_frame = mode_frame_temp_loop;
        loop_flag_frame = loop_flag_frame_loop;
        rdc_res_part = res_part_loop;
    else
        rdc = rdc_curr_temp_blk;
        mode_frame = mode_frame_temp_blk;
        loop_flag_frame = loop_flag_frame_blk;
        rdc_res_part = res_part_blk;
    end

    split_frame(x:x + PU - 1, y:y + PU - 1) = PU;
    %assert(all(img_rebuild_temp_blk == img_rebuild_temp_loop, [1, 2]))
    img_rebuild(x:x + PU - 1, y:y + PU - 1) = img_rebuild_temp_blk;

    rb_loop_reuse.prederr_blk_loop = prederr_blk_loop;
    rb_loop_reuse.pred_blk_loop = pred_blk_loop;
    rb_loop_reuse.mode_blk_loop = mode_blk_loop;
end
