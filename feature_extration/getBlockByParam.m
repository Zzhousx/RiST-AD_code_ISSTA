function block = getBlockByParam(fullText, paramStr)
    block = '';
    idxParam = strfind(fullText, paramStr);
    if isempty(idxParam), return; end
    beforeText = fullText(1:idxParam(1));
    idxStart = strfind(beforeText, '<ObjectInitialization');
    if isempty(idxStart), return; end
    startPos = idxStart(end);
    afterText = fullText(startPos:end);
    idxEnd = strfind(afterText, '</ObjectInitialization>');
    if isempty(idxEnd), return; end
    block = afterText(1:idxEnd(1));
end