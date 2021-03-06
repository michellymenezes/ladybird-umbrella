library(plotly)
library(dplyr)
library(rlang)

data <- data.frame(a = c(runif(1000), rep(NA, 10)),
                   b = rnorm(1010),
                   c = rpois(1010, 3),
                   d = rnorm(1010),
                   e = runif(1010),
                   f = factor(sample(1010)),
                   g = as.character(sample(5, size = 1010, replace = T)))



xx <- summarise_column(df = data,
                       col = "a",
                       observed = "b",
                       predictions1 = "e", 
                       predictions2 = "d", 
                       weightss = "c")



plot_bar_line_graph(df = xx$summary,
                    col = "binned_ordered",
                    weights = "c")

plot_bar_line_graph(df = xx$summary,
                    col = "binned_ordered",
                    weights = "c",
                    observed = "b")

plot_bar_line_graph(df = xx$summary,
                    col = "binned_ordered",
                    weights = "c",
                    predictions1 = "d",
                    observed = "b")

plot_bar_line_graph(df = xx$summary,
                    col = "binned_ordered",
                    weights = "c",
                    predictions1 = "d",
                    predictions2 = "e",
                    observed = "b")


plot_bar_line_graph <- function(df,
                                col,
                                observed = NULL,
                                predictions1 = NULL,
                                predictions2 = NULL,
                                weights,
                                rounding_digits = 5) {
  
  line_cols <- c(observed, predictions1, predictions2)
  
  # determine the range of the left axis (observed, predictions1, predictions2)
  if (!is.null(line_cols)) {

    left_axis_min <- min(df[ , line_cols], na.rm = T)
    
    left_axis_max <- max(df[ , line_cols], na.rm = T)
    
    line_cols_type <- character()
    line_cols_type_short <- character()
    line_colours <- character()
    
    if (!is.null(observed)) {
      
      line_cols_type <- c(line_cols_type, "observed")
      line_cols_type_short <- c(line_cols_type_short, "obs")
      line_colours <- c(line_colours, "pink")
      
    }
    
    if (!is.null(predictions1)) {
      
      line_cols_type <- c(line_cols_type, "predictions1")
      line_cols_type_short <- c(line_cols_type_short, "pred1")
      line_colours <- c(line_colours, "darkgreen")
      
    }
    
    if (!is.null(predictions2)) {
      
      line_cols_type <- c(line_cols_type, "predictions2")
      line_cols_type_short <- c(line_cols_type_short, "pred2")
      line_colours <- c(line_colours, "lightgreen")
      
    }
    
  }

  # need to find a better way to set the width so it looks good in the nb.html
  p <- plotly::plot_ly(width = 900) %>%
    
    # barplot for the weights
    plotly::add_trace(x = df[[col]], 
                      y = df[[weights]], 
                      type = 'bar', 
                      name = 'weights',
                      marker = list(color = 'yellow'),
                      hoverinfo = "text",
                      text = paste0(round(df[[weights]], rounding_digits), 
                                    ' (sum weights)'))  
  
    if (!is.null(line_cols)) {
      
      # loop and add a new line for each 
      for (i in 1:length(line_cols)) {
        
        p <- p %>% plotly::add_trace(x = df[[col]], 
                                     y = df[[line_cols[i]]], 
                                     type = 'scatter', 
                                     mode = 'lines', 
                                     name = line_cols_type[i], 
                                     yaxis = 'y2',
                                     line = list(color = line_colours[i]),
                                     hoverinfo = "text",
                                     text = paste0(round(df[[line_cols[i]]],
                                                         rounding_digits), 
                                                   ' (ave ',
                                                   line_cols_type_short[i],
                                                   ')'))
        
      }
      
      p <- p %>%  layout(#title = paste0("<br>", col),
                        title = col,
                        xaxis = list(title = ""),
                        yaxis = list(side = 'right', 
                                     title = 'total weights', 
                                     showgrid = F, 
                                     zeroline = F),
                        yaxis2 = list(side = 'left', 
                                      overlaying = "y", 
                                      title = 'response', 
                                      showgrid = F, 
                                      zeroline = F))
      
    } else {
      
      p <- p %>%  layout(title = col,
                         xaxis = list(title = ""),
                         yaxis = list(side = 'right', 
                                      title = 'total weights', 
                                      showgrid = F, 
                                      zeroline = F))
      
    }
  
  return(p)
  
}










