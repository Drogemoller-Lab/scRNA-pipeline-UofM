set.seed(333)

PrintSave <- function(plot, title, path="",  w=8, h=6){
  pdf(paste(path, title, sep=""), width = w, height = h)
  print(plot)
  graphics.off()
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
