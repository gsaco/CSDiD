<!-- PROJECT README - CSDiD -->
# CSDiD — Difference-in-Differences (TWFE & CSDiD) Homework

[![Notebook Status](https://img.shields.io/badge/notebooks-ready-brightgreen)](https://github.com/gsaco/CSDiD)
[![License](https://img.shields.io/badge/license-none-lightgrey)](#)

---

Welcome! This repository contains a clean, reproducible solution for a Difference-in-Differences homework assignment comparing two approaches:

- Two-Way Fixed Effects (TWFE), and
- Callaway & Sant'Anna's (CSDiD) heterogeneity-robust difference-in-differences estimator.

The analysis uses the Bacon (2021) example dataset (LOST-STATS) and includes both R and Python notebook implementations.

Key goals of this repository:

- Produce reproducible code and clear figures that answer the homework prompt.
- Demonstrate differences between TWFE and CSDiD in staggered adoption settings.
- Save all intermediate and final results to a tidy `output/` folder for reproducibility and review.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Project Structure](#project-structure)
3. [Data](#data)
4. [How to Run](#how-to-run)
5. [What’s Inside: Questions & Outputs](#whats-inside-questions--outputs)
6. [Methodology](#methodology)
7. [Reproducibility & Recommended Environments](#reproducibility--recommended-environments)
8. [References & Further Reading](#references--further-reading)
9. [Contact](#contact)

---

## Quick Start

Use these steps to run the analyses from scratch and reproduce results. There are both R and Python implementations.

1. Clone the repository:

```bash
git clone https://github.com/gsaco/CSDiD.git
cd CSDiD
```

2. Choose your environment:
- For Python: Create a virtual environment and install the Python requirements.
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r Python/requirements.txt
```
- For R: Use the environment and installation script under `R/`.
```r
# In an R session
source('R/install_packages.R')  # or follow the instructions in R/requirements.txt
```

3. Open and run the notebooks in order. The Python notebooks are in `Python/scripts/` and the R notebooks are in `R/scripts/`.
  - Run: `Q1_TWFE_EventStudy.ipynb` first (TWFE + Event Study)
  - Then: `Q2_CSDiD.ipynb` (Callaway & Sant'Anna + comparison)

4. Check `output/` for resulting CSVs and figures after execution.

---

## Project Structure

```
CSDiD/
├── README.md
├── R/
│   ├── scripts/
│   │   ├── Q1_TWFE_EventStudy.ipynb
│   │   └── Q2_CSDiD.ipynb
│   ├── output/
│   ├── csdid_env.yml
│   ├── requirements.txt
│   └── install_packages.R
├── Python/
│   ├── scripts/
│   │   ├── Q1_TWFE_EventStudy.ipynb
│   │   └── Q2_CSDiD.ipynb
│   ├── output/
│   └── requirements.txt
└── .gitignore
```

### Where to find the key files
- Notebook solutions (R and Python): `R/scripts/` and `Python/scripts/`
- Saved outputs and figures: `R/output/` and `Python/output/` (these are created when notebooks run)
- Environment requirements: `Python/requirements.txt` and `R/requirements.txt` or `R/csdidr_env.yml`

---

## Data

We use the Bacon (2021) example dataset provided in the LOST-STATS repository. The dataset is loaded directly from the GitHub URL in the notebooks:
```
https://raw.githubusercontent.com/LOST-STATS/LOST-STATS.github.io/master/Model_Estimation/Data/Event_Study_DiD/bacon_example.csv
```

The most important variables:
- `asmrs`: Outcome (age-standardized mortality rate)
- `pcinc`, `asmrh`, `cases`: Controls
- `_nfd`: First treatment period (cohort indicator, 0 for never-treated)
- `year`, `stfips`: Time and unit identifiers

---

## How to Run

R (recommended)
1. Install dependencies (see `R/requirements.txt` / `R/install_packages.R`).
2. Open `R/scripts/Q1_TWFE_EventStudy.ipynb` in Jupyter, run all cells.
3. Open `R/scripts/Q2_CSDiD.ipynb` in Jupyter, run all cells.

Python (equivalent)
1. Install Python dependencies: `pip install -r Python/requirements.txt`.
2. Open and run `Python/scripts/Q1_TWFE_EventStudy.ipynb` (run all cells).
3. Open and run `Python/scripts/Q2_CSDiD.ipynb` (run all cells).

Running order matters: Q2 uses outputs from Q1 (notably TWFE event-study coefficients) for comparison.

If you prefer CLI/automated runs, you can execute notebooks using `papermill` or `nbconvert`:

```bash
# Example with nbconvert (executes notebook and replaces with output)
jupyter nbconvert --execute --inplace Python/scripts/Q1_TWFE_EventStudy.ipynb
jupyter nbconvert --execute --inplace Python/scripts/Q2_CSDiD.ipynb
```

---

## What's Inside: Questions & Outputs

This repository answers the following tasks (matching the assignment rubric):

### Question 1 — TWFE & Event-Study (8 pts)
- Part a) TWFE regression (2 pts): Two-way fixed effects with unit/time FE and clustered SEs.
- Part b) Event-Study cleaning (3 pts): Create event time, frequency table, bin extremes, and dummies.
- Part c) Event-Study estimation (3 pts): Run event-study, extract coefficients, and plot.

### Question 2 — CSDiD (12 pts)
- Part a) ATT(g,t) estimation (3 pts): Callaway-Sant'Anna estimator with control group selection.
- Part b) Aggregations (3 pts): Group, calendar, and event-time aggregations.
- Part c) Explanation of aggregations (2.5 pts): Meaning and comparability with TWFE.
- Part d) Comparison and visualization (3.5 pts): Compare CSDiD event-time ATT with TWFE event-study estimates.

### Key Output Files
- `event_study_coefficients.csv` — Event study coefficients from the TWFE model
- `att_gt_results.csv` — ATT(g,t) estimates from Callaway & Sant'Anna
- `csdid_event_time.csv`, `group_aggregation.csv`, `calendar_aggregation.csv` — Aggregated summaries
- `comparison_csdid_twfe.csv` — Comparison table
- Plots in `output/` — Event-study plots, heatmaps, and comparison plots

---

## Methodology (Short)

1. TWFE (static and event-study): A linear model with unit and time fixed effects. May be biased in staggered adoption settings if treatment effects are heterogeneous.

2. Callaway & Sant'Anna (2021): Heterogeneity-robust DiD estimator providing ATT(g,t) estimates and aggregations that avoid forbidden comparisons.

The notebooks provide both implementations (R and Python), clear visualization, and CSV export of all estimates.

---

## Reproducibility & Recommended Environments

Python environment (recommended minimal setup):

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r Python/requirements.txt
```

R environment (recommended minimal setup):

1. Use `R/requirements.txt` to see required packages, or use `R/csdidr_env.yml` to create a conda environment.

Example using conda:

```bash
conda env create -f R/csdidr_env.yml
conda activate csdid_env
```

If you prefer to install packages directly in R (see `R/requirements.txt` for suggestions):

```r
packages <- c('tidyverse', 'fixest', 'did', 'broom', 'knitr', 'kableExtra', 'gridExtra', 'scales', 'IRkernel')
install.packages(packages)
IRkernel::installspec()
```

Notes:
- The notebooks write output files to `Python/output/` and `R/output/` by default. Ensure those folders exist or will be created at runtime.
- Some packages implement versions that update behaviour; testing with the versions listed in the `requirements.txt` files is recommended.

---

## References & Further Reading

1. Callaway, B., & Sant'Anna, P. H. (2021). Difference-in-Differences with Multiple Time Periods. Journal of Econometrics.
2. Goodman-Bacon, A. (2021). Difference-in-Differences with Variation in Treatment Timing. Journal of Econometrics.
3. de Chaisemartin, C., & D'Haultfœuille, X. (2020). Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects. American Economic Review.

---

## Contact

Repository maintained by Group 1 (gsaco). Please open an issue or contact the author via GitHub for questions, feedback, or requests.

---

## Acknowledgments

The example dataset and pedagogical approach are adapted from the LOST-STATS Bacon (2021) example and the foundational papers listed above.

---

*Generated: December 2025 — For educational use only.*
# TWFE and CSDiD Homework Solution

**Applied Econometrics — Difference-in-Differences Analysis**

---

## Overview

This repository contains a complete homework solution comparing **Two-Way Fixed Effects (TWFE)** with the **Callaway-Sant'Anna (CSDiD)** estimator for difference-in-differences with staggered treatment adoption.

### Assignment Structure

| Question | Topic | Points |
|----------|-------|--------|
| **Q1** | TWFE & Event-Study | 8 pts |
| **Q2** | CSDiD Estimation & Comparison | 12 pts |

### Dataset

**Bacon (2021) Example Data** — State-level panel data on:
- **Outcome**: `asmrs` (age-standardized mortality rate)
- **Controls**: `pcinc`, `asmrh`, `cases`
- **Treatment**: Staggered policy adoption across states

Data Source: [LOST STATS Repository](https://raw.githubusercontent.com/LOST-STATS/LOST-STATS.github.io/master/Model_Estimation/Data/Event_Study_DiD/bacon_example.csv)

---

## Project Structure

```
CSDiD/
├── README.md
├── R/
│   ├── scripts/
│   │   ├── Q1_TWFE_EventStudy.ipynb   # Question 1 solution
│   │   └── Q2_CSDiD.ipynb             # Question 2 solution
│   ├── output/                         # Generated plots and tables
│   └── requirements.txt
└── Python/
    ├── scripts/
    │   ├── Q1_TWFE_EventStudy.ipynb
    │   └── Q2_CSDiD.ipynb
    └── output/
```

---

## Quick Start (R)

### Prerequisites
- R 4.3+
- Jupyter with R kernel (IRkernel)

### Setup

```r
# Install required packages
install.packages(c("tidyverse", "fixest", "did", "broom", "scales"))

# Install Jupyter R kernel
IRkernel::installspec()
```

### Run Notebooks

1. Open `R/scripts/Q1_TWFE_EventStudy.ipynb` — Run all cells
2. Open `R/scripts/Q2_CSDiD.ipynb` — Run all cells (requires Q1 output)

---

## Question 1: TWFE & Event-Study (8 points)

### Part a) TWFE Regression (2 pts)
- Two-way fixed effects with unit and time FE
- Controls: `pcinc`, `asmrh`, `cases`
- Clustered standard errors at state level
- Interpretation of treatment effect coefficient

### Part b) Event-Study Preparation (3 pts)
- **b.1** Create relative time variable (1.5 pts)
- **b.2** Frequency table of event times (0.5 pts)
- **b.3** Choose bounds for binning: **[-10, +10]** (0.5 pts)
- **b.4** Answer: Why group distant event times? (0.5 pts)
  - Statistical power, multicollinearity, composition effects
- **b.5** Create event-time dummies with t = -1 reference (1 pt)

### Part c) Event-Study Estimation (2 pts)
- Event-study regression with unit and time FE
- Coefficient extraction and storage
- Publication-quality event-study plot

---

## Question 2: CSDiD (12 points)

### Part a) ATT(g,t) Estimation (3 pts)
- Callaway-Sant'Anna estimator with doubly-robust method
- Control group: **not-yet-treated** (never-treated + future-treated)
- Justification of control group choice

### Part b) Aggregations (3 pts)
1. **By Group** — Average effect per treatment cohort
2. **By Calendar Time** — Average effect per calendar year
3. **By Event-Time** — Dynamic effects (comparable to event-study)

### Part c) Explanation of Aggregations (2.5 pts)
- Meaning of each aggregation type
- **Answer**: Event-time aggregation is most comparable to TWFE event-study

### Part d) Comparison with TWFE (3.5 pts)
- Side-by-side comparison table
- Combined event-study plot (CSDiD vs TWFE)
- Discussion of similarities and differences

---

## Output Files

### From Q1 (TWFE & Event-Study)
| File | Description |
|------|-------------|
| `event_time_distribution.png` | Distribution of event times |
| `event_study_plot.png` | TWFE event-study coefficients |
| `event_study_coefficients.csv` | Coefficient estimates |

### From Q2 (CSDiD)
| File | Description |
|------|-------------|
| `att_gt_results.csv` | All ATT(g,t) estimates |
| `group_aggregation.csv` | Group-level aggregation |
| `calendar_aggregation.csv` | Calendar-time aggregation |
| `csdid_event_time.csv` | Event-time aggregation |
| `csdid_group_agg.png` | Group aggregation plot |
| `csdid_calendar_agg.png` | Calendar aggregation plot |
| `csdid_event_study.png` | Event-time plot |
| `comparison_csdid_twfe.csv` | Comparison table |
| `comparison_plot_csdid_twfe.png` | Combined comparison plot |

---

## Methodology

### Two-Way Fixed Effects (TWFE)

$$Y_{it} = \alpha_i + \gamma_t + \beta \cdot D_{it} + X_{it}'\delta + \varepsilon_{it}$$

**Limitation**: In staggered settings, TWFE can be biased because it implicitly uses already-treated units as controls.

### Callaway-Sant'Anna (2021)

$$ATT(g,t) = E[Y_t(1) - Y_t(0) \mid G_g = 1]$$

**Advantage**: Uses only clean comparisons (never-treated or not-yet-treated controls), producing unbiased estimates under weaker assumptions.

---

## Key References

1. **Callaway, B., & Sant'Anna, P. H. (2021)**. Difference-in-Differences with Multiple Time Periods. *Journal of Econometrics*, 225(2), 200-230.

2. **Goodman-Bacon, A. (2021)**. Difference-in-Differences with Variation in Treatment Timing. *Journal of Econometrics*, 225(2), 254-277.

3. **de Chaisemartin, C., & D'Haultfœuille, X. (2020)**. Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects. *American Economic Review*, 110(9), 2964-2996.

---

## Author

**Group 1**  
Repository: [github.com/gsaco/CSDiD](https://github.com/gsaco/CSDiD)

*Last updated: December 2024*
