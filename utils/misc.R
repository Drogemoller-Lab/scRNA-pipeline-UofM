set.seed(333)

PrintSave <- function(plot, title, path="",  w=8, h=6){
  pdf(paste(path, title, sep=""), width = w, height = h)
  print(plot)
  graphics.off()
}

ListAllPossibleComparisons <- function(se.integrated, seurat.subset) {
  list.comparisons <- list("group")
  if (length(se.integrated@misc) != 0){
    for (j in se.integrated@misc$co.conditions){
      group.co <- paste0("group_", j)
      seurat.subset <- AddMetaData(seurat.subset, 
                                             paste(seurat.subset$group, 
                                                   seurat.subset@meta.data[[j]], sep = "_"), 
                                             group.co
                                             )
      list.comparisons <- append(list.comparisons, group.co)
    }
  }
  return(list.comparisons)
}

MatchCovariantGroupPairs <- function(seurat.subset, grouping, not.main.group) {
  # create pairs for each possible combination
  group.pairs <- as.data.frame(combn(unique(seurat.subset@meta.data[[grouping]]), 2))
  group.pairs <- sapply(group.pairs, function(x) as.character(x), simplify = FALSE)
  
  if (not.main.group >= 2){
    group.pairs.filt <- list()
    for (z in group.pairs){
      time.match <- sub("^[^_]*_", "", z) # not just time, this is for any co-variant
      if (time.match[1] == time.match[2]) {
        cond.mismatch <- sub("_.*", "", z)
        if (cond.mismatch[1] != cond.mismatch[2]){
          group.pairs.filt <- append(group.pairs.filt, list(z))
        }
      }
    }
    group.pairs <- group.pairs.filt
    print(group.pairs)
    
  }
  return(group.pairs)
}

Correcth5SeuratFile <- function(file){
  f <- H5File$new(file, "r+")
  groups <- f$ls(recursive = TRUE)
  
  for (name in groups$name[grepl("categories", groups$name)]) {
    names <- strsplit(name, "/")[[1]]
    names <- c(names[1:length(names) - 1], "levels")
    new_name <- paste(names, collapse = "/")
    f[[new_name]] <- f[[name]]
  }
  
  for (name in groups$name[grepl("codes", groups$name)]) {
    names <- strsplit(name, "/")[[1]]
    names <- c(names[1:length(names) - 1], "values")
    new_name <- paste(names, collapse = "/")
    f[[new_name]] <- f[[name]]
    grp <- f[[new_name]]
    grp$write(args = list(1:grp$dims), value = grp$read() + 1)
  }
  
  f$close_all()
}
