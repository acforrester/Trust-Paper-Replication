/**************************************************************************
	
	Format WVS data
	
**************************************************************************/	
	
	* Project params
	loc	main	world-values
	loc	subd	wvs-data
	
	* Main directories
	gl	raw	${build}`main'/`subd'/raw/
	gl	zip	${build}`main'/`subd'/zip/
	gl	dta	${build}`main'/`subd'/dta/
	
/**************************************************************************
	
	Clean the data
	
**************************************************************************/	
	
	* Open DTA
	use ${dta}WVS_Longitudinal_1981_2016_stata_v20180912, clear
	
	* Subset the data
	keep S002 S003 S017 A165
	
	* Recode the missings
	recode A165 (-5/-1 = .) (2 = 0)
	
	* For comparability
	replace A165 = A165*100
	
	* Weighted averages
	collapse (mean) A165 [pw=S017], by(S002 S003)
	
	* Rename vars
	ren (A165 S002 S003) (wvs_trust wave un_code)
	
	* Keep united states
	keep if (un_code == 840)
	
	* Save in merge directory
	save ${merge}wvs-trust-compare, replace
	
***************************************************************************	
	
*	END OF FILE	
