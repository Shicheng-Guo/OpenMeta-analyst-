#######################################
# OpenMeta[Analyst]                   #
# ----                                #
# diagnostic_methods.r                # 
# Facade module; wraps methods        #
# that perform analysis on diagnostic #
# data in a coherent interface.       # 
#######################################

library(metafor)

diagnostic.logit.metrics <- c("Sens", "Spec", "PPV", "NPV", "Acc")
diagnostic.log.metrics <- c("PLR", "NLR", "DOR")

diagnostic.transform.f <- function(metric.str){
    display.scale <- function(x){
        if (metric.str %in% diagnostic.log.metrics){
            exp(x)
        }
        else {
            if (metric.str %in% diagnostic.logit.metrics){
                invlogit(x)
            }
            else {
                # identity function
                x
            }
        }
    }
    
    calc.scale <- function(x){
        if (metric.str %in% diagnostic.log.metrics){
            log(x)
        }
        else {
        	if (metric.str %in% diagnostic.logit.metrics){
                logit(x)
            }
            else {
                # identity function
                x
            }
         }
    }
    list(display.scale = display.scale, calc.scale = calc.scale)
}

compute.sens <- function(diagnostic.data) {
  diagnostic.data@Sens <- diagnostic.data@TP / (diagnostic.data@TP + diagnostic.data@FN)
  diagnostic.data
}

compute.spec <- function(diagnostic.data) {
  diagnostic.data@Spec <- diagnostic.data@TN / (diagnostic.data@TN + diagnostic.data@FP)
  diagnostic.data
}

compute.diag.point.estimates <- function(diagnostic.data, params) {
# Computes point estimates based on raw data and adds them to diagnostic.data
    metric <- params$measure    
    TP <- diagnostic.data@TP
    FN <- diagnostic.data@FN  
    TN <- diagnostic.data@TN 
    FP <- diagnostic.data@FP
    
    diagnostic.data@numerator <- switch(metric,
        # sensitivity
        Sens = TP, 
        # specificity
        Spec = TN,
        # pos. predictive value
        PPV =  TP,
        #neg. predictive value
        NPV =  TN,
        # accuracy
        Acc = TP + TN,
        # positive likelihood ratio
        PLR = TP / (TP + FN), 
        # negative likelihood ratio
        NLR = FN / (TP + FN),
        # diagnostic odds ratio
        DOR = TP * TN)
        
    diagnostic.data@denominator <- switch(metric,
        # sensitivity
        Sens = TP + FN, 
        # specificity
        Spec = TN + FP,
        # pos. predictive value
        PPV =  TP + FP,
        #neg. predictive value
        NPV =  TN + FN,
        # accuracy
        Acc = TP + TN + FP + FN,
        # positive likelihood ratio
        PLR = FP / (TN + FP), 
        # negative likelihood ratio
        NLR = TN / (TN + FP),
        # diagnostic odds ratio
        DOR = FP * FN)    
    
    y <- diagnostic.data@numerator / diagnostic.data@denominator
      
    diagnostic.data@y <- eval(call("diagnostic.transform.f", params$measure))$calc.scale(y)
 
    diagnostic.data@SE <- switch(metric,
        Sens <- sqrt((1 / TP) + (1 / FN)), 
        Spec <- sqrt((1 / TN) + (1 / FP)),
        PPV <- sqrt((1 / TP) + (1 / FP)),
        NPV <- sqrt((1 / TN) + (1 / FN)),
        Acc <- sqrt((1 / (TP + TN)) + (1 / (FP + FN))),
        PLR <- sqrt((1 / TP) - (1 / (TP + FN)) + (1 / FP) - (1 / (TN + FP))),
        NLR <- sqrt((1 / TP) - (1 / (TP + FN)) + (1 / FP) - (1 / (TN + FP))),
        DOR <- sqrt((1 / TP) + (1 / FN) + (1 / FP) + (1 / TN)))

    diagnostic.data
}

logit <- function(x) {
	log(x/(1-x))
}

invlogit <- function(x) {
	exp(x) / (1 + exp(x))
}

###################################################
#            diagnostic fixed effects             #
###################################################
diagnostic.fixed <- function(diagnostic.data, params){
    # assert that the argument is the correct type
    if (!("DiagnosticData" %in% class(diagnostic.data))) stop("Diagnostic data expected.")

    results <- NULL
    if (diagnostic.data@TP > 0) {
      diagnostic.data <- compute.diag.point.estimates(diagnostic.data, params)
    }
    res<-rma.uni(yi=diagnostic.data@y, sei=diagnostic.data@SE, 
                     slab=diagnostic.data@study.names,
                     method="FE", level=params$conf.level,
                     digits=params$digits)
    # Create list to display summary of results
    degf <- res$k - res$p
    model.title <- "Fixed-Effect Model - Inverse Variance"
    data.type <- "diagnostic"
    summary.disp <- create.summary.disp(res, params, degf, model.title, data.type)
    # function to pretty-print summary of results.
    if ((is.null(params$create.plot)) || params$create.plot == TRUE) {
      # A forest plot will be created unless
      # params.create.plot is set to FALSE.
      forest.path <- paste(params$fp_outpath, sep="")
      plot.data <- create.plot.data.diagnostic(diagnostic.data, params, res)
      forest.plot(plot.data, outpath=forest.path)
      #
      # Now we package the results in a dictionary (technically, a named
      # vector). In particular, there are two fields that must be returned;
      # a dictionary of images (mapping titles to image paths) and a list of texts
      # (mapping titles to pretty-printed text). In this case we have only one
      # of each.
      #
      images <- c("Forest Plot"=forest.path)
      plot.names <- c("forest plot"="forest_plot")
      results <- list("images"=images, "Summary"=summary.disp, "plot_names"=plot.names)
    }
    else {
        results <- list("Summary"=summary.disp)
    }   
    results
}

diagnostic.fixed.parameters <- function(){
    # parameters
    apply_adjustment_to = c("only0", "all")

    params <- list("conf.level"="float", "digits"="float",
                            "adjust"="float", "to"=apply_adjustment_to)

    # default values
    defaults <- list("conf.level"=95, "digits"=3, "adjust"=.5, "to"="only0")

    var_order = c("conf.level", "digits", "adjust", "to")

    parameters <- list("parameters"=params, "defaults"=defaults, "var_order"=var_order)
}

##################################
#  diagnostic random effects     #
##################################
diagnostic.random <- function(diagnostic.data, params){
    # assert that the argument is the correct type
    if (!("DiagnosticData" %in% class(diagnostic.data))) stop("Binary data expected.")
    
    results <- NULL
    if (diagnostic.data@TP > 0) {
      diagnostic.data <- compute.diag.point.estimates(diagnostic.data, params)
    }
    # call out to the metafor package
    res<-rma.uni(yi=diagnostic.data@y, sei=diagnostic.data@SE, 
                 slab=diagnostic.data@study.names,
                 method=params$rm.method, level=params$conf.level,
                 digits=params$digits)
    #                        
    # Create list to display summary of results
    #
    degf <- res$k.yi - 1
    model.title <- paste("Diagnostic Random-Effects Model (k = ", res$k, ")", sep="")
    data.type <- "diagnostic"
    summary.disp <- create.summary.disp(res, params, degf, model.title, data.type)
 
    #
    # generate forest plot 
    #
    if ((is.null(params$create.plot)) || (params$create.plot == TRUE)) {
        forest.path <- paste(params$fp_outpath, sep="")
        plot.data <- create.plot.data.diagnostic(diagnostic.data, params, res)
        forest.plot(plot.data, outpath=forest.path)
        
        #
        # Now we package the results in a dictionary (technically, a named 
        # vector). In particular, there are two fields that must be returned; 
        # a dictionary of images (mapping titles to image paths) and a list of texts
        # (mapping titles to pretty-printed text). In this case we have only one 
        # of each. 
        #     
        images <- c("Forest Plot"=forest.path)
        plot.names <- c("forest plot"="forest_plot")
        results <- list("images"=images, "Summary"=summary.disp, "plot_names"=plot.names)
    }
    else {
        results <- list("Summary"=summary.disp)
    }    
    results
}

diagnostic.random.parameters <- function(){
    # parameters
    rm_method_ls <- c("HE", "DL", "SJ", "ML", "REML", "EB")
    params <- list("rm.method"=rm_method_ls, "conf.level"="float", "digits"="float")
    
    # default values
    defaults <- list("rm.method"="DL", "conf.level"=95, "digits"=3)
    
    var_order <- c("rm.method", "conf.level", "digits")
    parameters <- list("parameters"=params, "defaults"=defaults, "var_order"=var_order)
}

diagnostic.random.overall <- function(results) {
    # this parses out the overall from the computed result
    res <- results$Summary$MAResults
    overall <- c(res$b[1], res$ci.lb, res$ci.ub)
    overall
}

###################################################
#            diagnostic SROC                      #
###################################################
diagnostic.fixed.sroc <- function(diagnostic.data, params){
    # assert that the argument is the correct type
    if (!("DiagnosticData" %in% class(diagnostic.data))) stop("Diagnostic data expected.")
    # adjust zero entries
    TP.adj <- diagnostic.data@TP
    TP.adj[TP.adj == 0] <- 0.5
    FN.adj <- diagnostic.data@FN
    FN.adj[FN.adj == 0] <- 0.5
    TN.adj <- diagnostic.data@TN
    TN.adj[TN.adj == 0] <- 0.5
    FP.adj <- diagnostic.data@FP
    FP.adj[FP.adj == 0] <- 0.5
    # compute true positive ratio = sensitivity 
    TPR <- TP.adj / (TP.adj + FN.adj)
    # compute false positive ratio = 1 - specificity
    FPR <- FP.adj / (TN.adj + FP.adj)
    S <- logit(TPR) + logit(FPR)
    D <- logit(TPR) - logit(FPR)
    s.range <- list("max"=max(S), "min"=min(S))
    if (params$sroc_weighted == TRUE) {
        inv.var <- diagnostic.data@TP + diagnostic.data@FN + diagnostic.data@FP + diagnostic.data@TN
        # compute total number in each study
        res <- lm(D ~ S, weights=inv.var)
        # weighted linear regression
    } else {
        res <- lm(D~S)
        # unweighted regression 
    }
    # Create list to display summary of results
    fitted.line <- list(intercept=res$coefficients[1], slope=res$coefficients[2])
    plot.data <- list("fitted.line" = fitted.line, "TPR"=TPR, "FPR"=FPR, "inv.var" = inv.var, "s.range" = s.range, "weighted"=params$sroc_weighted)
    #model.title <- "SROC"
    #summary.disp <- create.summary.disp(res, params, degf, model.title, data.type)
    diagnostic.sroc.plot(plot.data, outpath=params$sroc_outpath)
      #
      # Now we package the results in a dictionary (technically, a named
      # vector). In particular, there are two fields that must be returned;
      # a dictionary of images (mapping titles to image paths) and a list of texts
      # (mapping titles to pretty-printed text). In this case we have only one
      # of each.
      #
    images <- c("SROC"=params$sroc_outpath)
    plot.names <- c("sroc"="sroc")
    results <- list("images"=images, "plot_names"=plot.names)
    
    results
}

diagnostic.fixed.parameters <- function(){
    # parameters
    apply_adjustment_to = c("only0", "all")

    params <- list("conf.level"="float", "digits"="float",
                            "adjust"="float", "to"=apply_adjustment_to)

    # default values
    defaults <- list("conf.level"=95, "digits"=3, "adjust"=.5, "to"="only0")

    var_order = c("conf.level", "digits", "adjust", "to")

    parameters <- list("parameters"=params, "defaults"=defaults, "var_order"=var_order)
}
