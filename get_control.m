% [value] = get_control(handle)
%
% handle should be a handle returned by add_control.m-- this fn will then 
% return the value of the corresponding GUI
%


function [v] = get_control(name)
if ishandle(name),
  v = get(name, 'UserData');
  return;
end;

h = findobj(gcf, 'Tag', [name ':value']);

if ~isempty(h),
  v = get(h, 'UserData');
else
  v = NaN;
end;

