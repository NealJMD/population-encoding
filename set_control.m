% [] = set_control(handle, value)
%
% handle should be a handle returned by add_control.m-- this fn will then 
% set the value of the corresponding GUI to value
%



function [] = set_control(name, value)

if ~ishandle(name),
  h = findobj(gcf, 'Tag', [name ':value']);
else
  h = name;
end;

if ~isempty(h),
  set(h, 'UserData', value, 'String', num2str(value));
end;

