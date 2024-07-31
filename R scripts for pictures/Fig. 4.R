###Fig.4a
# Load the necessary library
library(ggplot2)

# Read the data file
dat<-read.table(file="data.txt", sep="\t", header=T)

# Plot the data
ggplot(dat, aes(x=Environment, y=Count, fill=Detection)) + 
  geom_bar(stat="identity", position="stack") +
  theme_bw() + 
  labs(y = "Number of metagenomes") +
  scale_fill_manual(values = c("Detected" = "#48A7C0", "Not detected" = "#22937D")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
###Fig.4b
# Load the necessary library
library(ggplot2)

# Read the data file
dat<-read.table(file="data.txt", sep="\t", header=T)

# Plot the data
ggplot(dat, aes(x = Environment, y = Normalized_crAssphage_abundance)) +
  geom_jitter(color = "#9A8647", alpha = 0.5, width = 0.3) +
  scale_y_log10(limits = c(1e2, 1e-4), oob = scales::squish_infinite) +
  theme_bw() +
  labs(y = "Normalized crAssphage abundance")
  
###Fig.4c
# Load necessary libraries
library(pheatmap)

# Read the data (adjust the path to your actual data file)
data <- read.csv("data.csv", row.names = 1)

# Generate the heatmap with column clustering
pheatmap(data, 
         cluster_cols = TRUE, 
         cluster_rows = FALSE, 
         fontsize = 12, 
         angle_col = 45, 
         color = colorRampPalette(c("white", "pink"))(50))
		 
###Fig.4d
# Load necessary libraries
library(ggplot2)
library(dplyr)

# Read the data (adjust the path to your actual data file)
data <- read.csv("data.csv", row.names = 1)
# Calculate total number of hgcA sequences
dat <- dat %>%
  mutate(Total_hgcA = Shared_hgcA + Unique_hgcA)

# Sort the data by Total_hgcA in descending order
dat <- dat %>%
  arrange(desc(Total_hgcA))

# Convert River column to a factor with levels in the order of Total_hgcA
dat$River <- factor(dat$River, levels = dat$River)

# Melt the data for ggplot
dat_melt <- reshape2::melt(dat, id.vars = c("River", "Total_hgcA"), 
                           measure.vars = c("Shared_hgcA", "Unique_hgcA"), 
                           variable.name = "Type", value.name = "Count")

# Plot the data
ggplot(dat_melt, aes(x=River, y=Count, fill=Type)) + 
  geom_bar(stat="identity") +
  theme_bw() + 
  labs(y = "Number of hgcA sequences") +
  scale_fill_manual(values = c("Shared_hgcA" = "#C05949", "Unique_hgcA" = "#78A9BD")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

###Fig.4e
# Load the necessary library
library(ggplot2)

# Read the data (adjust the path to your actual data file)
data <- read.csv("data.csv", row.names = 1)

# Plot the data
ggplot(dat, aes(x=Category, y=Abundance, fill=Category)) +
  geom_bar(stat="identity", position=position_dodge(), width=0.7) +
  geom_errorbar(aes(ymin=Abundance - Error, ymax=Abundance + Error), 
                width=0.2, position=position_dodge(0.7)) +
  theme_bw() +
  labs(y = "Abundance percentage (%)") +
  scale_fill_manual(values = c("Shared hgcA" = "brown", "Unique hgcA" = "mediumseagreen")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

###Fig.4f
# Load necessary libraries
library(ggplot2)
library(ggbeeswarm)

# Read the data (adjust the path to your actual data file)
data <- read.csv("data.csv", row.names = 1)

# Plot the data
ggplot(dat, aes(x = Category, y = Normalized_hgcA_abundance)) +
  geom_quasirandom(aes(color = Category), alpha = 0.5) +
  stat_summary(fun = median, geom = "crossbar", width = 0.5, color = "black", size = 1) +
  scale_y_log10(oob = scales::squish_infinite) +
  theme_bw() +
  labs(y = "Normalized hgcA abundance") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_color_manual(values = c("Urban rivers" = "#1B926C", "STPs effluent" = "#57A2CF", "Sewage" = "#B85747"))

###Fig.4g
# Install and load necessary packages
if (!requireNamespace("pheatmap", quietly = TRUE)) {
  install.packages("pheatmap")
}
if (!requireNamespace("RColorBrewer", quietly = TRUE)) {
  install.packages("RColorBrewer")
}

library(pheatmap)
library(RColorBrewer)

# Read the data (adjust the path to your actual data file)
data <- read.csv("data.csv", row.names = 1)

# Log10 transformation
data_log10 <- log10(data + 0.001)  # Add 1 to avoid log10(0)

# CRead the data (adjust the path to your actual data file)
annotation_col <- read.csv("anno.csv", row.names = 1)

# Define color scheme
heatmap_colors <- colorRampPalette(c("#313695", "#4575b4", "#74add1", "#abd9e9", "#fee090", "#f46d43", "#a50026"))(100)

# Draw heatmap
pheatmap(data_log10,
         color = heatmap_colors,
         cluster_rows = TRUE,     # Cluster rows
         cluster_cols = TRUE,     # Cluster columns
         annotation_col = annotation_col,
         show_rownames = TRUE,    # Show row names
         show_colnames = TRUE,    # Show column names
         fontsize = 10,           # Set font size
         border_color = NA)       # Remove border color
