function tree_size = get_tree_size_np_blk(split_frame, i, j, max_size)
    [h, w] = size(split_frame);
    type = summary_type(zeros(h, w), split_frame, i, j, max_size);

    tree_size = (type.NxN + type.blk_1111 + type.blk_0111 + type.blk_1011 + type.blk_1101 + type.blk_1110) * 3;
end
