#' Performs (semi)Parametric Bootstrap Joint ((s)PBJ) Spatial Extent Inference
#'
#' @param statMap statMap object as obtained from computeStats.
#' @param cfts Numeric vector of cluster forming thresholds to use. Consistent
#' with other imaging software these thresholds are one tailed (e.g. p<0.01 imples z>2.32).
#' @param nboot Number of bootstraps to perform.
#' @param kernel Kernel to use for computing connected components. Box is
#'  default (26 neighbors), but Diamond may also be reasonable.
#'
#' @return Returns a list of length length(cfts)+4. The first four elements contain
#' statMap$stat, statMap$template, statMap$mask, and statMap$df. The remaining elements are lists containing the following:
#' \item{pvalues}{A vector of p-values corresponding to the cluster labels in clustermaps.}
#' \item{clustermap}{A niftiImage object with the cluster labels.}
#' \item{pmap}{A nifti object with each cluster assigned the negative log10 of its cluster extent FWE adjusted p-value.}
#' \item{CDF}{A bootstrap CDF.}
#' @export
#' @importFrom stats ecdf qchisq rnorm
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @importFrom RNifti writeNifti updateNifti
#' @importFrom mmand shapeKernel
pbjSEI = function(statMap, cfts=c(0.01, 0.005), nboot=5000, kernel='box'){
  if(class(statMap)[1] != 'statMap')
    warning('Class of first argument is not \'statMap\'.')
  cftsnominal = cfts

  mask = if(is.character(statMap$mask)) readNifti(statMap$mask) else statMap$mask
  rawstat = stat.statMap(statMap)
  template = statMap$template
  df = statMap$df
  rdf = statMap$rdf

  if(df==0){
    cfts = cfts * 2
    ts = qchisq(cfts, 1, lower.tail=FALSE)
    sgnstat = sign(rawstat)
    stat = rawstat^2
    df=1; zerodf=TRUE
  } else {
    ts = qchisq(cfts, df, lower.tail=FALSE)
    zerodf=FALSE
  }

  tmp = mask
  tmp = lapply(ts, function(th){ tmp[ mask!=0] = (stat[mask!=0]>th); tmp})
  k = mmand::shapeKernel(3, 3, type=kernel)
  clustmaps = lapply(tmp, function(tm, mask) {out = mmand::components(tm, k); out[is.na(out)] = 0; RNifti::updateNifti(out, mask)}, mask=mask)
  ccomps = lapply(tmp, function(tm) table(c(mmand::components(tm, k))) )

  sqrtSigma <- if(is.character(statMap$sqrtSigma)) {
    apply(readNifti(statMap$sqrtSigma), 4, function(x) x[mask!=0])
  } else {
    statMap$sqrtSigma
  }
  rm(statMap)

  n = ncol(sqrtSigma)
  if(is.null(rdf)) rdf=n

  ssqs = sqrt(rowSums(sqrtSigma^2))
  if( any(ssqs != 1) ) sqrtSigma = sweep(sqrtSigma, 1, ssqs, '/')

  p=nrow(sqrtSigma)

  #sqrtSigma <- as.big.matrix(sqrtSigma)
  Fs = matrix(NA, nboot, length(cfts))

  # if(.Platform$OS.type=='windows')
  # {
    pb = txtProgressBar(style=3, title='Generating null distribution')
    for(i in 1:nboot)
    {
      tmp = mask
      S = matrix(rnorm(n*df), n, df)
      statimg = rowSums((sqrtSigma %*% S)^2)
      tmp = lapply(ts, function(th){ tmp[ mask!=0] = (statimg>th); tmp})
      Fs[i, ] = sapply(tmp, function(tm) max(c(table(c(mmand::components(tm, k))),0), na.rm=TRUE))
      setTxtProgressBar(pb, round(i/nboot,2))
    }
    close(pb)
  # } else { # Support for Shared memory
  #
  #   cat('Generating null distribution in parallel.\n')
  #
  #   jobs <- lapply(1:nboot, function(i) {
  #     mcparallel({
  #       require(bigalgebra)
  #       tmp     <- mask
  #       S       <- matrix(rnorm(r*df), r, df)
  #       statimg <- rowSums((sqrtSigma %*% S)^2)
  #       tmp     <- lapply(ts, function(th){ tmp[ mask!=0] = (statimg>th); tmp})
  #       sapply(tmp, function(tm) max(c(table(c(mmand::components(tm, k))),0), na.rm=TRUE))
  #       return(123)
  #     }, detached=FALSE)
  #
  #   })
  #   Fs = mccollect(jobs, wait=TRUE)
  #   Fs = mccollect(jobs)
  #   browser()
  #   Fs = do.call(rbind, Fs)
  #   cat('Completed generation of null distribution.\n')
  # }
  rm(sqrtSigma) # Free large big memory matrix object

  # add the stat max
  ccomps = lapply(ccomps, function(x) if(length(x)==0) 0 else x)
  Fs = rbind(Fs, sapply(ccomps, max)) + 0.01 # plus 0.01 to get bootstrap precision (nonzero) p-values
  # compute empirical CDFs
  Fs = apply(Fs, 2, ecdf)
  pvals = lapply(1:length(cfts), function(ind) 1-Fs[[ind]](ccomps[[ind]]) )
  names(pvals) = paste('cft', ts, sep='')
  if(!zerodf){
    pmaps = lapply(1:length(ts), function(ind){ for(ind2 in 1:length(pvals[[ind]])){
      clustmaps[[ind]][ clustmaps[[ind]]==ind2] = -log10(pvals[[ind]][ind2])
    }
      clustmaps[[ind]]
    } )
  } else {
    pmaps = lapply(1:length(ts), function(ind){ for(ind2 in 1:length(pvals[[ind]])){
      clustmaps[[ind]][ clustmaps[[ind]]==ind2] = -log10(pvals[[ind]][ind2]) * sgnstat[ clustmaps[[ind]]==ind2 ]
    }
      clustmaps[[ind]]
    } )
  }
  names(pvals) <- names(pmaps) <- names(clustmaps) <- paste('cft', cftsnominal, sep='')

  out = list(pvalues=pvals, clustermap=clustmaps, pmap=pmaps, CDF=Fs)
  # changes indexing order of out
  out = apply(do.call(rbind, out), 2, as.list)
  if(zerodf) df=0
  out = c(stat=list(rawstat), template=list(template), mask=list(mask), df=list(df), out)
  class(out) = c('pbj', 'list')
  return(out)
}
