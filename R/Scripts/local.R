# ============================================================================
# Question 1: TWFE & Event-Study Analysis
# ============================================================================
install.packages("fixest")
# Cargar librerías necesarias
library(dplyr)
library(ggplot2)
library(fixest)  # Para regresiones con efectos fijos
library(readr)

# ============================================================================
# a) TWFE Regression
# ============================================================================

data <- read.csv("C:/Users/VICTOR/Documents/GitHub/CSDiD/R/Input/bacon_example.csv")
head(data)
head(data)
str(data)
twfe_model <- feols(asmrs ~ post + pcinc + asmrh + cases | 
                      stfips + year, 
                    data = data)
cat("\n=== RESULTADOS TWFE ===\n")
summary(twfe_model)

# ============================================================================
# b) Cleaning for Event-Study
# ============================================================================

# 1
data <- data %>%
  mutate(
    event_time = year - X_nfd,
    ever_treated = ifelse(any(post == 1), 1, 0)
  ) %>%
  group_by(stfips) %>%
  mutate(ever_treated = max(post)) %>%
  ungroup()
data_treated <- data %>% filter(ever_treated == 1)

# 2
freq_table <- data_treated %>%
  count(event_time) %>%
  arrange(event_time)

cat("\n=== TABLA DE FRECUENCIAS DE EVENT_TIME ===\n")
print(freq_table)
cat("\n=== RESUMEN DESCRIPTIVO ===\n")
print(summary(data_treated$event_time))

# 3
dist_plot <- ggplot(data_treated, aes(x = event_time)) +
  geom_bar(fill = "steelblue", alpha = 0.7) +
  labs(title = "Distribución de Event Time",
       subtitle = "Solo unidades tratadas",
       x = "Event Time (años relativos al tratamiento)",
       y = "Frecuencia") +
  theme_minimal() +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1)

print(dist_plot)

min_et <- min(data_treated$event_time)
max_et <- max(data_treated$event_time)

cat(paste("\nRango de event_time:", min_et, "a", max_et, "\n"))
lower_bound <- -5
upper_bound <- 5
cat(paste("Límite inferior elegido:", lower_bound, "\n"))
cat(paste("Límite superior elegido:", upper_bound, "\n"))

# 5
data_treated <- data_treated %>%
  mutate(event_time_binned = case_when(
    event_time < lower_bound ~ lower_bound,
    event_time > upper_bound ~ upper_bound,
    TRUE ~ event_time
  ))

cat("\n=== DISTRIBUCIÓN DE EVENT_TIME_BINNED ===\n")
print(table(data_treated$event_time_binned))
event_times <- sort(unique(data_treated$event_time_binned))
for(et in event_times) {
  if(et != -1) {  
    var_name <- paste0("event_time_", ifelse(et < 0, "m", "p"), abs(et))
    data_treated[[var_name]] <- as.numeric(data_treated$event_time_binned == et)
  }
}

cat("\nDummies creadas para event_time (excepto -1 como referencia)\n")

# ============================================================================
# c) Event-Study Estimation
# ============================================================================

# 1
event_study_model <- feols(asmrs ~ i(event_time_binned, ref = -1) + 
                             pcinc + asmrh + cases | 
                             stfips + year, 
                           data = data_treated)

cat("\n=== RESULTADOS EVENT-STUDY ===\n")
summary(event_study_model)

coef_names <- names(coef(event_study_model))
event_coefs <- coef_names[grepl("event_time_binned", coef_names)]

results_df <- data.frame(
  event_time = as.numeric(gsub("event_time_binned::", "", event_coefs)),
  coefficient = coef(event_study_model)[event_coefs],
  se = se(event_study_model)[event_coefs]
)

results_df <- rbind(results_df, 
                    data.frame(event_time = -1, 
                               coefficient = 0, 
                               se = 0))
results_df <- results_df %>% arrange(event_time)
results_df <- results_df %>%
  mutate(
    ci_lower = coefficient - 1.96 * se,
    ci_upper = coefficient + 1.96 * se
  )

print("Coeficientes del Event-Study:")
print(results_df)

cat("\n=== INTERPRETACIÓN ===")
cat("\n- Coeficientes pre-tratamiento (negativos): deben estar cerca de 0 (test de tendencias paralelas)")
cat("\n- Coeficientes post-tratamiento (positivos): muestran el efecto dinámico del tratamiento\n")

# 3
event_study_plot <- ggplot(results_df, aes(x = event_time, y = coefficient)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), 
                width = 0.2, 
                linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray50") +
  labs(
    title = "Event-Study: Efectos Dinámicos del Tratamiento",
    subtitle = "Coeficientes con intervalos de confianza al 95%",
    x = "Tiempo Relativo al Tratamiento (Event Time)",
    y = "Coeficiente Estimado",
    caption = "Nota: Período -1 es la referencia. Línea vertical indica el momento del tratamiento."
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.title = element_text(size = 11),
    panel.grid.minor = element_blank()
  )
print(event_study_plot)





############## CS DID ############

library(did)
if (!require("knitr")) install.packages("knitr")
library(knitr)


# a)
data_csdid <- data %>%
  mutate(
    group = ifelse(ever_treated == 1, X_nfd, 0),
    year = as.integer(year),
    id = as.integer(stfips)
  )

cat("=== DISTRIBUCIÓN DE GRUPOS DE TRATAMIENTO ===\n")
print(table(data_csdid$group))
csdid_results <- att_gt(
  yname = "asmrs",             
  tname = "year",              
  idname = "id",               
  gname = "group",             
  xformla = ~ pcinc + asmrh + cases,  
  data = data_csdid,
  control_group = "notyettreated",  
  est_method = "dr",            
  clustervars = "id",           
  bstrap = TRUE,                
  cband = TRUE,                 
  biters = 1000                 
)

cat("\n=== RESUMEN CSDiD ===\n")
summary(csdid_results)
att_gt_table <- data.frame(
  Grupo = csdid_results$group,
  Periodo = csdid_results$t,
  ATT = csdid_results$att,
  SE = csdid_results$se,
  CI_lower = csdid_results$att - 1.96 * csdid_results$se,
  CI_upper = csdid_results$att + 1.96 * csdid_results$se
) %>%
  mutate(
    Significativo = ifelse(CI_lower * CI_upper > 0, "Sí", "No")
  )

cat("\n=== TABLA ATT(g,t) ===\n")
if(requireNamespace("knitr", quietly = TRUE)) {
  print(knitr::kable(head(att_gt_table, 20), 
                     digits = 3,
                     caption = "ATT(g,t): Efectos por Grupo y Período (primeras 20 filas)"))
} else {
  print(head(att_gt_table, 20))
}




#b)

# 1. Agregación por GRUPO
agg_group <- aggte(csdid_results, type = "group", na.rm = TRUE)
summary(agg_group)
ggdid(agg_group)

# 2. Agregación por PERÍODO (calendario)
agg_time <- aggte(csdid_results, type = "calendar", na.rm = TRUE)
summary(agg_time)
ggdid(agg_time)

# 3. Agregación por EVENT-TIME (dinámica)
agg_event <- aggte(csdid_results, type = "dynamic", na.rm = TRUE)
summary(agg_event)
ggdid(agg_event)


#c) En JUPYTER

#d) 











