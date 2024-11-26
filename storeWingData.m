function wingData = storeWingData(mainpath,wingRootStress,wingSparCurvature)
%Header Calling the Required Files for Use
mainpath = 'studentsWingLoadsResults.zip';
wingCoeffInput = 'wingSparCoefficients.xlsx';
wingRootStress =  bendingStressCalculation('studentsWingLoadsResults.zip','wingSparCoefficients.xlsx');
wingSparCurvature = calculateCurvature('studentsWingLoadsResults.zip','wingSparCoefficients.xlsx',bendingStressCalculation('studentsWingLoadsResults.zip','wingSparCoefficients.xlsx'));
extractFolder = 'studentsWingLoadsResults';
unzip(mainpath, extractFolder); 

%Getting Subfolders within the Extracted File
items = dir(extractFolder)
subfolder = items([items.isdir] & ~ismember({items.name}, {'.', '..'})); 
subFolders = subfolder([subfolder.isdir]);
 %Subfolder with a single Dot

% Initialize arrays to hold data
filePatharray = {};
studentNumbersArray = [];
Marray = [];
Iarray = [];
BendingStressarray = [];
numericalDataarray = [];
Marray =[];
BendingStressarray = [];
Karray = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Reading I and Bendingstress from wingRootstress structure
MomentOfInertia = wingRootStress.MomentofInertia;
Marray = [Marray MomentOfInertia];
bendingStress = wingRootStress.bendingStress;
BendingStressarray =[BendingStressarray bendingStress];

%Reading Curvature From a Curvature struct array
Curvature = wingSparCurvature.Curvature;
Karray = [Karray Curvature];
shearForcearray  = [];
resultantForcearray = [];
resultantForceLocationarray = [];
rootShearForcearray = [];
rootBendingMomentsarray  = [];

% Loop through each inner folder
for i = 1:length(subFolders)
    subfolderPath = fullfile(extractFolder, subFolders(i).name);  % Fixed full path

    % Get a list of all inner folders within the subfolder
    innerItems = dir(subfolderPath);
    innerFolders = innerItems([innerItems.isdir] & ~ismember({innerItems.name}, {'.', '..'}));

    % Loop through each inner folder
    for j = 1:length(innerFolders)
        innerFolderPath = fullfile(subfolderPath, innerFolders(j).name);
        
        % Get a list of all Excel files in the inner folder
        %excelFilesInFolder = dir(fullfile(innerFolderPath, '*bendingMoments.xls*'));
        %Get a list of all Excel files in the inner folder
        excelFilesInFolder = dir(fullfile(innerFolderPath, '*wingLoads.xlsx*'));
        shearforcefiles = dir(fullfile(innerFolderPath, '*shearForces.xlsx*'));
        bendingMomentsfiles = dir(fullfile(innerFolderPath, '*bendingMoments.xlsx*'));

        
        % Process each Excel File
          for j = 1:length(excelFilesInFolder)
            filePath = fullfile(innerFolderPath, excelFilesInFolder(j).name);
            shearfilePath = fullfile(innerFolderPath, shearforcefiles(j).name);
            bendingMoments = fullfile(innerFolderPath, bendingMomentsfiles(j).name);
            %filePatharray = [filePatharray; filePath]; % Store file paths as column array
            
            %Read The Excel File in shearForces
            data = readcell(filePath);
            shearForces =readcell(shearfilePath);
            shearForcearray = [shearForcearray; shearForces]; %%%Take all the contents of shear force array
    
    
            %Storing Resultant Forces
            resultantForce = data(2,2);
            resultantForce =cell2mat(resultantForce); % convert cell to matrix for calculations
            resultantForcearray=[resultantForcearray resultantForce];
    
            %Storing Resultant Force Location
            resultantForceLocation = data(3,2);
            resultantForceLocation = cell2mat(resultantForceLocation); %converting values from cell to matrix
            resultantForceLocationarray = [resultantForceLocationarray resultantForceLocation];
    
            %Storing rootshearForce 
            rootShearForce = data(4,2);
            rootShearForce = cell2mat(rootShearForce);
            rootShearForcearray =[rootShearForcearray rootShearForce];
    
            %storing roootBendingMoment 
            rootBendingMoments =data(5,2);
            rootBendingMoments = cell2mat(rootBendingMoments);
            rootBendingMomentsarray =[rootBendingMomentsarray rootBendingMoments];
         end
    end
end

% Reading Wing Span Coefficients
    wingCoeff = readtable(wingCoeffInput);
    wingCoeff = table2array(wingCoeff);
    key = length(wingCoeff);
    studentNumberarray =[];
for s=1:length(wingCoeff)
    studentNumber = wingCoeff(s,1);
    studentNumberarray =[studentNumberarray; studentNumber];
   
end

% After Collecting Shear
% Ensure you calculate the maximum length from shearForcearray
shearForcearray = shearForcearray(:,2); %trying to make the shearForce array a scalar

%%%%Possible problem the code cant tell that the shearForce contains all shearForces
maxlength = max(cellfun(@length, shearForcearray));

% Create the horizontal array based on the maximum length
shearForcearrayHorizontal = zeros(length(shearForcearray), maxlength); 

% Fill the horizontal array with shear forces
for k = 1:length(shearForcearray)
    currentLength = length(shearForcearray{k});
    shearForcearrayHorizontal(k, 1:currentLength) = shearForcearray{k};
end

Marray =[];
BendingStressarray = [];
Karray = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Reading I and Bendingstress from wingRootstress structure
MomentOfInertia = wingRootStress.MomentofInertia;
Marray = [Marray MomentOfInertia];
bendingStress = wingRootStress.bendingStress;
BendingStressarray =[BendingStressarray bendingStress];

%Reading Curvature From a Curvature struct array
Curvature = wingSparCurvature.Curvature;
Karray = [Karray Curvature];

%Creeating a Three layer Structure Array

%Initialize the main structure array
wingData = struct();

%Loop through each student number to populate the structure
for c = 1:length(studentNumberarray)
    studentNumber = studentNumberarray(c);
    
    %Converting student numbers to string so they can used for Names in the
    %array
    studentNumberStr = sprintf('Student_%d', studentNumber); % Create a valid field name

    %Initialize The student Structure
    wingData.(studentNumberStr) = struct();
    
    %Forces And Moments sub-structures
    wingData.(studentNumberStr).Forces = struct();
    wingData.(studentNumberStr).Moments = struct();
    
    %Populate Forces structure
    wingData.(studentNumberStr).Forces.ShearForcesArray = shearForcearrayHorizontal(c,:);%This is only Picking the First raw and the first column
    wingData.(studentNumberStr).Forces.RootShearForceArray = rootShearForcearray(c); 
    wingData.(studentNumberStr).Forces.ResultantForceArray = resultantForcearray(c);
    
    %Populate Moments structure
    wingData.(studentNumberStr).Moments.BendingMomentsArray = Marray(c);%Example array of bending moments
    wingData.(studentNumberStr).Moments.RootBendingMoment = rootBendingMomentsarray(c); 
    wingData.(studentNumberStr).Moments.MomentOfInertia = MomentOfInertia(c); 
    wingData.(studentNumberStr).Moments.BendingStress = BendingStressarray(c); 
    wingData.(studentNumberStr).Moments.Curvature = Karray(c); 
end
