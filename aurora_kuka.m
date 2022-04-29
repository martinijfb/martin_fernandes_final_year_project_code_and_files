%% HOW TO USE THIS CODE:
% This code reads the data measured using the Aurora, it eliminates
% outliers, and filters the data. It also saves the filtered data without
% outliers into a CSV file.

clear; clc;

%% Importing the data

% Data files that can be imported:
% Random-motion-with-water001.csv
% SittingStandingWithWater001.csv
% WalkingCirclesWithWater001.csv


table_data = readtable("Random-motion-with-water001.csv");

% Data collected from the aurora in the x, y ,and z coordinates
x = table_data{:,10};
y = table_data{:,11};
z = table_data{:,12};

% Create time array: the aurora records data every 0.0125 seconds
for i=1:1:size(x)
    t(i)=0.0125*i;
end

%% Outliers

% Find outliers in x, y, and z
A = isoutlier(x);
B = isoutlier(y);
C = isoutlier(z);

% Eliminate outliers from data
j = 1;
for i=1:1:size(x)
    if (A(i) == 0 && B(i) == 0  && C(i) == 0)
        x1(j,1)=x(i);
        y1(j,1)=y(i);
        z1(j,1)=z(i);
        t1(j,1)=t(i);
        j=j+1;  
    end
end

%% Apply a filter to the data
%A low-pass filter is a filter that allows signals below a cutoff frequency 
%(known as the passband) and attenuates signals above the cutoff frequency 
%(known as the stopband).

%testing different frequencies 

x2 = lowpass(x1,2,40); 
x3 = lowpass(x1,1,40);
x4 = lowpass(x1,0.3,40);

y2 = lowpass(y1,2,40);  
y3 = lowpass(y1,1,40);
y4 = lowpass(y1,0.3,40);

z2 = lowpass(z1,2,40);  
z3 = lowpass(z1,1,40);
z4 = lowpass(z1,0.3,40);

%% Create arrays with all the data

% Data without a filter
divide_factor = 1000;
for i=1:length(t1)
    final_data(i,1) = t1(i); % Time
    final_data(i,2) = y1(i)/divide_factor; % Horizontal Movement
    final_data(i,3) = z1(i)/divide_factor; % Forward and backwards (radius) 
    final_data(i,4) = x1(i)/divide_factor; % Vertical Movement
end

% Data with a filter 2

% NOTE: for walking in a straight line eliminate the first 60 and the last 10 (test9.csv)
% NOTE: for standing and sitting eliminate the first 107 and the last 62 (testc.csv) 
% NOTE: for underground eliminate the first 18 and the last 19 (testu.csv)
% NOTE: for walking in a straight line 2 eliminate the first 30 and the last 225 (testd.csv)
start_of_data = 1; % Eliminate the first part of the data
end_of_data = 0; % Eliminate ht elast part of the data
for i=start_of_data:(length(t1)-end_of_data)
    final_data_2(i-start_of_data+1,1) = t1(i-start_of_data+1); % Time
    final_data_2(i-start_of_data+1,2) = y2(i)/divide_factor; % Horizontal Movement
    final_data_2(i-start_of_data+1,3) = z2(i)/divide_factor; % Forward and backwards (radius) 
    final_data_2(i-start_of_data+1,4) = x2(i)/divide_factor; % Vertical Movement
end

%% Plots

% Plot unfiltered data
figure('Name','Unfiltered Data','NumberTitle','off')
subplot(2,2,1);
plot(final_data(:,2));
title('Horizontal Movement');
ylabel('metres', 'FontSize',16);
xlabel('Number of data points', 'FontSize',16);

subplot(2,2,2);
plot(final_data(:,3));
title('Distance to Aurora');
ylabel('metres', 'FontSize',16);
xlabel('Number of data points', 'FontSize',16);

subplot(2,2,3);
plot(final_data(:,4));
title('Vertical Movement');
ylabel('metres', 'FontSize',16);
xlabel('Number of data points', 'FontSize',16);

subplot(2,2,4);
plot3(final_data(:,2),final_data(:,3),final_data(:,4));
title('Whole Motion');
grid on
axis equal

% Plot filtered data
figure('Name','Filtered Data','NumberTitle','off')
subplot(2,2,1);
plot(final_data_2(:,2));
title('Horizontal Movement');
ylabel('metres', 'FontSize',16);
xlabel('Number of data points', 'FontSize',16);
grid on

subplot(2,2,2);
plot(final_data_2(:,3));
title('Distance to Aurora');
ylabel('metres', 'FontSize',16);
xlabel('Number of data points', 'FontSize',16);
grid on

subplot(2,2,3);
plot(final_data_2(:,4));
title('Vertical Movement');
ylabel('metres', 'FontSize',16);
xlabel('Number of data points', 'FontSize',16);
grid on

subplot(2,2,4);
plot3(final_data_2(:,2),final_data_2(:,3),final_data_2(:,4));
title('Whole Motion');
grid on
axis equal

%% Save data in a CSV file:
%writematrix(final_data_2,'underground_kuka.csv')