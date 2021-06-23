function type = summary_type(loop_flag_frame, split_frame, i, j, max_size)
    type.blk_1111 = 0;
    type.blk_0111 = 0;
    type.blk_1011 = 0;
    type.blk_1101 = 0;
    type.blk_1110 = 0;
    type.loop_1111 = 0;
    type.loop_0111 = 0;
    type.loop_1011 = 0;
    type.loop_1101 = 0;
    type.loop_1110 = 0;
    type.NxN = 0;
    type.blk_4x4 = 0;
    type.loop_4x4 = 0;

    mark = zeros(max_size, max_size);
    loop_flag = loop_flag_frame(i:i + max_size - 1, j:j + max_size - 1);
    split = split_frame(i:i + max_size - 1, j:j + max_size - 1);

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
        mark_sub = zeros(PU, PU);
        for i = 1:5
            not_NxN = false;
            pred_range = get_pred_range(PU, mask_mat(i));
            if (all(split_sub(pred_range) == PU) || all(split_sub(pred_range) == PU / 2 + 1))
                not_NxN = true;
                mark_sub(pred_range) = nan;
                mark(z_ind_x_mat(n):z_ind_x_mat(n) + PU - 1, z_ind_y_mat(n):z_ind_y_mat(n) + PU - 1) = mark_sub;
                if (loop_flag_sub(pred_range(1)) == 1)
                    if (PU == 4)
                        type.loop_4x4 = type.loop_4x4 + 1;
                    else
                        switch i
                            case 1
                                type.loop_1111 = type.loop_1111 + 1;
                            case 2
                                type.loop_0111 = type.loop_0111 + 1;
                            case 3
                                type.loop_1011 = type.loop_1011 + 1;
                            case 4
                                type.loop_1101 = type.loop_1101 + 1;
                            case 5
                                type.loop_1110 = type.loop_1110 + 1;
                        end
                    end
                else
                    if (PU == 4)
                        type.blk_4x4 = type.blk_4x4 + 1;
                    else
                        switch i
                            case 1
                                type.blk_1111 = type.blk_1111 + 1;
                            case 2
                                type.blk_0111 = type.blk_0111 + 1;
                            case 3
                                type.blk_1011 = type.blk_1011 + 1;
                            case 4
                                type.blk_1101 = type.blk_1101 + 1;
                            case 5
                                type.blk_1110 = type.blk_1110 + 1;
                        end
                    end
                end
                break;
            end
        end

        if (~not_NxN)
            type.NxN = type.NxN + 1;
        end

        n = n + 1;
    end
end
