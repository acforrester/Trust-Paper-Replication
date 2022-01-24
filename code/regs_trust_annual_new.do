/**************************************************************************
	
	regs-trust-annual.do
	
	AC Forrester
	
	Last update: 20.12.2019
	
	Run the annual regressions for the trust paper.
	
**************************************************************************/	
	
	* set a seed
	set seed  12345
		
	* open the annual data
	use ${output}trust-1yr, clear
	
	* variables for regressions
	foreach var in trust helpful fair {
		gen log_`var' = log(l.i`var')
		lab var log_`var' "Log `var' (\(t-1\))"
	}
	
/**************************************************************************
	
	run regression specifications
	
**************************************************************************/	
	
	* clear stored
	eststo clear
	
	* dependent vars
	local depvar d.pcincome
	
	* exogenous vars
	local varexo log_trust log_helpful log_fair 
	
	* specifications
	local spec1 
	local spec2	l.pcincome
	local spec3 l.pcincome
	
	* fixed effects (external)
	local fxd1	i.year
	local fxd2	i.year
	local fxd3	division_code#c.year
	
	* run the specs
	foreach dv of local depvar {
	
		foreach ev of local varexo {
			
			forval i = 1/2 {
				
				
				local reg_name reg_`ev'_`i'
				
				* run the regression and store results
				qui eststo `reg_name': ///	
					reghdfe `dv' `ev' `spec`i'' `fxd`i'', a(division_code) cl(division_code)
				
				* variables 
				local indep_vars `ev'
									
				* which vars to test
				local indep_hypotheses
				foreach var of local indep_vars {
					local indep_hypotheses = "`indep_hypotheses' {`var'}"
				}	
				
				di "`indep_hypotheses'"
				
				* run the wild cluster bootstrap
				qui boottest `indep_hypotheses',  boottype(wild) weight(webb) seed(12345) nogr
				
				local n_vars = 1
				
				matrix boot_pval  = J(1,`n_vars',.)
				matrix boot_ci_lb = J(1,`n_vars',.)
				matrix boot_ci_ub = J(1,`n_vars',.)
				
				if (`n_vars' > 1) {
					
					forval k = 1/`n_vars' {
						matrix boot_pval[1,`k'] = r(p_`k')
						matrix CI_temp = r(CI_`k')
						matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
						matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
					}
					
				}
				else {
					matrix boot_pval[1,1] = r(p)
					matrix CI_temp = r(CI)
					matrix boot_ci_lb[1,1] = round(CI_temp[1,1], 0.001)
					matrix boot_ci_ub[1,1] = round(CI_temp[1,2], 0.001)
				}
				
				foreach mat in "boot_pval" "boot_ci_lb" "boot_ci_ub" {
					matrix colnames `mat' = `ev'
					estadd matrix `mat' = `mat': `reg_name'
				}
			
			}			
			
		}
		
	}
	
	
	#delim ;
	
	estout 
		using ${output}regs-annual.tex,
		label 
		style(tex) 
		keep(*log*)
		indicate(
			L.pcincome
			*.year
			)
		ml(, noti)
		collabels(none) 
		varlabels() 
		num
		cells(	b(fmt(3))
				boot_pval(fmt(3) par)
				boot_ci_lb(fmt(a3) par(`"["' `","'))
				& boot_ci_ub(fmt(a3) par(`""' `"]"')))
		stats(	r2_a
				N_clust
				N,
				fmt(3 %9.0gc %9.0gc)
				l(	"Adj R-Sq." 
					"Divisions"
					"\(N\)")
				)
		prehead( 
			\begin{table}[h]
			\refstepcounter{table}            
			
			\label{table:regs-annual}            
			
			\centering
			
			\textbf{Table \ref{table:regs-annual}. Trust and Growth, Annual Data} \\
			
			\begin{tabular}{@{\extracolsep{4pt}}l*{@M}{c}@{}} 
			\hline \hline
			
			& \multicolumn{2}{c}{\it Log Trust} &
			\multicolumn{2}{c}{\it Log Helpful} &
			\multicolumn{2}{c}{\it Log Fair} \\
			\cline{2-3}  
			\cline{4-5}
  			\cline{6-7}
		)
		posthead(\hline) 
		prefoot() 
		postfoot(
			\noalign{\smallskip} \hline \hline 
			\end{tabular}
			\medskip
			\begin{minipage}{0.9\textwidth}
			\footnotesize Notes: \( @starlegend \). 
			\end{minipage}        
		\end{table}
		)
		replace;
	#delim cr
	
***************************************************************************	
	
*	End of file	
