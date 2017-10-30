// Checks whether array contains element

var array = argument0;
var element = argument1;
for (var i = 0 ; i < array_length_1d(array) ; i++) {
	if (array[i] == element) {
		return true;	
	}
}
return false;