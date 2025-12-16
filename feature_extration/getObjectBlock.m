function block = getObjectBlock(fullText, refName)
    block = '';
    pattern = sprintf('ObjectInitialization objectRef="%s"', refName);
    idx = strfind(fullText, pattern);
    if ~isempty(idx)
        sub = fullText(idx(1):end);
        idxEnd = strfind(sub, '</ObjectInitialization>');
        if ~isempty(idxEnd), block = sub(1:idxEnd(1)); end
    end
end