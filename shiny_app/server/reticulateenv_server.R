PYTHON_DEPENDENCIES = c("hic-straw==1.3","matplotlib==3.7","pandas==2.0", "pybigwig==0.3.18", "requests")


envs<-reticulate::virtualenv_list()

if(!'example_env_name' %in% envs){

    # ------------------ App virtualenv setup (Do not edit) ------------------- #
    virtualenv_dir = Sys.getenv('VIRTUALENV_NAME')
    python_path = Sys.getenv('PYTHON_PATH')

    shinyCatch({message("Initializing Environment...This can take a couple minutes")}, prefix = '')
    # Create virtual env and install dependencies
    reticulate::virtualenv_create(envname = virtualenv_dir, python = python_path)
    shinyCatch({message("Downloading Python packages...")}, prefix = '')
    reticulate::virtualenv_install(virtualenv_dir, packages = PYTHON_DEPENDENCIES, ignore_installed=TRUE)
    reticulate::use_virtualenv(virtualenv_dir, required = T)
    shinyCatch({message("Finished Initializing environment...")}, prefix = '')
}
  


reticulate::source_python("python/functions.py")
