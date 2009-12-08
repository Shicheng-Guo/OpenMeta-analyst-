####################################
# OpenMeta[Analyst]                                             #
# ----                                                                       #
# binary_methods.r                                                # 
# Facade module; wraps methods that perform    #
# analysis on binary data in a coherent interface.  #
####################################


library(metafor)


binary.rmh <- function(binaryData, params){
    
    # assert that the argument is the correct type
    if (!("BinaryData" %in% class(binaryData))) stop("Binary data expected.")
    
    # call out to the metafor package
    res<-rma.uni(measure=params$measure, ai=binaryData@g1O1, bi=binaryData@g1O2, 
                                ci=binaryData@g2O1, di=binaryData@g2O2)
    
    #
    # generate forest plot (should we do this here?)
    #
    getwd()
    #pdf("./r_tmp/forest.pdf")
    forest_path <- "./r_tmp/forest.png"
    png(forest_path)
    forest.rma(res)
    dev.off()
    
    images <- c(forest_path)
    text <- c(res)
    results <- list("images"=images, "text"=text)
    results
}


binary.rmh.parameters <- function(){
    # parameters
    binary_metrics <- c("OR", "RR", "RD")
    rm_method_ls <- c("HE", "DL", "SJ", "ML", "REML", "EB")
    params <- list("rm.method"=rm_method_ls, "measure"=binary_metrics, "conf.level"="float", "digits"="float")
    
    # default values
    defaults <- list("rm.method"="REML", "measure"="OR", "conf.level"=.95, "digits"=3)
    
    parameters <- list("parameters"=params, "defaults"=defaults)
}