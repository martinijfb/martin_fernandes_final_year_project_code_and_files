%% HOW TO USE THIS CODE:
% This code only works for walking motion (forwards in a straight line)

clear; clc;

%% Importing the data

% NOTE: the column order should be: Time, Horizontal Movement, Forward and
% Backward, Vertical Movement

% Read data
% walking_filtered.csv for walking with filter
read_data = readtable("walking_filtered_ver2.csv");

% Create an array for time and motion in each of the axis
time = read_data{:,1}; % time
walking_line = read_data{:,2}; % walking direction
r_var = read_data{:,3}; % distance to aurora
vertical_motion = read_data{:,4}; % vertical motion

%% Plots: Measured data

figure('Name','Data','NumberTitle','off')
subplot(2,2,1);
plot(walking_line);
title('Horizontal Movement');
set(gca,'XTick',[]);
grid on;

subplot(2,2,2);
plot(r_var);
title('Distance to Aurora');
set(gca,'XTick',[]);
grid on;

subplot(2,2,3);
plot(vertical_motion);
title('Vertical Movement');
set(gca,'XTick',[]);
grid on;

subplot(2,2,4);
plot3(walking_line, r_var, vertical_motion);
title('Whole Motion');
axis equal;
grid on;


%% Robot Parameters: adapt motion to the robot

r = 0.65 + abs(r_var(1)); % radius
x_centre = -0.65; % centre is shift as the robot motion starts relative to it's starting position
y_centre = 0;
robot_limit = pi/9; % Robot can turn only +/-170

arc = (17*pi/9) * 3 * (r + mean(r_var)); % approximate distance that the robot will move
distance_walked = range(walking_line); % Distance Walked while measuring data
number_of_repeated_motions = arc/distance_walked; % Repeated number of motions


%Find the number of data points needed
number_of_data_points = round(number_of_repeated_motions * length(walking_line));

% Make sure it's divisible by three
if mod(number_of_data_points, 3) == 1
    number_of_data_points = number_of_data_points - 1;
elseif mod(number_of_data_points, 3) == 2
    number_of_data_points = number_of_data_points - 2;    
end

% create a final array for the radius
% create a final array for the vertical motion
final_r_var = [];
final_vertical_motion = [];

while length(final_r_var) < number_of_data_points
    for i = 1:length(r_var)
        final_r_var(end+1) = r_var(i);
        final_vertical_motion(end+1) = vertical_motion(i);
        if length(final_r_var) == number_of_data_points
            break
        end
    end
end

%% Create robot motion data

% 1/3 of the motion (init part), get x and y coordinates.
theta = (linspace(0, pi-(robot_limit), number_of_data_points/3));
for i = 1:1:number_of_data_points/3
    x_init(i) = (r + final_r_var(i)) * cos(theta(i)) + x_centre;
    y_init(i) = (r + final_r_var(i)) * sin(theta(i)) + y_centre;
end

% get the rest of the motion, get x and y coordinates.
theta_2 = linspace(pi-(robot_limit), -pi+(robot_limit), 2*number_of_data_points/3);
for i = (length(final_r_var)/3)+1:1:length(final_r_var)
    x(i-length(final_r_var)/3) = (r + final_r_var(i)) * cos(theta_2(i-length(final_r_var)/3)) + x_centre;
    y(i-length(final_r_var)/3) = (r + final_r_var(i)) * sin(theta_2(i-length(final_r_var)/3)) + y_centre;
 
end

% Create final arrays by combining both parts above
x_final = x_init;
y_final = y_init;

for i=1:length(x)
    x_final(end+1) = x(i);
    y_final(end+1) = y(i); 
end

%% Plots: Robot Motion

figure('Name','Circular Motion Data','NumberTitle','off')
subplot(2,2,1)
plot(x_init, y_init);
title('Initial Motion (1/3)');
xlabel('x coordinate');
ylabel('y coordinate');
axis equal;
grid on;

subplot(2,2,2)
plot(x, y);
title('Final Part of Motion');
xlabel('x coordinate');
ylabel('y coordinate');
axis equal;
grid on;

subplot(2,2,[3 4])
plot3(x_final, y_final, final_vertical_motion);
title('Whole Motion in 3D');
xlabel('x coordinate');
ylabel('y coordinate');
zlabel('z coordinate');
axis equal;
grid on;

%% Create final data

% Create time array for the data
time_interval = time(2) - time(1);
init = 0;
for i=1:length(x_final)
    time_final(i) = init;
    init = init + time_interval;
end

% Combine the whole data into 1 array
for i=1:length(x_final)
    ubuntu_data(i,1) = time_final(i);
    ubuntu_data(i,2) = x_final(i); 
    ubuntu_data(i,3) = y_final(i); 
    ubuntu_data(i,4) = final_vertical_motion(i); % Vertical Movement
end

% Add header
header = {'Time', 'Tx', 'Ty', 'Tz'};
ubuntu_data = [header; num2cell(ubuntu_data)];

%% Save data into a CSV file
%writecell(ubuntu_data, 'filtered_walking_1.csv')