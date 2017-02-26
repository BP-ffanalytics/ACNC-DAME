

	######################################################################
	## Toggle regular/larger text 
	######################################################################
	observe({
		shinyjs::toggleClass("text_import", "big", input$IMPORTbig)
    })

	######################################################################
	## Import .BIOM file
	######################################################################
	BIOM_DAT <- reactive({
		if (is.null(input$biomINPUT)) {
			return(NULL)	
		} else {
		
			## check whether a .BIOM file is uploaded
			validate(
				need(tools::file_ext(input$biomINPUT$name) %in% c(
					'biom'
				), "Wrong File Format Uploaded")
			)			
			# Extract OTU table and convert OTU data into a matrix
			BIOM <- read_biom(fixUploadedFilesNames(input$biomINPUT)$datapath)
			BIOMmatrix <- as(biom_data(BIOM), "matrix")
			## Extract TAXA data and rename columns
			BIOMtax_matrix <- as.matrix(observation_metadata(BIOM))
			colnames(BIOMtax_matrix) <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
			## Return OTU and TAXA data as list
			list(OTU=BIOMmatrix, TAXA=BIOMtax_matrix)
			
		}
	})	 

	######################################################################
	## Import Example .BIOM file
	######################################################################
	Example_BIOM_DAT <- reactive({
		if (is.null(input$biomINPUT) & is.null(input$biommetaINPUT) & is.null(input$treINPUT)) {
			if(as.numeric(input$loadexample) == 2){
				BIOM <- read_biom("./Example/otu_table_mc2_w_tax_KITTEST.biom")
				BIOMmatrix <- as(biom_data(BIOM), "matrix")
				## Extract TAXA data and rename columns
				BIOMtax_matrix <- as.matrix(observation_metadata(BIOM))
				colnames(BIOMtax_matrix) <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
				## Return OTU and TAXA data as list
				list(OTU=BIOMmatrix, TAXA=BIOMtax_matrix)
			} else {
				NULL
			}
		} else {
			NULL
		}
	})	 

	######################################################################
	## Extract OTU data from upload 
	######################################################################		
	BIOM_OTU <- reactive({
		req(BIOM_DAT())
		## Order columns in ascending order
		BIOM_DAT()$OTU[,order(colnames(BIOM_DAT()$OTU))]
	})

	######################################################################
	## Extract Example OTU data from upload 
	######################################################################		
	Example_BIOM_OTU <- reactive({
		req(Example_BIOM_DAT())
		## Order columns in ascending order
		Example_BIOM_DAT()$OTU[,order(colnames(Example_BIOM_DAT()$OTU))]
	})

	######################################################################
	## Import .CSV Metadata file
	######################################################################
	BIOMmetad_IMPORT <- reactive({
		if (is.null(input$biommetaINPUT)) {
			return(NULL)
		} else {
			## check whether a .CSV file is uploaded
			validate(
				need(tools::file_ext(input$biommetaINPUT$name) %in% c(
					'csv'
				), "Wrong File Format Uploaded")
			)	
			## Import .CSV file
			metaD <- read.csv(input$biommetaINPUT$datapath, header=TRUE, comment.char = "", check.names = FALSE)
			metaD <- metaD[!duplicated(lapply(metaD, summary))]
			metaD
		}
	})	

	# output$importTEXT <- renderPrint({
	# })	
	
	######################################################################
	## Import Example .CSV Metadata file
	######################################################################
	Example_BIOMmetad_IMPORT <- reactive({
		if (is.null(input$biomINPUT) & is.null(input$biommetaINPUT) & is.null(input$treINPUT)) {
			if(as.numeric(input$loadexample) == 2){		
				metaD <- read.csv("./Example/map_KITTEST_infantfeces_v2_DAME.csv", header=TRUE, comment.char = "", check.names = FALSE)
				metaD		
			} else {
				return(NULL)
			}
		} else {
			return(NULL)
		}
	})	

	######################################################################
	## Assess whether OTU and metadata have the same dimensions
	######################################################################	
	BIOM_META_rowlengthmatch <- reactive({
		req(BIOM_OTU())
		req(BIOMmetad_IMPORT())
		## if number of rows in metadata does not equal number of columns in OTU data
		if(nrow(BIOMmetad_IMPORT()) != length(colnames(BIOM_OTU()))) {
			## Return object
			"Column length of BIOM file and row length of BIOM Metadata do NOT match!"
		} else {
			## Or return nothing
			NULL
		}
	})

	######################################################################
	## Assess whether all labels in OTU are found in metadata
	######################################################################		
	BIOM_META_nomatchingcolumn <- reactive({
		req(BIOM_OTU())
		req(BIOMmetad_IMPORT())
		## if number of rows in metadata does not equal number of columns in OTU data
		if(nrow(BIOMmetad_IMPORT()) != length(colnames(BIOM_OTU()))) {
			## Return nothing
			NULL
		} else {
			## Or check if the column names in the OTU file match elements in 
			## at least 1 of the metadata columns
			## If there is not a match
			if(sapply(BIOMmetad_IMPORT(), function(x) setequal(colnames(BIOM_OTU()) %in% x, TRUE)) == FALSE){
				## Return Object
				"There is a not a column in the BIOM Metadata that contains all column IDS in the BIOM file"
			} else {
				## Or return nothing
				NULL
			}
		}
	})

	######################################################################
	## Assess whether labels in OTU and metadata are equal
	######################################################################			
	BIOM_META_nomatchingIDs <- renderUI({
		req(BIOM_OTU())
		req(BIOMmetad_IMPORT())
		metaD <- BIOMmetad_IMPORT()
		## if number of rows in metadata does not equal number of columns in OTU data
		if(nrow(metaD) != length(colnames(BIOM_OTU()))) {
			## Return nothing
			NULL
		} else {
			## Or check if the column names in the OTU file match elements in 
			## at least 1 of the metadata columns
			## If there is not a match
			if(setequal(sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE)), FALSE)){
				## Return nothing
				NULL
			} else {
				## Or set row names of the metadata as the matching column of BIOM identifiers
				# matchcolumn <- metaD[,sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE))]
				rownames(metaD) <- metaD[,sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE))]
				## Make sure BIOM columns are in ascending order
				biomDAT <- BIOM_OTU()[,order(colnames(BIOM_OTU()))]
				## set metadata rows into ascending order
				metaDAT <- metaD[order(rownames(metaD)),]
				## test whether the metadata row names equals the BIOM data column names
				if(setequal(rownames(metaDAT) != colnames(biomDAT), TRUE)) {
					## If it doesn't then return object
					"There is disagreement between the IDs in the BIOM file and the IDs of the BIOM Metadata file."
				} else {
					## Or return nothing
					NULL
				}
			}
		}
	})

	######################################################################
	## Check whether a factor level starts with a number
	######################################################################				
	BIOM_META_numberstartgroup <- reactive({
		req(BIOM_OTU())
		req(BIOMmetad_IMPORT())
		metaD <- BIOMmetad_IMPORT()
		## if number of rows in metadata does not equal number of columns in OTU data
		if(nrow(metaD) != length(colnames(BIOM_OTU()))) {
			## Return nothing
			NULL
		} else {
			if(setequal(sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE)), FALSE)){
			## Return nothing
				NULL
			} else {
				# matchcolumn <- metaD[,sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE))]
				## Or set row names of the metadata as the matching column of BIOM identifiers
				rownames(metaD) <- metaD[,sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE))]
				metaD[,sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE))] <- NULL
				## Make sure BIOM columns are in ascending order
				biomDAT <- BIOM_OTU()[,order(colnames(BIOM_OTU()))]
				## set metadata rows into ascending order
				metaDAT <- metaD[order(rownames(metaD)),]		
				## In each metadata column, extract the first element in the character string,
				## coerce into a factor, character, and number.
				## If number, will result in an NA
				isthereNA <- lapply(metaDAT, function(x) as.numeric(as.character(factor(as.character(substr(x, 1, 1))))))
				## Check whether there is NA and sum.
				sumSC <- sum(unlist(lapply(isthereNA, function(x) length(x[!(x %in% NA)]) != 0)) > 0)
				## If sum does not equal 0
				if(sumSC != 0) {
					## return object
					"Groups starting with number or SC"
				} else {
					## Or return nothing
					NULL
				}
			}
		}
	})

	######################################################################
	## Render mismatch row warning
	######################################################################		
	output$BIOMMETArowlengthmatch <- renderUI({
		req(BIOM_OTU())
		req(BIOMmetad_IMPORT())
		req(BIOM_META_rowlengthmatch())
		
			p(id="nomatch", em(strong("The inputs for \"Biom Data\" and \"Biom Metadata\" do not have the same number of rows.  
				Please re-configure BIOM MetaData .CSV files to correct.")))

	})	

	
	######################################################################
	## Render mismatch label warning
	######################################################################			
	output$BIOMMETAnomatch <- renderUI({
		req(BIOM_OTU())
		req(BIOMmetad_IMPORT())
		req(BIOM_META_nomatchingcolumn())
		
			p(id="nomatch", em(strong("There is not a column in the \"Biom Metadata\" that exactly equals the column labels in the \"Biom Metadata\".  
					Please re-configure BIOM MetaData .CSV files to correct.")))

	})	
	
	######################################################################
	## Render missing/duplicate warning
	######################################################################	
	output$BIOMMETAnomatchingIDs <- renderUI({
		req(BIOM_OTU())
		req(BIOMmetad_IMPORT())
		req(BIOM_META_nomatchingcolumn())
		req(BIOM_META_nomatchingIDs())
		
			p(id="nomatch", em(strong("There is either a missing or duplicate ID in the \"Biom Metadata\".  
					Please re-configure BIOM MetaData .CSV files to correct.")))

	})

	######################################################################
	## Render numerical factor warning
	######################################################################						
	output$BIOMMETAnumberstartgroup <- renderUI({
		req(BIOM_OTU())
		req(BIOMmetad_IMPORT())
		req(BIOM_META_numberstartgroup())
		
			p(id="nomatch", em(strong("There is a column the \"Biom Metadata\" that has a group level starting with an integer.  
					Please re-configure BIOM MetaData .CSV files to correct.")))

	})	

	######################################################################
	## Import .TRE file
	######################################################################	
	TRE_DAT <- reactive({
		if (is.null(input$treINPUT)) {
			return(NULL)
		} else {
			validate(
				need(tools::file_ext(input$treINPUT$name) %in% c(
					'tre'
				), "Wrong File Format Uploaded")
			)		
			read.tree(fixUploadedFilesNames(input$treINPUT)$datapath)
		}
	})	

	######################################################################
	## Render Example text and option
	######################################################################	
	output$PHYLOSEQloadexampleRENDER <- renderUI({
		if (is.null(input$biomINPUT) & is.null(input$biommetaINPUT) & is.null(input$treINPUT)) {
			list(
				column(3,
					HTML("
					
					<h4><strong>Load example data set?</strong></h4>
					"
					),
					radioButtons("loadexample", label = "",
						choices = list("NO" = 1, "YES" = 2), selected = 1
					)
				)
			)
		} else {
			NULL
		}
	})
	
	
	######################################################################
	## Create label key
	######################################################################		
	KEY <- reactive({
		req(BIOM_OTU())
		req(BIOMmetad_DAT())		
		colnames(BIOM_OTU())
	})

	######################################################################
	## Finalize metadata object
	######################################################################		
	BIOMmetad_DAT <- reactive({
		req(BIOM_OTU())
		req(BIOMmetad_IMPORT())
		
		metaD <- BIOMmetad_IMPORT()
		## if number of rows in metadata does not equal number of columns in OTU data
		if(nrow(metaD) != length(colnames(BIOM_OTU()))) {
			"rows in metadata does not equal number of columns in OTU data"
			# NULL
		} else {
			if(setequal(sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE)), FALSE)){
			"There is not a columns that has all of the OTU labels in the metadata"
				# NULL		
			} else {
				# matchcolumn <- metaD[,sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE))]
				## Or set row names of the metadata as the matching column of BIOM identifiers
				rownames(metaD) <- metaD[,sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE))]
				metaD[,sapply(metaD, function(x) setequal(x %in% colnames(BIOM_OTU()), TRUE))] <- NULL
				
				
				## Make sure BIOM columns are in ascending order
				biomDAT <- BIOM_OTU()[,order(colnames(BIOM_OTU()))]
				## set metadata rows into ascending order
				metaDAT <- metaD[order(rownames(metaD)),]
				if(class(metaDAT) != "data.frame") {
					metaDAT <- data.frame(metaDAT)
					colnames(metaDAT)[1] <- colnames(metaD)[1]
					rownames(metaDAT) <- rownames(metaD)[order(rownames(metaD))]
				} else {
					metaDAT <- metaDAT
				}
				# list(metaD,metaDAT)
				
				
				if(setequal(rownames(metaDAT) == colnames(biomDAT), TRUE)) {
					"There is disagreement between the IDs in the BIOM file and the IDs of the BIOM Metadata file."
				} else {
					# Return nothing
					NULL
				}
				## In each metadata column, extract the first element in the character string,
				## coerce into a factor, character, and number.
				## If number, will result in an NA
				if(ncol(metaDAT) == 1) {
					isthereNA <- as.numeric(as.character(factor(as.character(substr(metaDAT[,1], 1, 1)))))
					sumSC <- length(isthereNA[!(isthereNA %in% NA)])
				} else {
					isthereNA <- lapply(metaDAT, function(x) as.numeric(as.character(factor(as.character(substr(x, 1, 1))))))
					sumSC <- sum(unlist(lapply(isthereNA, function(x) length(x[!(x %in% NA)]) != 0)) > 0)
				}
				if(sumSC != 0) {
					## Return nothing
					NULL
				} else {
					if(ncol(metaDAT) == 1) {
						BIOMmetad_DAT <- metaDAT
						BIOMmetad_DAT[,1] <- as.factor(BIOMmetad_DAT[,1])
						BIOMmetad_DAT
					} else {
						## Subset metadata to match column IDs
						BIOMmetad_DAT <- metaDAT[rownames(metaDAT) %in% colnames(BIOM_OTU()),]
						## Coerce all metadata columns into factors
						BIOMmetad_DAT <- data.frame(sapply(BIOMmetad_DAT, as.factor))
						## Set names and return
						rownames(BIOMmetad_DAT) <- colnames(BIOM_OTU())
						BIOMmetad_DAT
					}
				}
				# list(ncol(metaDAT), isthereNA, sumSC, BIOMmetad_DAT)
			}	
		}
	})

	######################################################################
	## Process Example data
	######################################################################
	ExampleProcessing <- reactive({
		if (is.null(input$biomINPUT) & is.null(input$biommetaINPUT) & is.null(input$treINPUT)) {
			req(Example_BIOM_OTU())
			req(Example_BIOMmetad_IMPORT())
			key <- colnames(Example_BIOM_OTU())
			EBOTU <- Example_BIOM_OTU()
			EBTAXA <- Example_BIOM_DAT()$TAXA
			metaD <- Example_BIOMmetad_IMPORT()
			rownames(metaD) <- metaD[,sapply(metaD, function(x) setequal(x %in% colnames(EBOTU), TRUE))]
			metaD[,sapply(metaD, function(x) setequal(x %in% colnames(EBOTU), TRUE))] <- NULL
			# Make sure BIOM columns are in ascending order
			biomDAT <- EBOTU[,order(colnames(EBOTU))]
			# set metadata rows into ascending order
			metaDAT <- metaD[order(rownames(metaD)),]			
			## Subset metadata to match column IDs
			BIOMmetad_DAT <- metaDAT[rownames(metaDAT) %in% colnames(EBOTU),]
			## Coerce all metadata columns into factors
			BIOMmetad_DAT <- data.frame(sapply(BIOMmetad_DAT, as.factor))
			## Set names and return
			rownames(BIOMmetad_DAT) <- colnames(EBOTU)
			# BIOMmetad_DAT
			list(OTU=biomDAT, META=BIOMmetad_DAT, TAXA=EBTAXA, KEY=key)
		} else {
			return(NULL)
		}
		
	})	
	
	######################################################################
	## Create initial phyloseq object
	######################################################################		
	PHYLOSEQ <- reactive({
		if (is.null(input$biomINPUT) & is.null(input$biommetaINPUT) & is.null(input$treINPUT)) {
			req(ExampleProcessing())
			OTU_import <- ExampleProcessing()$OTU
			META_import <- ExampleProcessing()$META
			TAXA_import <- ExampleProcessing()$TAXA
		} else {
			req(BIOMmetad_DAT())
			req(BIOM_OTU())
			OTU_import <- BIOM_OTU()
 			META_import <- BIOMmetad_DAT()
			TAXA_import <- BIOM_DAT()$TAXA
		}
				## If no tree data
				if(is.null(TRE_DAT())){
					# Convert OTU data into phyloseq otu_table class
					OTU <- otu_table(OTU_import, taxa_are_rows = TRUE)
					# Convert taxa data into phyloseq taxonomyTable class
					TAXA <- tax_table(TAXA_import)
					# Convert Sample Metadata data frame into phyloseq sample_data class
					SAMP <- sample_data(META_import)	
					## Create phyloseq object
					pseq <- phyloseq(OTU, TAXA, SAMP)
				} else {
					# Convert OTU data into phyloseq otu_table class
					OTU <- otu_table(OTU_import, taxa_are_rows = TRUE)
					# Convert taxa data into phyloseq taxonomyTable class
					TAXA <- tax_table(TAXA_import)
					# Convert Sample Metadata data frame into phyloseq sample_data class
					SAMP <- sample_data(META_import)
					## Finalize tree data
					tre <- TRE_DAT()
					TRE <- root(tre, 1, resolve.root = T)
					## Create phyloseq object
					pseq <- phyloseq(OTU, TAXA, SAMP, TRE)
				}
				## Remove taxa prefixes (eg., 'g__') and add 'Unassigned' labels to all missing labels
				tax_table(pseq) <- taxaconvert(pseq, label_UNK=TRUE)
				pseq
			# }
		# }
	})

	######################################################################
	## Make object that lists Metadata column names and factor levels
	######################################################################		
	metaselections <- reactive({ 
		if (is.null(input$biomINPUT) & is.null(input$biommetaINPUT) & is.null(input$treINPUT)) {
		
			req(PHYLOSEQ())
			meta <- ExampleProcessing()$META
		} else {	
			req(PHYLOSEQ())
			meta <- BIOMmetad_DAT()
		}
		## Remove KEY column
		
		# metakey <- meta[,!(colnames(meta) %in% KEY())]
		## Remove columns that have the same number of factor levels as number of rows in data frame
		# if object is still a data frame, ie, multiple columns remain
		if(class(meta) != "data.frame") {
			## make a list with factor levels
			singleLEVELS <- list(levels(meta))
			## Get name of remaining column
			# Metacolumns <- colnames(meta)[!(colnames(meta) %in% KEY())]
			## update name of list with name of remaining column
			names(singleLEVELS) <- colnames(meta)				
			# names(singleLEVELS) <- colnames(meta)[!(colnames(meta) %in% KEY())]				
			# print("single columns after key filter")
		} else {
			
			metaALLROWS <- meta[,sapply(meta, nlevels) != nrow(meta)]
			if(class(metaALLROWS) != "data.frame") {
			# If not a data frame, ie, only one column left
				# make a list with factor levels
				singleLEVELS <- list(levels(metaALLROWS))
				# Get name of remaining column
				# Metacolumns <- colnames(meta)
				Metacolumns <- colnames(meta)[sapply(meta, nlevels) != nrow(meta)]
				# update name of list with name of remaining column
				names(singleLEVELS) <- colnames(meta)[sapply(meta, nlevels) != nrow(meta)]
				# print("single columns after nrow filter")
			} else {
				meta1FL <- metaALLROWS[,sapply(metaALLROWS, nlevels) != 1]
				if(class(meta1FL) != "data.frame") {
				# If not a data frame, ie, only one column left
					# make a list with factor levels
					singleLEVELS <- list(levels(meta1FL))
					# Get name of remaining column
					# Metacolumns <- colnames(meta)
					Metacolumns <- colnames(meta)[sapply(meta, nlevels) != nrow(meta)]
					# update name of list with name of remaining column
					names(singleLEVELS) <- colnames(meta)[sapply(meta, nlevels) != nrow(meta)]
					# print("single columns after nrow filter")					
				} else {		
				
					
					# Get names of remaining columns 
					# Metacolumns <- colnames(meta)
					# Metacolumns <- colnames(meta)[sapply(meta, nlevels) != nrow(meta)]
					Metacolumns <- colnames(meta1FL)[sapply(meta1FL, nlevels) != nrow(meta1FL)]
					# Get factor levesl across all columns and turn it into a list
					singleLEVELS <- lapply(meta1FL[,sapply(meta1FL, nlevels) != nrow(meta1FL)], levels)
					# print("multiple columns after key and nrow filter")
				}
			}
			
		}
		list(Groups = Metacolumns, Levels=singleLEVELS)
		# metaFINAL

	})

	######################################################################
	## Render Taxonomic level text for original data description
	######################################################################			
	output$PHYLOSEQtaxaselectTEXT <- renderUI({
		req(PHYLOSEQ())
		HTML("
			<p id=\"filterheader\"><strong>Select Taxonomic level</strong></p>
			"
		)

	})

	######################################################################
	## Render taxonomic levels for original data description
	######################################################################	
	output$tableTAXAselection_RENDER <- renderUI({ 
		req(PHYLOSEQ())
		selectInput(inputId="PHYLOSEQtabletaxa", label="", 
			choices=c("Domain","Phylum","Class","Order","Family","Genus"), selected="Phylum"
		)
	})

	######################################################################
	## Create object with data description
	######################################################################		
	PHYLOSEQ1desc <- reactive({
		# Compute prevalence of each feature, store as data.frame
		preval = apply(X = otu_table(PHYLOSEQ()),
						 MARGIN = ifelse(taxa_are_rows(PHYLOSEQ()), yes = 1, no = 2),
						 FUN = function(x){sum(x > 0)})
		# Add taxonomy and total read counts to this data.frame
		prevdf = data.frame(Prevalence = preval, # Number of samples (rats) that contain a specific OTU
							  TotalAbundance = taxa_sums(PHYLOSEQ()), # total number of OTUs found across all samples
							  tax_table(PHYLOSEQ()))
						  
		## Group by taxa level, and then calculate, mean, median, max, min of sample prevalance, and sum of total reads
		## and remove any data with no reads
		SAMPLE_prevalence_stats <- prevdf %>% group_by_(input$PHYLOSEQtabletaxa) %>% 
			summarise(MEAN_READS=round(mean(Prevalence),1), MEDIAN_READS=median(Prevalence), MAX_READ=max(Prevalence), 
				MIN_READ=min(Prevalence),TOTALREADS=sum(TotalAbundance)) %>%
				subset(TOTALREADS > 0) 
		## Subset Taxonomic level and coerce to data frame		
		SAMPLE_taxa <- as.data.frame(SAMPLE_prevalence_stats[,input$PHYLOSEQtabletaxa])[,1]
		## Sum the amount of TAXA for selected level
		ps0p <- table(tax_table(PHYLOSEQ())[, input$PHYLOSEQtabletaxa], exclude = NULL)[SAMPLE_taxa]
		## Add columns with percent reads, total taxa, and percent taxa. 
		## Return
		SAMPLE_prevalence_stats <- SAMPLE_prevalence_stats %>%
			mutate(PC_TR = (round(TOTALREADS/sum(TOTALREADS), 5))*100)  %>%
			mutate(N = ps0p) %>%
			mutate(PC_ABUND = (round(N/sum(N), 5))*100)
		SAMPLE_prevalence_stats
	})

	######################################################################
	## Create DataTable object with original data description
	######################################################################	
	output$PHYLOSEQinitialdescRENDER <- DT::renderDataTable({
		req(PHYLOSEQ())	
		t1 <- as.data.frame(PHYLOSEQ1desc())
		t1[,!(colnames(t1) %in% input$PHYLOSEQtabletaxa)] <- 
			apply(PHYLOSEQ1desc()[,!(colnames(PHYLOSEQ1desc()) %in% input$PHYLOSEQtabletaxa)], 2, as.numeric)
		datatable(t1, extensions='Buttons', rownames = FALSE,
			container = htmltools::withTags(table(
				class = 'display',
					thead(
						tr(
							th(colspan = 1, ''),
							th(colspan = 4, 'Sample Prevalance'),
							th(colspan = 2, 'Reads'),
							th(colspan = 2, 'OTU')	  
						),
						tr(
							th(colspan = 1, 'Taxa'),
							th(colspan = 1, 'Mean Sample Prevalance'),
							th(colspan = 1, 'Median Sample Prevalance'),
							th(colspan = 1, 'Max Sample Prevalance'),
							th(colspan = 1, 'Min Sample Prevalance'),
							th(colspan = 1, 'Total Reads'),
							th(colspan = 1, 'Percent of Total Reads')	,
							th(colspan = 1, 'Total OTUs'),
							th(colspan = 1, 'Percent of Total OTUs')	  
						)
					)
				)
			),
			options = list(
				dom = 'lf<"floatright"B>rtip',
				buttons = c('excel', 'pdf', 'csv'),
				searching = TRUE,
				pageLength = 5,
				lengthMenu = c(5, nrow(t1))
			)
		) 
	})	

	######################################################################
	## Render DataTable text
	######################################################################	
	output$PHYLOSEQdesctitle <- renderUI({
		req(PHYLOSEQ())	
		HTML("
			<h3>Original Data Description</h3>
			"
		)	
	})

	######################################################################
	## Render phyloseq descriptions
	######################################################################			
	output$PHYLOSEQdescription <- renderUI({
	req(PHYLOSEQ())	
		## If no .TRE file
		if(is.null(TRE_DAT())){	
			## Total number of OTUs
			taxaN <- ntaxa(PHYLOSEQ())
			## Total number of samples
			sampleN <- nsamples(PHYLOSEQ())
			## Number of metadata
			sampvarN <- length(sample_variables(PHYLOSEQ()))
			## Total number of TAXA levels
			taxarankN <- length(rank_names(PHYLOSEQ()))
			## Render HTML
			HTML("
				<p id=\"phylodesc\"><strong>Number of Taxonomic Levels</strong>: ", taxarankN, "</p>
				<p id=\"phylodesc\"><strong>Number of OTUs</strong>: ", taxaN, "</p>
				<p id=\"phylodesc\"><strong>Number of samples</strong>: ", sampleN, "</p>
				<p id=\"phylodesc\"><strong>Number of MetaData</strong>: ", sampvarN, "</p>
				<p></p>
				<p></p>
				<p></p>				
				"
			)	
		} else {
			## Total number of OTUs
			taxaN <- ntaxa(PHYLOSEQ())
			## Total number of samples
			sampleN <- nsamples(PHYLOSEQ())
			## Number of metadata
			sampvarN <- length(sample_variables(PHYLOSEQ()))
			## Total number of TAXA levels
			xarankN <- length(rank_names(PHYLOSEQ()))
			## Number of nodes
			trenodeN <- Nnode(phy_tree(PHYLOSEQ()))
			## Number of tips
			tretipN <- Ntip(phy_tree(PHYLOSEQ()))
			## Render HTML
			HTML("
				<p id=\"phylodesc\"><strong>Number of Taxonomic Levels</strong>: ", taxarankN, "</p>
				<p id=\"phylodesc\"><strong>Number of OTUs</strong>: ", taxaN, "</p>
				<p id=\"phylodesc\"><strong>Number of Samples</strong>: ", sampleN, "</p>
				<p id=\"phylodesc\"><strong>Number of MetaData</strong>: ", sampvarN, "</p>
				<p id=\"phylodesc\"><strong>Number of Tips in Phylogeny Tree</strong>: ", tretipN, "</p>
				<p id=\"phylodesc\"><strong>Number of Nodes in Phylogeny Tree</strong>: ", tretipN, "</p>
				<p></p>
				<p></p>
				<p></p>
				"
			)	
		}
	})
	
	######################################################################
	## Render phyloseq description text
	######################################################################		
	output$PHYLOSEQdesctitle <- renderUI({
		req(PHYLOSEQ())
		HTML("
				<h3>Original Data Description</h3>

			"
		)
	})

	######################################################################
	## Render import text
	######################################################################	
	output$PHYLOSEQtabledescTEXT <- renderUI({
		req(PHYLOSEQ())
		HTML("
			<h4><strong><em>Description of Imported Data.</em></strong></h4>
			<br></br>
			"
		)
	})

	######################################################################
	## Render filter description text
	######################################################################		
	output$PHYLOSEQfilterinstructionTEXT <- renderUI({
		req(PHYLOSEQ())
		HTML("
			<h4><strong><em>Choose data filters, if necessary.  Press the \"Finalize Import and Filters\" button when 
			the desired filters are selected.</em></strong></h4>
			<br></br>
			"
		)
	})

	######################################################################
	## Render filter header text
	######################################################################	
	output$PHYLOSEQmetaTEXT <- renderUI({
		req(PHYLOSEQ())
		HTML("
			<p id=\"filterheader\"><strong>Choose Metadata to Filter</strong></p>
			<p>Unselect checked boxes to remove group</p>
			"
		)
		
	})
	
	######################################################################
	## Render selection boxes for metadata
	######################################################################	
	output$metaselection_RENDER <- renderUI({ 
		req(PHYLOSEQ())
		lapply(metaselections()$Groups, function(x) {
			checkboxGroupInput(paste0("meta_", x), 
				label = x, choices = metaselections()$Levels[[x]], inline=TRUE,
				selected = metaselections()$Levels[[x]])
		})

	})

	######################################################################
	## Render read filter text
	######################################################################		
	output$PHYLOSEQminotuTEXT <- renderUI({
		req(PHYLOSEQ())
		HTML("
			<p id=\"filterheader\"><strong>Choose Minimum Number of Reads per Measurement</strong></p>
			<p>OTUs will be filtered based on the percentage of reads that are above the read count selected here.</p>
			"
		)

	})
	
	######################################################################
	## Render read filter selection
	######################################################################	
	output$minimumOTU_RENDER <- renderUI({ 
		req(PHYLOSEQ())
		selectInput(inputId="PHYLOSEQminOTU", label="", 
			choices=seq(0, 20, 1), selected=0
		)

	})

	######################################################################
	## Render percent read threshold text
	######################################################################		
	output$PHYLOSEQpccutTEXT <- renderUI({
		req(PHYLOSEQ())
		HTML("
			<p id=\"filterheader\"><strong>Choose Percent Threshold to Filter OTUs</strong></p>
			<p>The previous input selects the minimum numbers of reads that must be in this percent of samples</p>
			"
		)
		
	})

	######################################################################
	## Render percent read threshold selection
	######################################################################	
	output$pccut_RENDER <- renderUI({ 
		req(PHYLOSEQ())
		selectInput(inputId="PHYLOSEQpccut", label="", 
			choices=seq(0, 20, 1), selected=0)

	})

	######################################################################
	## Render bacteria only text
	######################################################################		
	output$PHYLOSEQdomainTEXT <- renderUI({
		req(PHYLOSEQ())
		HTML("
			<p id=\"filterheader\"><strong>Only Analyze Bacteria</strong></p>
			<p>Selecting yes will filter out other organisms that are not in the Bacteria domain, e.g., Archaea, etc.</p>
			"
		)
		
	})

	######################################################################
	## Render bacteria only radio button
	######################################################################	
	output$domain_RENDER <- renderUI({ 
		req(PHYLOSEQ())
		radioButtons("PHYLOSEQ_domain", label = "",
			choices = list("NO" = 1, "YES" = 2), selected = 1)

	})

	######################################################################
	## Render finalize import action button
	######################################################################	
	output$finalizeimportBUTTON_RENDER <- renderUI({
		
		req(PHYLOSEQ())
		actionButton("goIMPORT", "Finalize Import and Filters", icon("bicycle"), 
			style="color: #fff; background-color: #2c2cad; border-color: #000")

	})	

	######################################################################
	## Create final phyloseq object
	######################################################################	
	phyloseqFINAL <- reactive({
		if (is.null(input$biomINPUT) & is.null(input$biommetaINPUT) & is.null(input$treINPUT)) {
		
			req(PHYLOSEQ())
			metaDAT_import <- ExampleProcessing()$META
			BIOM_OTU_import <- ExampleProcessing()$OTU
			TAXA_import <- ExampleProcessing()$TAXA
		} else {	
			req(PHYLOSEQ())
			metaDAT_import <- BIOMmetad_DAT()
			BIOM_OTU_import <- BIOM_OTU()
			TAXA_import <- BIOM_DAT()$TAXA
		}
		if(input$goIMPORT){
			isolate({	
				## Extract filtered metadata selections into a list and set name of list to experimental groups
				metaselectionsREACTIVE <- lapply(metaselections()$Groups, function(x) reactiveValuesToList(input)[[paste0("meta_", x)]])
				names(metaselectionsREACTIVE) <- metaselections()$Groups
				## Import metadata
				metaDAT <- metaDAT_import
				## Filter metadata based on filtered metadata selections
				if(ncol(metaDAT) == 1) {
					metaDAT <- data.frame(droplevels(metaDAT[metaDAT[,1] %in% metaselectionsREACTIVE[[1]] ,]))
					colnames(metaDAT)[1] <- colnames(metaDAT_import)[1]
					rownames(metaDAT) <- rownames(metaDAT_import)[metaDAT_import[,1] %in% metaselectionsREACTIVE[[1]]]
				} else {
					for(i in 1:length(metaselectionsREACTIVE)) {
						metaDAT <- droplevels(metaDAT[metaDAT[,names(metaselectionsREACTIVE)[i]] %in% metaselectionsREACTIVE[[i]] ,])
					}
				}
				## Extract updated row names from metadata
				filteredIDs <- rownames(metaDAT)
				# Filter OTU object and data into phyloseq otu_table class
				OTU <- phyloseq::otu_table(BIOM_OTU_import[,colnames(BIOM_OTU_import) %in% filteredIDs], taxa_are_rows = TRUE)
				# Convert taxa data into phyloseq taxonomyTable class
				TAXA <- phyloseq::tax_table(TAXA_import)
				# Convert filtered Sample Metadata data frame into phyloseq sample_data class
				SAMP <- phyloseq::sample_data(metaDAT)	
				## If no tree data
				if(is.null(TRE_DAT())){	
					## create phyloseq data
					pseq_SAMPfilt <- phyloseq(OTU, TAXA, SAMP)
				} else {
					## format tree data and create phyloseq object
					tre <- TRE_DAT()
					TRE <- root(tre, 1, resolve.root = T)
					pseq_SAMPfilt <- phyloseq::phyloseq(OTU, TAXA, SAMP, TRE)
				}						
				## Remove taxa prefixes (eg., 'g__') and add 'Unassigned' labels to all missing labels
				tax_table(pseq_SAMPfilt) <- taxaconvert(pseq_SAMPfilt, label_UNK=TRUE)
				## Coerce minimum read input to numeric object
				minOTU <- as.numeric(input$PHYLOSEQminOTU)		
				## Coerce percent read threshold input to numeric object
				pcCUT <- as.numeric(input$PHYLOSEQpccut)/100
				## Filter OTUs based on minimum read and percent read threshold using phyloseq::filter_taxa() function
				pseq_lowabundCUT <- filter_taxa(pseq_SAMPfilt, function(x) sum(x > minOTU) > (pcCUT * length(x)), TRUE)
				## If only bacteria are to be analyzed
				if(input$PHYLOSEQ_domain == 2) {
					## Subset taxa on Bacteria domain using phyloseq::subset_taxa() function
					pseq_FINALfilter <- subset_taxa(pseq_lowabundCUT, Domain=="Bacteria")
				} else {
					## Finalize phyloseq object
					pseq_FINALfilter <- pseq_lowabundCUT
				}
				pseq_FINALfilter
			})
		} else {
			NULL
		}

	})

	######################################################################
	## Render Taxonomic level text for final data description
	######################################################################
	output$PHYLOSEQFINALdesctitle <- renderUI({
		req(phyloseqFINAL())
		HTML("
				<h3>Final Data Description</h3>

			"
		)
	})

	######################################################################
	## Render Taxonomic level header text for final data description
	######################################################################
	output$PHYLOSEQtaxaselect2TEXT <- renderUI({
		req(phyloseqFINAL())
		HTML("
			<p id=\"filterheader\"><strong>Select Taxonomic level</strong></p>
			"
		)

	})

	######################################################################
	## Render Taxonomic level selection for final data description
	######################################################################	
	output$tableTAXAselection2_RENDER <- renderUI({ 
		req(phyloseqFINAL())
		selectInput(inputId="PHYLOSEQtable2taxa", label="", 
			choices=c("Domain","Phylum","Class","Order","Family","Genus"), selected="Phylum"
		)
	})

	######################################################################
	## Render phyloseq descriptions
	######################################################################				
	output$PHYLOSEQFINALdescription <- renderUI({
		req(phyloseqFINAL())
		if(is.null(TRE_DAT())){		
			## Total number of OTUs
			taxaN <- ntaxa(phyloseqFINAL())
			## Total number of samples
			sampleN <- nsamples(phyloseqFINAL())
			## Number of metadata
			sampvarN <- length(sample_variables(phyloseqFINAL()))
			## Total number of TAXA levels
			taxarankN <- length(rank_names(phyloseqFINAL()))
			## Render HTML
			HTML("
				<p id=\"phylodesc\"><strong>Number of Taxonomic Levels</strong>: ", taxarankN, "</p>
				<p id=\"phylodesc\"><strong>Number of OTUs</strong>: ", taxaN, "</p>
				<p id=\"phylodesc\"><strong>Number of samples</strong>: ", sampleN, "</p>
				<p id=\"phylodesc\"><strong>Number of MetaData</strong>: ", sampvarN, "</p>
				<p></p>
				<p></p>
				<p></p>				
				"
			)	
		} else {
			## Total number of OTUs
			taxaN <- ntaxa(phyloseqFINAL())
			## Total number of samples
			sampleN <- nsamples(phyloseqFINAL())
			## Number of metadata
			sampvarN <- length(sample_variables(phyloseqFINAL()))
			## Total number of TAXA levels
			taxarankN <- length(rank_names(phyloseqFINAL()))
			## Number of nodes
			trenodeN <- Nnode(phy_tree(phyloseqFINAL()))
			## Number of tips
			tretipN <- Ntip(phy_tree(phyloseqFINAL()))
			## Render HTML
			HTML("
				<p id=\"phylodesc\"><strong>Number of Taxonomic Levels</strong>: ", taxarankN, "</p>
				<p id=\"phylodesc\"><strong>Number of OTUs</strong>: ", taxaN, "</p>
				<p id=\"phylodesc\"><strong>Number of Samples</strong>: ", sampleN, "</p>
				<p id=\"phylodesc\"><strong>Number of MetaData</strong>: ", sampvarN, "</p>
				<p id=\"phylodesc\"><strong>Number of Tips in Phylogeny Tree</strong>: ", tretipN, "</p>
				<p id=\"phylodesc\"><strong>Number of Nodes in Phylogeny Tree</strong>: ", tretipN, "</p>
				<p></p>
				<p></p>
				<p></p>
				"
			)	
		}
	})

	######################################################################
	## Create object with final data description	
	######################################################################		
	PHYLOSEQFINALdesc <- reactive({
		req(phyloseqFINAL())
		# Compute prevalence of each feature, store as data.frame
		preval = apply(X = otu_table(phyloseqFINAL()),
						 MARGIN = ifelse(taxa_are_rows(phyloseqFINAL()), yes = 1, no = 2),
						 FUN = function(x){sum(x > 0)}
		)
		# Add taxonomy and total read counts to this data.frame
		prevdf = data.frame(Prevalence = preval, # Number of samples (rats) that contain a specific OTU
			TotalAbundance = taxa_sums(phyloseqFINAL()), # total number of OTUs found across all samples
			tax_table(phyloseqFINAL())
		)	
		## Group by taxa level, and then calculate, mean, median, max, min of sample prevalance, and sum of total reads
		## and remove any data with no reads
		SAMPLE_prevalence_stats <- prevdf %>% group_by_(input$PHYLOSEQtable2taxa) %>% 
			summarise(MEAN_READS=round(mean(Prevalence),1), MEDIAN_READS=median(Prevalence), MAX_READ=max(Prevalence), MIN_READ=min(Prevalence),TOTALREADS=sum(TotalAbundance)) %>%
			subset(TOTALREADS > 0) 
		## Subset Taxonomic level and coerce to data frame	
		SAMPLE_taxa <- as.data.frame(SAMPLE_prevalence_stats[,input$PHYLOSEQtable2taxa])[,1]
		## Sum the amount of TAXA for selected level
		ps0p <- table(tax_table(phyloseqFINAL())[, input$PHYLOSEQtable2taxa], exclude = NULL)[SAMPLE_taxa]
		## Add columns with percent reads, total taxa, and percent taxa. 
		## Return
		SAMPLE_prevalence_stats <- SAMPLE_prevalence_stats %>%
			mutate(PC_TR = (round(TOTALREADS/sum(TOTALREADS), 5))*100)  %>%
			mutate(N = ps0p) %>%
			mutate(PC_ABUND = (round(N/sum(N), 5))*100)
		SAMPLE_prevalence_stats
	})

	######################################################################
	## Create DataTable object with final data description
	######################################################################		
	output$PHYLOSEQFINALinitialdescRENDER <- DT::renderDataTable({
		req(phyloseqFINAL())	
		t1 <- as.data.frame(PHYLOSEQFINALdesc())
		t1[,!(colnames(t1) %in% input$PHYLOSEQtable2taxa)] <- 
			apply(PHYLOSEQFINALdesc()[,!(colnames(PHYLOSEQFINALdesc()) %in% input$PHYLOSEQtable2taxa)], 2, as.numeric)
		datatable(t1, extensions='Buttons', rownames = FALSE,
			container = htmltools::withTags(table(
				class = 'display',
					thead(
						tr(
							th(colspan = 1, ''),
							th(colspan = 4, 'Sample Prevalance'),
							th(colspan = 2, 'Reads'),
							th(colspan = 2, 'OTU')	   
						),
						tr(
							th(colspan = 1, 'Taxa'),
							th(colspan = 1, 'Mean'),
							th(colspan = 1, 'Median'),
							th(colspan = 1, 'Max'),
							th(colspan = 1, 'Min'),
							th(colspan = 1, 'Total Reads'),
							th(colspan = 1, 'Percent of Total Reads')	,
							th(colspan = 1, 'Total OTUs'),
							th(colspan = 1, 'Percent of Total OTUs')	  
						)
					)
				)
			),
			options = list(
				dom = 'lf<"floatright"B>rtip',
				buttons = c('excel', 'pdf', 'csv'),
				searching = TRUE,
				pageLength = 5,
				lengthMenu = c(5, nrow(t1))
			)
		) 
		
	})	

	######################################################################
	## Create object with Experimental groups and factor levels
	######################################################################		
	CompGroups <- reactive({
		if (is.null(input$biomINPUT) & is.null(input$biommetaINPUT) & is.null(input$treINPUT)) {
			req(phyloseqFINAL())
			key <- ExampleProcessing()$KEY
		} else {	
			req(phyloseqFINAL())
			key <- KEY()
		}	

		## Extract SAMPLE data, coerce into data frame, and set names
		sd_DF <- data.frame(sample_data(phyloseqFINAL())@.Data)
		names(sd_DF) <- sample_data(phyloseqFINAL())@names
		## Remove column of OTU labels from metadata
		sdfilt_DF <- sd_DF[,!(colnames(sd_DF) %in% key)]
		## If no longer data frame, ie, only 1 column of metadata remaining
		if(!is.data.frame(sdfilt_DF)) {
			## Identify name of metadata, identify levels in column, and set name of level object
			Metacolumns <- colnames(sd_DF)[!(colnames(sd_DF) %in% key)]
			sdLEVELS <- list(levels(sdfilt_DF))
			names(sdLEVELS) <- Metacolumns
			
		} else {
			## If object is still a data frame after removing key
			## Remove columns where the number of factor levels equal the number of rows in the data frame
			sdnlevelgnrow_DF <- sdfilt_DF[,sapply(sdfilt_DF, nlevels) != nrow(sdfilt_DF)]
			## If no longer data frame, ie, only 1 column of metadata remaining 
			if(!is.data.frame(sdnlevelgnrow_DF)) {
				## Identify name of metadata, identify levels in column, and set name of level object
				Metacolumns <- colnames(sdfilt_DF)[sapply(sdfilt_DF, nlevels) != nrow(sdfilt_DF)]
				sdLEVELS <- list(levels(sdnlevelgnrow_DF))
				names(sdLEVELS) <- Metacolumns
			} else {
				## Remove columns where there is only 1 factor level 
				sdnlevela1_DF <- sdnlevelgnrow_DF[,sapply(sdnlevelgnrow_DF, nlevels) > 1]
				## If no longer data frame, ie, only 1 column of metadata remaining 
				if(!is.data.frame(sdnlevela1_DF)) {
					## Identify name of metadata, identify levels in column, and set name of level object
					Metacolumns <- colnames(sdnlevelgnrow_DF)[sapply(sdnlevelgnrow_DF, nlevels) > 1]
					sdLEVELS <- list(levels(sdnlevela1_DF))
					names(sdLEVELS) <- Metacolumns
				} else {
					## Identify names of all columns with > 1 factor levels and create a list of each factor levels
					Metacolumns <- colnames(sdnlevela1_DF)[sapply(sdnlevela1_DF, nlevels) > 1]
					sdLEVELS <- lapply(sdnlevela1_DF, levels)
				}
			}
		}
		## Return a list with name of the final Experimental groups and their respective factor levels
		list(Groups = Metacolumns, Levels=sdLEVELS)	
	})