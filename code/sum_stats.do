/**************************************************************************
	
	sum_stats.do
	
	AC Forrester
	
	Last update: 12.23.2019
	
	Clean the BEA accounts data st the state level (SAINC50).
	
**************************************************************************/	

	* Output directory already set
	
/**************************************************************************

	Print summary statistics table

**************************************************************************/	
	
	* open the annual data
	use ${out}trust-annual, clear
	
	* collect summary stats
	estpost tabstat trust_impute, stat(mean sd min max) by(division_name)
	
	* export as TeX
	esttab ., tex cells("mean(fmt(a3)) sd(fmt(a3)) min(fmt(a3)) max(fmt(a3))")
	
	
	
***************************************************************************	
	
*	End of file
