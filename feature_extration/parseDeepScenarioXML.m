function feats = parseDeepScenarioXML(xmlPath)
    feats = zeros(1, 12);
    try
        txt = fileread(xmlPath);
        egoBlock = getObjectBlock(txt, 'Ego0');
        if isempty(egoBlock), egoBlock = getBlockByParam(txt, 'ObjectType="Ego"'); end
        [egoPos, egoVel] = extractMotion(egoBlock);
        
        npcBlock = getObjectBlock(txt, 'NPC0');
        if isempty(npcBlock)
            npcBlock = getBlockByParam(txt, 'ObjectType="NPC"');
            if isempty(npcBlock)
                allStarts = strfind(txt, '<ObjectInitialization');
                allEnds = strfind(txt, '</ObjectInitialization>');
                if length(allStarts) >= 2, npcBlock = txt(allStarts(2):allEnds(2)); end
            end
        end
        [npcPos, npcVel] = extractMotion(npcBlock);
        feats = [egoPos, egoVel, npcPos, npcVel];
    catch
    end
end