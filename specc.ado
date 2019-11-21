// Program file to manage specification curves


// ---------------------------------------------------------------------------------------------
// Main command
cap prog drop specc
prog def specc

  // Syntax setup
  syntax [anything] using/  ///
    [if] ///
    , ///
    [*]

  // Parse subcommand
  gettoken subcommand anything : anything

  // Make sure some subcommand is specified
  if !inlist("`subcommand'","initialize","remove","new","report","build","run") {
    di as err "{bf:specc} requires [initialize], [remove], [report], [new method], [build], [run] to be specified. Type {bf:help specc} for details."
    error 197
  }

  specc_`subcommand' `anything' using "`using'" `if', `options'

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Initialization subcommand
cap prog drop specc_initialize
prog def specc_initialize

  // Syntax setup
  syntax using/ , ///
    [*]

  // Create empty dataset for specc storage
  mkdir `"`using'"' , public
  preserve
    clear
    save `"`using'/specc.dta"' , emptyok
  restore

  // Set up model class and main method
  specc new method ///
    "mat results = nullmat(results) \ [b,ll,ul,p]" ///
    using "`using'" ///
    , class(model) method(main) description(Main Specification)

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Removal subcommand
cap prog drop specc_remove
prog def specc_remove

  // Syntax setup
  syntax using/ , ///
    clear [*]

  // Create empty dataset for specc storage
  rm `"`using'/*.*"'
  rmdir `"`using'"'

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Build subcommand
cap prog drop specc_build
prog def specc_build

  // Syntax setup
  syntax anything using/ , ///
    clear [*]

  // Create empty dofile for specc storage
  cap rm `"`using'/specc.do"'

  cap file close main
  file open main using `"`using'/specc.do"' , write
  file write main "/* SPECC Runfile will iterate over:" _n
  file write main "`anything'" _n
  file write main "*/" _n _n

  foreach class in `anything' {
    file write main "\``class''" _n _n
  }

  file write main "// End of SPECC Runfile" _n
  file close main

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Build subcommand
cap prog drop specc_run
prog def specc_run

  // Syntax setup
  syntax using/ , ///
    clear [*]

  // Create empty dofile for specc storage
  cap file close main
  file open main using `"`using'/specc.do"' , read
    di "SPECC Runfile detected at {browse `using'/specc.do}."
    cap file close main
    file open main using `"`using'/specc.do"' , read
    file read main line
    forv i = 1/2 {
      display "`line'"
      if `i' == 1 file read main line
    }
  file close main

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Report subcommand
cap prog drop specc_report
prog def specc_report

  // Syntax setup
  syntax using/ [if], ///
    [class(string asis)] [method(string asis)] [*]

  // Load and display report
  if "`class'" == "" {
    preserve
      use `"`using'/specc.dta"' `if', clear
      li
    restore

    cap confirm file `"`using'/specc.do"'
    if _rc == 0 {
      di "SPECC Runfile detected at {browse `using'/specc.do}."
      cap file close main
      file open main using `"`using'/specc.do"' , read
      file read main line
      forv i = 1/2 {
      	display "`line'"
      	file read main line
      }
    }
  }

  // Display contents if requested
  if "`class'" != "" {
    cap file close main
    file open main using `"`using'/`class'/`method'.do"' , read
    file read main line
    while r(eof)==0 {
    	display "`line'"
    	file read main line
    }
    file close main
  }

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// NEW subcommand
cap prog drop specc_new
prog def specc_new

  // Syntax setup
  syntax [anything] using/ , ///
    [*]

  // Parse subcommand
  gettoken subcommand anything : anything

  // Make sure some subcommand is specified
  if !inlist("`subcommand'","class","method") {
    di as err "{bf:specc new} requires a [class] or [method] to be specified. Type {bf:help specc} for details."
    error 197
  }

  specc_new_`subcommand' `anything' using "`using'" , `options'

end
// ---------------------------------------------------------------------------------------------

  // -------------------------------------------------------------------------------------------
  // NEW METHOD subcommand
  cap prog drop specc_new_method
  prog def specc_new_method

    // Syntax setup
    syntax [anything] using/ , ///
      class(string asis) method(string asis) DESCription(string asis) ///
      [*]

    // Append new method dataset for specc storage
    preserve
    qui {
    clear
      set obs 1
      gen class = "`class'"
      gen method = "`method'"
      gen dofile = "/`class'/`method'.do"
      gen timestamp = "`c(current_date)' `c(current_time)'"
      gen description = "`description'"

      append using `"`using'/specc.dta"'
        save `"`using'/specc.dta"' , replace
    }

    // Set up method dofile
    cap mkdir `"`using'/`class'/"' , public
      cap file close main
      file open main using `"`using'/`class'/`method'.do"' , write
      file write main "// `description'" _n _n
      file write main `anything' _n _n
      file write main "// End of `description'" _n
      file close main

  end
  // -------------------------------------------------------------------------------------------

// End of adofile
