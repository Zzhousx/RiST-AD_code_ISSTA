# Artifact for ISSTA 2026 Submission

This artifact provides the MATLAB implementation for our ISSTA 2026 submission. The code allows for the full replication of the experimental results presented in the paper, including the performance of our proposed framework and all baseline methods.
The core contributions of this artifact are:
- The source code for the proposed algorithm.
- Implementations of all baseline algorithms described in the paper.
- Scripts to process the DeepScenario dataset, run the experiments.

## Requirements
- MATLAB (R2021b or newer recommended)
- Statistics and Machine Learning Toolbox

## Project Structure
- "deepscenario-dataset/": Place raw dataset files here.
- "feature_extration/": Scripts for feature embedding and processing.
- "experiment/": Configuration files for experimental settings.
- "results/": Output folder for generated figures.
- "statistical_analysis/": Scripts for A12 effect size and other statistical tests.
- "main.m": This script orchestrates the entire experimental pipeline from feature extraction to result generation (Main entry point).
- "run_baseline_euclidean_fps.m": Script to execute the FPS baseline.
- "run_baseline_greedy_risk.m": Script to execute the Greedy baseline.
- "run_baseline_mab_adaptive_ea.m": Script to execute the MAB-EA baseline.
- "...": Other helper ".m" files for specific calculations.

## Usage
1. Clone this repository.
2. Download the "DeepScenario" dataset.
3. Unzip the data into the "deepscenario-dataset/" folder. 
4. Run "main.m"
