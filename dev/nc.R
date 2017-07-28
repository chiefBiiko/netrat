# nc

init_nc_server <- function(host, port) {
  stopifnot(grepl('unix', .Platform$OS.type, TRUE), 
            grepl('[[:alnum:][:punct:]]+', host),
            port %in% 1024L:65535L)
  NC_SER <- file.path(getwd(), 'nc_server.R')
  NC_LOG <- file.path(getwd(), 'nc_server.log')
  RSCRIPT <- normalizePath(file.path(R.home(), 'bin', 'Rscript'))
  if (!file.exists(RSCRIPT)) stop('Rscript.exe not found @\n', RSCRIPT)
  cat(sprintf('sys::exec_background(\'nc\', \'-l %s %d 2>&1 | tee -a "%s"\')', 
              host, port, NC_LOG), 
      file=NC_SER)
  cat('', file=NC_LOG)
  message('Launching child process...')
  RS_PID <- as.integer(sys::exec_background(RSCRIPT, NC_SER))
  return(RS_PID)
}
