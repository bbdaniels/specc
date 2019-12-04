// Program file to manage specification curves


// ---------------------------------------------------------------------------------------------
// Main command
cap prog drop specc
prog def specc

  // Syntax setup
  syntax [anything] [using/]  ///
    [if] ///
    , ///
    [*]

  // Default specc directory
  if "`using'" == "" local using "specc"

  // Parse subcommand
  gettoken subcommand anything : anything

  // Allow abbreviations
  if "`subcommand'" == "init" local subcommand = "initialize"

  // Make sure some subcommand is specified
  if !inlist("`subcommand'","initialize","remove","new","report","set","run") {
    di as err "{bf:specc} requires [initialize], [remove], [report], [new], [set], [run] to be specified. Type {bf:help specc} for details."
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
  specc new model main ///
    using "`using'" ///
    , description(Main Specification)

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Removal subcommand
cap prog drop specc_remove
prog def specc_remove

  // Syntax setup
  syntax [anything] using/ , ///
    [*]

  gettoken class anything : anything
  gettoken method anything : anything

  // Create empty dataset for specc storage
  preserve
    use `"`using'/specc.dta"' `if', clear
    drop if class == "`class'" & method == "`method'"
    save `"`using'/specc.dta"' , replace
  restore

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Build subcommand
cap prog drop specc_set
prog def specc_set

  // Syntax setup
  syntax anything using/ , ///
    reset [*]

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
// Run subcommand
cap prog drop specc_run
prog def specc_run

  // Syntax setup
  syntax using/ , ///
    [*]

  // Read out execution order
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
  local params = "`line'"

  // Create iteration loop
  local n_params: word count `params'
  tempname current max

    mat `current' = J(1,`n_params',1)
      mat colnames `current' = `params'
    mat `max' = J(1,`n_params',1)

    forv i = 1/`n_params' {
      local c`i' : word `i' of `params'

      preserve
        use `"`using'/specc.dta"' `if', clear
        qui levelsof method if class == "`c`i''" , local(m`i')
          local max_`c`i'' : word count `m`i''
          mat `max'[1,`i'] = `max_`c`i'''
        qui levelsof description if class == "`c`i''" , local(d`i')
      restore

      di `" `c`i'' :: `d`i''   "'
    }

  // Loop over combinations

    // Calculate total combinations
    local total = 1
    forv i = 1/`n_params' {
      local next = `max'[1,`i']
      local total = `total'*`next'
    }

    // Set up to loop over all differences
    tempname diffmat

    local diff = 1
    local counter = 0
    while `diff' != 0 {
      local ++counter
      di " "
      di "(`counter'/`total') Running:"

      // Get the dofile list
      forv i = 1/`n_params' {
        local theIndex = `current'[1,`i']
        local theClass = "`c`i''"
        local theMethod : word `theIndex' of `m`i''
        di " `theDesc' (`using'/`theClass'/`theMethod'.do)"
      }

      // Quit if this was the max iteration
      mat `diffmat' = (`current' - `max')*(`current' - `max')'
      local diff = `diffmat'[1,1] // Diff becomes zero when matrices are equal

      // Increment first unmaxed param
      local increment = 1
      forv i = 1/`n_params' {
        local theCurrent = `current'[1,`i']
        local theMax = `max'[1,`i']
        if (`theCurrent' < `theMax') & (`increment' == 1) {
          mat `current'[1,`i'] = `theCurrent' + 1
          local increment = 0
        }
        else if (`theCurrent' == `theMax') & (`increment' == 1) {
          mat `current'[1,`i'] = 1
        }
      }

    }

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Report subcommand
cap prog drop specc_report
prog def specc_report

  // Syntax setup
  syntax [anything] using/ [if], ///
    [*]

  // Load and display report
  if "`anything'" == "" {
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
      	if `i' == 1 file read main line
      }
    }

    local params = "`line'"
    local n_params: word count `params'

    forv i = 1/`n_params' {
      local c`i' : word `i' of `params'

      preserve
        use `"`using'/specc.dta"' `if', clear
        qui levelsof method if class == "`c`i''" , local(m`i')
        qui levelsof description if class == "`c`i''" , local(d`i')
      restore

      di `" `c`i'' :: `d`i''   "'
    }
  }

  // Display contents if requested
  if "`anything'" != "" {
    gettoken class anything : anything
    gettoken method anything : anything
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

// -------------------------------------------------------------------------------------------
// NEW METHOD subcommand
cap prog drop specc_new
prog def specc_new

  // Syntax setup
  syntax anything using/ , ///
    DESCription(string asis) ///
    [*]

  // Get info
  gettoken class anything : anything
  gettoken method anything : anything

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
    if class == "model" {
      file write main "mat results = nullmat(results) \ [b,ll,ul,p]" _n _n
    }
    file write main "// End of `description'" _n
    file close main

end
// -------------------------------------------------------------------------------------------

// End of adofile
