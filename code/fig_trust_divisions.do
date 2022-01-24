/**************************************************************************
	
	Format PCE from FRED
	
**************************************************************************/	
		
	* Open the annual data
	use ${out}trust-annual, clear
	
	* For convenience
	drop if year < 1972
	
	* Get the labels for graphing
	labmask division_code, val(division_name)
	
	#delim ;
	
	xtline trust,
		ytitle("Average Trust") 
		ylabel(, nogrid) 
		ttitle("") 
		tlabel(1970(10)2020) 
		byopts(legend(off));
	
	graph export ${out}fig-trust-divisions.pdf, as(pdf) replace;
	
	#delim cr
	
