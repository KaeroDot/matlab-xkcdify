% This file contains a simple Matlab script that demonstrates how to use
% xkcdify.m  
%
% The most up to date version of this file can be found at
% https://github.com/slayton/matlab-xkcdify
%
% Copyright(c) 2012, Stuart P. Layton <stuart.layton@gmail.com>
% http://stuartlayton.com
%
% Revision History
%   2012/10/04 - Initial Release

%% - Example 1, XKCDify plot with lines, markers, axes and text

clear;
clc;
close all;

figure();

x = 0:.05:2*pi;
y1 = zeros(size(x));  % flat line
y2 =  mod(round(x / pi),2)*1.5 - .75; % Square wave
xcrosses = x(1:15:end);
ycrosses = y2(1:15:end);
y3 = .2 + .6 * sin(x); % sine wave
xdots = x(1:15:end);
ydots = y3(1:15:end);

% Plot lines individually to ensure all have linewidth of 4
hold('on');
plot(x, y1, 'linewidth', 4);
plot(x, y2, 'linewidth', 4);
plot(x, y3, 'linewidth', 4);
plot(xdots, ydots, 'o');
plot(xcrosses, ycrosses, 'xk');
xlabel('Time')
ylabel('Value')
text(2, -0.5, 'Funny Plot', 'FontSize', 16);
title('Funny Plot');
hold('off');

xlim([0, 6])
ylim([-1.1, 1.1])

input('Press Enter to xkcdify actual image...');
xkcdify(gca());

input('Press Enter to continue...');

%% - Example 2, XKCDify simple line plots
clear;
clc;
close all;

figure('Position', [100 460 1120 420]);
a(1) = subplot(121); a(2) = subplot(122);

x = 0:.05:2*pi;
y1 = zeros(size(x));  % flat line
y2 =  mod(round(x / pi),2)*1.5 - .75; % Square wave
y3 = .2 + .6 * sin(x); % sine wave

% Plot lines individually to ensure all have linewidth of 4
hold(a(1), 'on');
plot(a(1), x, y1, 'linewidth', 4);
plot(a(1), x, y2, 'linewidth', 4);
plot(a(1), x, y3, 'linewidth', 4);
xlabel(a(1), 'Time')
ylabel(a(1), 'Value')
text(a(1), 2, -0.5, 'Normal Plot', 'FontSize', 16);
title(a(1), 'Normal Plot');
hold(a(1), 'off');

hold(a(2), 'on');
plot(a(2), x, y1, 'linewidth', 4);
plot(a(2), x, y2, 'linewidth', 4);
plot(a(2), x, y3, 'linewidth', 4);
xlabel(a(2), 'Time')
ylabel(a(2), 'Value')
text(a(2), 2, -0.5, 'XKCDified Plot', 'FontSize', 16);
title(a(2), 'XKCDified Plot');
hold(a(2), 'off');

set(a, 'XLim', [x(1) - .25, x(end)+.25], 'YLim', [-.9 .9]);

xkcdify(a(2));
input('Press Enter to continue...');

%% - Example 3, XKCDify a bar plot with a line plot on top
clear; close all; clc;

figure('Position', [100 460 1120 420]);
a(1) = subplot(121); a(2) = subplot(122);


x = [0:.1:5];
y = 1 + (x-2).^2;

bar([ 3 2 4 6], 'Parent', a(1));
line(x,y,'Color', 'r', 'lineWidth', 3, 'Parent', a(1));
bar([ 3 2 4 6], 'Parent', a(2));
line(x,y,'Color', 'r', 'lineWidth', 3, 'Parent', a(2));


xkcdify(a(2));

set(a, 'XLim', [.5 4.5], 'YLim', [0 7]);
input('Press Enter to continue...');

%% - Example 4, XKCDify a boxplot with a line plot on top
clear; close all; clc;
n = 5;  data = rand(20,n) * 5;
x = 1:n; y =  mean(data) + rand(1,n);

figure('Position', [100 460 1120 420]);
a(1) = subplot(121); a(2) = subplot(122);

boxplot( data, 'Parent', a(1)); 

set( get(get(a(1), 'Children'),'Children'), 'LineWidth', 3); % Hack to grow the line width of the boxplot
line(x, y, 'color', 'g', 'linewidth', 3, 'Parent', a(1));

boxplot( data, 'Parent', a(2)); 

set( get(get(a(2), 'Children'),'Children'), 'LineWidth', 3); % Hack to grow the line width of the boxplot
line(x, y, 'color', 'g', 'linewidth', 3, 'Parent', a(2));

xkcdify(gca)
input('Press Enter to continue...');

%% - Example 5, XKCDify a subset of axes inside a figure

clear; close all; clc;
figure('Position', [100 460 1120 420]);
x = 0:.1: 2 * pi;
y1 = sin(x);
y2 = cos(x);

for i = 1:3
    a(i) = subplot(1,3,i);

    plot(x * i, sin(x ./ (i/2)), x*i, cos(x ./ (i/2)), 'Parent', a(i), 'linewidth', 4);
    set(a(i), 'XLim', [x(1) - .25, x(end)+.25] * i, 'YLim', [-1.2 1.2]);
end
xkcdify(a(2:3))
