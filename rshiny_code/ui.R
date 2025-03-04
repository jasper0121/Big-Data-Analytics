library(shiny)
library(plotly)
library(DT)

source("global.R")

shinyUI(navbarPage(
  title = "員工離職預測-資料分析",
  
  tabPanel("特徵之間的離職率佔比",
           sidebarLayout(
             sidebarPanel(
               h3("特徵之間的離職率佔比"),
               helpText("使用說明："),
               helpText("1. 從下拉選單中選擇一個特徵值。"),
               helpText("2. 圖表將顯示所選特徵值的離職率佔比。"),
               helpText("3. 堆疊長條圖顯示不同特徵值的離職情況。"),
               helpText("4. 每個長條代表該特徵值在離職和未離職員工中的比例。"),
               selectInput("xcol", "選擇特徵值", choices = setdiff(names(data), "PerStatus")),
               HTML("<br>")
             ),
             mainPanel(
               plotlyOutput("barPlot")
             )
           )
  ),
  
  tabPanel("特徵值資料佔比",
           sidebarLayout(
             sidebarPanel(
               h3("特徵值資料佔比"),
               helpText("使用說明："),
               helpText("1. 從下拉選單中選擇一個特徵值。"),
               helpText("2. 圓餅圖將顯示所選特徵值的資料佔比。"),
               helpText("3. 圓餅圖展示了不同特徵值的分佈情況。"),
               selectInput("xcol_pie", "選擇特徵值", choices = setdiff(names(data), "PerStatus")),
             ),
             mainPanel(
               plotlyOutput("pieChart")
             )
           )
  ),
  
  tabPanel("特徵篩選分數長條圖",
           sidebarLayout(
             sidebarPanel(
               h3("特徵篩選分數長條圖"),
               helpText("使用說明："),
               helpText("1. 使用滑桿選擇Score閥值。"),
               helpText("2. 長條圖將顯示Score小於所選閥值的特徵值及其分數。"),
               helpText("3. 根據特徵值的分數，可以了解哪些特徵對預測模型的重要性較高。"),
               sliderInput("score_threshold", "選擇Score閥值", min = 0, max = 0.1, value = 0.01, step = 0.0001),
             ),
             mainPanel(
               plotlyOutput("barPlot_feature_filiter")
             )
           )
  ),
  
  tabPanel("下載篩選後資料",
           sidebarLayout(
             sidebarPanel(
               h3("下載篩選後資料"),
               helpText("使用說明："),
               helpText("1. 使用滑桿選擇Score閥值。"),
               helpText("2. 從下拉選單中選擇所需的資料類型（train.csv 或 test.csv）。"),
               helpText("3. 根據特徵分數閥值篩選後的資料會顯示在表格中。"),
               helpText("4. 選擇所需的特徵值，並從中選擇要包括在下載文件中的特徵。"),
               helpText("5. 選擇下載文件的編碼格式（UTF-8 或 Big5）。"),
               helpText("6. 點擊下載按鈕以CSV格式下載篩選後的資料。"),
               sliderInput("score_threshold_table", "選擇Score閥值", min = 0, max = 0.1, value = 0.01, step = 0.0001),
               selectizeInput("selected_features", "選擇篩選後的特徵",
                              choices = NULL,  # 初始時不設置選項
                              selected = NULL,
                              multiple = TRUE),
               selectInput("data_type", "選擇資料類型", choices = c("train.csv", "test.csv"), selected = "train.csv"),
               selectInput("file_encoding", "選擇下載檔案編碼格式", choices = c("UTF-8", "Big5"), selected = "Big5"),
               downloadButton("downloadData", "下載篩選後的資料")
             ),
             mainPanel(
               DT::DTOutput("filteredDataTable")
             )
           )
  )
))
