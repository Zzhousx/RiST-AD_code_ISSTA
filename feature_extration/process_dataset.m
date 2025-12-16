function deepScenarioData = process_dataset()

    rootPath = 'E:\code_dr\RiST-AD_code_ISSTA\deepscenario-dataset\greedy-strategy';
    dt = 0.5; 
    
    deepScenarioData = struct('BatchID', {}, 'Features', {}, 'Label', {}, 'Duration', {}, 'FeatureNames', {}, 'ScenarioInfo', {});
    structCounter = 1;
    
    featNames = get_feature_names_20();
    fprintf('=== extracting features ===\n');
    rewardDirs = dir(fullfile(rootPath, 'reward-*'));
    rewardDirs = rewardDirs([rewardDirs.isdir]);
    if isempty(rewardDirs)
        error('error: not found reward-*，please check: %s', rootPath);
    end
    for i = 1:length(rewardDirs)
        rewardName = rewardDirs(i).name;
        rewardPath = fullfile(rootPath, rewardName);
        scenarioDirs = dir(fullfile(rewardPath, '*-scenarios'));
        scenarioDirs = scenarioDirs([scenarioDirs.isdir]);
        for j = 1:length(scenarioDirs)
            scenFolderName = scenarioDirs(j).name;
            scenFolderPath = fullfile(rewardPath, scenFolderName);
            is_rain = contains(scenFolderName, 'rain', 'IgnoreCase', true);
            is_night = contains(scenFolderName, 'night', 'IgnoreCase', true);
            fprintf('processing: %s\n', scenFolderName);
            
            % read CSV
            csvFiles = dir(fullfile(scenFolderPath, '*.csv'));
            if isempty(csvFiles), csvFiles = dir(fullfile(scenFolderPath, '*.xls*')); end
            crashBatchIDs = [];
            
            if ~isempty(csvFiles)
                csvPath = fullfile(scenFolderPath, csvFiles(1).name);
                try
                    opts = detectImportOptions(csvPath);
                    opts.VariableNamingRule = 'preserve';
                    tbl = readtable(csvPath, opts);
                    
                    colIdx = find(contains(tbl.Properties.VariableNames, 'Attribute[COL]'));
                    nameColIdx = 1;
                    if ~isempty(colIdx)
                        nameCol = tbl{:, nameColIdx};
                        labelCol = tbl{:, colIdx};
                        for r = 1:height(tbl)
                            if check_is_crash(labelCol(r))
                                v = sscanf(char(string(nameCol(r))), '%d_scenario');
                                if ~isempty(v), crashBatchIDs(end+1) = v(1); end %#ok<AGROW>
                            end
                        end
                        crashBatchIDs = unique(crashBatchIDs);
                    end
                catch
                end
            end
            
            xmlFiles = dir(fullfile(scenFolderPath, '*.deepscenario'));
            batchGroups = containers.Map('KeyType', 'double', 'ValueType', 'any');
            
            for k = 1:length(xmlFiles)
                fname = xmlFiles(k).name;
                tokens = regexp(fname, '^(\d+)_scenario_(\d+)', 'tokens');
                if isempty(tokens), continue; end
                
                bID = str2double(tokens{1}{1});
                sID = str2double(tokens{1}{2});
                
                fileData.Path = fullfile(scenFolderPath, fname);
                fileData.StepID = sID;
                
                if isKey(batchGroups, bID)
                    list = batchGroups(bID);
                    list{end+1} = fileData; %#ok<AGROW>
                    batchGroups(bID) = list;
                else
                    batchGroups(bID) = {fileData};
                end
            end
            
            allBatchIDs = cell2mat(keys(batchGroups));
            allBatchIDs = sort(allBatchIDs);
            localPos = 0;
            
            for b = 1:length(allBatchIDs)
                bID = allBatchIDs(b);
                filesCell = batchGroups(bID); 
                fileList  = [filesCell{:}];   
                [~, sortIdx] = sort([fileList.StepID]);
                sortedFiles = fileList(sortIdx);
                numSteps = length(sortedFiles);
                [simHour, ~] = parseEnvFromXML(sortedFiles(1).Path); 
                rawFeatsMatrix = zeros(numSteps, 12);
                for t = 1:numSteps
                    rawFeatsMatrix(t, :) = parseDeepScenarioXML(sortedFiles(t).Path);
                end
                manifoldFeatures = extract_20dim_features(rawFeatsMatrix, is_rain, is_night, simHour);
                scenarioLabel = 0;
                if ismember(bID, crashBatchIDs)
                    scenarioLabel = 1;
                    localPos = localPos + 1;
                end
                
                deepScenarioData(structCounter).BatchID = bID;
                deepScenarioData(structCounter).Features = manifoldFeatures;
                deepScenarioData(structCounter).Label = scenarioLabel;
                deepScenarioData(structCounter).Duration = numSteps * dt;
                deepScenarioData(structCounter).FeatureNames = featNames;
                
                deepScenarioData(structCounter).ScenarioInfo.Reward = rewardName;
                deepScenarioData(structCounter).ScenarioInfo.Env = scenFolderName;
                
                structCounter = structCounter + 1;
            end
        end
    end
    fprintf('=== finished！Generated %d independent scenario ===\n', length(deepScenarioData));
end


