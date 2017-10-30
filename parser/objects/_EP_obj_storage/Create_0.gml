/// @description Initialize storage variables

// If another instance already exists, get rid of yourself
if (instance_number(_EP_obj_storage) > 1) {
	instance_destroy();
	exit;
}

// Operators list
operators = ds_map_create();
operator_array = [];

// Iterate through resources and find operators
for(var s = 0; s < 100000; s++) {
	if (script_exists(s)) {
		var scr_name = script_get_name(s);

		// Given it has the right prefix, it is an operator
		if(string_copy(scr_name, 1, 7) == "_EP_OP_") {
			var op_data = script_execute(s, s);
			ds_map_add(operators, op_data[0], op_data);
			operator_array[array_length_1d(operator_array)] = op_data[0];
		}
	}
}

// Other data
digits = ["0","1","2","3","4","5","6","7","8","9","."];
brackets = ["(", ")"];

// Append brackets to operator_array as well
operator_array[array_length_1d(operator_array)] = "(";
operator_array[array_length_1d(operator_array)] = ")";

