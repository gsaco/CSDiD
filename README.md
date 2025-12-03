# 🔬 CSDiD: Callaway-Sant'Anna Difference-in-Differences Analysis

<div align="center">

![Python](https://img.shields.io/badge/Python-3.9+-blue?style=for-the-badge&logo=python&logoColor=white)
![R](https://img.shields.io/badge/R-4.3+-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?style=for-the-badge&logo=jupyter&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A comprehensive implementation of Two-Way Fixed Effects (TWFE) and Callaway-Sant'Anna (2021) Difference-in-Differences estimators in both Python and R**

[📊 View Results](#-output-gallery) • [🚀 Quick Start](#-quick-start) • [📖 Documentation](#-methodology) • [🤝 Contributing](#-contributing)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Methodology](#-methodology)
- [Assignment Solutions](#-assignment-solutions)
- [Output Gallery](#-output-gallery)
- [Dependencies](#-dependencies)
- [References](#-references)

---

## 🎯 Overview

This repository provides a complete analysis of **staggered difference-in-differences** estimation, comparing traditional **Two-Way Fixed Effects (TWFE)** approaches with the modern **Callaway and Sant'Anna (2021)** estimator. The analysis is implemented in both **Python** and **R** using Jupyter notebooks, demonstrating best practices for causal inference with panel data.

### 👥 Team: Group 1

### Key Features

✅ **Dual Implementation**: Complete solutions in both Python and R  
✅ **Interactive Notebooks**: Well-documented Jupyter notebooks with explanations  
✅ **Publication-Quality Visualizations**: All graphs exported to output folders  
✅ **Comprehensive Comparisons**: TWFE vs. CSDiD side-by-side analysis  
✅ **Reproducible Research**: Requirements files for easy environment setup  

### Dataset

We use the **Bacon (2021) example dataset** containing state-level data on:
- **Outcome**: `asmrs` (age-standardized mortality rate)
- **Controls**: `pcinc` (per capita income), `asmrh`, `cases`
- **Treatment timing**: Staggered adoption across states

**Data Source**: [LOST STATS Repository](https://raw.githubusercontent.com/LOST-STATS/LOST-STATS.github.io/master/Model_Estimation/Data/Event_Study_DiD/bacon_example.csv)

---

## 📁 Project Structure

```
CSDiD/
├── 📄 README.md                    # This file
│
├── 🐍 Python/
│   ├── 📁 scripts/
│   │   ├── Q1_TWFE_EventStudy.ipynb    # Question 1: TWFE & Event-Study
│   │   └── Q2_CSDiD.ipynb              # Question 2: CSDiD Analysis
│   ├── 📁 output/                       # Generated plots and tables
│   └── 📄 requirements.txt              # Python dependencies
│
└── 📊 R/
    ├── 📁 scripts/
    │   ├── Q1_TWFE_EventStudy.ipynb    # Question 1: TWFE & Event-Study
    │   └── Q2_CSDiD.ipynb              # Question 2: CSDiD Analysis
    ├── 📁 output/                       # Generated plots and tables
    ├── 📄 requirements.txt              # R package list
    └── 📄 install_packages.R            # R package installer script
```

---

## 🚀 Quick Start

### Prerequisites

- **Python 3.9+** or **R 4.3+**
- **Jupyter Notebook** or **JupyterLab**

### Python Setup

```bash
# Clone the repository
git clone https://github.com/gsaco/CSDiD.git
cd CSDiD

# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r Python/requirements.txt

# Launch Jupyter
jupyter notebook Python/scripts/
```

### R Setup

```r
# Option 1: Run the installation script
Rscript R/install_packages.R

# Option 2: Manual installation
install.packages(c("tidyverse", "fixest", "did", "broom", 
                   "knitr", "kableExtra", "gridExtra", "scales", "IRkernel"))

# Register R kernel for Jupyter
IRkernel::installspec()
```

```bash
# Launch Jupyter
jupyter notebook R/scripts/
```

---

## 📖 Methodology

### Two-Way Fixed Effects (TWFE)

The traditional TWFE model is specified as:

$$Y_{it} = \alpha_i + \gamma_t + \beta \cdot D_{it} + X_{it}'\delta + \epsilon_{it}$$

Where:
- $\alpha_i$ = unit fixed effects
- $\gamma_t$ = time fixed effects
- $D_{it}$ = treatment indicator
- $X_{it}$ = time-varying controls

**⚠️ Limitations**: In staggered settings, TWFE can be biased due to:
- Negative weighting of already-treated units
- Heterogeneous treatment effects across cohorts

### Callaway-Sant'Anna (2021) Estimator

CSDiD addresses TWFE limitations by computing **group-time average treatment effects**:

$$ATT(g,t) = E[Y_t(1) - Y_t(0) | G_g = 1]$$

**Key advantages**:
- Uses only "clean" comparisons (never-treated or not-yet-treated controls)
- Explicit group-time decomposition
- Principled aggregation methods
- Robust to effect heterogeneity

---

## 📝 Assignment Solutions

### Question 1: TWFE & Event-Study (8 points)

| Part | Description | Points |
|------|-------------|--------|
| **a)** | TWFE regression with unit and time fixed effects | 2 |
| **b)** | Relative time creation, frequency table, bounds selection, dummy creation | 4 |
| **c)** | Event-study estimation, coefficient storage, and visualization | 2 |

#### Key Deliverables:
- ✅ TWFE regression with clustered standard errors
- ✅ Event-time distribution analysis with justification for bounds
- ✅ Event-study coefficient plot with 95% confidence intervals
- ✅ Answer: Why group distant event times? (Statistical power, multicollinearity, composition effects)

### Question 2: CSDiD (12 points)

| Part | Description | Points |
|------|-------------|--------|
| **a)** | ATT(g,t) estimation and presentation | 3 |
| **b)** | Aggregations by group, period, and event-time | 3 |
| **c)** | Explanation of aggregations and comparison question | 2.5 |
| **d)** | Comparison table, combined plot, and discussion | 3.5 |

#### Key Deliverables:
- ✅ Complete ATT(g,t) table and heatmap visualization
- ✅ Three aggregation types with individual visualizations
- ✅ Detailed explanations of each aggregation's meaning
- ✅ Answer: Event-time aggregation is most comparable to TWFE event-study
- ✅ Side-by-side comparison table and combined coefficient plot
- ✅ Discussion of differences and implications

---

## 🖼️ Output Gallery

All visualizations are automatically exported to the respective `output/` folders when notebooks are executed:

### Event-Study Plots

| Description | Python | R |
|-------------|--------|---|
| Event Time Distribution | `event_time_distribution.png` | `event_time_distribution.png` |
| TWFE Event-Study | `event_study_plot.png` | `event_study_plot.png` |

### CSDiD Visualizations

| Description | Filename |
|-------------|----------|
| ATT(g,t) Heatmap | `att_gt_heatmap.png` |
| Aggregation by Group | `csdid_aggregation_group.png` |
| Aggregation by Calendar | `csdid_aggregation_calendar.png` |
| Dynamic Effects (Event-Time) | `csdid_event_study.png` |

### Comparison Outputs

| Description | Filename |
|-------------|----------|
| Combined Coefficient Plot | `comparison_plot_csdid_twfe.png` |
| Comparison Table | `comparison_csdid_twfe.csv` |

### Data Exports

| Description | Filename |
|-------------|----------|
| Event-Study Coefficients | `event_study_coefficients.csv` |
| ATT(g,t) Results | `att_gt_results.csv` |
| CSDiD Event-Time | `csdid_event_time.csv` |

---

## 📦 Dependencies

### Python

| Package | Version | Purpose |
|---------|---------|---------|
| `pandas` | ≥1.5.0 | Data manipulation |
| `numpy` | ≥1.23.0 | Numerical computing |
| `statsmodels` | ≥0.14.0 | Statistical models |
| `linearmodels` | ≥5.0 | Panel data models (TWFE) |
| `csdid` | ≥0.1.0 | Callaway-Sant'Anna DiD |
| `matplotlib` | ≥3.6.0 | Base visualization |
| `seaborn` | ≥0.12.0 | Statistical graphics |
| `scipy` | ≥1.10.0 | Scientific computing |

### R

| Package | Version | Purpose |
|---------|---------|---------|
| `tidyverse` | ≥2.0.0 | Data manipulation & visualization |
| `fixest` | ≥0.11.0 | Fast fixed-effects estimation |
| `did` | ≥2.1.0 | Callaway-Sant'Anna DiD |
| `broom` | ≥1.0.0 | Tidy model outputs |
| `kableExtra` | ≥1.3.0 | Enhanced tables |
| `gridExtra` | ≥2.3 | Multiple plot arrangements |
| `scales` | ≥1.2.0 | Axis scale formatting |

---

## 🔬 Technical Notes

### Why CSDiD over TWFE?

In settings with **staggered treatment adoption**, traditional TWFE estimators can produce biased estimates because:

1. **Negative Weights**: Already-treated units may serve as controls for newly-treated units, receiving negative weights in the estimator
2. **Heterogeneity Bias**: If treatment effects vary across cohorts or over time, TWFE averages these in potentially misleading ways
3. **Forbidden Comparisons**: TWFE implicitly makes comparisons that violate the parallel trends assumption

The Callaway-Sant'Anna estimator solves these issues by:
- Computing separate ATT(g,t) for each group-time combination
- Using only never-treated or not-yet-treated units as controls
- Providing transparent aggregation methods

### Aggregation Interpretations

| Aggregation | What it Measures | Use Case |
|-------------|------------------|----------|
| **By Group** | Average effect for each treatment cohort | Heterogeneity across cohorts |
| **By Calendar** | Average effect in each calendar period | Policy evaluation at specific times |
| **By Event-Time** | Average effect at each relative time | Dynamic treatment effects |

---

## 📚 References

### Primary Literature

1. **Callaway, B., & Sant'Anna, P. H. (2021)**. *Difference-in-Differences with Multiple Time Periods*. Journal of Econometrics, 225(2), 200-230. [DOI](https://doi.org/10.1016/j.jeconom.2020.12.001)

2. **Goodman-Bacon, A. (2021)**. *Difference-in-Differences with Variation in Treatment Timing*. Journal of Econometrics, 225(2), 254-277. [DOI](https://doi.org/10.1016/j.jeconom.2021.03.014)

3. **Sun, L., & Abraham, S. (2021)**. *Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects*. Journal of Econometrics, 225(2), 175-199.

4. **de Chaisemartin, C., & D'Haultfœuille, X. (2020)**. *Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects*. American Economic Review, 110(9), 2964-2996.

### Additional Resources

- 📖 [LOST STATS - Event Study](https://lost-stats.github.io/Model_Estimation/Research_Design/event_study.html)
- 📖 [Mixtape Sessions - Difference-in-Differences](https://github.com/Mixtape-Sessions/Difference-in-Differences)
- 📖 [Asjad Naqvi's DiD Repository](https://asjadnaqvi.github.io/DiD/)
- 📖 [Pedro Sant'Anna's DiD Resources](https://psantanna.com/software/)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👥 Authors

**Group 1**

- GitHub Repository: [CSDiD](https://github.com/gsaco/CSDiD)

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

---

Made with ❤️ for causal inference

*Last updated: December 2024*

</div>
