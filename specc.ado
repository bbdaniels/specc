// Program file to manage specification curves


// ---------------------------------------------------------------------------------------------
// Main command
cap prog drop specc
prog def specc

  // Syntax setup
  syntax [anything] using/ , ///
    [*]

  // Parse subcommand
  gettoken subcommand anything : anything

  // Make sure some subcommand is specified
  if !inlist("`subcommand'","initialize","remove") {
    di as err "{bf:specc} requires [initialize] to be specified. Type {bf:help specc} for details."
    error 197
  }

  specc_`subcommand' `anything' using "`using'" , `options'

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
      set obs 1
      gen class = "model"
      gen method = "main"
      gen description = "Main Specification"
      gen dofile = "/model/main.do"
    save `"`using'/specc.dta"' , emptyok
  restore

  // Set up model class and main method
  mkdir `"`using'/model/"' , public
    file open main using `"`using'/model/main.do"' , write
    file write main "// Main Specification" _n _n
    file write main "mat results = nullmat(results) \ [b,ll,ul,p]" _n _n
    file write main "// End of Main Specification" _n
    file close main

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
  // NEW CLASS subcommand
  cap prog drop specc_new_class
  prog def specc_new_class

    // Syntax setup
    syntax using/ , ///
      [*]

    // Load dataset for specc storage
    preserve
    use `"`using'/specc.dta"' , clear


  end
  // -------------------------------------------------------------------------------------------

  // -------------------------------------------------------------------------------------------
  // NEW METHOD subcommand
  cap prog drop specc_new_class
  prog def specc_new_class

    // Syntax setup
    syntax using/ , ///
      [*]

    // Load dataset for specc storage
    preserve
    use `"`using'/specc.dta"' , clear

  end
  // -------------------------------------------------------------------------------------------

// End of adofile
