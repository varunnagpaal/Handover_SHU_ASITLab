% 应用新分块方法 编码单个 CTU
function [CTU_bits, img_rebuild, split_frame, mode_frame] = encode_CTU_np_blk(CTU, img_src, img_rebuild, split_frame, mode_frame)

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
                [img_rebuild, split_frame, mode_frame, rdc_4(rdc_ind), rdc_4_res_part(rdc_ind)] = get_rdc4_np_blk(x, y, img_src, img_rebuild, split_frame, mode_frame);

            case 8
                [img_rebuild, split_frame, mode_frame, rdc_8(rdc_ind), rdc_8_res_part(rdc_ind)] = get_rdc8_np_blk(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_4, rdc_ind, rdc_4_res_part);

            case 16
                [img_rebuild, split_frame, mode_frame, rdc_16(rdc_ind), rdc_16_res_part(rdc_ind)] = get_rdc16_np_blk(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_8, rdc_ind, rdc_8_res_part);

            case 32
                [img_rebuild, split_frame, mode_frame, rdc_32(rdc_ind), rdc_32_res_part(rdc_ind)] = get_rdc32_np_blk(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_16, rdc_ind, rdc_16_res_part);

            case 64
                [img_rebuild, split_frame, mode_frame, rdc_64(rdc_ind), rdc_64_res_part(rdc_ind)] = get_rdc64_np_blk(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_32, rdc_ind, rdc_32_res_part);

        end
    end

    % 计算分块信息所需 bits, 外部不用另计该部分信息
    CTU_split_tree_bits = get_tree_size_np_blk(split_frame, CTU.x, CTU.y, 64);
    new_mode_bits = get_ctu_mode_bits_np(mode_frame, split_frame, zeros(1600, 2560), CTU.x, CTU.y, 64);
    CTU_bits = rdc_64_res_part + CTU_split_tree_bits + new_mode_bits;

end
