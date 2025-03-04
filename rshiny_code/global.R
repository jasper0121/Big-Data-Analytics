# global.R
library(shiny)
library(plotly)
data <- read.csv("og/train.csv")
train_data =  read.csv("og/train.csv")
test_data = read.csv("og/test.csv")
data = select(data, -PerNo) 
data[is.na(data)] <- -1
train_data[is.na(train_data)] <- -1
test_data[is.na(test_data)] <- -1

X <- data %>%
  select(-PerStatus)
y <- data$PerStatus

# 使用ANOVA選擇特徵
anova_result <- apply(X, 2, function(x) {
  model <- glm(PerStatus ~ x, data = data, family = "binomial")
  summary(model)$coefficients["x", "Pr(>|z|)"]
})

# 將特徵和得分組合成元組列表
features_scores_tuples <- data.frame(Feature = names(anova_result), Score = anova_result)

# 根據得分排序特徵
sorted_features_scores_tuples <- features_scores_tuples %>%
  arrange(Score)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
# 打印排序後的特徵和得分
print(sorted_features_scores_tuples)
# 打印篩選後的特徵
print("篩選出的特徵數量:")
print(length(sorted_features_scores_tuples$Feature))