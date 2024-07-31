###Fig.2a
# Load necessary libraries
library(ggplot2)
library(dplyr)

# Load data from file
data <- read.table("data.txt", header = TRUE, sep = "\t")

# Convert data into a format suitable for ggplot
data <- data %>%
  rename(crAssphage_abundance = `Normalized.crAssphage.abundance`, 
         hgcA_abundance = `Normalized.hgcA.abundance`,
         Study = Local)

# Plot the data
ggplot(data, aes(x = crAssphage_abundance, y = hgcA_abundance)) +
  geom_point(size = 3, color = rgb(0, 158, 115, 200, maxColorValue = 255)) +
  geom_smooth(method = "lm", color = "blue") +
  theme_bw() +
  labs(y = "Normalized hgcA abundance", x = "Normalized crAssphage abundance") +
  facet_wrap(~ Study, scales = "free", ncol = 5) +
  scale_x_log10(oob = scales::squish_infinite) +
  scale_y_log10(oob = scales::squish_infinite)

###Fig.2b
# Load data from file
dat <- read.table("dat.txt", header = TRUE, sep = "\t")
dat <- dat %>%
    group_by(Local) %>%
    mutate(MaxGhgcA = max(hgcA_abundance, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(Local = factor(Local, levels = unique(Local[order(MaxGhgcA)])))

# Create the plot with Local sorted by the maximum 'GhgcA' value from smallest to largest
p <- ggplot(dat, aes(x = hgcA_abundance, y = Local, fill = stat(log10(x)))) +
    geom_density_ridges_gradient(scale = 3, size = 0.3, rel_min_height = 0.01) +
    scale_fill_viridis_c(name = "Temp. [F]", option = "C") +
    labs(title = 'Temperatures in Lincoln NE') +
    scale_x_log10(oob = scales::squish_infinite)+theme_bw()


