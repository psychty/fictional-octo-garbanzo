

packages <- c('easypackages', 'tidyverse', 'beepr')
install.packages(setdiff(packages, rownames(installed.packages())))
easypackages::libraries(packages)

n_data_points <- 40
pct_missing <- .05

# Create a dummy dataset
dummy_df <- data.frame(Value = sample(1:100, n_data_points, replace = TRUE)) 

# rows to delete
rows_to_delete <- sample(1: nrow(dummy_df), nrow(dummy_df) * pct_missing)

dummy_df <- dummy_df %>% 
  mutate(Value = ifelse(row_number() %in% rows_to_delete, NA, Value))  
  
for (i in 1:nrow(dummy_df)) {
  
  dummy_x <- dummy_df %>% 
    slice(i)
  
  print(log(dummy_x$Value))
  
}
  
# You get some NAs, and if this is a code that requires something that isn't there then it breaks entirely.

# Lets try to do something with an object that does not exist (but first make sure it truly does not exist)
if(exists('df_which_is_not_available') == TRUE){
  rm(df_which_is_not_available)}

made_up_df <- df_which_is_not_available

# You get an error 'Error: object 'df_which_is_not_available'

# But it is silent.

# What if you could hear a notification if/when the error occurs
# We can use beep_on_error() from beepr
beep_on_error(sound = 'wilhelm',
              expr = 
                
                made_up_df <- df_which_is_not_available
              
)

# Lets see if we can get it a bit more complicated. We'll make sure it is successful first

if(exists('df_which_is_not_available') == FALSE){
  df_which_is_not_available = df
  }

beep_on_error(sound = 'wilhelm',
              expr = 
                
made_up_df <- df_which_is_not_available

)

# No error

# What if it is successful to start with but later fails
beep_on_error(sound = 'wilhelm',
              expr = { # You can wrap the whole code with this
                
                if(exists('df_which_is_not_available') == FALSE){
                  df_which_is_not_available = df
                }
                
                made_up_df <- df_which_is_not_available
                
                if(exists('df_which_is_not_available') == TRUE){
                  rm(df_which_is_not_available)}

                made_up_df <- df_which_is_not_available
                
            
}) # and this
