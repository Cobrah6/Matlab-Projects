function wingSparCurvature = calculateCurvature(mainpath, wingCoeffInput, wingRootStress)

%Header Calling the Required Files for Use
%mainPath = 'studentsWingLoadsResults.zip'; % Path to the ZIP file
%wingRootStress =  bendingStressCalculation('studentsWingLoadsResults.zip','wingSparCoefficients.xlsx');
extractFolder = 'studentsWingLoadsResults';
unzip(mainpath, extractFolder); 


%Getting Subfolders within the Extracted File
items = dir(extractFolder)
subfolder = items([items.isdir] & ~ismember({items.name}, {'.', '..'})); 
subFolders = subfolder([subfolder.isdir]); 

% Initialize arrays to hold data
filePatharray = {};
studentNumbersArray = [];
Marray = [];
Iarray = [];
BendingStressarray = [];
numericalDataarray = [];

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
        excelFilesInFolder = dir(fullfile(innerFolderPath, '*bendingMoments.xls*'));

        % Process each Excel file
        for k = 1:length(excelFilesInFolder)
            filePath = fullfile(innerFolderPath, excelFilesInFolder(k).name);
            filePatharray{end+1} = filePath; % Store file paths as cell array

            % Read the Excel file using readtable or readmatrix for numeric data
            % data = readcell(filePath);  % This is an alternative method, but it's prone to mixed types
            data = readtable(filePath);  % Use readtable for better handling of data types
           
            numericalData = data{2, 2};  % Get the numerical value from the table (should now be numeric)
            numericalDataarray = [numericalDataarray ,numericalData]; % Store numerical data

            % Store the numeric data in Marray
            Marray = [Marray; numericalData]; % Marray(end + 1) = numerical data is similar to Marray = [Marray, numericalData};
        end
    end
end

% Reading Wing Span Coefficients
    wingCoeff = readtable(wingCoeffInput);
    wingCoeff = table2array(wingCoeff);
    key = length(wingCoeff);

    % Initialize arrays for storing student numbers and Young's Modulus (E)
    Earray2 = []; 
    studentNumberarray = [];
    Iarray2 = [];

    % Read wing coefficients (including student numbers and E)
    for i = 1:length(wingCoeff)
        studentNumber = wingCoeff(i, 1);
        studentNumberarray = [studentNumberarray; studentNumber];
        E = wingCoeff(i, 6);
        Earray2 = [Earray2, E];
    end
    % Flip arrays
    Earray2 = flipud(Earray2);
    studentNumberarray = fliplr(studentNumberarray);

    % Use MomentofInertia directly from wingRootStress
    MomentOfInertia = wingRootStress.MomentofInertia;
    I2 = MomentOfInertia;
    Iarray2 = [];
    Iarray2 = [Iarray2 I2];
    Karray = [];

    % Calculating the Curvature (K = M / (E * I))
    for s = 1:length(Earray2)
        K = Marray(s) / (Earray2(s) * Iarray2(s)); % Curvature formula
        Karray = [Karray; K]; %% Store curvature values
    end

    % Make Curvature and Bending Moments nx2 arrays with student numbers aligned
    nx2Curvature = [Karray, studentNumberarray]; % Curvature nx2 array
    nx2bendingMoments = [Marray, studentNumberarray]; % Bending moments nx2 array

    % Creating the structure array for the results
    wingSparCurvature = struct('studentNumber', studentNumberarray, ...
                               'bendingMoments', nx2bendingMoments, ...
                               'Curvature', nx2Curvature);
