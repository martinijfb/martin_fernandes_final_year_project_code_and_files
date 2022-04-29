%% HOW TO USE THIS CODE:
% This code optimise the standing and sitting data so the robot can read it
% Use this code after running kinza_code with standing and sitting data
% (testc.csv)

clear; clc;

%% Importing the data

% NOTE: the column order needs to be: Time, Horizontal Movement, Forward and
% Backward, Vertical Movement

% Read data: standing_and_sitting.csv
read_data = readtable("standing_and_sitting.csv");

%% Optimise the data

% Create an array for time and motion in each of the axis
time = read_data{:,1}; % time
x_coor = read_data{:,2};
y_coor = read_data{:,3};
z_coor = read_data{:,4}; % vertical motion

% Create time array for the data
time_interval = time(2) - time(1);
init = 0;
for i=1:length(x_coor)
    time_final(i) = init;
    init = init + time_interval;
end

% Combine the whole data into 1 array
for i=1:length(x_coor)
    ubuntu_data(i,1) = time_final(i);
    ubuntu_data(i,2) = x_coor(i) - abs(x_coor(1));
    ubuntu_data(i,3) = y_coor(i) + abs(y_coor(1)); 
    ubuntu_data(i,4) = z_coor(i) + abs(z_coor(1)); % Vertical Movement
end

figure(1)
plot3(ubuntu_data(:,2), ubuntu_data(:,3), ubuntu_data(:,4));
axis equal

% Add header
header = {'Time', 'Tx', 'Ty', 'Tz'};
ubuntu_data = [header; num2cell(ubuntu_data)];

%% Save data into a CSV file
%writecell(ubuntu_data, 'standing_and_sitting.csv')