library(ggraph)

data.sc_neurons <- data.sc %>% dplyr::select(vm:fi, dvlocmm) %>%
  na.omit
N               <- nrow(data.sc)
Rho_neurons     <- cor(data.sc_neurons)
tol             <- 1.96/sqrt(N)           # rough approximation for
# significance of partial
# correlation.  Samples not
# independent due to
# multiple measurements for
# each mouse.  TODO: adjust
# tolerance level according
# to efficient sample size
# obtained from autocorrelation
# function
tol            <- 2*tol
Q_neurons      <- corpcor::cor2pcor(Rho_neurons)
Q_neurons      <- Q_neurons %>% as.data.frame
g              <- igraph::graph.adjacency(abs(Q_neurons)>tol,
                                  mode="undirected", diag=FALSE)
igraph::V(g)$class     <- c(data.sc_r$property, "dvlocmm")
igraph::V(g)$degree    <- igraph::degree(g)
edge_width    <- NULL
edge_colour      <- NULL
k <- 0
for(i in 1:(ncol(Q_neurons)-1))
{
  for(j in (i+1):ncol(Q_neurons))
    if(abs(Q_neurons[i,j])>tol)
    {
      k<-k+1
      edge_width[k] <- abs(Q_neurons[i,j])/2
      edge_colour[k]   <- ifelse(Q_neurons[i,j] > 0 , 1, 3)
    }
}
igraph::E(g)$width     <- edge_width
igraph::E(g)$colour    <- edge_colour
graph          <- tidygraph::as_tbl_graph(g)
##

p <- ggraph(graph, 'igraph', algorithm = 'circle') +
  ## ggraph(graph, layout= "kk") +
  geom_node_circle(aes( r=0.1), fill="orange", colour="black")+
  geom_edge_fan(aes(width = edge_width, color= colour), 
                show.legend = FALSE,
                start_cap = circle(1.4, 'cm'),
                end_cap = circle(1.4,  'cm'),
                lineend = "butt") +
  ## scale_edge_color_hue(colour=c("black","gray"))+
  geom_node_text(aes(label=class),
                 size=6, nudge_x=.0, nudge_y=0.0, colour="blue") +
  coord_fixed()+ 
  theme_graph(foreground = 'steelblue', fg_text_colour = 'white')
## 
p

ggsave(filename="Figures/CIG_neurons.pdf")