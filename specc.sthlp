{smcl}
{* 7 Dec 2019}{...}
{hline}
help for {hi:specc}
{hline}

{title:Title}

{p 2 4}{cmdab:specc} {hline 2} manages component dofiles and alternative specifications
for the creation of specification curves in Stata.

{title:Description}
{marker description}{...}

{p 2 4}{cmdab:specc} is designed to automate the creation of specification curves.
First, it enables the assisted creation of sets of alternative options ("methods")
for each choice in the estimation of a given statistical parameter
(such as outcome definition, covariate choice, and functional form; i.e. "the garden of forking paths").
Second, it automatically assembles all of these individual decisions
into the full set of possible specifications formed by interacting these various choices.
In other words, the intent of {cmdab:specc} is to reduce the programming task
for an exponential number of specifications to a linear amount of coding.
{p_end}

{title:Functions}

{p 2 4}{cmdab:specc initialize}{break} creates the directory and database
that the command will use to build a particular specification curve,
and need only be used at the first call of the command.

{p 2 4}{cmdab:specc new}{break} is used to create a new method
which represents a possible choice at some stage in the choice tree;
it creates a dofile to hold the instructions and a registry entry for the method.

{p 2 4}{cmdab:specc remove}{break} is used to delete a method
which represents a possible choice at some stage in the choice tree;
it deletes the corresponding dofile and registry entry for the method.

{p 2 4}{cmdab:specc set}{break} is used to inform the command
the order in which the choices ("classes") are to be iterated over.
This sequence of choices must end with the estimation ("model") class
so that the estimated parameters are passed back to the results.

{p 2 4}{cmdab:specc report}{break} returns the current state
of the {cmdab:specc} registry (i.e., the available choice classes and methods).
It also reports whether an execution order has been {cmdab:set}
and what the corresponding methods for the ordered classes will be.

{p 2 4}{cmdab:specc run}{break} calculates and executes the full set
of possible choices over the entire range of classes that are {cmdab:set}
and returns the results in the form of a specification curve,
reporting the combination of methods that corresponds to each estimate.


{title:Syntax}

{p 2 2}{it:Note that the correct command is always created by replacing}
	{break}{it:"apply" or "append" with "template" when creating the template,}
	{break}{it:and changing it back to use the completed codebook. It's that easy!}{p_end}

{dlgtab 0:Apply: Setting up and using a codebook to alter current data}

{p 2}{cmdab:iecodebook template} {help using} {it:"/path/to/codebook.xlsx"}{p_end}

{p 2 4 }{cmdab:iecodebook apply} {help using} {it:"/path/to/codebook.xlsx"} {break}
, [{bf:drop}] [{opt miss:ingvalues(# "label" [# "label" ...])}]{p_end}

{p 2 4 } {it:Note: This function operates on the dataset that is open in the current Stata session.}{p_end}

{dlgtab 0:Append: Setting up and using a codebook to harmonize and append multiple datasets}

{p 2 4}{cmdab:iecodebook template} {break}
{it:"/path/to/survey1.dta" "/path/to/survey2.dta" [...]} {break}
{help using} {it:"/path/to/codebook.xlsx"} {break}{p_end}
{p 2 4}, {bf:surveys(}{it:Survey1Name} {it:Survey2Name} [...]{bf:)} [{bf:match}] [{opth gen:erate(varname)}]{p_end}

{p 2 4}{cmdab:iecodebook append} {break}
{it:"/path/to/survey1.dta" "/path/to/survey2.dta" [...]} {break}
{help using} {it:"/path/to/codebook.xlsx"} {break} {p_end}
{p 2 3}, {bf:clear} {bf:surveys(}{it:Survey1Name} {it:Survey2Name} [...]{bf:)} {break}
[{opth gen:erate(varname)} {opt miss:ingvalues(# "label" [# "label" ...])} {bf:keepall}]{p_end}


{dlgtab 0:Export: Creating codebooks and signatures for datasets}

{p 2 4}{cmdab:iecodebook export} ["/path/to/data.dta"] [{help if}] [{help in}] {break}
{help using} {it:"/path/to/codebook.xlsx"} {break} {p_end}
{p 2 4}, [{bf:replace}] [{opt text:only}] [{opt copy:data}] [{opt hash}] [{opt reset}] {break}
    [{bf:trim(}{it:"/path/to/dofile1.do"} [{it:"/path/to/dofile2.do"}] [...]{bf:)}]{p_end}

{hline}

{title:Options}

{synoptset}{...}
{marker Options}{...}
{synopthdr:Apply Options}
{synoptline}
{synopt:{opt drop}}Requests that {cmdab:iecodebook} drop all variables which have no entry in the "name" column in the codebook.
The default behavior is to retain all variables. {bf:Alternatively, to drop variables (or value labels) one-by-one, write . (a single period) in the "name" (or "choices") column of the codebook.}{p_end}
{break}
{synopt:{opt miss:ingvalues()}}This option specifies standardized "extended missing values" to add to every value label definition.
For example, specifying {bf:missingvalues(}{it:.d "Don't Know" .r "Refused" .n "Not Applicable"}{bf:)} will add those codes to every coded answer.{p_end}
{synoptline}

{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Append Options}
{synoptline}
{synopt:{opt clear}}{bf:This option is required}, as {cmdab:iecodebook append} will clear the data in memory.{p_end}
{break}
{synopt:{opt surveys()}}{bf:This option is always required in append.} When creating a template {it:or} reading a codebook from {it:"/path/to/codebook.xlsx"},
{cmdab:iecodebook} will use this list of names to identify each survey in the codebook.
{it:These must be exactly one word} for each survey, and they must come in the same order as the filepaths.
Names must have no spaces or special characters.
When importing, this will also be used to create a variable identifying the source of each observation.{p_end}
{break}
{synopt:{opt match}}This option can be used to "auto-align" the {bf:template} command when preparing for {bf:iecodebook append}.
If specified, it will cause any variables in later datasets with the same original name as a variable in the first dataset
to appear in the same row of the Excel sheet.{p_end}
{break}
{synopt:{opt gen:erate()}}This option names the variable identifying the source of each observation. If left blank, the default is "survey".
This must be specified during both the template and append steps.{p_end}
{break}
{synopt:{opt miss:ingvalues()}}This option specifies standardized "extended missing values" to add to every value label definition.
For example, specifying {bf:missingvalues(}{it:.d "Don't Know" .r "Refused" .n "Not Applicable"}{bf:)} will add those codes to every value-labeled answer.{p_end}
{break}
{synopt:{opt keep:all}}By default, {cmdab:iecodebook append} will only retain those variables with a new {it:name} explicitly written in the codebook to signify manual review for harmonization.
{bf:Specifying this option will keep all variables from all datasets. Use carefully!}
Forcibly appending data, especially of different types, can result in loss of information.
For example, appending a same-named string variable to a numeric variable may cause data deletion.
(This is common when one dataset has all missing values for a given variable.){p_end}
{synoptline}

{break}
{synoptset}{...}
{marker Options}{...}
{synopthdr:Export Options}
{synoptline}
{synopt:{opt replace}}This option allows {cmdab:iecodebook export} to overwrite an existing codebook or dataset.{p_end}
{break}
{synopt:{opt text:only}}This option requests that the codebook be created as a plaintext file.{p_end}
{break}
{synopt:{opt copy:data}}This option requests that a copy of the data be placed at the same location as the codebook, with the same name.{p_end}
{break}
{synopt:{opt hash}}This option requests that a {help datasignature} be placed at the same location as the codebook,
and will return an error if a datasignature file is already there and is different.{p_end}
{break}
{synopt:{opt reset}}This option allows {cmdab:iecodebook export} to overwrite an existing datasignature.{p_end}
{break}
{synopt:{opt trim()}}This option takes one or more dofiles as inputs, and trims the current dataset to only include variables used in those dofiles,
before executing any of the other {bf: export} tasks requested.{p_end}
{synoptline}

{marker example}
{title:Examples}

{dlgtab 0:Apply: Create and prepare a codebook to clean current data}

{p 2 4}{it:Step 1: Use the {bf:template} function to create a codebook template for the current dataset.}{p_end}
    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
    {stata iecodebook template using "codebook.xlsx":iecodebook template using "codebook.xlsx"}

{p 2 4}{it:Step 2: Fill out some instructions on the "survey" sheet.}{p_end}
{p 4}{it:The "name" column renames variables and the "label" column applies labels.}{p_end}
{p 4}{it:The "choices" column applies value labels (defined on the "choices" sheet in Step 3):}{p_end}

{col 3}{c TLC}{hline 91}{c TRC}
{col 3}{c |}{col 4} name{col 12}label{col 22}choices{col 31}name:current{col 45}label:current{col 60}choices:current{col 80}recode:current{col 95}{c |}
{col 3}{c LT}{hline 91}{c RT}
{col 3}{c |}{col 4} _template{col 12}{it:(Ignore this placeholder, but do not delete it.)}{col 45}{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4} {col 95}{c |}
{col 3}{c |}{col 4} car{col 12}Name{col 22}{col 31}make{col 45}Make and Model{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}{it:value}{col 31}{col 45}{col 60} {col 80}{it:recode}{col 95}{c |}
{col 3}{c |}{col 4}{it:rename}{col 12}{it:label}{col 22}{it:labels}{col 31}{it:Current names, labels, types, & value labels}{col 45}{col 60} {col 80}{it:commands}{col 95}{c |}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}  |{col 31}{col 45}{col 60} {col 80}  |{col 95}{c |}
{col 3}{c |}{col 4} dom{col 12}Domestic?{col 22}yesno{col 31}foreign{col 45}Car type{col 60}origin{col 80}(0=1)(1=0){col 95}{c |}
{col 3}{c BLC}{hline 91}{c BRC}

{p 2}{it:Step 3: Use the "choices" sheet to define variable labels according to the following syntax.}{p_end}
{col 3}{c TLC}{hline 27}{c TRC}
{col 3}{c |}{col 4} list_name{col 15} value{col 22} label{col 31}{c |}
{col 3}{c LT}{hline 27}{c RT}
{col 3}{c |}{col 4} yesno{col 15} 0{col 22} No{col 31}{c |}
{col 3}{c |}{col 4} yesno{col 15} 1{col 22} Yes{col 31}{c |}
{col 3}{c |}{col 4}  {col 31}{c |}
{col 3}{c |}{col 4} {it:Each individual label}{col 31}{c |}
{col 3}{c |}{col 4} {it:gets an entry, grouped}{col 31}{c |}
{col 3}{c |}{col 4} {it:by the "list_name"}{col 31}{c |}
{col 3}{c |}{col 4} {it:corresponding to "choices"}{col 31}{c |}
{col 3}{c |}{col 4} {it:on the "survey" sheet.}{col 31}{c |}
{col 3}{c BLC}{hline 27}{c BRC}

{p 2}{it:Step 4: Use the {bf:apply} function to read the completed codebook.}{p_end}
{p 4 4}{it:Note that the correct command is created by replacing}
	{break}{it:"template" with "apply" after creating the template.}{p_end}
{break}
    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
    {stata iecodebook apply using "codebook.xlsx":iecodebook apply using "codebook.xlsx"}
    {stata ta dom:tab dom}

{dlgtab 0:Append: Harmonize and combine multiple datasets using a codebook}

{p 2}{it:Step 0: Create two dummy datasets for testing iecodebook append.}{p_end}
    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
    	{stata save data1.dta , replace:save data1.dta , replace}
    {stata rename (price foreign mpg)(cost origin car_mpg):rename (price foreign mpg)(cost origin car_mpg)}
    	{stata save data2.dta , replace:save data2.dta , replace}

{p 2 4}{it:Step 1: Create a harmonization template for iecodebook append.}{break}{it:Note that this clears current data.}{p_end}
{break}
{p 4 6}{inp:iecodebook template}
{break}{inp:"data1.dta" "data2.dta"}
{break}{inp: using "codebook.xlsx"}
{break}{inp: , surveys(First Second)}
{break}{stata iecodebook template "data1.dta" "data2.dta" using "codebook.xlsx" , surveys(First Second):(Run)}
{p_end}

{p 2}{it:Step 2: Fill out some instructions on the "survey" sheet.}{p_end}
{break}{p 4}{it:The survey sheet is designed to be rearranged so that stacked variables are placed in the same row.}{p_end}
{break}{p 4}{it:There will also be one extra "choices" sheet per survey with existing value labels for your reference.}{p_end}
{col 3}{c TLC}{hline 91}{c TRC}
{col 3}{c |}{col 4} name{col 12}label{col 22}choices{col 31}name:First{col 45}recode:First{col 60}name:Second{col 80}recode:Second{col 95}{c |}
{col 3}{c LT}{hline 91}{c RT}
{col 3}{c |}{col 4} survey{col 12}{it:Data Source (do not edit this row)}{col 45}{col 60} {col 80} {col 95}{c |}
{col 3}{c |}{col 4} {col 95}{c |}
{col 3}{c |}{col 4} cost{col 12}Cost{col 22}{col 31}price{col 45}{col 60}cost{col 80}{col 95}{c |}<- {it:align old}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}{it:value}{col 31}{col 45}{col 60} {col 80}{col 95}{c |}   {it:names}
{col 3}{c |}{col 4}{it:rename}{col 12}{it:label}{col 22}{it:labels}{col 31}{it:Original names, labels, types, & value labels for reference}{col 45}{col 60} {col 80}{col 95}{c |}   {it:and new}
{col 3}{c |}{col 4}  |{col 12}  |{col 22}  |{col 31}{col 45}{col 60} {col 80}{col 95}{c |}   {it:recode}
{col 3}{c |}{col 4} dom{col 12}Domestic?{col 22}yesno{col 31}foreign{col 45}(0=1)(1=0){col 60}origin{col 80}(0=1)(1=0){col 95}{c |}<- {it:commands}
{col 3}{c BLC}{hline 91}{c BRC}
{p 2 4} {it: Note: When aligning the old variable names in the same row, cut and paste the whole variable entry.}
{break}{it:Don't just copy the names, leaving the old names in the original place.}

{p 2}{it:Step 3: Read and apply the harmonization template.}{p_end}
{p 4 4}{it:Note that the correct command is created by replacing}
	{break}{it:"template" with "append" after creating the template.}{p_end}
{break}
{p 4 6}{inp:iecodebook append}
{break}{inp:"data1.dta" "data2.dta"}
{break}{inp: using "codebook.xlsx"}
{break}{inp: , clear surveys(First Second)}
{break}{stata iecodebook append "data1.dta" "data2.dta" using "codebook.xlsx" , clear surveys(First Second):(Run)}{p_end}

{dlgtab 0:Export: Creating a simple codebook}
{break}
{p 2 2}{stata sysuse auto.dta , clear:sysuse auto.dta , clear}
{break}{stata iecodebook export using "codebook.xlsx":iecodebook export using "codebook.xlsx"}{p_end}

{hline}

{title:Acknowledgements}

{p 2 4}We would like to acknowledge the help in testing and proofreading we received
 in relation to this command and help file from (in alphabetical order):{p_end}{break}
{pmore}Kristoffer Bjarkefur{break}Luiza Cardoso De Andrade{break}Saori Iwamoto{break}Maria Ruth Jones{break}{break}...and all DIME Research Assistants and Field Coordinators{break}

{title:Authors}

{p 2}Benjamin Daniels, The World Bank, DEC

{p 2 4}Please send bug reports, suggestions and requests for clarifications
		 writing "iefieldkit: iecodebook" in the subject line to the email address
		 found {browse "https://github.com/worldbank/iefieldkit":here}.

{p 2 4}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through
		 the GitHub repository for iefieldkit:{break}
		 {browse "https://github.com/worldbank/iefieldkit"}
		 {p_end}
