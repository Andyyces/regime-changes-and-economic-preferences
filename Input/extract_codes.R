# Function to extract R code chunks from .Rmd and save to .R
extract_r_code_from_rmd <- function(input_rmd, output_r) {
  lines <- readLines(input_rmd)
  
  inside_chunk <- FALSE
  code_lines <- c()
  
  for (line in lines) {
    if (grepl("^```\\{r", line)) {
      inside_chunk <- TRUE
      next
    } else if (grepl("^```", line) && inside_chunk) {
      inside_chunk <- FALSE
      next
    }
    
    if (inside_chunk) {
      code_lines <- c(code_lines, line)
    }
  }
  
  writeLines(code_lines, con = output_r)
  cat("✅ Code extracted to", output_r, "\n")
}
