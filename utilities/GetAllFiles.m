function fileList = GetAllFiles(dirName,pattern)
  if (nargin < 2)
      pattern = '*';
  end
  dirData = dir(dirName);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  rawFileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  if ~isempty(rawFileList)
    rawFileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       rawFileList,'UniformOutput',false);
  end
  fileList = {};
  for i=1:numel(rawFileList)
    tmpFile = rawFileList{i};
    isFile = exist(tmpFile, 'file') == 2;
    if (isFile && numel(regexpi(tmpFile,regexptranslate('wildcard',pattern))> 0))
        fileList = {fileList{:} tmpFile};
    end
  end
  fileList = fileList';
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; GetAllFiles(nextDir,pattern)];  %# Recursively call getAllFiles
  end

end