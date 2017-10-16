var ds_list = argument0;
var str = "["
for (var i = 0 ; i < ds_list_size(ds_list) ; i++) {
	str += string(ds_list_find_value(ds_list, i));
	if (ds_list_size(ds_list)-i !=1) {
		str += ", ";
	}	
}
return str + "]"