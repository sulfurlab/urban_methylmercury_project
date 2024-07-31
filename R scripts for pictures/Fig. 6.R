# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)

# Read the data
dat <- read.csv("data.txt", sep="\t")

# Convert the Type column to factor with levels in order
dat$Type <- factor(dat$Type, levels = c("INF", "EFF"))

# Reshape the data to a longer format for ggplot
dat_long <- dat %>%
  pivot_longer(cols = c("Normalized.crAssphage.abundance", "Normalized.hgcA.abundance"), 
               names_to = "AbundanceType", 
               values_to = "Abundance") %>%
  mutate(AbundanceType = recode(AbundanceType, 
                                "Normalized.crAssphage.abundance" = "Normalized crAssphage abundance",
                                "Normalized.hgcA.abundance" = "Normalized hgcA abundance"))

# Plot the data
ggplot(dat_long, aes(x = Type, y = Abundance, fill = Type)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.3) +
  geom_jitter(width = 0.2, size = 1) +
  scale_y_log10() +
  facet_grid(facets = AbundanceType ~ Local, scales = "free_y", switch = "y") +
  theme_bw() +
  labs(y = NULL, x = "Sample Type") +
  scale_fill_manual(values = c("INF" = "#E64B35", "EFF" = "#4DBBD5")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.text = element_text(size = 10),
        strip.background = element_blank(),
        strip.placement = "outside",
        legend.position = "none",
        panel.spacing = unit(1, "lines"),
        axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)))
