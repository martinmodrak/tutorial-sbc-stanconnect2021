target_dir <- "./html"
if(!dir.exists(target_dir)) {
  dir.create(target_dir)
}
rmarkdown::render("index.Rmd")
rmarkdown::render("sbc_intro.Rmd")
rmarkdown::render("exercise_1_theory.Rmd")
rmarkdown::render("exercise_2_first_SBC.Rmd")
#rmarkdown::render("exercise_2_first_SBC_solutions.Rmd")
rmarkdown::render("exercise_3_regression.Rmd")

files <- c("libs", list.files(pattern = "*.html"), list.files(pattern = "_files", include.dirs = TRUE))
file.rename(from = files, to = paste0(target_dir, "/", files))

