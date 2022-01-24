/**************************************************************************
	
	clean-trust-sample.do
	
	AC Forrester
	
	Last update: 12.23.2019
	
	Merge the GSS and BEA income data for the trust paper and perform some
	light cleaning.
	
**************************************************************************/	
	
	* make a temp file
	tempfile tmp
	
/**************************************************************************
	
	collapse the BEA data by division
	
**************************************************************************/	
	
	* Start with BEA accounts
	use ${merge}bea-accts-state, clear
	
	* Merge Census divisions
	merge m:1 state_code using ${merge}census-regions, nogen
	
	* Collapse to division-year
	collapse (sum) income population, by(division_code division_name year)
	
	* Drop prior years
	drop if year < 1971
		
	* Set as panel
	xtset division_code year
	
	* Merge data
	merge m:1 year using ${merge}fred-pcepi, keep(1 3) nogen
	
	* resort
	sort division_code year
	
	* Adjust for inflation
	replace income = income*pce
	
	* Don't need
	drop pce
		
	* Per capita (log)
	gen pcincome = ln(income/population)
	
	* Growth
	gen growth = d.pcincome*100
	
	* save in tempfile
	save `tmp'
	
/**************************************************************************
	
	sample 1: annual data
	
**************************************************************************/	
	
	* start with BEA data
	use `tmp'
	
	* Merge data
	merge 1:1 division_code year using ${merge}gss-trust-1yr, nogen
	
	* keep the interpolated values
	drop trust helpful fair
	
	* set as panel
	xtset division_code year, delta(1)
	
	* save the annual data
	save ${output}trust-1yr, replace
	
/**************************************************************************
	
	sample 2: biennial data
	
**************************************************************************/	
	
	* start with BEA data
	use `tmp'
	
	* recode gdp
	bys division_code (year): replace pcincome = pcincome[_n+1] if mod(year,2) == 1
	
	* recode year
	bys division_code (year): replace year = year[_n+1] if mod(year,2) == 1
	
	* average
	collapse (mean) growth pcincome, by(division_code year)
	
	* merge trust data
	merge 1:1 division_code year using ${merge}gss-trust-2yr, nogen
	
	* set as panel
	xtset division_code year, delta(2)
	
	* save the biennial data
	save ${output}trust-2yr, replace
	
/**************************************************************************
	
	sample 3: quinquennial data
	
**************************************************************************/	
	
	* start with BEA data
	use `tmp'
	
	* recode gdp
	bys division_code (year): replace pcincome = . if !(mod(year,10) == 0 | mod(year,10) == 5)
	
	* loop over intervals
	forval i = 1975(5)2010 {
		recode year (`i'/`=`i'+4' = `i')
	}
	drop if (year > 2015 | year < 1975)
	
	* average
	collapse (mean) growth pcincome, by(division_code year)
	
	* merge trust data
	merge 1:1 division_code year using ${merge}gss-trust-5yr, nogen
	
	* set as panel
	xtset division_code year, delta(2)
	
	* save the biennial data
	save ${output}trust-2yr, replace
	
	
	
	
	
	
***************************************************************************	
	
*	End of file	
