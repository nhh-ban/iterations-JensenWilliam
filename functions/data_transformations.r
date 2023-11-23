library(purrr)

# New function to convert to dataframe
transform_metadata_to_df = function(data) {
    data |>
      map(as_tibble) |>
      list_rbind() |>
      mutate(latestData = map_chr(latestData, 1, .default = "")) |>
      mutate(latestData = as_datetime(latestData, tz = "UTC")) |>
      mutate(location = map(location, unlist)) |>
      mutate(
        lat = map_dbl(location, "latLon.lat"),
        lon = map_dbl(location, "latLon.lon")
      ) %>%
      select(-location)
}


# Testing funciton  
test = transform_metadata_to_df(stations_metadata[[1]])
head(test)  

# Cheking wd
getwd()


# Task 4A - Time-function

library(lubridate)

to_iso8601 = function(datetime, offset_in_days) 
  {
  # Add the offset to the datetime variable
  adjusted_datetime = datetime + lubridate::days(offset_in_days)
  
  # Convert the adjusted datetime to ISO8601 format and append "Z" for UTC
  iso8601_str = format(adjusted_datetime, format = "%Y-%m-%dT%H:%M:%OSZ")
  
  return(iso8601_str)
}


# Transform volumes
transform_volumes <- function(json_data) {
  
  # Check if the json_data contains the necessary fields
  if (is.null(json_data$trafficData) || 
      is.null(json_data$trafficData$volume) || 
      is.null(json_data$trafficData$volume$byHour)) {
    stop("Invalid JSON data format.")
  }
  
  # Extract the nested 'edges' data
  volume_data <- json_data$trafficData$volume$byHour$edges
  
  # Extract relevant fields from the nested structure
  df <- data.frame(
    from = sapply(volume_data, function(x) x$node$from),
    to = sapply(volume_data, function(x) x$node$to),
    volume = sapply(volume_data, function(x) x$node$total$volumeNumbers$volume)
  )
  
  # Convert the 'from' and 'to' columns to date-time objects for easier plotting
  df$from <- as.POSIXct(df$from, format="%Y-%m-%dT%H:%M:%OSZ", tz="UTC")
  df$to <- as.POSIXct(df$to, format="%Y-%m-%dT%H:%M:%OSZ", tz="UTC")
  
  # Filtering out rows with missing 'from' values. 
  # Couldnt get the code to run without this
  df <- df %>% filter(!is.na(from))
  
  return(df)
}


#Test
to_iso8601(as_datetime("2016-09-01 10:11:12"),0)






