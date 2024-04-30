#' Map a Variable at the Local Authority Level
#'
#' This function takes a dataset and a specified variable from that dataset to create a
#' geographic map displaying the values of that variable across UK Local Authorities.
#' The boundaries are defined at the Lower Tier Local Authority (LTLA) level.
#'
#' @param df DataFrame containing the data to be plotted, which must include a region identifier that matches that of the 'boundaries_ltla21' dataset of the geographr package (ltla21_code or ltla21_name).
#' @param fill_variable The name of the variable to be used for the fill aesthetic in the map. This must be provided as a string. For example, 'population_density'.
#'
#' @return A ggplot object representing the map with the specified variable highlighted.
#' @export
#' 
#' @import dplyr
#' @import stringr
#' @import ggplot2
#' @import geographr
#' @importFrom sf st_make_valid
#' @importFrom sf st_transform
#'

map_variable_ltla <- function(df, fill_variable){
  # Load LTLA boundaries
  ltla_boundaries <- geographr::boundaries_ltla21 |> 
    filter(!str_starts(ltla21_code, "N"))
  
  # Prepare the dataset by joining and transforming it
  map_df <- ltla_boundaries |> 
    left_join(df) |>
    sf::st_make_valid() |> 
    sf::st_transform(crs = "EPSG:27700")
  
  # Generate a dynamic title based on the fill variable
  map_title <- paste("Map of '", tolower(sub("_", " ", fill_variable)), "' across UK Local Authorities")
  
  # Create the map with ggplot
  map_ltla <- ggplot(data = map_df, aes(geometry = geometry)) +
    geom_sf(aes(fill = .data[[fill_variable]])) +
    theme_void() +
    theme(text = element_text(color = "#22211d"), 
          plot.margin = margin(0, 1, 0, 1, "cm"),
          plot.background = element_rect(fill = "white", color = NA),
          panel.background = element_rect(fill = "white", color = NA), 
          legend.background = element_rect(fill = "white", color = NA),
          plot.title = element_text(size = 16, hjust = 0.01, color = "#4e4d47",
                                    margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
          plot.subtitle = element_text(size = 14, hjust = 0.01, color = "#4e4d47",
                                       margin = margin(b = 0.5, t = 0.43, l = 2, unit = "cm")),
          plot.caption = element_text(size = 9, color = "#4e4d47", 
                                      margin = margin(b = 0.3, r = -99, unit = "cm"),
                                      hjust = 1),
          legend.title = element_text(color = "#4e4d47", size = 10),
          legend.key.height = unit(1.1, 'cm'),
          legend.key.width = unit(0.3, 'cm')) +
    scale_fill_viridis_c(option = "plasma", direction = -1, na.value = "#ECECEC") +
    labs(
      title = map_title,
      fill = fill_variable,
      caption = "https://github.com/MatteoLarrode/ChildrenLowIncomeHouseholdsUK")
  
  # Return the map object
  return(map_ltla)
}
