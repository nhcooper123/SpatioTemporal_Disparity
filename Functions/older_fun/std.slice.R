##########################
#pco.slice
##########################
#Generates a pco.slice list containing pco.scores through time and taxonomic information
#Modyfied paleotree::timeSliceTree function
#v1.0
#Update: added RATES method
#Update: changed the RATES method into PROXIMITY

##########################
#SYNTAX :
#<tree> a 'phylo' object
#<pco.scores> a pco.scores object containing PC axis data and optional taxonomic data.
#<slices> slices ages. Can be either a single value (for a single slice) or a series of values (for multiple slices)
#<method> the slicing method (what becomes of the sliced branches): can be ACCTRAN, DELTRAN or RATE.
#<anc.matrix> Optional, needed for the RATES method
##########################
#----
#guillert(at)tcd.ie 20/10/2014
##########################

std.slice<-function(tree, pco.scores, slices, method, anc.matrix) {

    #SANITIZING
    #tree
    check.class(tree, 'phylo', ' must be a \"phylo\" object.')
    #must have node labels
    if(is.null(tree$node.label)) {
        stop('The tree must have node label names.')
    }

    #pco.scores
    check.class(pco.scores, 'pco.scores', ' must be a \"pco.scores\" object.')

    #slices
    check.class(slices, 'numeric', ' must be numeric.')

    #method
    check.class(method, 'character', " must be \'ACCTRAN\', \'DELTRAN\' or \'PROXIMITY\'.")
    if(method != "ACCTRAN") {
        if(method != "DELTRAN") {
            if(method != "PROXIMITY") {
                stop(as.character(substitute(method)), " must be \'ACCTRAN\', \'DELTRAN\' or \'PROXIMITY\'." , call.=FALSE)
            }
        }
    }

    #anc.matrix
    if(method == "RATES") {
        if(missing(anc.matrix)) {
            stop("Missing ancestral matrix for the \"RATES\" method.")
        } else {
            check.class(anc.matrix, "list", " must be a list from anc.state containing three elements: \'state\', \'prob\' and \'rate\'.")
            check.length(anc.matrix, 3, " must be a list from anc.state containing three elements: \'state\', \'prob\' and \'rate\'.")
            if(names(anc.matrix)[1] != "state") {
                stop(as.character(substitute(anc.matrix)), " must be a list from anc.state containing three elements: \'state\', \'prob\' and \'rate\'.", call.=FALSE)
            } 
            if(names(anc.matrix)[2] != "prob") {
                stop(as.character(substitute(anc.matrix)), " must be a list from anc.state containing three elements: \'state\', \'prob\' and \'rate\'.", call.=FALSE)
            }
            if(names(anc.matrix)[3] != "rate") {
                stop(as.character(substitute(anc.matrix)), " must be a list from anc.state containing three elements: \'state\', \'prob\' and \'rate\'.", call.=FALSE)
            }
            rate<-anc.matrix$rate
            prob<-anc.matrix$prob
        }
    }

    #SLICING THE TREE
    n.slices<-length(slices)

    slices.list<-list()
    for (slice in 1:n.slices) {
        
        #subtree
        sub_tree<-slice.tree(tree, slices[slice], method)

        #ADD IF method=RATES
        
        #subtaxa list (sub_tree tip labels)
        sub_taxa<-sub_tree$tip.label
        
        #sub pco scores table
        sub_scores<-pco.scores$scores[sub_taxa,]

        #age
        sub_age<-slices[slice]
        
        #sub_taxonomy (if taxonomy is present)
        if(length(grep("taxonomy", names(pco.scores))) == 1) {
            
            #Creating a sub_taxonomy table but keeping all the taxonomic levels
            sub_taxonomy<-cbind(pco.scores$taxonomy, rownames(pco.scores$taxonomy))
            sub_taxonomy[,1]<-as.factor(sub_taxonomy[,1])
            sub_taxonomy<-subset(sub_taxonomy[sub_taxa,])
            sub_taxonomy<-data.frame(row.names=rownames(sub_taxonomy), "taxonomy"=as.factor(sub_taxonomy[,1]))
            
            #Creating the slice list (with taxonomy)
            sub_list<-list('age'=sub_age, 'sub_tree'=sub_tree, 'sub_scores'=sub_scores, 'sub_taxonomy'=sub_taxonomy)
        } else {
            
            #Creating the slice list (without taxonomy)
            sub_list<-list('age'=sub_age, 'sub_tree'=sub_tree, 'sub_scores'=sub_scores)
        }

        #Naming the list sliceX
        slice.name<-paste("slice", slices[slice], sep="_")
        assign(slice.name, sub_list)

        #Saving the list names before modifying it
        former.names<-names(slices.list)

        #Adding the sub_list to the list
        slices.list<-c(slices.list, list(get(slice.name)))
        names(slices.list)<-c(former.names, slice.name)
    }

    #Adding the method
    former.names<-names(slices.list)
    slices.list<-c(slices.list, as.character(method))
    names(slices.list)<-c(former.names, "method")
    
    #OUTPUT
    class(slices.list)<-'std.slices'
    return(slices.list)

#End   
}