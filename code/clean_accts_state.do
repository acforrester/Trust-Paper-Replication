/**************************************************************************	
	
	Program:  clean_accts_state.do
	Authors:  AC Forrester
	
	Purpose: Clean the BEA accounts data st the state level (SAINC50).
		
**************************************************************************/	
	
	* Project params
	loc	main	bea-data
	loc	subd	state
	
	* Main directories
	gl	raw	${build}`main'/`subd'/raw/
	gl	zip	${build}`main'/`subd'/zip/
	gl	dta	${build}`main'/`subd'/dta/
	
/**************************************************************************

	Load the income data

**************************************************************************/	
	
	* Open the CSV file as strings
	import delim using ${raw}SAINC50__ALL_AREAS_1948_2018.csv, /*
		*/	varn(nonames) stringc(_all) clear
	
	* Loop over vars
	foreach var of varlist * {
		* Determine if year or key variable
		if (`=real(`var'[1])' > 1947 & `=real(`var'[1])' != .) {
			* Destring the year and replace missings
			destring `var', ignore("(NA)") replace 
			ren `var' value`=`var'[1]'
		}
		else {
			* Rename and label the key variables
			lab var `var' "`=`var'[1]'"
			ren `var' `=lower(strtoname(`var'[1]))'
		}
		
	}
	drop in 1
	
	* Drop footnotes
	drop if (geoname == "")
	
	* Geo id
	ren (geofips geoname) (state_code geo_name)
	
	* Destring
	destring *, ignore(`"""') replace
	
	* Fix geofips
	replace state_code = int(state_code / 1000)
	
	* Drop regions
	drop if (state_code > 56 | state_code < 1)
	
	* Keep per capita
	keep if (linecode == 10 | linecode == 20)
	
	* Subset
	keep geo* state_code line value*
	
	* Reshape to long
	reshape long value, i(state_code line) j(year)
	
	* Reshape to long
	reshape wide value, i(state_code year) j(line)
	
	* Rename values
	ren (value10 value20) (income population)
	
	* Save in merge
	save ${merge}bea-accts-state, replace
	
***************************************************************************	
	
*	End of file
