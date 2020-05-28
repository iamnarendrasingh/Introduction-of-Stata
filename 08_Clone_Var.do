* clonevar generates newvar as an exact copy of an existing variable, varname, with the same
* storage type, values, and display format as varname. varname’s variable label, value labels, notes,
* and characteristics will also be copied

* Data Manaagement 
* Narendra Singh


clear 
use http://www.stata-press.com/data/r14/travel

clonevar airtrain = mode if mode == 1 | mode == 2

describe airtrain mode

list mode airtrain in 1/5

drop airtrain
* important label can be used with the variable 
* user guide 13.11 
clonevar airtrain = mode if mode == "air":travel | mode == "train":travel
