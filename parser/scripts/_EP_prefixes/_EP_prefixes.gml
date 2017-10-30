// Counts for how many elements the given prefix (argument1) is a prefix in the given array (argument0), prefix must be string and array must be array with only strings

var array = argument0;
var prefix = argument1;
var total = 0;
for (var i = 0 ; i < array_length_1d(array) ; i++) {
	if (string_copy(array[i], 1, string_length(prefix))==prefix) {
		total++;	
	}
}
return total;