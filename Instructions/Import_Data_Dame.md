# Importing Data

The Import Data tab has several functions beyond uploading the necessary files to run DAME. It can be considered the core of DAME and establishes the data used in the analysis tabs (α-Diversity, β -Diversity, and Differential-Abundance).  

Importation of the BIOM file is handled by the read_biom() function from the [biomformat](https://www.bioconductor.org/packages/release/bioc/html/biomformat.html) package, and converted to a phyloseq object using the [phyloseq package](https://joey711.github.io/phyloseq/index.html).

# Getting Started

Selecting the Import Data tab provides widgets for uploading the required files in addition to a widget for uploading a TRE file for phylogenic trees and an option to use an example data set.  

![](https://github.com/bdpiccolo/ACNC-DAME/blob/master/Instructions/Images/DAME_Import_Upload_Widgets.png?raw=true)

1. Import Microbiome Data (.biom):

    * Select Browse..., and a new window will open.  Files with a .biom extension will be displayed in the window.  Select file and press open.
	
	* A full status bar will appear on the widget when the .biom file is fully uploaded.   
	
	* Larger .biom files will require a longer loading time.

2. Import Metadata (.csv):

    * Select Browse..., and a new window will open.  Files with a .csv extension will be displayed in the window.  Select file and press open.
	
	* A full status bar will appear on the widget when the .biom file is fully uploaded.   	

3. Import Phylogeny (OPTIONAL; .tre):

	* Phylogenic Tree file is optional.  Currently, DAME only utilizes a .tre file for β-Diversity calculations (Weighted and Unweighted Unifrac, and DPCoA distances). 
  
  * Importation of .tre file is handled through the read.tree() function from the [ape package](http://ape-package.ird.fr/)

  * Select Browse..., and a new window will open.  Files with a .tre extension will be displayed in the window.  Select file and press open.
	
	* A full status bar will appear on the widget when the .biom file is fully uploaded.   
	
	* Larger .tre files will require a longer loading time.

	* Addition of .tre file will likely slow other computational calculations, e.g. agglomerations, beta-diversity calculations, etc.
	
4. Load example data set?

	* An example data set is provided and can be rendered by choosing *Yes*.

# Description of Imported Data

When both the BIOM and metadata CSV files are uploaded (or loading the example dataset), DAME will automatically render descriptive statistics of the data and filtering widgets.

![](https://github.com/bdpiccolo/ACNC-DAME/blob/master/Instructions/Images/DAME_Import_importdata_description.png?raw=true)

1. Select Taxonomic level

	* Selects the taxonomic level displayed on the table to the right.
	
	* Update table to the right to display individual taxa data at Domain, Phylum, Class, Order, Family, and Genus levels.
	
2. Original Data Description

	* Provides global details of the BIOM and Metadata files
	
	* Displays number of taxonomic levels, number of OTUs, number of samples, and number of columns detected in the metadata file.

3. Taxa level descriptive statistics

	* Provided as an interactive table using the [DT](https://rstudio.github.io/DT/) package.  
	
	* Defaults to phylum level.  Other taxonomic levels can be chosen using the widget to the left.  
	
	* Individual taxa is displayed in left column and the other columns provides statistics related to prevalance, total reads, and total OTUs
	
	* Sample Prevalance is defined as the number of samples that a taxa was found with at least 1 count.  The table provides mean, median, max, and min prevalance statistics.
	
	* Reads are the total read counts found in the BIOM file for each taxa.  The table provides the total reads and percent of total reads for a given taxa.
	
	* OTU (Operational Taxonomic Unit) is the cluster of similar sequences that are synonymous with bacterial species.  The table provides the total number of OTUs and the percent of total OTUs under a given taxa.

	* Table is fully interactive: 
	
		* Expand and contract number of rows using the Show entries drop down feature.
		
		* Save table to either different file formats (Excel, PDF, and CSV).  Will only save the currently displayed information.
		
		* Search capabilities.
		
		* All columns are sortable.
		
		* Can select previous or next pages.
		
4. Downloading raw OTU tables

	* Clicking on the hyperlink, *Show/hide Raw OTU Table Downloading Options* will reveal a character input box, data type selections, and a control button.
	
	* The OTU table is agglomerated to the selected taxonomic levels (selected from input above).  Defaults to phylum.

	* Can choose name of file by inputting text into Choose File Name widget.  
	
	* Can choose OTU table in total reads or as percent abundance.
	
	* Pressing the *Download Raw Data* button will download an OTU table in .csv format.
		
# Selecting experimental groups, samples, and filters

Although the data has been imported, DAME will not open the disabled tabs until the *Finalize Import and Filters* tab is pressed. DAME automatically selects all experimental group levels for analyses, but group levels can be unselected if desired.  DAME also defaults to a minimum sample count threshold of 1000 with no additional OTU filters.  Thus, pressing the *Finalize Import and Filters* button at the default setting will keep all loaded samples that have > 1000 total counts and retain all OTUs.

The disabled tabs will open after the *Finalize Import and Filters* button is pressed for the first time after DAME has loaded.  Although the tabs are now open and available for statistical analysis, it does not prevent the user to modify the data utilized for these analyses.  At any point, experimental groups/samples can be selected/deselected and additional filtering thresholds can be set.  __The *Finalize Import and Filters* button must be pressed again when future selections are required__ or the new selections will not carry over to the other tabs for statistical analyses. 

![](https://github.com/bdpiccolo/ACNC-DAME/blob/master/Instructions/Images/DAME_Import_filter_options.png?raw=true)

1. Choose Metadata to Filter

	* Rendering of experimental groups are directly from the uploaded metadata.
	
	* The title of each experimental group is the column header in the metadata file.  Factor levels are rendered with selection boxes that can be checked and unchecked.
	
	* Duplicate columns in the metadata file will render a single group selection.  
  
  * Columns from the metadata file will not render if the number of factors equal the number of total rows in the metadata (e.g., continuous data).  Note: continous data that have 2 or more measurement with the same value will render here.
	
	* Deselecting a factor level within an experimental group will remove all samples from further analyses.  The sample IDs selections to the right do not need to be unselected as well.  DAME will not automatically unselect those samples, i.e., the sample ID selections are not reactive to selections in the group filter or vice versa.
  
  * Selected/unselected choices will not be updated until the *Finalize Import and Filters* button is pressed
	
2. Choose Sample ID(s) to Filter

	* All sample IDs that matched between the BIOM and Metadata file are displayed here and can be selected/unselected.
	
	* Unselecting sample ID will remove sample from further analyses.
 
  * Selected/unselected choices will not be updated until the *Finalize Import and Filters* button is pressed
		
3. Select Minimum Count Threshold

	* Sets threshold to filter samples that have a low total number of counts.  Samples with total number of counts below the threshold will be removed from further analyses.
	
	* Defaults to 1000.  Minimum input of 0 and no limit on maximum input.
	
4. Choose Minimum Number of Reads per Measurement/Choose Percent Threshold to Filter OTUs

	* Sets threshold to filter OTUs that do not have a minimum number of counts.  
	
	* Dropdown selection sequenced between 0 and 20 by 1 unit.  
	
	* Works in conjuction with the widget to the right, *Choose Percent Threshold to Filter OTUs*.
	
		* Sets threshold to filter OTUS that are found within a minimum total percentage.
		
		* Dropdown selection to set minimum filter percentage between 0 and 20 by 1 unit.
		
		* For example, Use both filter widgets to filter OTUs that have a minimum number of reads across a minimum percentage of all samples.
		
5. Only Analyze Bacteria

	* Sequence reads from other organisms (i.e., non-bacteria) may be in BIOM file.  Selection default to NO, meaning all OTUs will be used in analysis.
	
	* Selecting YES will filter OTUs that are not found within the Bacteria domain.
	
6. Finalize Import and Filter

	* Pressing the *Finalize Import and Filter* finalizes the experimental group selections and filters samples/OTUs based on inputs.
	
	* On the initial loading of DAME, pressing the *Finalize Import and Filter* button will open the Alpha-Diversity, Beta-Diversity, and Differential-Abundance tabs.
	
	* Needs to be pressed if any changes are made to experimental groups, sample ID, and filter inputs after the first pressing.  Subsequent changes will not be reflected in other tabs if not pressed.
	
	* Renders another descriptive table as before, but detailing final data used in further analysis.
	
7. Description of Final Data

Exactly the same output and table provided above in Description of Imported Data, but for finalized data.  
		
![](https://github.com/bdpiccolo/ACNC-DAME/blob/master/Instructions/Images/DAME_Import_filterdata_description.png?raw=true)
