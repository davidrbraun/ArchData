#version for linear models course 2015

draw.2.w.int.bw.cov.2<-function(plot.data, vars, coefs, link=c("identity", "logit", "log"),
  grid.resol=11, var.names, zlab, zlim=NULL, theta, phi=10, expand=0.6, r=sqrt(3), cex.lab=1, response, size.fac=NA, print.NA.cells, quiet=T, col="black"){
  #version nov 25, 2013
  #plots also when there is no interaction and also squared terms (potentially involved in interactions)
  old.par = par(no.readonly = TRUE)
  link=link[1]
	if(length(grid.resol)==1){grid.resol=rep(grid.resol, 2)}
	#extract coefficients needed:
	tk=unlist(lapply(strsplit(names(coefs), split=":", fixed=T), function(cf){
		length(cf)==sum(unlist(lapply(vars, function(v){
			grepl(x=cf, pattern=v)
		})))
	}))
	if(names(coefs)[1]=="(Intercept)"){tk[1]=T}
	coefs=coefs[tk]
  # coefs=coefs[unique(
    # c(grep(x=names(coefs), pattern="(Intercept)"),
    # grep(x=names(coefs), pattern=vars[1]),
    # grep(x=names(coefs), pattern=vars[2])))]
  # names.to.sort=names(coefs)[grep(names(coefs), pattern=":")]
  # names.to.sort=unlist(lapply(names.to.sort, function(x){
    # return(paste(sort(unlist(strsplit(x, split=":", fixed=T))), collapse=":"))
  # }))
  # names(coefs)[grep(names(coefs), pattern=":")]=names.to.sort
  # terms.to.add=c(
    # paste(sort(c(vars[1], vars[2])), collapse=":"),
    # paste(c("I(", vars[1],"^2)"), collapse=""),
    # paste(c("I(", vars[2],"^2)"), collapse=""),
    # paste(sort(c(paste(c("I(", vars[1],"^2)"), collapse=""), vars[2])), collapse=":"),
    # paste(sort(c(vars[1], paste(c("I(", vars[2],"^2)"), collapse=""))), collapse=":"),
    # paste(sort(c(paste(c("I(", vars[1],"^2)"), collapse=""), paste(c("I(", vars[2],"^2)"), collapse=""))), collapse=":"))
  # terms.to.add=terms.to.add[!terms.to.add%in%names(coefs)]
  # new.names=c(names(coefs), terms.to.add)
  # coefs=c(coefs, rep(0, length(terms.to.add)))
  # names(coefs)=new.names
  #browser()
	xvar1=seq(min(plot.data[,vars[1]]), max(plot.data[,vars[1]]), length.out=grid.resol[1])
  yvar2=seq(min(plot.data[,vars[2]]), max(plot.data[,vars[2]]), length.out=grid.resol[2])
	bin.x=cut(x=plot.data[,vars[1]], breaks=xvar1, labels=F, include.lowest=T)
	bin.y=cut(x=plot.data[,vars[2]], breaks=yvar2, labels=F, include.lowest=T)
	bin.x=min(xvar1)+diff(xvar1)[1]/2+((bin.x-1)*diff(xvar1)[1])
	bin.y=min(yvar2)+diff(yvar2)[1]/2+((bin.y-1)*diff(yvar2)[1])

  obs.mean=tapply(response, list(bin.x, bin.y), mean, na.rm=T)
  obs.mean=as.data.frame(as.table(obs.mean))
  names(obs.mean)[1:2]=c("x", "y")
  obs.mean$x=as.numeric(as.character(obs.mean$x))
  obs.mean$y=as.numeric(as.character(obs.mean$y))
  obs.mean=na.omit(obs.mean)
	#determine complete observation:
	complete.obs=apply(is.na(data.frame(plot.data[, vars], response)), 1, sum)==0
  #and the sample zize per cell
  obs.n=tapply(complete.obs, list(bin.x, bin.y), sum)
  obs.n=as.data.frame(as.table(obs.n))
  names(obs.n)[1:2]=c("x", "y")
  obs.n$x=as.numeric(as.character(obs.n$x))
  obs.n$y=as.numeric(as.character(obs.n$y))
  obs.n=na.omit(obs.n)
  if(is.na(size.fac)){obs.n$Freq=1; size.fac=1}
  # pred.mean=coefs[names(coefs)=="(Intercept)"]+
        # coefs[names(coefs)%in%vars[1]]*obs.mean$x+
        # coefs[names(coefs)%in%vars[2]]*obs.mean$y+
        # coefs[names(coefs)%in%paste(sort(c(vars[1], vars[2])), collapse=":")]*obs.mean$x*obs.mean$y+
        # #and for the coefficients involving squared terms
        # coefs[names(coefs)%in%paste(c("I(", vars[1],"^2)"), collapse="")]*obs.mean$x^2+
        # coefs[names(coefs)%in%paste(c("I(", vars[2],"^2)"), collapse="")]*obs.mean$y^2+
        # coefs[names(coefs)%in%paste(sort(c(paste(c("I(", vars[1],"^2)"), collapse=""), vars[2])), collapse=":")]*obs.mean$x^2*obs.mean$y+
        # coefs[names(coefs)%in%paste(sort(c(vars[1], paste(c("I(", vars[2],"^2)"), collapse=""))), collapse=":")]*obs.mean$x*obs.mean$y^2+
        # coefs[names(coefs)%in%paste(sort(c(paste(c("I(", vars[1],"^2)"), collapse=""), paste(c("I(", vars[2],"^2)"), collapse=""))), collapse=":")]*obs.mean$x^2*obs.mean$y^2
  #get the predicted means at the centers of the cells:
	rr=runif(nrow(obs.mean))
	xx=obs.mean[, c("x", "y")]
	colnames(xx)=vars 
  pvs=model.matrix(object=as.formula(paste(c("rr", paste(c(1, names(coefs)[-1]), collapse="+")), collapse="~")), data=xx)
	pred.mean=apply(t(coefs*t(pvs[, names(coefs)])), 1, sum)
  if(link=="log"){pred.mean=exp(pred.mean)}
  if(link=="logit"){pred.mean=exp(pred.mean)/(1+exp(pred.mean))}
  symbol=rep(1, nrow(obs.mean))
  symbol[obs.mean$Freq>pred.mean]=19
	xcol=rep("black", nrow(obs.mean))
	xcol[obs.mean$Freq>pred.mean]=col
  # z=outer(xvar1, yvar2, function(x,y){
    # LP=coefs[names(coefs)=="(Intercept)"]+
      # coefs[names(coefs)%in%vars[1]]*x+
      # coefs[names(coefs)%in%vars[2]]*y+
      # coefs[names(coefs)%in%paste(sort(c(vars[1], vars[2])), collapse=":")]*x*y+
      # #and for the coefficients involving squared terms
      # coefs[names(coefs)%in%paste(c("I(", vars[1],"^2)"), collapse="")]*x^2+
      # coefs[names(coefs)%in%paste(c("I(", vars[2],"^2)"), collapse="")]*y^2+
      # coefs[names(coefs)%in%paste(sort(c(paste(c("I(", vars[1],"^2)"), collapse=""), vars[2])), collapse=":")]*x^2*y+
      # coefs[names(coefs)%in%paste(sort(c(vars[1], paste(c("I(", vars[2],"^2)"), collapse=""))), collapse=":")]*x*y^2+
      # coefs[names(coefs)%in%paste(sort(c(paste(c("I(", vars[1],"^2)"), collapse=""), paste(c("I(", vars[2],"^2)"), collapse=""))), collapse=":")]*x^2*y^2
    # return(LP)
  # })
	pv.mat=data.frame(expand.grid(xvar1, yvar2))
	names(pv.mat)=vars
	rr=runif(nrow(pv.mat))
	z=model.matrix(object=as.formula(paste(c("rr", paste(c(1, names(coefs)[-1]), collapse="+")), collapse="~")), data=pv.mat)
	z=apply(t(coefs*t(z[, names(coefs)])), 1, sum)
	z=tapply(z, pv.mat[, c(vars[1], vars[2])], mean)

  if(link=="log"){z=exp(z)}
  if(link=="logit"){z=exp(z)/(1+exp(z))}
  if(!print.NA.cells){
    obs.mat=tapply(response, list(bin.x, bin.y), mean, na.rm=T)
    rownames(z)=xvar1
    colnames(z)=yvar2
    use=use.mat(obs.mat=obs.mat, z.mat=z)
    z[!use]=NA
  }
	if(length(zlim)==0){zlim=range(c(pred.mean, obs.mean$Freq), na.rm=T)}
  xplot=persp(x=xvar1, y=yvar2, z=z, theta=theta, phi=phi, expand=expand, r=r, xlab=var.names[1], ylab=var.names[2], zlab=zlab, zlim=zlim, cex.lab=cex.lab)
  for(i in 2:(grid.resol[1]-1)){
    lines(trans3d(x=xvar1[i], y=range(yvar2), z=min(zlim), pmat=xplot), lty=3, col="grey")
	}
  for(i in 2:(grid.resol[2]-1)){
    lines(trans3d(x=range(xvar1), y=yvar2[i], z=min(zlim), pmat=xplot), lty=3, col="grey")
  }
  points(trans3d(x=obs.mean$x, y=obs.mean$y, z=obs.mean$Freq, pmat=xplot), pch=symbol, cex=size.fac*obs.n$Freq^(1/3), col=xcol)
  sel.obs=data.frame(obs.mean, pred.mean)
  for(i in 1:nrow(sel.obs)){
    if(obs.mean$Freq[i]<=pred.mean[i]){
      lines(trans3d(x=sel.obs$x[i], y=sel.obs$y[i], z=c(min(zlim), sel.obs$Freq[i]), pmat=xplot), lty=3)
    }else{
      lines(trans3d(x=sel.obs$x[i], y=sel.obs$y[i], z=c(pred.mean[i], sel.obs$Freq[i]), pmat=xplot), lty=1)
      lines(trans3d(x=sel.obs$x[i], y=sel.obs$y[i], z=c(min(zlim), pred.mean[i]), pmat=xplot), lty=3)
    }
  }
  par(old.par)
  if(!quiet){
		names(obs.mean)=c(vars, "mean.response")
		obs.mean=data.frame(obs.mean, N=obs.n$Freq)
		return(list(zlim=zlim, plotted.data=obs.mean))
	}
}

use.mat<-function(obs.mat, z.mat){
  #version Mar. 13, 2012
  #create matrix with fake NAs such that each entry in z has four observations around it:
  xobs=cbind(NA, rbind(NA,obs.mat, NA),NA)
  zr.vals=as.numeric(rownames(z.mat))
  zc.vals=as.numeric(colnames(z.mat))
  rownames(xobs)[1]=min(zr.vals)-mean(diff(zr.vals))/2
  rownames(xobs)[nrow(xobs)]=max(zr.vals)+mean(diff(zr.vals))/2
  colnames(xobs)[1]=min(zc.vals)-mean(diff(zc.vals))/2
  colnames(xobs)[ncol(xobs)]=max(zc.vals)+mean(diff(zc.vals))/2
  #potentially include missing rows and columns:
  if(ncol(xobs)<ncol(z.mat)+1){
    cnames=round(seq(min(as.numeric(colnames(xobs))), max(as.numeric(colnames(xobs))), length.out=ncol(z.mat)+1),digits=4)
    xx=cnames%in%round(as.numeric(colnames(xobs)), digits=4)
    new.xobs=matrix(NA, ncol=ncol(z.mat)+1, nrow=nrow(xobs))
    new.xobs[,xx]=xobs
    colnames(new.xobs)=cnames
    rownames(new.xobs)=rownames(xobs)
    xobs=new.xobs
  }
  if(nrow(xobs)<nrow(z.mat)+1){
    cnames=round(seq(min(as.numeric(rownames(xobs))), max(as.numeric(rownames(xobs))), length.out=nrow(z.mat)+1),digits=4)
    xx=cnames%in%round(as.numeric(rownames(xobs)), digits=4)
    new.xobs=matrix(NA, nrow=nrow(z.mat)+1, ncol=ncol(xobs))
    new.xobs[xx,]=xobs
    rownames(new.xobs)=cnames
    colnames(new.xobs)=colnames(xobs)
    xobs=new.xobs
  }
  x.use=matrix(NA, ncol=ncol(z.mat), nrow=nrow(z.mat))
  for(rz in 1:nrow(x.use)){
    for(cz in 1:ncol(x.use)){
      x.use[rz, cz]=sum(!is.na(xobs[rz:(rz+1), cz:(cz+1)]))>0
    }
  }
  return(x.use)
}
