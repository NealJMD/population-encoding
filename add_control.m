% handle = add_control(name, value, delta_up, delta_down, pos_x, pos_y)
%
% Adds a GUI control to the current figure. 
%
% PARAMETERS:
% -----------
%
% name      A string that will be used as a label on the figure
%
% value     A double, the initial value of this GUI variable
%
% delta_up  By how much the variable should increase when its "up" button
%           is pressed
%
% delta_down By how much the variable should decrease when its "down" button
%           is pressed
%
% pos_x     x position, in pixels, within current figure, for lower left of GUI
%
% pos_y     y position, in pixels, within current figure, for lower left of GUI
%
%
% RETURNS:
% --------
%
% handle    A handle to the uicontrol. This handle can be used with
%           get_control.m and set_control.m
%


function [hval] = add_control(name, value, delta_up, delta_down, pos_x, pos_y, callback)

width = 80;

hstr = uicontrol('Style', 'text', 'Position', [pos_x pos_y width 20], 'String', name, ...
  'Tag', [name ':name']);
hval = uicontrol('Style', 'edit', 'Position', [pos_x+width pos_y width 20], 'String', num2str(value), ...
  'UserData', value, 'Tag', [name ':value'], 'BackgroundColor', 'w');
hup = uicontrol('Style', 'pushbutton', 'Position', [pos_x+2*width pos_y 20 20], 'String', '^', ...
  'UserData', delta_up, 'Tag', [name ':up']);
hdn = uicontrol('Style', 'pushbutton', 'Position', [pos_x+2*width+20 pos_y 20 20], 'String', 'v', ...
  'UserData', delta_down, 'Tag', [name ':down']);
  
set([hstr;hval;hup;hdn], 'Callback', {@control_callback, hstr, hval, hup, hdn, callback});
