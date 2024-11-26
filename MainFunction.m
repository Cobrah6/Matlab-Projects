%function [Data, wingRootStress, wingSparCurvature] = MainFunction(mainpath, wingCoeffInput)

%CALLING SUB FUNCTION ONE TO CALCULATING BENDING STRESS
mainpath = 'studentsWingLoadsResults.zip';
wingCoeffInput = 'wingSparCoefficients.xlsx';
wingRootStress =  bendingStressCalculation('studentsWingLoadsResults.zip','wingSparCoefficients.xlsx');
wingSparCurvature = calculateCurvature('studentsWingLoadsResults.zip','wingSparCoefficients.xlsx',bendingStressCalculation('studentsWingLoadsResults.zip','wingSparCoefficients.xlsx'));
wingRootStress = bendingStressCalculation(mainpath, wingCoeffInput);
 
%CALLING SUBFUNCTION TWO FOR CALCULATING CURVATURE
wingSparCurvature = calculateCurvature(mainpath,wingCoeffInput,bendingStressCalculation(mainpath,wingCoeffInput));

%CALLING SUBFUNCTION THREE FOR STRUCTURE ARRAY
Data = storeWingData(mainpath, wingRootStress, wingSparCurvature);

% Reading wing span coefficients
wingCoeff = readtable(wingCoeffInput);
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

for x = 1:length(wingCoeff) 
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
end
bendingstressarray =[];
MomentsofInertiaarray = [];
Curvaturearray = [];


bendingstress = wingRootStress.bendingStress
bendingstressarray = [bendingstressarray ; bendingstress];

conditionArray = strings(length(Earray), 1);

    for z = 1:length(Earray)
        if bendingstress(z) > Earray(z)
            conditionArray(z) = "yes";
        else
            conditionArray(z) = "no";
        end
    end
%Data = storeWingData(wingRootStress, wingSparCurvature, bendingstress, conditionArray);
for c = 1:length(studentnumbersarray)
    studentNumber = studentnumbersarray(c);

    %Converting student numbers to string so they can used for Names in the
    %array
    studentNumberStr = sprintf('Student_%d', studentNumber); % Create a valid field name

    %Initialize The student Structure
    wingData.(studentNumberStr) = struct();

    %Populate Moments structure
    wingData.(studentNumberStr).Moments.YieldStress = Earray(c); 
    wingData.(studentNumberStr).Moments.Failure = conditionArray(c)
   
end

 Data.wingData.(studentNumberStr).Moments.Failure = conditionArray
 Data.wingData.(studentNumberStr).Moments.YieldStress = Earray