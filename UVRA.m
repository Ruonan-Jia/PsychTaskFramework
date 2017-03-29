function [ Data ] = UVRA(subjectId)
% UVRA Task script for a monetary R&A task with relaxed test-taking conditions.
%   ("U" stands for "unlimited", "V" for vertical layout of the choices.)
%
% Like all main tasks scripts, this function loads settings, executes requisite
%   blocks, and records data for the subject whose ID is passed as an argument.

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/UVRA'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
settings = UVRA_blockDefaults();
settings = loadPTB(settings);
if ~exist('subjectId', 'var') % Practice
  subjectId = NaN;
  settings = setupPracticeConfig(settings);
end

% Find-or-create subject data file *in appropriate location*
fname = [num2str(subjectId) '.mat'];
folder = fullfile(settings.task.taskPath, 'data');
fname = [folder filesep fname];
[ Data, subjectExisted ] = loadOrCreate(subjectId, fname);

% TODO: Prompt experimenter if this is correct
if subjectExisted
  disp('Subject file exists, reusing...')
elseif ~isnan(subjectId)
  disp('Subject has no file, creating...')
end

if ~isnan(subjectId)
  if mod(subjectId, 2) == 0
    settings.runSetup.refSide = 1;
  else
    settings.runSetup.refSide = 2;
  end
end

%% Generate trials/blocks - if they haven't been generated before
% NOTE: If the number of generated trials changes, settings.task.numBlocks
%   will need to be changed to an integer that divides the generated trial count.
if ~isfield(Data, 'blocks') || isempty(Data.blocks)
  blocks = generateBlocks(settings);
  numBlocks = settings.task.numBlocks;
  Data.numFinishedBlocks = 0;
  for blockIdx = 1:numBlocks
    Data = addGeneratedBlock(Data, blocks{blockIdx}, settings);
  end
end

%% Display blocks
% Select which blocks to run
if ~isnan(subjectId)
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForSession(Data);
else
  % Gut the generated blocks to be limited to practice
  % TODO: Set this in settings
  practiceBlocks = 1;
  numSelect = 3;
  Data = preparePractice(Data, practiceBlocks, numSelect);
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForPractice(practiceBlocks);
end

for blockIdx = firstBlockIdx:lastBlockIdx
  Data = runNthBlock(Data, blockIdx);
end

unloadPTB(settings);
end
