function [mode_diff_sum, mode_dct_sum] = test_mode_dct(loop_flag_frame, split_frame, mode_frame, i, j, max_size)
    mode_diff_sum = zeros(1, 140);
    mode_dct_sum = zeros(1, 140);

    mark = zeros(max_size, max_size);
    loop_flag = loop_flag_frame(i:i + max_size - 1, j:j + max_size - 1);
    split = split_frame(i:i + max_size - 1, j:j + max_size - 1);
    mode_val = mode_frame(i:i + max_size - 1, j:j + max_size - 1);

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
        mode_sub = mode_val(z_ind_x_mat(n):z_ind_x_mat(n) + PU - 1, z_ind_y_mat(n):z_ind_y_mat(n) + PU - 1);
        mode_sub = diag(mode_sub);
        mode_diff = [mode_sub(1); diff(mode_sub)];
        mode_diff_dct = round(dct(mode_diff));
        mark_sub = zeros(PU, PU);

        i = 1;
        pred_range = get_pred_range(PU, mask_mat(i));
        if (all(split_sub(pred_range) == PU) || all(split_sub(pred_range) == PU / 2 + 1))
            mark_sub(pred_range) = nan;
            mark(z_ind_x_mat(n):z_ind_x_mat(n) + PU - 1, z_ind_y_mat(n):z_ind_y_mat(n) + PU - 1) = mark_sub;
            if (loop_flag_sub(pred_range(1)) == 1)
                for j = 1:numel(mode_diff)
                    mode_diff_sum(mode_diff(j) + 70) = mode_diff_sum(mode_diff(j) + 70) + 1;
                    mode_dct_sum(mode_diff_dct(j) + 70) = mode_dct_sum(mode_diff_dct(j) + 70) + 1;
                end
            end
        end

        n = n + 1;
    end
end
