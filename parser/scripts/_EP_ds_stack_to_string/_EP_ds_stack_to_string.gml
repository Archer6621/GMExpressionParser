// Outputs a string representation of the contents of a given ds_stack

var stack = argument0;
var temp = ds_stack_create();
ds_stack_copy(temp, stack);
var str = "[";
while (!ds_stack_empty(temp)) {
	str += string(ds_stack_pop(temp));
	if (ds_stack_size(temp)>0) {
		str += ", ";
	}	
}
ds_stack_destroy(temp);
return str + "]";