% 返回 Planar 模式预测值
function Intra_Planar = Planar_Model(PU, PX, PY)

    % Intra Planar Prediction
    % Inputs :
    %   PU = Prediction Unit Size
    %   PX = Left Neighboring Pixels
    %   PY = Top  Neighboring Pixels

    % Output:
    %   Intra_Planar : Planar Predicted Output PU

    tr = PY(PU + 2);
    bl = PX(PU + 2);
    for i = 1:PU
        for j = 1:PU
            w_t = PU - 1 - (i - 1);
            w_bl = PU - w_t;
            w_l = PU - 1 - (j - 1);
            w_tr = PU - w_l;
            Intra_Planar(i, j) = round((w_t * PY(j + 1) + w_bl * bl + w_l * PX(i + 1) + w_tr * tr) / 2 / PU);
        end
    end

    % for i = 0:PU - 1
    %     for j = 0:PU - 1

    %         Intra_Planar(i + 1, j + 1) = uint8(((PU - 1 - i) * PY(j + 2) + (i + 1) * PX(PU) + (PU - 1 - j) * PX(i + 2) + (j + 1) * PY(PU) + PU) / (2^(log2(PU) + 1)));

    %     end
    % end
    % Intra_Planar = double(Intra_Planar);

end
