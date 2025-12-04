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

# Importar datos desde URL
data <- read.csv("C:/Users/VICTOR/Documents/GitHub/CSDiD/R/Input/bacon_example.csv")
head(data)

# Explorar la estructura de los datos
head(data)
str(data)

# Estimar regresión TWFE con efectos fijos de unidad y tiempo
# Modelo: asmrs ~ post + controls + unit FE + time FE
# 'post' es la variable de tratamiento (1 después del tratamiento, 0 antes)
twfe_model <- feols(asmrs ~ post + pcinc + asmrh + cases | 
                      stfips + year, 
                    data = data)

# Mostrar resultados
cat("\n=== RESULTADOS TWFE ===\n")
summary(twfe_model)

# ============================================================================
# b) Cleaning for Event-Study
# ============================================================================

# 1. Crear variable de tiempo relativo (event time)
# X_nfd contiene el año de tratamiento para cada unidad
# Para unidades nunca tratadas, X_nfd podría ser un valor especial
data <- data %>%
  mutate(
    # Calcular event_time como diferencia entre año actual y año de tratamiento
    event_time = year - X_nfd,
    # Identificar unidades tratadas (aquellas donde post eventualmente es 1)
    ever_treated = ifelse(any(post == 1), 1, 0)
  ) %>%
  group_by(stfips) %>%
  mutate(ever_treated = max(post)) %>%  # 1 si alguna vez fue tratada, 0 si nunca
  ungroup()

# Para análisis Event-Study, solo usamos unidades tratadas
data_treated <- data %>% filter(ever_treated == 1)

# 2. Tabla de frecuencias del event time
freq_table <- data_treated %>%
  count(event_time) %>%
  arrange(event_time)

cat("\n=== TABLA DE FRECUENCIAS DE EVENT_TIME ===\n")
print(freq_table)

# Resumen descriptivo
cat("\n=== RESUMEN DESCRIPTIVO ===\n")
print(summary(data_treated$event_time))

# 3. Elegir límites razonables basados en la distribución
# Analizar la distribución
dist_plot <- ggplot(data_treated, aes(x = event_time)) +
  geom_bar(fill = "steelblue", alpha = 0.7) +
  labs(title = "Distribución de Event Time",
       subtitle = "Solo unidades tratadas",
       x = "Event Time (años relativos al tratamiento)",
       y = "Frecuencia") +
  theme_minimal() +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1)

print(dist_plot)

# Determinar el rango de event_time
min_et <- min(data_treated$event_time)
max_et <- max(data_treated$event_time)

cat(paste("\nRango de event_time:", min_et, "a", max_et, "\n"))

# Basado en la distribución, elegir bounds
# Ajustar según lo que veas en la distribución
lower_bound <- -5
upper_bound <- 5

cat(paste("Límite inferior elegido:", lower_bound, "\n"))
cat(paste("Límite superior elegido:", upper_bound, "\n"))

# 4. Respuesta: ¿Por qué agrupamos event times distantes?
cat("\n=== Respuesta a la pregunta ===\n")
cat("Agrupamos event times muy distantes por varias razones:\n")
cat("1. Pocas observaciones: Los períodos muy lejanos al tratamiento tienen pocas unidades,\n")
cat("   lo que genera estimaciones imprecisas y ruidosas.\n")
cat("2. Supuesto de tendencias paralelas: Es menos creíble que las tendencias se mantengan\n")
cat("   paralelas en períodos muy distantes del evento.\n")
cat("3. Eficiencia estadística: Agrupar mejora la precisión de las estimaciones.\n")
cat("4. Interpretación: Los efectos muy lejanos son menos relevantes para la política evaluada.\n\n")

# 5. Crear variables dummy de tiempo relativo
# Agrupar los extremos
data_treated <- data_treated %>%
  mutate(event_time_binned = case_when(
    event_time < lower_bound ~ lower_bound,
    event_time > upper_bound ~ upper_bound,
    TRUE ~ event_time
  ))

# Verificar la agrupación
cat("\n=== DISTRIBUCIÓN DE EVENT_TIME_BINNED ===\n")
print(table(data_treated$event_time_binned))

# Crear dummies para cada período (excepto -1, que es la referencia)
event_times <- sort(unique(data_treated$event_time_binned))

# Crear dummies manualmente (aunque fixest lo hará automáticamente)
for(et in event_times) {
  if(et != -1) {  # -1 es el período de referencia
    var_name <- paste0("event_time_", ifelse(et < 0, "m", "p"), abs(et))
    data_treated[[var_name]] <- as.numeric(data_treated$event_time_binned == et)
  }
}

cat("\nDummies creadas para event_time (excepto -1 como referencia)\n")

# ============================================================================
# c) Event-Study Estimation
# ============================================================================

# 1. Estimar modelo Event-Study
# Usar i() de fixest para crear automáticamente las dummies y excluir -1 como referencia
event_study_model <- feols(asmrs ~ i(event_time_binned, ref = -1) + 
                             pcinc + asmrh + cases | 
                             stfips + year, 
                           data = data_treated)

# Mostrar resultados
cat("\n=== RESULTADOS EVENT-STUDY ===\n")
summary(event_study_model)

# 2. Almacenar coeficientes y errores estándar
# Extraer coeficientes relacionados con event_time
coef_names <- names(coef(event_study_model))
event_coefs <- coef_names[grepl("event_time_binned", coef_names)]

# Crear dataframe con resultados
results_df <- data.frame(
  event_time = as.numeric(gsub("event_time_binned::", "", event_coefs)),
  coefficient = coef(event_study_model)[event_coefs],
  se = se(event_study_model)[event_coefs]
)

# Añadir el período de referencia (-1) con coeficiente 0
results_df <- rbind(results_df, 
                    data.frame(event_time = -1, 
                               coefficient = 0, 
                               se = 0))
results_df <- results_df %>% arrange(event_time)

# Calcular intervalos de confianza (95%)
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

# 3. Graficar los coeficientes del event-study
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

# Mostrar gráfico
print(event_study_plot)

# Guardar gráfico (opcional)
# ggsave("event_study_plot.png", event_study_plot, width = 10, height = 6, dpi = 300)

# ============================================================================
# Resumen de resultados
# ============================================================================

cat("\n=== RESUMEN DE ANÁLISIS ===\n")
cat("1. Modelo TWFE estimado exitosamente\n")
cat("2. Event time creado y agrupado en bounds:", lower_bound, "a", upper_bound, "\n")
cat("3. Modelo Event-Study estimado con", nrow(results_df)-1, "coeficientes\n")
cat("4. Gráfico generado con intervalos de confianza\n")




library(did)
if (!require("knitr")) install.packages("knitr")
library(knitr)

# a)
data_csdid <- data %>%
  mutate(
    # Grupo = año en que fueron tratados (X_nfd)
    # Para nunca tratados, asignar 0
    group = ifelse(ever_treated == 1, X_nfd, 0),
    # Asegurar que year y stfips son del tipo correcto
    year = as.integer(year),
    id = as.integer(stfips)
  )

# Verificar la distribución de grupos
cat("=== DISTRIBUCIÓN DE GRUPOS DE TRATAMIENTO ===\n")
print(table(data_csdid$group))

# Estimar ATT(g,t) usando CSDiD
# att_gt calcula el efecto del tratamiento para cada grupo en cada período
# Nota: Usamos "notyettreated" porque no hay suficientes unidades nunca tratadas
csdid_results <- att_gt(
  yname = "asmrs",              # Variable de resultado
  tname = "year",               # Variable de tiempo
  idname = "id",                # Identificador de unidad
  gname = "group",              # Variable de grupo (año de tratamiento)
  xformla = ~ pcinc + asmrh + cases,  # Controles
  data = data_csdid,
  control_group = "notyettreated",  # Grupo de control: aún no tratados
  est_method = "dr",            # "doubly robust" - más robusto
  clustervars = "id",           # Errores estándar agrupados por unidad
  bstrap = TRUE,                # Bootstrap para inferencia
  cband = TRUE,                 # Bandas de confianza simultáneas
  biters = 1000                 # Iteraciones de bootstrap
)

cat("Nota: Usando 'notyettreated' como grupo de control.\n")
cat("Esto significa que las unidades que serán tratadas más tarde sirven de control.\n")

# Mostrar resumen de resultados
cat("\n=== RESUMEN CSDiD ===\n")
summary(csdid_results)

# Crear tabla limpia de ATT(g,t)
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
# Usar kable si está disponible, sino print simple
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
cat("--- 1. AGREGACIÓN POR GRUPO ---\n")
summary(agg_group)
ggdid(agg_group)

# 2. Agregación por PERÍODO (calendario)
agg_time <- aggte(csdid_results, type = "calendar", na.rm = TRUE)
cat("\n--- 2. AGREGACIÓN POR PERÍODO ---\n")
summary(agg_time)
ggdid(agg_time)

# 3. Agregación por EVENT-TIME (dinámica)
agg_event <- aggte(csdid_results, type = "dynamic", na.rm = TRUE)
cat("\n--- 3. AGREGACIÓN POR EVENT-TIME ---\n")
summary(agg_event)
ggdid(agg_event)





#c)



