clc; clear; close all;
addpath("E:\code_dr\RiST-AD_code_ISSTA\statistical_analysis")
addpath("E:\code_dr\RiST-AD_code_ISSTA\feature_extration")
addpath("E:\code_dr\RiST-AD_code_ISSTA\RiST-AD_code_ISSTA\feature_extration")
rng('default');  

results_table = table('Size', [0, 3], ... 
                      'VariableTypes', {'double', 'double', 'double'}, ... 
                      'VariableNames', {'alpha', 'tau_number', 'APFDc'}); 

deepScenarioData = process_dataset(); 

apfdc_ours = run_RiST(1);