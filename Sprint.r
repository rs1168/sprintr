# A program to prepare Sprint Cell-Site dumps for QGIS


#importing libraries
library(plyr)
library(dplyr)
library(readxl)

#Initial input of the main spreadsheet file
input_cell <- readline("Main spreadsheet with cell-site data name?")
cell_sites <- NULL
if (grepl(".csv", input_cell)) {
  cell_sites <- read.csv(input_cell)
} else if(grepl(".xlsx", input_cell) || grepl(".xls", input_cell)) {
  cell_sites <- readxl::read_excel(input_cell)
} else {
  print("I couldn't find your file. Did you set the directory and include the file extension?")
}

#Input of the towers
towers <- NULL
continue <- "yes"
while(continue == "yes") {
    input <- readline("Name of the tower spreadsheet?")
    towers_add <- NULL
    if (grepl(".csv", input)) {
      towers_add <- read.csv(input)
    } else if(grepl(".xlsx", input) || grepl(".xls", input)) {
      towers_add <- readxl::read_excel(input)
    } else {
      print("I couldn't find your file. Did you set the directory and include the file extension?")
      
    }
    towers <- rbind(towers, towers_add)
    continue <- readline("Will you continue? Please type yes to continue.")
    continue <- tolower(continue)
  }
remove(towers_add)

#Final table to be exported. Created here due to two different ifs, wanted to keep it in scope for the end.
master_cellsites <- NULL


if(grepl(".csv", input_cell)) {
  #creating the sector id and the cell number
  cell_sites["Sector ID"] <- cell_sites$X1ST.CELL%/%10000
  cell_sites["Cell Number"] <- cell_sites$X1ST.CELL%%10000

  #Creating a unique value to cross reference the tower locations
  cell_sites["Unique Value"] <- paste(cell_sites$NEID, cell_sites$`Cell Number`)

  #Creating unique values in the towers table
  towers["Unique Value"] <- paste(towers$NEID, towers$Cell.)

  #Smaller table to append to the master cell-site spreadsheet

  append <- select(towers, Latitude, Longitude, 'Unique Value')

  #Master spreadsheet with latitude and longitudes from the towers dataframe
  master_cellsites <- inner_join(cell_sites, append, by = "Unique Value")
}

if(grepl(".xlsx", input_cell) || grepl(".xls", input_cell)) {
  #creating the sector id and the cell number
  cell_sites["Sector ID"] <- cell_sites$`1ST CELL`%/%10000
  cell_sites["Cell Number"] <- cell_sites$`1ST CELL`%%10000
  
  #Creating a unique value to cross reference the tower locations
  cell_sites["Unique Value"] <- paste(cell_sites$NEID, cell_sites$`Cell Number`)
  
  #Creating unique values in the towers table
  towers["Unique Value"] <- paste(towers$NEID, towers$`Cell#`)
  
  #Smaller table to append to the master cell-site spreadsheet
  
  append <- select(towers, Latitude, Longitude, 'Unique Value')
  
  #Master spreadsheet with latitude and longitudes from the towers dataframe
  master_cellsites <- inner_join(cell_sites, append, by = "Unique Value")
}

#remove identical rows if necessary
master_cellsites <- unique(master_cellsites)

#Export
write.csv(master_cellsites, "Master_Cell-Sites.csv")
print("Thank you very much for using this program!")
