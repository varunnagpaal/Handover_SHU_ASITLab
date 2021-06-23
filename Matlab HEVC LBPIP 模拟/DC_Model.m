% 返回 DC 模式预测值
function Intra_DC = DC_Model(PU, PX, PY)

    % Intra DC Prediction
    % Inputs:
    %   PU : Prediction Unit Size
    %   PX : Left Neighborinh Pixels
    %   PY : Top  Neighboring Pixels

    % Output:
    %   Intra_DC : DC Predicted Output PU

    % dc_Val = uint8((sum(PY(2:(PU + 1))) + sum(PX(2:(PU + 1))) + 8) / (2^(log2(PU) + 1)));
    dc_Val = round((sum(PY(2:PU + 1)) + sum(PX(2:PU + 1))) / 2 / PU);

    % if(PU < 32)
    %     Intra_DC(1,1) = uint8((PY(2) + PX(2) + 2*dc_Val + 2)/4);
    %     for i=2:PU
    %         Intra_DC(i,1) = uint8((PX(i+1) + 3*dc_Val + 2)/4);
    %         Intra_DC(1,i) = uint8((PY(i+1) + 3*dc_Val + 2)/4);
    %     end
    %     Intra_DC(2:PU,2:PU) = dc_Val;

    % else
    Intra_DC(1:PU, 1:PU) = dc_Val;
end
