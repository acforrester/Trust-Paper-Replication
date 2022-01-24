/**************************************************************************
	
	Format Census geo codes data
	
**************************************************************************/	
	
	* Project params
	loc	main	census-bureau
	loc	subd	geography
	
	* Main directories
	gl	raw	${build}`main'/`subd'/raw/
	gl	zip	${build}`main'/`subd'/zip/
	gl	dta	${build}`main'/`subd'/dta/
	
	* URL
	loc url	https://www2.census.gov/programs-surveys/popest/geographies/2017/
	
/**************************************************************************
	
	Load the income data
	
**************************************************************************/	
		
	* Pull the file
	cap confirm file ${raw}state-geocodes-v2017.xlsx
	if _rc {
		copy `url'state-geocodes-v2017.xlsx ${raw}
	}
	
/**************************************************************************
	
	Load the income data
	
**************************************************************************/	
	
	* Open the xl file
	import excel using ${raw}state-geocodes-v2017.xlsx, clear
	
	* Loop over vars
	ren (A B C D) (region_code division_code state_code geo_name)
	
	* Var labels
	foreach var of varlist * {
		lab var `var' "`=`var'[6]'"
	}
	drop in 1/6
	
	* Drop the headers
	destring *, replace
	
	* Sort
	sort region division state_code
	
	* Region name
	bys region_code (division_code): gen region_name = geo_name[1]
	
	* Division name
	bys region_code division_code: gen division_name = geo_name[1]
	
	* Drop the regions/divisions
	drop if (state_code == 0)
	
	ren geo_name state_name
	
	* Sort
	sort state_code
	
	* Save in merge 
	save ${merge}census-regions, replace
	
***************************************************************************	
	
*	END OF FILE	
