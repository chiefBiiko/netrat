# netrat

install_ncat <- function() {
  stopifnot(grepl('win', .Platform$OS.type, TRUE))
  URL <- 'http://nmap.org/dist/ncat-portable-5.59BETA1.zip'
  DEST <- sub('^.+/([^/]+)$', '\\1', URL)
  NCATDIR <- file.path('C:', sub('^.+/([^/]+)\\.zip$', '\\1', URL))
  NCATEXE <- file.path(NCATDIR, 'ncat.exe')
  if (file.exists(NCATEXE)) return(structure(NCATEXE, directory=NCATDIR))
  if (download.file(URL, DEST) != 0L) stop('Error downloading ncat')
  cat('Unzipped:', unzip(DEST, exdir=file.path('C:', '')), sep='\n')
  if (unlink(DEST) != 0L) warning('Error deleting zip file')
  return(structure(NCATEXE, directory=NCATDIR))
}

init_ncat_server <- function(NCAT, host, port) {
  stopifnot(grepl('^.+ncat\\.exe$', NCAT),
            grepl('[[:alnum:][:punct:]]+', host),
            is.numeric(port) && port %in% 0L:65535L)
  NCATSER <- file.path(attr(NCAT, 'directory'), 'ncat_server.R')
  NCATLOG <- file.path(attr(NCAT, 'directory'), 'ncat_server.log')
  cat(sprintf('system2("%s", "%s %d -l -k -o %s")', 
              NCAT, host, port, NCATLOG), 
      file=NCATSER)
  RS_PID <- sys::exec_background('Rscript', NCATSER)
  Sys.sleep(3L)  # allow ncat to launch
  cmdout <- system2('cmd.exe', input='tasklist | findstr ncat.exe', 
                    stdout=TRUE, stderr=TRUE)
  ncatline <- grep('^\\s*ncat\\.exe', cmdout, value=TRUE)
  ncatlast <- ncatline[length(ncatline)]
  NC_PID <- as.integer(sub('^.*ncat\\.exe\\s+(\\d+)\\s+.*$', '\\1', ncatlast))
  return(list(NC_PID=NC_PID, RS_PID=RS_PID))
}

