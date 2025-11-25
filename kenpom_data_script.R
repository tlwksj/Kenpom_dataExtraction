# Kenpom update script

library(dplyr)
library(httr)
library(stringr)
library(tidyr)


url <- "https://kenpom.com/cbbga26.txt"
response <- GET(url)
text <- content(response, "text")

text <- text |> str_split("\n") |> unlist()|> str_squish()

pattern <- "^([0-9]{2}/[0-9]{2}/[0-9]{4})\\s+([A-Za-z0-9.&' ]+?)\\s+(\\d+)\\s+([A-Za-z0-9.&' ]+?)\\s+(\\d+)(?:\\s+([Nn1]))?\\s*(.*)$"

components <- str_match(text, pattern)

data <- data.frame(
  Date = as.Date(components[,2],"%m/%d/%Y"),
  teamA = components[,3],
  Away = as.integer(components[,4]),
  teamH = components[,5],
  Home = as.integer(components[,6])
)


## Data to post to csv

csv_file <- paste0("data/kenpom_basketball_data.csv")
total_away <- data |> group_by(Date) |> summarize(total_away = sum(Away, na.rm= TRUE))
total_home <- data |> group_by(Date) |> summarize(total_home = sum(Home, na.rm= TRUE))

total_points_average <- data |> group_by(Date) |> summarize(avrpoints = mean(Away+Home, na.rm = TRUE))

output <- data.frame(
  Date = unique(data$Date),
  total_away = total_away$total_away,
  total_home =  total_home$total_home,
  total_points_average = total_points_average$avrpoints
)
if (!dir.exists("data")) {
  dir.create("data")
}
write.csv(output, csv_file, row.names = FALSE)




