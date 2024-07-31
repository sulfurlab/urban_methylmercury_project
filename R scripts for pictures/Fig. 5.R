##Fig.5a
library(sf)
library(ggplot2)
china_shp <- "中国省级地图GS（2019）1719号.geojson"
nine <- "九段线GS（2019）1719号.geojson"
china <- sf::read_sf(china_shp)
nine_line <- sf::read_sf(nine)
nine_map <- ggplot() +
    geom_sf(data = china, fill = NA) + 
    geom_sf(data = nine_line, color = 'gray70', size = 1.0) +
    coord_sf(ylim = c(-4028017, -1877844), xlim = c(117131.4, 2115095), crs = "+proj=laea +lat_0=40 +lon_0=104") +
    theme(axis.text = element_blank(),
          axis.ticks = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank(),
          panel.background = element_blank(),
          panel.border = element_rect(fill = NA, color = "grey10", linetype = 1, size = 1),
          plot.margin = unit(c(0, 0, 0, 0), "mm"))
		  
scatter_df_tro <- read.table("data.txt", sep = "\t", header=T)
map <- ggplot() + 
    geom_sf(data = china, fill = NA) + 
    geom_sf(data = nine_line, color = 'gray50', size = 0.8) +
    geom_point(data = scatter_df_tro, aes(x = Lon, y = Lat, fill=Type,shape = Type), size = 4,alpha=0.8) +
    scale_shape_manual(values = c("Sewage" = 21, "River" = 24)) + 
    scale_fill_manual(values = c("Sewage" = "#EEC000", "River" = "#E64B35")) + 
    coord_sf(ylim = c(-2387082, 1654989), crs = "+proj=laea +lat_0=40 +lon_0=104") +
    annotation_scale(location = "bl") +
    annotation_north_arrow(location = "tl", which_north = "false", style = north_arrow_fancy_orienteering) +
    labs(caption = 'Visualization by DataCharm') +
    theme_bw()+ coord_sf(xlim = c(70, 135), ylim = c(15, 55), crs = "+proj=longlat +datum=WGS84")
gg_inset_map <- ggdraw() +
    draw_plot(map) +
    draw_plot(nine_map, x = 0.8, y = 0.15, width = 0.1, height = 0.3)
print(gg_inset_map)


##Fig.5b
library(ggplot2)
data <- read.table("data.txt", sep = "\t", header=T)
ggplot(data, aes(x = hgcA, y = km)) +
    geom_point(size = 5, color = "#009E73",alpha=0.8) +
    geom_errorbar(aes(ymin = km - km_sd, ymax = km + km_sd), width = 20000, color = "#009E73") +
    geom_errorbarh(aes(xmin = hgcA - hgcA_sd, xmax = hgcA + hgcA_sd), height = 0.6, color = "#009E73") +
    geom_smooth(method = "lm", color = "black") +
    scale_x_continuous(
        breaks = c(0, 2e5, 4e5, 6e5, 8e5, 1e6),
        labels = scales::scientific) +
    scale_y_continuous(
        breaks = c(0, 5, 10, 15, 20),
        limits = c(0, 20)
    ) +
    theme_bw() +
    labs(
        x = "hgcA gene copies/ng gDNA",
        y = "Me202Hg/(% of 202HgT)"
    )

##Fig.5c
library(ggplot2)
library(dplyr)
library(ggsci)
data <- read.table("data.txt", sep = "\t", header=T)
data$type <- factor(data$type, levels = c("RW", "DS/RW (10%)", "S/RW (5%)", "S/RW (10%)"))
ggplot(data, aes(x = type, y = km, fill = type)) +
    geom_bar(stat = "identity", position = position_dodge(), width = 0.7) +
    geom_errorbar(aes(ymin = km - sd, ymax = km + sd), width = 0.2, position = position_dodge(0.7)) +
    facet_wrap(~ river, nrow = 1) +
    labs(x = "Type", y = "Km", title = "Km values with error bars by type and river") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_npg(name = "Type")
