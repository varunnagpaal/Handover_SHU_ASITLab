% Ӧ���·ֿ鷽�� + ��״Ԥ�⣨��״���� 3x3���Ĳ������
% �·ֿ鷽������������ʱ������ 1/4 �ײ����ķֿ鷽��
% 1111: �������ײ���
% 0111: �������Ͻǵײ���
% 1011: �������Ͻ�
% 1101: �������½�
% 1110: ���½�
function [size_all, blk_size_sum, split_frame, mode_frame, loop_flag_frame_np, CTU_bits, CTU_split_tree_bits, type_cnt] = encode_main_np(srcy)
    initGlobals(100);

    [CTU, img_src] = split_CTU(srcy);
    [h, w] = size(srcy);
    img_rebuild = nan(h + 64, w + 64);
    split_frame = nan(h, w);
    mode_frame = nan(h, w);
    loop_flag_frame_np = nan(h, w);

    % for i = 1:numel(CTU)
    for i = 1:3
        i
        [CTU_bits(i), CTU_split_tree_bits(i), type_cnt{i}, img_rebuild, split_frame, mode_frame, loop_flag_frame_np] = encode_CTU_np(CTU(i), img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame_np);
    end

    [size_all, blk_size_sum] = summary(CTU_bits, split_frame, mode_frame);
end
