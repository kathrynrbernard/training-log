# using approach from: https://www.andrewaage.com/post/analyzing-strava-data-using-r/
# strava api documentation: https://developers.strava.com/docs/reference/

## analysis ideas
# get strava data
# get garmin data
# compare running times with:
# - garmin sleep/stress
# - strava perceived exertion (suffer score)
# - number of other athletes (running alone?)
# - prs or achievements
# - VO2 max
# try to get segment data from all of Strava - how popular are the segments that I run?


# packages
install.packages("httr") # for making web requests
install.packages("dplyr")
install.packages("rStrava") # for strava specific things; https://github.com/fawda123/rStrava


library(httr)
library(dplyr)
library(rStrava)

# garmin setup
# export data from the garmin connect website - doesn't seem to be a public API to pull the data unless you are a commercial dev?
# log into garmin connect
# choose reports from the left sidebar
# go to Health & Fitness category - exported Resting Heart Rate, Sleep Duration, Stress, and Calories for the past year on 06/26/2022
# maybe do something with intensity minutes later?

# strava setup
client_id <- 80261
secret <- "338bebfd602d2ed75992246efc0d0e6ac4e42dc1"
app_name <- "Training_Analysis"
stoken <- httr::config(token = strava_oauth(app_name, client_id, secret, app_scope="activity:read_all"))
#last step launches a browser window where you have to manually authenticate the app

# extract data
my_acts <- get_activity_list(stoken)
my_acts
df <- compile_activities(my_acts)
df
nrow(df) # 641 activities as of 7/18

head(df) 

# clean up a little

colnames(df) # need to drop some columns
# [1] "achievement_count"             "athlete_count"                 "athlete.id"                    "athlete.resource_state"        "average_speed"                 "comment_count"                 "commute"                      
# [8] "display_hide_heartrate_option" "distance"                      "elapsed_time"                  "flagged"                       "from_accepted_tag"             "has_heartrate"                 "has_kudoed"                   
# [15] "heartrate_opt_out"             "id"                            "kudos_count"                   "manual"                        "map.id"                        "map.resource_state"            "max_speed"                    
# [22] "moving_time"                   "name"                          "photo_count"                   "pr_count"                      "private"                       "resource_state"                "sport_type"                   
# [29] "start_date"                    "start_date_local"              "timezone"                      "total_elevation_gain"          "total_photo_count"             "trainer"                       "type"                         
# [36] "utc_offset"                    "visibility"                    "average_cadence"               "average_heartrate"             "average_temp"                  "average_watts"                 "device_watts"                 
# [43] "elev_high"                     "elev_low"                      "end_latlng1"                   "end_latlng2"                   "external_id"                   "gear_id"                       "kilojoules"                   
# [50] "map.summary_polyline"          "max_heartrate"                 "start_latlng1"                 "start_latlng2"                 "suffer_score"                  "upload_id"                     "upload_id_str"                
# [57] "workout_type"  

# https://developers.strava.com/docs/reference/#api-models-DetailedActivity

drop <- names(df) %in% c("athlete.id", "athlete.resource_state", "commute",
                         "display_hide_heartrate_option", "flagged", "from_accepted_tag", "has_heartrate", "has_kudoed",
                         "heartrate_opt_out", "manual", "map.id", "map.resource_state",
                         "photo_count", "private", "resource_state",
                         "start_date_local", "timezone", "total_photo_count", "trainer",
                         "utc_offset", "visibility", "average_watts", "device_watts",
                         "end_latlng1", "end_latlng2", "external_id", "gear_id", "kilojoules",
                         "map.summary_polyline", "start_latlng1", "start_latlng2", "upload_id", "upload_id_str"
                         )

test <- df[6,] 
test <- test[!drop]

# data quality checks - need to do a lot of unit conversions
# distance is in km and we want miles

# sport_type vs type?

# what is workout_type?

# temp is in C and we want F

# elapsed_time and moving_time are in seconds and we want hours

# speed is in km per hour and we want minutes per mile



# filtering data set
# can use sport_type=Run or type=Run
df <- df[!drop]
runs <- df %>% filter(sport_type=="Run")
nrow(runs) # 181 runs
