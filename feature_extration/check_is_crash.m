function isCrash = check_is_crash(val)
    isCrash = 0;
    if iscell(val) || isstring(val)
        strVal = strip(string(val));
        if strcmpi(strVal, 'TRUE'), isCrash = 1; end
    elseif iscategorical(val)
        if val == 'TRUE', isCrash = 1; end
    elseif isnumeric(val) || islogical(val)
        if val > 0, isCrash = 1; end
    end
end