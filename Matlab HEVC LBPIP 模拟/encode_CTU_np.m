% 应用新分块方法 编码单个 CTU
function [CTU_bits, CTU_split_tree_bits, type_cnt, img_rebuild, split_frame, mode_frame, loop_flag_frame] = encode_CTU_np(CTU, img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame)

    [z_ind_x_mat, z_ind_y_mat, z_size_mat, rdc_ind_mat] = gen_z_mat();

    rdc_4 = nan(1, 256);
    rdc_8 = nan(1, 64);
    rdc_16 = nan(1, 16);
    rdc_32 = nan(1, 4);
    rdc_64 = nan;
    for i = 1:341
        x = z_ind_x_mat(i) + CTU.x;
        y = z_ind_y_mat(i) + CTU.y;
        rdc_ind = rdc_ind_mat(i);
        switch z_size_mat(i)
            case 4
                [img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_4(rdc_ind), rdc_4_res_part(rdc_ind), rb_loop_reuse_4] = get_rdc4_np(x, y, img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame);

            case 8
                [img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_8(rdc_ind), rdc_8_res_part(rdc_ind), rb_loop_reuse_8] = get_rdc8_np(x, y, img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_4, rdc_ind, rdc_4_res_part, rb_loop_reuse_4);

            case 16
                [img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_16(rdc_ind), rdc_16_res_part(rdc_ind), rb_loop_reuse_16] = get_rdc16_np(x, y, img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_8, rdc_ind, rdc_8_res_part, rb_loop_reuse_8);

            case 32
                [img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_32(rdc_ind), rdc_32_res_part(rdc_ind), rb_loop_reuse_32] = get_rdc32_np(x, y, img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_16, rdc_ind, rdc_16_res_part, rb_loop_reuse_16);

            case 64
                [img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_64(rdc_ind), rdc_64_res_part(rdc_ind)] = get_rdc64_np(x, y, img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame, rdc_32, rdc_ind, rdc_32_res_part, rb_loop_reuse_32);

        end
    end

    % 计算分块信息所需 bits, 包含了每个块使用块状/环状，外部不用另计该部分信息
    [CTU_split_tree_bits, type_cnt] = get_tree_size_np(loop_flag_frame, split_frame, CTU.x, CTU.y, 64);
    % new_mode_bits = get_ctu_mode_bits_np_backup(mode_frame, split_frame, loop_flag_frame, 64, CTU.x, CTU.y, 3);
    new_mode_bits = get_ctu_mode_bits_np(mode_frame, split_frame, loop_flag_frame, CTU.x, CTU.y, 64);
    CTU_bits = rdc_64_res_part + CTU_split_tree_bits + new_mode_bits;
end
