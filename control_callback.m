function [] = control_callback(my_handle, extra, hstr, hval, hup, hdn, callback) %#ok<INUSL>

value = get(hval, 'UserData');

if my_handle == hval,
  value = str2double(get(hval, 'String'));
elseif my_handle == hup,
  value = get(hval, 'UserData') + get(hup, 'UserData');
elseif my_handle == hdn,
  value = get(hval, 'UserData') - get(hdn, 'UserData');
end;
  
set(hval, 'UserData', value);
set(hval, 'String', num2str(value));

callback();