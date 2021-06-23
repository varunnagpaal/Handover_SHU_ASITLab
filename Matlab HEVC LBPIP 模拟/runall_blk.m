% 测试脚本入口
% 编码所有测试序列第一帧的亮度分量

load('./Luma_sort.mat');
log = Luma_sort;
filecnt = length(log);

% for f = 3:3
% parfor f = [8:15]
parfor f = 1:filecnt
    % parfor f = 1:filecnt - 2
    % for f = 1:1
    % for f = [22]
    tic

    srcy = Luma_sort(f).Ydata;

    [size_all_b, blk_size_sum_b, split_frame_b, mode_frame_b, CTU_bits_all_b] = encode_main_blk(srcy);
    % [size_all_c_loop21, blk_size_sum_c_loop21, split_frame_c_loop21, mode_frame_c_loop21, CTU_bits_all_c_loop21] = encode_main_comb_loop21(srcy);
    % [size_all_c_loop22, blk_size_sum_c_loop22, split_frame_c_loop22, mode_frame_c_loop22, CTU_bits_all_c_loop22] = encode_main_comb_loop22(srcy);
    % [size_all_c_loop23, blk_size_sum_c_loop23, split_frame_c_loop23, mode_frame_c_loop23, CTU_bits_all_c_loop23] = encode_main_comb_loop23(srcy);
    % [size_all_c_loop24, blk_size_sum_c_loop24, split_frame_c_loop24, mode_frame_c_loop24, CTU_bits_all_c_loop24] = encode_main_comb_loop24(srcy);
    % [size_all_np, blk_size_sum_np, split_frame_np, mode_frame_np, CTU_bits_all_np] = encode_main_np(srcy);
    % [size_all_np_b, blk_size_sum_np_b, split_frame_np_b, mode_frame_np_b, CTU_bits_all_np_b] = encode_main_np_blk(srcy);

    log(f).size_block = size_all_b;
    % log(f).size_comb_loop21 = size_all_c_loop21;
    % log(f).size_comb_loop22 = size_all_c_loop22;
    % log(f).size_comb_loop23 = size_all_c_loop23;
    % log(f).size_comb_loop24 = size_all_c_loop24;
    % log(f).size_np = size_all_np;
    % log(f).size_np_blk = size_all_np_b;

    log(f).partition_block = blk_size_sum_b;
    % log(f).prtition_comb_loop21 = blk_size_sum_c_loop21;
    % log(f).prtition_comb_loop22 = blk_size_sum_c_loop22;
    % log(f).prtition_comb_loop23 = blk_size_sum_c_loop23;
    % log(f).prtition_comb_loop24 = blk_size_sum_c_loop24;
    % log(f).prtition_np = blk_size_sum_np;
    % log(f).prtition_np_blk = blk_size_sum_np_b;

    log(f).split_frame_block = split_frame_b;
    % log(f).split_frame_comb_loop21 = split_frame_c_loop21;
    % log(f).split_frame_comb_loop22 = split_frame_c_loop22;
    % log(f).split_frame_comb_loop23 = split_frame_c_loop23;
    % log(f).split_frame_comb_loop24 = split_frame_c_loop24;
    % log(f).split_frame_np = split_frame_np;
    % log(f).split_frame_np_blk = split_frame_np_b;

    log(f).mode_frame_block = mode_frame_b;
    % log(f).mode_frame_comb_loop21 = mode_frame_c_loop21;
    % log(f).mode_frame_comb_loop22 = mode_frame_c_loop22;
    % log(f).mode_frame_comb_loop23 = mode_frame_c_loop23;
    % log(f).mode_frame_comb_loop24 = mode_frame_c_loop24;
    % log(f).mode_frame_np = mode_frame_np;
    % log(f).mode_frame_np_blk = mode_frame_np_b;

    log(f).CTU_bits_block = CTU_bits_all_b;
    % log(f).CTU_bits_comb_loop21 = CTU_bits_all_c_loop21;
    % log(f).CTU_bits_comb_loop22 = CTU_bits_all_c_loop22;
    % log(f).CTU_bits_comb_loop23 = CTU_bits_all_c_loop23;
    % log(f).CTU_bits_comb_loop24 = CTU_bits_all_c_loop24;
    % log(f).CTU_bits_np = CTU_bits_all_np;
    % log(f).CTU_bits_np_blk = CTU_bits_all_np_b;

    f
    toc

end

save('./allLOG_blk.mat', 'log');
