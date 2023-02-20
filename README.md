# Trust and Growth Replication Files for "Trust plays no role in regional U.S. economic development – and five other problems with the trust literature"

This repository contains the Stata codes and datasets to reproduce 

## Run This First

1. [`main_trust_codes.do`](./codes/main_trust_codes.do) will set the main global variables and directories.

## Data Prep

1. [`clean_accts_state.do`](./codes/clean_accts_state.do) cleans the personal income accounts data from the Bureau of Economic Analysis (BEA) Regional Economic Information.
   - These data come from [`SAINC50`](https://www.bea.gov/data/income-saving/personal-income-county-metro-and-other-areas)
2. [`clean_gss_trust.do`](./code/clean_gss_trust.do) tabulates the General Social Survey (GSS) data downloaded from the [National Opinion Research Center (NORC)](https://gss.norc.org)
3. [`clean_trust_wvs.do`](./code/clean_trust_wvs.do) tabulates the [World Values Survey (WVS)](https://www.worldvaluessurvey.org/wvs.jsp) data to compare against the national trends from the GSS.
4. [`code/clean_trust_sample.do`](code/clean_trust_sample.do) assembles the BEA and GSS datasets to create the final division panel dataset.

## Analysis

### Figures
1. [`fig_trust_comparison.do`](./code/fig_trust_comparison.do) creates the comparison time series plot for GSS and WVS trust (Figure 1).
2. [`fig_trust_divisions.do`](./code/fig_trust_divisions.do) creates the time series plots of generalized trust for each census division (Figure 2).

### Tables
1. [`sum_stats.do`](./code/sum_stats.do) produces the table of summary statistics (Table 1).
2. [`regs_trust_biennial_new.do`](./code/regs_trust_biennial_new.do) produces the regressions of growth on trust measures using biennial data (Table 2).
3. [`regs_trust_annual_new.do`](./code/regs_trust_annual_new.do) produces the regressions of growth on trust measures with the annual interpolated trust data (Table 3).

