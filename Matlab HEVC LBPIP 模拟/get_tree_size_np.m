function [tree_size, type_cnt] = get_tree_size_np(loop_flag_frame, split_frame, i, j, max_size)
    type = summary_type(loop_flag_frame, split_frame, i, j, max_size);

    type_cnt = [type.blk_1111, type.blk_0111, type.blk_1011, type.blk_1101, type.blk_1110, type.loop_1111, type.loop_0111, type.loop_1011, type.loop_1101, type.loop_1110, type.NxN, type.blk_4x4, type.loop_4x4];

    tree_size = sum(type_cnt(1:11)) * 4 + sum(type_cnt(12:13));

end
