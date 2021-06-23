% 顺序：
% type.blk_1111 = 0;
% type.blk_0111 = 0;
% type.blk_1011 = 0;
% type.blk_1101 = 0;
% type.blk_1110 = 0;
% type.loop_1111 = 0;
% type.loop_0111 = 0;
% type.loop_1011 = 0;
% type.loop_1101 = 0;
% type.loop_1110 = 0;
% type.NxN = 0;
% type.blk_4x4 = 0;
% type.loop_4x4 = 0;

type_cnt_all = 0;
for i = 1:25
    if ~isempty(log(i).type_cnt_np)
        L = numel(log(i).type_cnt_np);
        for n = 1:L
            type_cnt_all = type_cnt_all + log(i).type_cnt_np{n};
        end
    end
end

cnt_1_22 = [20197, 16205, 19549, 19874, 22911, 11448, 8384, 14947, 16288, 23266, 148819];
cnt_4x4 = [284073, 135138];
% 挑出4个频率最高的，类似MPM。统计得分块信息能变 87.4%，少 12.6%

for i = 1:25
    if ~isempty(log(i).type_cnt_np)
        % L = numel(log(i).type_cnt_np);
        pic_i_tree_size_src(i) = sum(log(i).CTU_split_tree_bits_np);
        pic_i_tree_size_opt(i) = round(pic_i_tree_size_src(i) * 0.874);
        log(i).size_np_tree_size_opt = log(i).size_np - pic_i_tree_size_src(i) + pic_i_tree_size_opt(i);
    end
end

[dict, avglen] = huffmandict(1:11, cnt_1_22 / sum(cnt_1_22));
new_size_all = round(avglen * sum(cnt_1_22)) + sum(cnt_4x4);
src_size_all = sum(cnt_1_22) * 4 + sum(cnt_4x4);
huff_per = new_size_all / src_size_all;

% 用 huffman 编码分块信息，得分块信息压缩到 76.83%
for i = 1:25
    if ~isempty(log(i).type_cnt_np)
        % L = numel(log(i).type_cnt_np);
        pic_i_tree_size_src(i) = sum(log(i).CTU_split_tree_bits_np);
        pic_i_tree_size_huff_opt(i) = round(pic_i_tree_size_src(i) * huff_per);
        log(i).size_np_tree_size_huff_opt = log(i).size_np - pic_i_tree_size_src(i) + pic_i_tree_size_huff_opt(i);
    end
end
