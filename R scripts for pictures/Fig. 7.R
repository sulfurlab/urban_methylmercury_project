##Fig.7a
library(ggplot2)
library(dplyr)

# Read the data
dat <- read.csv("data.txt", sep="\t")

# To factorize the river, ensure the X-axis is arranged in the given order.
expanded_data$River <- factor(expanded_data$River, levels = c("Southeastern Uganda & Kisumu(Uganda&Kenya)", "Abidjian(Côte d’Ivoire)", "Orura(Bolivia)", "Kerala(India)", 
                                                              "Tianjin(China)", "Panjin(China)", "Dongguan(China)", "Lijin(China)", "Zhaoqing(China)", 
                                                              "Zhangzhou(China)", "Foshan(China)", "Dandong(China)", "Chaozhou(China)", 
                                                              "Masan(South Koera)", "San Francisco(USA)", "Washington(USA)", 
                                                              "Connecticut(USA)", "New York & New Jersey(USA)", "Philadelphia(USA)", "*Spain", 
                                                              "*France", "*Sweden", "*Austria", "*Great Britain", "*Germany", 
                                                              "Bayonne(France)", "Lausanne(Switzerland)"))
# Custom colors
continent_colors <- c("Asia" = "#DE9B15", "Africa" = "#C30D23", "North America" = "#12679D", 
                      "South America" = "#EA5514", "Europe" = "#159870")														
p1 <- ggplot(expanded_data, aes(x = River, y = MeHg, color = Continents)) +
    geom_boxplot(fill = "white") +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
    labs(x = "River", y = "MeHg concentration (ng/L)", color = "Continents") +
    scale_color_manual(values = continent_colors)+theme_bw()

p2 <- ggplot(data, aes(x = River, y = Treatment)) +
    geom_bar(stat = "identity", fill = "red") +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
    labs(x = "River", y = "National sewage treatment ratio (%)")+theme_bw()

#Manually merge p1 and p2 using Adobe Illustrator.

##Fig.7b
library(ggplot2)
dat <- read.csv("data.txt", sep="\t")
# Specify custom colors
bar_color <- "#4BA988"
point_color <- "#004383"
errorbar_color <- "#231815"  # Blue for error bars
line_color <- "#004383"
# Plotting
p <- ggplot(data, aes(x=factor(year))) + 
    geom_col(aes(y=sewage_ratio), fill=bar_color, width=0.6, color="black") + 
    geom_errorbar(aes(ymin=mercury * (100 / 0.16) - std_dev * (100 / 0.16), ymax=mercury * (100 / 0.16) + std_dev * (100 / 0.16)), width=0.2, color=errorbar_color) +
    geom_point(aes(y=mercury * (100 / 0.16)), color=point_color, size=3.5) +
    geom_smooth(aes(x=as.numeric(factor(year)), y=mercury * (100 / 0.16)), method="lm", se=FALSE, color=line_color, linetype=2) +  # Add linear regression line
    scale_y_continuous(
        name = "Sewage treatment ratio along the Yangtze River (%)",
        limits = c(0, 100),
        sec.axis = sec_axis(~ . * 0.16 / 100, name="Total mercury concentration in fish in the Yangtze River (mg/kg)", breaks=seq(0, 0.16, by=0.02))
    ) +
    labs(x="Year", y="Sewage treatment ratio along the Yangtze River (%)", title="Total Mercury Concentration in Fish and Sewage Treatment Ratio along the Yangtze River") +
    theme_test(base_size = 15) +
    theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(color = 'black', face = 'bold'),
        plot.margin = margin(1, 0.5, 0.5, 2.5, 'cm'),
        panel.border = element_rect(size = 1),
        axis.title = element_text(face = 'bold'),
        plot.title = element_text(face = 'bold', size=13, hjust = 0.5)
    ) +
    annotate("text", x=12, y=75, label=paste("R = -0.73\np = 2.52e-04"), size=5)  # Adjust x position to fit within the plot

print(p)