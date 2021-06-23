function [PX, PY] = fill_PXPY_nan(PX, PY)
    if (all(isnan([PX(:); PY(:)])))
        PX = 128;
        PY = 128;
        return
    end

    ref_2 = [PY(end:-1:1), PX(2:end)'];

    PY(isnan(PY)) = ref_2(find(~isnan(ref_2), 1));

    ref_1 = [PX(end:-1:2)', PY];
    PX(isnan(PX)) = ref_1(find(~isnan(ref_1), 1));
end
