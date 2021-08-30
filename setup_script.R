dir <- getwd()
cat("Setting up SBC tutorial materials in ", dir, "\n")
cat("This will: \n")
cat(" - Install packages `remotes`, `rstudioapi` and `SBC` (if not already installed)\n")
cat(" - Download and compile Stan models used in the exercise\n")
cat("\n")

if(menu(c("Never", "Yes", "No"), title="Do you want this?") != 2) {
  stop("Stopping")
}

cat("If you are having trouble before the live event, please ask for help at https://discourse.mc-stan.org/t/sbc-pre-tutorial-assistance-thread/24113\n")
cat("If the event is already running, you can get help at one of the 'Resolving Stan Problems' tables.\n")



if(length(list.files(path = dir, include.dirs = TRUE)) > 0) {
  if(menu(c("No", "No", "Sure, do this!"), title="The current directory is not empty. Setup tutorial here anyway?") != 3) {
    stop("Stopping.")
  }
}

if(!exists("stan_package")) {
  cat("\nLooking for Stan installation. To skip this step set `stan_package` to either 'rstan' or 'cmdstanr'.\n")

  if("cmdstanr" %in% rownames(installed.packages())) {
    cat("Found cmdstanr installation\n")
    cmdstanr::check_cmdstan_toolchain()
    cat("Trying to run cmdstanr example. This may take a minute.\n")
    example_res <- cmdstanr::cmdstanr_example(chains = 1, refresh = 0)
    if(!inherits(example_res, "CmdStanMCMC") || !all(example_res$return_codes() == 0)) {
      cat("Example failed. See above for instructions how to get help\n")
      stop("Stopping")
    }
    stan_package <- "cmdstanr"
  } else if("rstan" %in% rownames(installed.packages())) {
    cat("Found rstan installation\n")
    cat("Trying to run rstan example. This may take a minute or two\n")
    stancode <- 'data {real y_mean;} parameters {real y;} model {y ~ normal(y_mean,1);}'
    example_mod <- rstan::stan_model(model_code = stancode)
    example_res <- rstan::sampling(example_mod, data = list(y_mean = 0), chains = 1, refresh = 0)
    if(!inherits(example_res, "stanfit") || example_res@mode != 0L) {
      cat("Example failed. See above for instructions how to get help.\n")
      stop("Stopping")
    }
    stan_package <- "rstan"

  } else {
    cat("Didn't find an installation of either `rstan` or `cmdstanr`.\n")
    cat("We recommend installing `cmdstanr` - see https://mc-stan.org/cmdstanr/articles/cmdstanr.html for instructions.\n")
    stop("Stopping")
  }
}

if(!("remotes" %in% rownames(installed.packages()))) {
  cat("Installing remotes\n")
  install.packages("remotes")
}

if(stan_package == "rstan" && !("rstudioapi" %in% rownames(installed.packages()))) {
  cat("Installing rstudioapi\n")
  install.packages("rstudioapi")
}


if(!("SBC" %in% rownames(installed.packages()))) {
  cat("Installing SBC\n")
  remotes::install_github("hyunjimoon/SBC")
} else {
  cat("SBC already installed.\n")
}

models_to_prepare <- c("gamma.stan", "regression_1.stan", "regression_2.stan", "regression_3.stan")

cat("Downloading and compiling models\n")
for(i in 1:length(models_to_prepare)) {
  m_name <- models_to_prepare[i]
  cat("[", i , "/", length(models_to_prepare), "] - ", m_name, "\n", sep = "")
  if(!file.exists(m_name)) {
    download.file(paste0("https://raw.githubusercontent.com/martinmodrak/tutorial-sbc-stanconnect2021/main/", m_name),
                destfile = m_name)
  }
  if(stan_package == "cmdstanr") {
    m_tmp <- cmdstanr::cmdstan_model(m_name)
  } else if(stan_package == "rstan") {
    rstan::rstan_options(auto_write = TRUE)
    m_tmp <- rstan::stan_model(file = m_name)
  } else {
    stop("Invalid value of `stan_package`")
  }
}

cat("All OK. Using `", stan_package, "` as Stan interface.\n")
