function mode_bits = get_ctu_mode_bits_np(mode_frame, split_frame, loop_flag_frame, x, y, max_size)
    mode_bits = 0;

    mark = zeros(max_size, max_size);
    loop_flag = loop_flag_frame(x:x + max_size - 1, y:y + max_size - 1);
    mode = mode_frame(x:x + max_size -1, y:y + max_size - 1);
    split = split_frame(x:x + max_size - 1, y:y + max_size - 1);

    [z_ind_x_mat, z_ind_y_mat, z_size_mat, ~] = gen_z_mat();
    z_ind_x_mat = z_ind_x_mat(end:-1:1) + 1;
    z_ind_y_mat = z_ind_y_mat(end:-1:1) + 1;
    z_size_mat = z_size_mat(end:-1:1);

    mask_mat = [1111, 0111, 1011, 1101, 1110];

    n = 1;
    while ~(all(all(isnan(mark))))
        if (isnan(mark(z_ind_x_mat(n), z_ind_y_mat(n))))
            n = n + 1;
            continue;
        end
        PU = z_size_mat(n);
        split_sub = split(z_ind_x_mat(n):z_ind_x_mat(n) + PU - 1, z_ind_y_mat(n):z_ind_y_mat(n) + PU - 1);
        loop_flag_sub = loop_flag(z_ind_x_mat(n):z_ind_x_mat(n) + PU - 1, z_ind_y_mat(n):z_ind_y_mat(n) + PU - 1);
        mode_sub = mode(z_ind_x_mat(n):z_ind_x_mat(n) + PU - 1, z_ind_y_mat(n):z_ind_y_mat(n) + PU - 1);
        mark_sub = zeros(PU, PU);
        for i = 1:5
            pred_range = get_pred_range(PU, mask_mat(i));
            if (all(split_sub(pred_range) == PU) || all(split_sub(pred_range) == PU / 2 + 1))
                mark_sub(pred_range) = nan;
                mark(z_ind_x_mat(n):z_ind_x_mat(n) + PU - 1, z_ind_y_mat(n):z_ind_y_mat(n) + PU - 1) = mark_sub;
                if (loop_flag_sub(pred_range(1)) == 1)
                    if (PU == 4)
                        mode_bits = mode_bits + cal_loop_mode_bits_np(mode_sub, mode_frame, z_ind_x_mat(n) + x - 1, z_ind_y_mat(n) + y - 1, 1111);
                    else
                        mode_bits = mode_bits + cal_loop_mode_bits_np(mode_sub, mode_frame, z_ind_x_mat(n) + x - 1, z_ind_y_mat(n) + y - 1, mask_mat(i));
                    end
                else
                    if (PU == 4)
                        mode_bits = mode_bits + get_mode_bits_blk_np(0, mode_frame, z_ind_x_mat(n) + x - 1, z_ind_y_mat(n) + y - 1, 1111, PU);
                    else
                        mode_bits = mode_bits + get_mode_bits_blk_np(0, mode_frame, z_ind_x_mat(n) + x - 1, z_ind_y_mat(n) + y - 1, mask_mat(i), PU);
                    end
                end
                break;
            end
        end

        n = n + 1;
    end
end
