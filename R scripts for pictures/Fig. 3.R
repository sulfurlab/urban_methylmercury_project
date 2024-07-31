###Fig.3b
# Load the necessary library
library(ggplot2)

# Read the data file
dat <- read.csv("data.txt", sep="\t")

# Ensure column names are correct
colnames(dat) <- c("Sites", "hgcA", "hgcB", "hgcA_Richness", "hgcB_Richness")

# Ensure sites are ordered as specified
dat$Sites <- factor(dat$Sites, levels = c("N1", "N2", "N3", "S1", "S2", "S3", "S4", "SB", "H1", "H2", "H3", "H4", "H5", "H6", "H7"))

# Plot the data
ggplot(dat) + 
  geom_point(aes(x=Sites, y=hgcA, size=hgcA_Richness, color="hgcA"), alpha=0.6) + 
  geom_point(aes(x=Sites, y=hgcB, size=hgcB_Richness, color="hgcB"), alpha=0.6) + 
  theme_bw() + 
  labs(y = "Normalized hgcA abundance") +
  scale_y_log10(oob = scales::squish_infinite) + 
  scale_size(range = c(0, 10)) + 
  scale_color_manual(name = "Type", values = c("hgcA" = "purple", "hgcB" = "orange"))
  

###Fig.3c
# Load the necessary library
library(ggplot2)

# Read the data
dat <- read.csv("data.txt", sep="\t")

# Ensure column names are correct
colnames(dat) <- c("Sites", "Normalized_crAssphage_abundance", "Normalized_hgcA_abundance", "Sampling_time")

# Plot the data
ggplot(dat, aes(x=Normalized_crAssphage_abundance, y=Normalized_hgcA_abundance, color=Sampling_time)) +
  geom_point(aes(size=1)) + 
  geom_text(aes(label=Sites), vjust=1.5, hjust=1.5) +
  theme_bw() + 
  labs(x = "Normalized crAssphage abundance", y = "Normalized hgcA abundance") +
  scale_x_log10(oob = scales::squish_infinite) +
  scale_y_log10(oob = scales::squish_infinite) +
  scale_color_manual(values = c("2016/5/1" = "#EF7E49", "2016/8/1" = "#159870", "2017/2/1" = "#0E6CA7")) + 
  geom_smooth(method="lm", se=TRUE, color="blue", fill="lightgray") +
  theme(legend.position = "right") +
  annotate("text", x = Inf, y = Inf, label = "R = 0.63\np = 3.7e-06", hjust = 1.1, vjust = 1.1, size=4)


