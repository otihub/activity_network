options(java.parameters = "- Xmx3g")
require(tidyverse)
require(igraph)
require(rgexf)
require(gplots)
require(httr)

#read in data from csv
edges <- read.csv("Report.csv") %>% as.tibble 
#list of activity numbers, need this to remove mistaken matches later
activities <- as.list(as.character(unique(edges$Activity.Number))) 
#combines text from background and activity summary finds mentions and makes a from-to list that will be edges in network
edges <- edges %>% 
          mutate(Text = paste(Activity.Summary,Background, sep=" ")) %>%
          select(c(Activity.Number,Text)) %>% 
          mutate(From = Activity.Number, To = str_extract_all(Text, '[A-Z]{3,5}[0-9]{3}')) %>% 
          filter(To != "character(0)")  
         
#removes mentions when there are more than one of the same in one activity description/background text        
edges$To <- lapply(edges$To, unique)


edges <- edges %>% unnest(To) %>% select(From, To) 

#omit when To is not found in from as that is an indication of a negative match
edges <- subset(edges, To %in% activities)
#remove activities they are not longer needed
rm(activities)

#make graph from edge list
g = graph_from_data_frame(edges,directed = TRUE)

#get attributes
vertices = read.csv("Report.csv", header = TRUE, sep= ",") %>% 
    select(c(Activity.Number,Current.Status,Amount.Disbursed,Activity.Title)) %>% as_tibble %>%
    mutate(Activity.Number = as.character(Activity.Number), Current.Status = as.character(Current.Status), Activity.Title = as.character(Activity.Title))


#filter vertices on only activities from graph 
vertices <- vertices %>% filter(Activity.Number %in% V(g)$name)
#arrange in order of graph
vertices <- vertices[match(V(g)$name,vertices$Activity.Number),]

#add attributes from vertices to graph (for some reason this was tripping up
# igraph.to.gexf will have to fix if we need attributes) Also removes ampersands because
# there is a big in igraph.to.gexf

g <- g %>% set_vertex_attr("Status",value=vertices$Current.Status) %>% 
      set_vertex_attr("Disbursed", value=vertices$Amount.Disbursed) %>% 
      set_vertex_attr("Title", value=gsub('&','',vertices$Activity.Title)) %>% 
      set_vertex_attr("ActivityNumber", value=vertices$Activity.Number)

conv <- igraph.to.gexf(g)

#write.gexf(nodes=users[c("id","label")],nodesAtt=users[c("membership","botIndex")]  ,edges=conv$edges[c("source","target")],output = "gephy_activities.gexf")
write.gexf(nodes = conv$nodes[c("id","label")], edges=conv$edges[c("source","target")],output = "gephy_activities.gexf")

