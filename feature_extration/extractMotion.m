function [pos, vel] = extractMotion(blockText)
    pos = [0, 0, 0]; vel = [0, 0, 0];
    if isempty(blockText), return; end
    tokensPos = regexp(blockText, 'ObjectInitialPosition\s+positionX="([^"]+)"\s+positionY="([^"]+)"\s+positionZ="([^"]+)"', 'tokens');
    if ~isempty(tokensPos)
        pos = [str2double(tokensPos{1}{1}), str2double(tokensPos{1}{2}), str2double(tokensPos{1}{3})];
    end
    tokensVel = regexp(blockText, 'ObjectInitialVelocity\s+velocityX="([^"]+)"\s+velocityY="([^"]+)"\s+velocityZ="([^"]+)"', 'tokens');
    if ~isempty(tokensVel)
        vel = [str2double(tokensVel{1}{1}), str2double(tokensVel{1}{2}), str2double(tokensVel{1}{3})];
    end
end