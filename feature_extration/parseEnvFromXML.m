function [hour, timestamp] = parseEnvFromXML(xmlPath)
    hour = NaN; timestamp = NaN;
    try
        txt = fileread(xmlPath);
        token = regexp(txt, 'EnvironmentInitialization dateTime="[^"]+\s+(\d+):(\d+):(\d+)"', 'tokens');
        if ~isempty(token)
            hh = str2double(token{1}{1}); mm = str2double(token{1}{2});
            hour = hh + mm/60.0;
        end
    catch
    end
end