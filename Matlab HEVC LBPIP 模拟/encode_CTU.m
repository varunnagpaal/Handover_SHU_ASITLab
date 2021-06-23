% ±àÂëµ¥¸ö CTU
function [CTU_bits, img_rebuild, split_frame, mode_frame] = encode_CTU(CTU, img_src, img_rebuild, split_frame, mode_frame)

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
                [img_rebuild, split_frame, mode_frame, rdc_4(rdc_ind)] = get_rdc4(x, y, img_src, img_rebuild, split_frame, mode_frame);

            case 8
                [img_rebuild, split_frame, mode_frame, rdc_8(rdc_ind)] = get_rdc8(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_4, rdc_ind);

            case 16
                [img_rebuild, split_frame, mode_frame, rdc_16(rdc_ind)] = get_rdc16(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_8, rdc_ind);

            case 32
                [img_rebuild, split_frame, mode_frame, rdc_32(rdc_ind)] = get_rdc32(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_16, rdc_ind);

            case 64
                [img_rebuild, split_frame, mode_frame, rdc_64(rdc_ind)] = get_rdc64(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_32, rdc_ind);
        end
    end

    CTU_split_tree_bits = getbitlength(split_frame(CTU.x:CTU.x + 63, CTU.y:CTU.y + 63));
    CTU_bits = rdc_64 + CTU_split_tree_bits;

end
