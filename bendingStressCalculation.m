function wingRootStress = bendingStressCalculation(mainpath, wingCoeffInput)
mainpath = 'studentsWingLoadsResults.zip'; % Path to the ZIP file
extractFolder = 'studentsWingLoadsResults'; % Folder to extract files into
wingCoeffInput = 'wingSparCoefficients.xlsx';
unzip(mainpath, extractFolder); % Extracting ZIP file contents to extractFolder

% Getting a list of SubFolders within the main File
items = dir(extractFolder);
subfolder = items([items.isdir] & ~ismember({items.name}, {'.', '..'}));
subFolders = subfolder([subfolder.isdir]);

% Initializing arrays to hold data
filePatharray = {};
studentNumbersArray = [];
Marray = [];
Iarray = [];
BendingStressarray = [];
numericalDataarray = [];

% Looping through each inner folder
for i = 1:length(subFolders)
    subfolderPath = fullfile(extractFolder, subFolders(i).name);  

    % Getting a list of all inner folders within the subfolder
    innerItems = dir(subfolderPath);
    innerFolders = innerItems([innerItems.isdir] & ~ismember({innerItems.name}, {'.', '..'}));

    % Looping through each inner folder
    for j = 1:length(innerFolders)
        innerFolderPath = fullfile(subfolderPath, innerFolders(j).name);
        
        % Getting a list of all Excel files in the inner folder
        excelFilesInFolder = dir(fullfile(innerFolderPath, '*bendingMoments.xls*'));
        for k = 1:length(excelFilesInFolder)
            filePath = fullfile(innerFolderPath, excelFilesInFolder(k).name);
            filePatharray{end+1} = filePath; 

            % Read the Excel file for numeric data, a person can also use
            % the readmatrix functio which will directly read numeric data
            data = readtable(filePath);  % Use readtable for better handling of data types
           
            numericalData = data{2, 2};  % Get the numerical value from the table (should now be numeric)
            numericalDataarray = [numericalDataarray ,numericalData]; % Store numerical data

            % Store the numeric data in Marray
            Marray = [Marray, numericalData];% Marray(end + 1) = numerical data is similar to Marray = [Marray, numericalData};
        end
    end
end
% Reading wing span coefficients
wingCoeff = readtable( wingCoeffInput);
wingCoeff = table2array(wingCoeff);
key = size(wingCoeff, 1);

% Create arrays for wing coefficients
studentnumbersarray = [];
twarray = [];
tfarray = [];
Warray = [];
Harray = [];
Earray = [];
yieldStressarray = [];

% Process each wing coefficient
for x = 1:key
    studentnumber = wingCoeff(x, 1);
    twmm = wingCoeff(x, 2);
    tfmm = wingCoeff(x, 3);
    Wmm = wingCoeff(x, 4);
    Hmm = wingCoeff(x, 5);
    E = wingCoeff(x, 6);
    yieldStress = wingCoeff(x, 7);

    % Convert to meters
    tw = twmm / 1000;
    tf = tfmm / 1000;
    W = Wmm / 1000;
    H = Hmm / 1000;

    % Store Converted Coefficients
    studentnumbersarray(end + 1) = studentnumber;
    twarray(end + 1) = tw;
    tfarray(end + 1) = tf;
    Warray(end + 1) = W;
    Harray(end + 1) = H;
    Earray(end + 1) = E;
    yieldStressarray(end + 1) = yieldStress;

    % Calculating the Moment of Inertia
    I = ((W * H^3) / 12) - 2 * (((W - 2 * tf) * (H - 2 * tw)^3) / 12);
    Iarray(end + 1) = I;
end

% Flip student numbers array and Moment of Inertia array
studentnumbersarray = flip(studentnumbersarray);
Iarray = flip(Iarray);

% Calculate Bending Stress
for k = 1:length(Iarray)
    % Removed size check
    BendingStress = (Marray(k) * Harray(k)) / (2 * Iarray(k));
    BendingStressarray(end + 1) = BendingStress;
end

% Creating a Structure Array for the results
wingRootStress = struct('studentNumber', studentnumbersarray, ...
                         'rootBendingMoment', Marray, ...
                         'MomentofInertia', Iarray, ...
                         'bendingStress', BendingStressarray);
