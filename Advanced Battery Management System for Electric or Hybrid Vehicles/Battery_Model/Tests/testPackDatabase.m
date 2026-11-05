clc
clear

%% Load Battery Pack Database
% Load the available commercial battery-pack data into MATLAB.
% The database contains the specifications required for
% pack comparison, recommendation, and analysis.

PackDB = loadPackDatabase();

%% Display Sample Database Records
% Display the first 10 entries of the battery-pack database
% to verify that the database has been loaded correctly.

disp(PackDB(1:10,:))