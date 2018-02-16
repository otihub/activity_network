# Activity Network Generator
## Background

This R script will convert OTI Anywhere activity reports into a network graph. Running the script generates a gephi file which can be loaded in the gephi software for further styling and export to pdf.

The script makes a network by creating edges whenever an activity number is mentioned in the activity description or background field of an activity report.

## Dependancies
- gephi: Styling of network graphs. Available at [gephi.org](https://gephi.org/).
- r: R statistical analysis software. Available at [r-project.org](https://www.r-project.org/) 
- r-studio(optional): Code editor for r. Not necessary but makes using r much nicer. Available at [rstudio.com](https://www.rstudio.com) 


## Steps

 1. Get Data 
 Background is not in the default reports generated from the activity database so generating a custom report is necessary. Do `OTI Anywhere Country Page -> Reports -> Report Builder -> Detail`
Add *Background* as a reporting field by adding it from the Purpose section. Remember to add pending to closed, completed, and completed activities (unless you dont care about pending). 

[report builder]:https://raw.githubusercontent.com/otihub/activity_network/report-builder.png 

   
