#FUNCTIONS FOR tree.age


#Extract the ages table from a tree
#Calculating the tips and the edges age
tree.age_table<-function(tree){
    ages<-dist.nodes(tree)[length(tree$tip.label)+1,]
    tip.names<-tree$tip.label
    if(is.null(tree$node.label)) {
        nod.names<-c((length(tree$tip.label)+1):length(dist.nodes(tree)[,1]))
    } else {
        nod.names<-tree$node.label
    }
    edges<-c(tip.names, nod.names)
    ages.table<-data.frame(ages=ages,edges=edges)
    return(ages.table)
}


#Scaling the ages from tree.age_table if scale != 1
tree.age_scale<-function(ages.table, scale){
    ages.table$ages<-ages.table$ages/max(ages.table$ages)
    ages.table$ages<-ages.table$ages*scale
    return(ages.table)
}