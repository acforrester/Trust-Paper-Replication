	
	
	
	use ${mrg}wvs-trust-compare, clear
	
	
	merge 1:1 wave using ${mrg}gss-trust-compare, nogen
	
	sort wave
	
	* Variable labels
	lab var	wvs_trust	"WVS"
	lab var	gss_trust	"GSS"
	
	
	#delim ;
	twoway
		connected gss_trust wave,
			cmissing(n)
			msymbol(circle)
			mcolor(gray)
			lcolor(gray)||
		connected wvs_trust wave, 
			cmissing(n)
			msymbol(circle)
			mcolor(black)
		xtitle("")
		ytitle("Average Trust")
		legend(	pos(1) 
				ring(0)
				col(1)
				bplacement(1)
				bmargin(0))
		xlabel(	1(1)6.5, 
				labsize(small) 
				valuelabel);
	
	graph export ${out}fig-trust-comparison.pdf, as(pdf) replace;
	
	#delim cr
