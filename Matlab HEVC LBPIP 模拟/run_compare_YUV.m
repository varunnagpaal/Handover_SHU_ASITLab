load('./YUV.mat');
log_forcompareYUV = YUV;
filecnt = length(log_forcompareYUV);

% for f = 3:3
% parfor f = [8:15]
% parfor f = 1:filecnt - 2
for f = [12]
    % 192 * 384  Y做2*6个 UV做1*3个
    % parfor f = 19:22
    tic

    srcy = YUV(f).Ydata;
    srcu = YUV(f).Udata;
    srcv = YUV(f).Vdata;

    [size_all_by, blk_size_sum_by, split_frame_by, mode_frame_by, CTU_bits_all_by] = encode_main_blk_lforcom(srcy);
    [size_all_bu, blk_size_sum_bu, split_frame_bu, mode_frame_bu, CTU_bits_all_bu] = encode_main_blk_cforcom(srcu);
    [size_all_bv, blk_size_sum_bv, split_frame_bv, mode_frame_bv, CTU_bits_all_bv] = encode_main_blk_cforcom(srcv);
    % [size_all_c_loop21, blk_size_sum_c_loop21, split_frame_c_loop21, mode_frame_c_loop21, CTU_bits_all_c_loop21] = encode_main_comb_loop21(srcy);
    % [size_all_c_loop22, blk_size_sum_c_loop22, split_frame_c_loop22, mode_frame_c_loop22, CTU_bits_all_c_loop22] = encode_main_comb_loop22(srcy);
    % [size_all_c_loop23, blk_size_sum_c_loop23, split_frame_c_loop23, mode_frame_c_loop23, CTU_bits_all_c_loop23] = encode_main_comb_loop23(srcy);
    % [size_all_c_loop24, blk_size_sum_c_loop24, split_frame_c_loop24, mode_frame_c_loop24, CTU_bits_all_c_loop24] = encode_main_comb_loop24(srcy);
    [size_all_npy, blk_size_sum_npy, split_frame_npy, mode_frame_npy, loop_flag_frame_npy, CTU_bits_all_npy, CTU_split_tree_bits_npy, type_cnt_npy] = encode_main_np_lforcom(srcy);
    [size_all_npu, blk_size_sum_npu, split_frame_npu, mode_frame_npu, loop_flag_frame_npu, CTU_bits_all_npu, CTU_split_tree_bits_npu, type_cnt_npu] = encode_main_np_cforcom(srcu);
    [size_all_npv, blk_size_sum_npv, split_frame_npv, mode_frame_npv, loop_flag_frame_npv, CTU_bits_all_npv, CTU_split_tree_bits_npv, type_cnt_npv] = encode_main_np_cforcom(srcv);
    % [size_all_np_b, blk_size_sum_np_b, split_frame_np_b, mode_frame_np_b, CTU_bits_all_np_b] = encode_main_np_blk(srcy);

    log_forcompareYUV(f).size_blocky = size_all_by;
    log_forcompareYUV(f).size_blocku = size_all_bu;
    log_forcompareYUV(f).size_blockv = size_all_bv;
    % log_forcompareYUV(f).size_comb_loop21 = size_all_c_loop21;
    % log_forcompareYUV(f).size_comb_loop22 = size_all_c_loop22;
    % log_forcompareYUV(f).size_comb_loop23 = size_all_c_loop23;
    % log_forcompareYUV(f).size_comb_loop24 = size_all_c_loop24;
    log_forcompareYUV(f).size_npy = size_all_npy;
    log_forcompareYUV(f).size_npu = size_all_npu;
    log_forcompareYUV(f).size_npv = size_all_npv;
    % log_forcompareYUV(f).size_np_blk = size_all_np_b;

    log_forcompareYUV(f).partition_blocky = blk_size_sum_by;
    log_forcompareYUV(f).partition_blocku = blk_size_sum_bu;
    log_forcompareYUV(f).partition_blockv = blk_size_sum_bv;
    % log_forcompareYUV(f).prtition_comb_loop21 = blk_size_sum_c_loop21;
    % log_forcompareYUV(f).prtition_comb_loop22 = blk_size_sum_c_loop22;
    % log_forcompareYUV(f).prtition_comb_loop23 = blk_size_sum_c_loop23;
    % log_forcompareYUV(f).prtition_comb_loop24 = blk_size_sum_c_loop24;
    log_forcompareYUV(f).prtition_npy = blk_size_sum_npy;
    log_forcompareYUV(f).prtition_npu = blk_size_sum_npu;
    log_forcompareYUV(f).prtition_npv = blk_size_sum_npv;
    % log_forcompareYUV(f).prtition_np_blk = blk_size_sum_np_b;

    log_forcompareYUV(f).split_frame_blocky = split_frame_by;
    log_forcompareYUV(f).split_frame_blocku = split_frame_bu;
    log_forcompareYUV(f).split_frame_blockv = split_frame_bv;
    % log_forcompareYUV(f).split_frame_comb_loop21 = split_frame_c_loop21;
    % log_forcompareYUV(f).split_frame_comb_loop22 = split_frame_c_loop22;
    % log_forcompareYUV(f).split_frame_comb_loop23 = split_frame_c_loop23;
    % log_forcompareYUV(f).split_frame_comb_loop24 = split_frame_c_loop24;
    log_forcompareYUV(f).split_frame_npy = split_frame_npy;
    log_forcompareYUV(f).split_frame_npu = split_frame_npu;
    log_forcompareYUV(f).split_frame_npv = split_frame_npv;
    % log_forcompareYUV(f).split_frame_np_blk = split_frame_np_b;

    log_forcompareYUV(f).mode_frame_blocky = mode_frame_by;
    log_forcompareYUV(f).mode_frame_blocku = mode_frame_bu;
    log_forcompareYUV(f).mode_frame_blockv = mode_frame_bv;
    % log_forcompareYUV(f).mode_frame_comb_loop21 = mode_frame_c_loop21;
    % log_forcompareYUV(f).mode_frame_comb_loop22 = mode_frame_c_loop22;
    % log_forcompareYUV(f).mode_frame_comb_loop23 = mode_frame_c_loop23;
    % log_forcompareYUV(f).mode_frame_comb_loop24 = mode_frame_c_loop24;
    log_forcompareYUV(f).mode_frame_npy = mode_frame_npy;
    log_forcompareYUV(f).mode_frame_npu = mode_frame_npu;
    log_forcompareYUV(f).mode_frame_npv = mode_frame_npv;
    % log_forcompareYUV(f).mode_frame_np_blk = mode_frame_np_b;

    log_forcompareYUV(f).CTU_bits_blocky = CTU_bits_all_by;
    log_forcompareYUV(f).CTU_bits_blocku = CTU_bits_all_bu;
    log_forcompareYUV(f).CTU_bits_blockv = CTU_bits_all_bv;
    % log_forcompareYUV(f).CTU_bits_comb_loop21 = CTU_bits_all_c_loop21;
    % log_forcompareYUV(f).CTU_bits_comb_loop22 = CTU_bits_all_c_loop22;
    % log_forcompareYUV(f).CTU_bits_comb_loop23 = CTU_bits_all_c_loop23;
    % log_forcompareYUV(f).CTU_bits_comb_loop24 = CTU_bits_all_c_loop24;
    log_forcompareYUV(f).CTU_bits_npy = CTU_bits_all_npy;
    log_forcompareYUV(f).CTU_bits_npu = CTU_bits_all_npu;
    log_forcompareYUV(f).CTU_bits_npv = CTU_bits_all_npv;
    % log_forcompareYUV(f).CTU_bits_np_blk = CTU_bits_all_np_b;

    % log_forcompareYUV(f).loop_flag_frame_np = loop_flag_frame_np;
    % log_forcompareYUV(f).CTU_split_tree_bits_np = CTU_split_tree_bits_np;
    % log_forcompareYUV(f).type_cnt_np = type_cnt_np;

    f
    toc

end

save('./alllog_forcompareYUV.mat', 'log_forcompareYUV');
