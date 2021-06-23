% ����ʱ�ֱ����һ���� ��״��ʽ �� ��״��ʽ �� rdcost������
% ��״��ʽһֱ���� 4x4
% 4x4 ��̶��ÿ�״��ʽ
function [size_all, blk_size_sum, split_frame, mode_frame, CTU_bits] = encode_main_comb_loop24(srcy)
    initGlobals(100);

    [CTU, img_src] = split_CTU(srcy);
    [h, w] = size(srcy);
    img_rebuild = nan(h + 64, w + 64);
    split_frame = nan(h, w);
    mode_frame = nan(h, w);

    for i = 1:numel(CTU)
        % for i = 1:2
        i
        [CTU_bits(i), img_rebuild, split_frame, mode_frame] = encode_CTU_comb(CTU(i), img_src, img_rebuild, split_frame, mode_frame);
    end

    [size_all, blk_size_sum] = summary(CTU_bits, split_frame, mode_frame);
    % �÷�������Ҫ 1bit/�� ��¼��ǰ���õ��ǿ�״���ǻ�״ ��4x4 ����⣩
    size_all = size_all + sum(blk_size_sum(2:end));
end
