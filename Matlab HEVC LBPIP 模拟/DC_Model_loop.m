% 环状模式下的 DC 预测
% 仅计算正上方和正左方的均值（是否合理？）
% function [TOP, LEFT, TOPLEFT] = DC_Model_loop(PU, PX, PY)
function [pred_1d] = DC_Model_loop(PU, PX, PY)

    % Intra DC Prediction
    % Inputs:
    %   PU : Prediction Unit Size
    %   PX : Left Neighborinh Pixels
    %   PY : Top  Neighboring Pixels

    % Output:
    %   Intra_DC : DC Predicted Output PU
    dc_Val = round((sum(PY(2:PU + 1)) + sum(PX(2:PU + 1))) / 2 / PU);

    if (PU ~= 1)
        TOP = repmat(dc_Val, 1, PU - 1);
        LEFT = TOP';
        TOPLEFT = dc_Val;
        pred_1d = [LEFT(end:-1:1)', TOPLEFT, TOP];
    else
        pred_1d = dc_Val;
    end
end
