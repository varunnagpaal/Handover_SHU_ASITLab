% 新分块方法下，块状预测一个块
% step1: 产生 35 个预测值
function [pred_pixels, dst] = mode_select_blk_np_step1(Seq, Seq_r, i, j, PU)
    dst = Seq(i:i + PU - 1, j:j + PU - 1);
    if (i == 1 || j == 1)
        lt = nan;
    else
        lt = Seq_r(i - 1, j - 1);
    end
    if (j == 1)
        left = nan(2 * PU, 1);
    else
        left = Seq_r(i:i + 2 * PU - 1, j - 1);
    end
    if (i == 1)
        top = nan(1, 2 * PU);
    else
        top = Seq_r(i - 1, j:j + 2 * PU - 1);
    end
    [PX, PY] = fill_ref_nan(left, top, lt, PU);
    % Intra DC Prediction
    Intra_DC = DC_Model(PU, PX, PY);
    % Intra Planar Prediction
    Intra_Planar = Planar_Model(PU, PX, PY);
    % Intra Angular Prediction
    Intra_Angular = Intra_Angular_Model(PY, PX, PU);
    pred_pixels{1} = Intra_DC;
    pred_pixels{2} = Intra_Planar;
    pred_pixels{3} = Intra_Angular{1};
    pred_pixels{4} = Intra_Angular{2};
    pred_pixels{5} = Intra_Angular{3};
    pred_pixels{6} = Intra_Angular{4};
    pred_pixels{7} = Intra_Angular{5};
    pred_pixels{8} = Intra_Angular{6};
    pred_pixels{9} = Intra_Angular{7};
    pred_pixels{10} = Intra_Angular{8};
    pred_pixels{11} = Intra_Angular{9};
    pred_pixels{12} = Intra_Angular{10};
    pred_pixels{13} = Intra_Angular{11};
    pred_pixels{14} = Intra_Angular{12};
    pred_pixels{15} = Intra_Angular{13};
    pred_pixels{16} = Intra_Angular{14};
    pred_pixels{17} = Intra_Angular{15};
    pred_pixels{18} = Intra_Angular{16};
    pred_pixels{19} = Intra_Angular{17};
    pred_pixels{20} = Intra_Angular{18};
    pred_pixels{21} = Intra_Angular{19};
    pred_pixels{22} = Intra_Angular{20};
    pred_pixels{23} = Intra_Angular{21};
    pred_pixels{24} = Intra_Angular{22};
    pred_pixels{25} = Intra_Angular{23};
    pred_pixels{26} = Intra_Angular{24};
    pred_pixels{27} = Intra_Angular{25};
    pred_pixels{28} = Intra_Angular{26};
    pred_pixels{29} = Intra_Angular{27};
    pred_pixels{30} = Intra_Angular{28};
    pred_pixels{31} = Intra_Angular{29};
    pred_pixels{32} = Intra_Angular{30};
    pred_pixels{33} = Intra_Angular{31};
    pred_pixels{34} = Intra_Angular{32};
    pred_pixels{35} = Intra_Angular{33};
end
