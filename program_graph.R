options(java.parameters = "- Xmx3g")
require(tidyverse)
require(igraph)
require(rgexf)
require(gplots)
require(httr)


edges <- read.csv("Report.csv") %>% as.tibble 
activities <- as.list(unique(edges$Activity.Number))
edges <- edges %>% 
          select(c(Activity.Number,Activity.Summary)) %>% 
          mutate(From = Activity.Number, To = str_extract_all(Activity.Summary, '[A-Z]{3,5}[0-9]{3}')) %>% 
          filter(To != "character(0)")  
         
          
edges$To <- lapply(edges$To, unique)

edges <- edges %>% unnest(To) %>% select(From, To) 

#omit when To is not found in From as that is an indication of a negative match

edges <- subset(edges, To %in% activities)


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

#add attributes from vertices to graph

g <- g %>% set_vertex_attr("Status",value=vertices$Current.Status) %>% 
      set_vertex_attr("Disbursed", value=vertices$Amount.Disbursed) %>% 
      set_vertex_attr("Title", value=vertices$Activity.Title)%>% 
      set_vertex_attr("ActivityNumber", value=vertices$Activity.Number)



conv <- igraph.to.gexf(g)


#write.gexf(nodes=users[c("id","label")],nodesAtt=users[c("membership","botIndex")]  ,edges=conv$edges[c("source","target")],output = "gephy_activities.gexf")

write.gexf(nodes = conv$nodes[c("id","label")], edges=conv$edges[c("source","target")],output = "gephy_activities.gexf")

