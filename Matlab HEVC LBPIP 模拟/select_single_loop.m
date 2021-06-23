% 使用 35 种预测方式预测一个环形区域，得到
% 预测残差
% 预测值
% SAE
% 模式
function [prederr, pred, sae, mode] = select_single_loop(Seq, Seq_r, i, j, k, PU)
    dst = Seq(i:i + PU - 1, j:j + PU - 1);
    [dst_1d] = get_dst_k_loop(dst, k, PU);
    [PX, PY] = get_px_py(Seq_r, i, j, k, PU);
    % Intra DC Prediction
    [pred_dc] = DC_Model_loop(k, PX, PY);
    % Intra Planar Prediction
    [pred_pl] = Planar_Model_loop(k, PX, PY);
    % Intra Angular Prediction
    [pred_ang] = Intra_Angular_Model_loop(PY, PX, k);
    pred_pixels{1} = pred_dc;
    pred_pixels{2} = pred_pl;
    pred_pixels{3} = pred_ang{1};
    pred_pixels{4} = pred_ang{2};
    pred_pixels{5} = pred_ang{3};
    pred_pixels{6} = pred_ang{4};
    pred_pixels{7} = pred_ang{5};
    pred_pixels{8} = pred_ang{6};
    pred_pixels{9} = pred_ang{7};
    pred_pixels{10} = pred_ang{8};
    pred_pixels{11} = pred_ang{9};
    pred_pixels{12} = pred_ang{10};
    pred_pixels{13} = pred_ang{11};
    pred_pixels{14} = pred_ang{12};
    pred_pixels{15} = pred_ang{13};
    pred_pixels{16} = pred_ang{14};
    pred_pixels{17} = pred_ang{15};
    pred_pixels{18} = pred_ang{16};
    pred_pixels{19} = pred_ang{17};
    pred_pixels{20} = pred_ang{18};
    pred_pixels{21} = pred_ang{19};
    pred_pixels{22} = pred_ang{20};
    pred_pixels{23} = pred_ang{21};
    pred_pixels{24} = pred_ang{22};
    pred_pixels{25} = pred_ang{23};
    pred_pixels{26} = pred_ang{24};
    pred_pixels{27} = pred_ang{25};
    pred_pixels{28} = pred_ang{26};
    pred_pixels{29} = pred_ang{27};
    pred_pixels{30} = pred_ang{28};
    pred_pixels{31} = pred_ang{29};
    pred_pixels{32} = pred_ang{30};
    pred_pixels{33} = pred_ang{31};
    pred_pixels{34} = pred_ang{32};
    pred_pixels{35} = pred_ang{33};
    for m = 1:35
        prederr_all{m} = dst_1d - pred_pixels{m};
        sae_all(m) = sum(abs(prederr_all{m}));
    end
    [sae, mode] = min(sae_all);
    prederr = prederr_all{mode};
    pred = pred_pixels{mode};
end
