# R Package Installation Script
# ==============================
# Run this script to install all required R packages for the CSDiD project
# Usage: Rscript install_packages.R

cat("Installing required R packages for CSDiD project...\n\n")

# List of required packages
packages <- c(
  "tidyverse",   # Data manipulation and visualization
  "fixest",      # Fast fixed-effects estimation
  "did",         # Callaway-Sant'Anna DiD
  "broom",       # Tidy model outputs
  "knitr",       # Report generation
  "kableExtra",  # Enhanced tables
  "gridExtra",   # Arrange multiple plots
  "scales",      # Scale functions for visualization
  "IRkernel"     # R kernel for Jupyter notebooks
)

# Install packages that are not already installed
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(paste("Installing:", pkg, "\n"))
    # Try from conda (already installed) otherwise fallback to CRAN
    tryCatch({
      install.packages(pkg, repos = "https://cloud.r-project.org/")
    }, error = function(e) {
      cat(paste("CRAN install failed for:", pkg, "- trying remotes::install_github fallback\n"))
      if (!require("remotes", quietly = TRUE)) {
        install.packages("remotes", repos = "https://cloud.r-project.org/")
      }
      # Add common fallbacks for specific packages not available on CRAN
      if (pkg == "did") {
        tryCatch({
          remotes::install_github("bcallaway11/did")
        }, error = function(e2) {
          cat(paste("Failed to install 'did' from GitHub: ", e2$message, "\n"))
        })
      }
    })
  } else {
    cat(paste("Already installed:", pkg, "\n"))
  }
}

# Install all packages
invisible(sapply(packages, install_if_missing))

cat("\n========================================\n")
cat("Package installation complete!\n")
cat("========================================\n\n")

# Install and register IRkernel for Jupyter
cat("Registering R kernel for Jupyter...\n")
if (require("IRkernel", quietly = TRUE)) {
  # Register a kernel that displays as 'R (csdidr)' in Jupyter
  IRkernel::installspec(name = "ir-csdidr", displayname = "R (csdidr)", user = TRUE)
  cat("R kernel 'R (csdidr)' registered successfully!\n")
} else {
  cat("Warning: Could not register R kernel. Please install IRkernel manually.\n")
}

cat("\nAll set! You can now run the R notebooks.\n")
