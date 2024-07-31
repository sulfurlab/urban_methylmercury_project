library(ggplot2)
library(sf)
library(rworldmap)
library(dplyr)

# Load data from file
data <- read.table("data.txt", header = TRUE, sep = "\t")

# Convert data to a spatial object
data_sf <- st_as_sf(data, coords = c("longtitude_inferred", "latitude_inferred"), crs = 4326)

# Load world map
world <- getMap(resolution = "low")
world_sf <- st_as_sf(world)

# Define color palette
color_palette <- c("Sewage" = "#DA8F99", 
                   "19 urban rivers and a whole river basin" = "#009E73", 
                   "Pristine aquatic environments" = "#0A6CA6")

# Define size mapping
data_sf <- data_sf %>%
  mutate(size = case_when(
    Type == "Sewage" ~ 3,
    Type == "19 urban rivers and a whole river basin" ~ 6,
    Type == "Pristine aquatic environments" ~ 6
  ))

# Plot the map
ggplot() +
  geom_sf(data = world_sf, fill = "#DBD7C6", color = "grey") +
  geom_sf(data = data_sf, aes(color = Type, size = size)) +
  scale_color_manual(values = color_palette) +
  scale_size_identity() +
  theme_minimal() +
  labs(title = "Global Distribution of Sewage, Urban Rivers, and Pristine Aquatic Environments",
       x = "Longitude", y = "Latitude")
	   