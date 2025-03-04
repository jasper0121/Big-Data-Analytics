#server.r
library(shiny)
library(plotly)
library(dplyr)
source("global.R")

shinyServer(function(input, output, session) {
  
  observe({
    threshold <- input$score_threshold_table
    filtered_features <- sorted_features_scores_tuples$Feature[sorted_features_scores_tuples$Score <= threshold]
    
    updateSelectizeInput(session, "selected_features",
                         choices = sorted_features_scores_tuples$Feature,  # 所有特徵作為選項
                         selected = filtered_features)  # 預設選擇篩選後的特徵
  })
  
  # 畫堆疊長條圖
  output$barPlot <- renderPlotly({
    # 將資料依照 xcol 和 PerStatus 分組，計算各組的數量 count，再將每組的 count 轉換成比例 prop
    plot_data <- data %>%
      group_by(xcol = get(input$xcol), PerStatus) %>%
      summarise(count = n()) %>%
      group_by(xcol) %>%
      mutate(prop = count / sum(count))
    # 將 PerStatus 轉換為 factor 並設定順序為 1, 0
    plot_data$PerStatus <- factor(plot_data$PerStatus, levels = c(1, 0))
    
    # 繪製堆疊式長條圖
    plot_ly(plot_data, x = ~xcol, y = ~prop, color = ~factor(PerStatus), type = 'bar')%>%
      layout(barmode = 'stack', 
             title = list(text = input$xcol, font = list(size = 24, color = 'black')),
             xaxis = list(title = input$xcol, tickmode = 'array', tickvals = unique(plot_data$xcol)),
             yaxis = list(title = "PerStatus", range = c(0, max(plot_data$prop))),
             legend = list(title = list(text = 'PerStatus')),
             margin = list(t = 100))
  })
  
  # 畫圓餅圖
  output$pieChart <- renderPlotly({
    # 繪製圓餅圖，標籤為資料中 xcol_pie 欄位的值
    plot_ly(data, labels = ~get(input$xcol_pie), type = 'pie') %>%
      layout(title = list(text = input$xcol_pie, font = list(size = 24, color = 'black')),
             margin = list(t = 100))
  })
  
  # 顯示選擇那些特徵
  output$barPlot_feature_filiter <- renderPlotly({
    # 篩選出Score小於使用者輸入的門檻值的特徵
    sorted_features_scores_tuples <- sorted_features_scores_tuples %>% filter(Score < input$score_threshold)
    
    # 設置特徵值的順序
    sorted_features_scores_tuples$Feature <- factor(sorted_features_scores_tuples$Feature, levels = sorted_features_scores_tuples$Feature)
    
    # 產生長條圖
    plot_ly(sorted_features_scores_tuples, x = ~Feature, y = ~Score, type = 'bar') %>%
      layout(title = "特徵篩選",
             xaxis = list(title = "特徵值"),
             yaxis = list(title = "Score"),
             margin = list(t = 100))
  })
  
  # 顯示資料表
  output$filteredDataTable <- DT::renderDT({
    # 根據使用者選擇的資料類型載入相應的資料集
    output_data <- switch(input$data_type,
                          "train.csv" = train_data,
                          "test.csv" = test_data)
    
    # 篩選特徵分數低於使用者指定閾值的特徵
    sorted_features_scores_tuples <- sorted_features_scores_tuples %>%
      filter(Score < input$score_threshold_table)
    
    # 將 Feature 欄位轉換為 factor 類型以便排序
    sorted_features_scores_tuples$Feature <- factor(sorted_features_scores_tuples$Feature, levels = sorted_features_scores_tuples$Feature)
    
    # 選擇需要顯示的欄位
    
    selected_features <- c("PerNo", "PerStatus", input$selected_features)
    filtered_data <- output_data %>%
      select(all_of(selected_features))
    
    # 返回篩選後的資料集
    filtered_data
  })
  
  
  output$downloadData <- downloadHandler(
    # 設定下載檔案的檔名
    filename = function() {
      paste("processed_", input$data_type, sep = "")
    },
    
    # 設定下載檔案的內容
    content = function(file) {
      # 根據使用者的輸入選擇適當的資料集
      output_data <- switch(input$data_type,
                            "train.csv" = train_data,
                            "test.csv" = test_data)
      
      # 根據分數閥值過濾特徵
      sorted_features_scores_tuples <- sorted_features_scores_tuples %>%
        filter(Score < input$score_threshold_table)
      
      
      selected_features <- c("PerNo", "PerStatus", input$selected_features)
      filtered_data <- output_data %>%
        select(all_of(selected_features))
      
    
      # 將過濾後的資料寫入 CSV 檔案
      file_encoding <- if (input$file_encoding == "UTF-8") "UTF-8" else "Big5"
      
      write.csv(filtered_data, file, row.names = FALSE, fileEncoding = file_encoding)    }
  )
})