# netrat

install_ncat <- function() {
  stopifnot(grepl('win', .Platform$OS.type, TRUE))
  URL <- 'http://nmap.org/dist/ncat-portable-5.59BETA1.zip'
  DEST <- sub('^.+/([^/]+)$', '\\1', URL)
  NCATDIR <- file.path('C:', sub('^.+/([^/]+)\\.zip$', '\\1', URL))
  NCATEXE <- file.path(NCATDIR, 'ncat.exe')
  if (file.exists(NCATEXE)) return(structure(NCATEXE, directory=NCATDIR))
  if (download.file(URL, DEST) != 0L) stop('Error downloading ncat @\n', URL)
  message('Unzipped:', unzip(DEST, exdir=file.path('C:', '')))
  if (unlink(DEST) != 0L) warning('Error deleting zip file @\n', DEST)
  if (!file.exists(NCATEXE)) stop('oops...')
  return(structure(NCATEXE, directory=NCATDIR))
}

init_ncat_server <- function(NCAT, host, port) {
  stopifnot(grepl('win', .Platform$OS.type, TRUE), 
            grepl('^.+ncat\\.exe$', NCAT),
            grepl('[[:alnum:][:punct:]]+', host),
            is.numeric(port) && port %in% 1024L:65535L)
  NCATSER <- file.path(attr(NCAT, 'directory'), 'ncat_server.R')
  NCATLOG <- file.path(getwd(), 'ncat_server.log')
  RSCRIPT <- normalizePath(file.path(R.home(), 'bin', 'Rscript.exe'))
  if (!file.exists(RSCRIPT)) stop('Rscript.exe not found @\n', RSCRIPT)
  cat(sprintf('system2(\'%s\', \'%s %d -l -k -o "%s"\')', 
              NCAT, host, port, NCATLOG), 
      file=NCATSER)
  message('Launching child processes...')
  RS_PID <- as.integer(sys::exec_background(RSCRIPT, NCATSER))
  Sys.sleep(3L)  # allow ncat to launch
  cmdout <- system2('cmd.exe', input='tasklist | findstr ncat.exe', 
                    stdout=TRUE, stderr=TRUE)
  ncatline <- grep('^\\s*ncat\\.exe', cmdout, value=TRUE)
  ncatlast <- ncatline[length(ncatline)]
  NC_PID <- as.integer(sub('^.*ncat\\.exe\\s+(\\d+)\\s+.*$', '\\1', ncatlast))
  message('Returning PIDS of child processes. To terminate them run:\n',
          '> lapply(PIDS, tools::pskill)')
  return(list(NC_PID=NC_PID, RS_PID=RS_PID))
}

locate_netrat_ncat <- function() {
  stopifnot(grepl('win', .Platform$OS.type, TRUE))
  EXE_PATH <- structure(file.path('C:', 
                                  'ncat-portable-5.59BETA1', 
                                  'ncat.exe'),
                        directory=file.path('C:', 
                                            'ncat-portable-5.59BETA1'))
  return(if (file.exists(EXE_PATH)) EXE_PATH else NULL)
}
