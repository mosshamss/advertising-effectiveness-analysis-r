# Advertising Effectiveness Analysis Using R

data <- read.csv("advertising.csv")

# Section 1: Data overview and summary statistics
head(data)
summary(data)

summary_table <- data.frame(
  Variable = c("TV", "Radio", "Newspaper", "Sales"),
  Mean = c(mean(data$TV), mean(data$Radio), mean(data$Newspaper), mean(data$Sales)),
  SD = c(sd(data$TV), sd(data$Radio), sd(data$Newspaper), sd(data$Sales)),
  Min = c(min(data$TV), min(data$Radio), min(data$Newspaper), min(data$Sales)),
  Q1 = c(quantile(data$TV, 0.25), quantile(data$Radio, 0.25), quantile(data$Newspaper, 0.25), quantile(data$Sales, 0.25)),
  Median = c(median(data$TV), median(data$Radio), median(data$Newspaper), median(data$Sales)),
  Q3 = c(quantile(data$TV, 0.75), quantile(data$Radio, 0.75), quantile(data$Newspaper, 0.75), quantile(data$Sales, 0.75)),
  Max = c(max(data$TV), max(data$Radio), max(data$Newspaper), max(data$Sales))
)

summary_table[, -1] <- round(summary_table[, -1], 2)

summary_table
View(summary_table)

hist(data$TV, main = "TV Advertising Spend", xlab = "TV")
hist(data$Radio, main = "Radio Advertising Spend", xlab = "Radio")
hist(data$Newspaper, main = "Newspaper Advertising Spend", xlab = "Newspaper")
hist(data$Sales, main = "Sales Distribution", xlab = "Sales")

# Section 2: Correlation and scatterplots
cor(data[, c("TV", "Radio", "Newspaper", "Sales")])

plot(data$TV, data$Sales,
     main = "Sales vs TV Advertising",
     xlab = "TV Advertising",
     ylab = "Sales")

plot(data$Radio, data$Sales,
     main = "Sales vs Radio Advertising",
     xlab = "Radio Advertising",
     ylab = "Sales")

plot(data$Newspaper, data$Sales,
     main = "Sales vs Newspaper Advertising",
     xlab = "Newspaper Advertising",
     ylab = "Sales")

# Tests of association among predictors
cor.test(data$TV,data$Radio)
cor.test(data$TV,data$Newspaper)
cor.test(data$Radio,data$Newspaper)

# Section 3: Simple linear regression
model1 <- lm(Sales ~ TV, data = data)
summary(model1)
plot(data$TV, data$Sales,
     main = "Sales vs TV Advertising with Fitted Regression Line",
     xlab = "TV Advertising",
     ylab = "Sales")

abline(model1, lwd = 2)

# Section 4: Multiple linear regression
model2 <- lm(Sales ~ TV + Radio + Newspaper, data = data)
summary(model2)
model_news <- lm(Sales ~ Newspaper, data = data)
summary(model_news)

# Section 5: Diagnostic plots
par(mfrow = c(2, 2))
plot(model2)
par(mfrow = c(1, 1))
std_res <- rstandard(model2)
lev <- hatvalues(model2)

n <- nrow(data)
p <- length(coef(model2))

outliers <- which(abs(std_res) > 2)
high_leverage <- which(lev > (2 * p / n))

outliers
high_leverage

diagnostic_points <- data.frame(
  Observation = 1:n,
  Standardized_Residual = std_res,
  Leverage = lev
)

diagnostic_points[abs(diagnostic_points$Standardized_Residual) > 2 | diagnostic_points$Leverage > (2 * p / n), ]

# Section 6: Model comparison
anova(model1, model2)

summary(model1)$r.squared
summary(model1)$adj.r.squared
summary(model1)$sigma

summary(model2)$r.squared
summary(model2)$adj.r.squared
summary(model2)$sigma

# Extra budget of 10 thousand dollars
10 * coef(model2)["TV"]
10 * coef(model2)["Radio"]
# Section 7a: Two-group sales split for t-tests
data$SalesGroup <- ifelse(data$Sales > mean(data$Sales), "High", "Low")
data$SalesGroup <- factor(data$SalesGroup, levels = c("Low", "High"))

table(data$SalesGroup)

t.test(TV ~ SalesGroup, data = data)
t.test(Radio ~ SalesGroup, data = data)
t.test(Newspaper ~ SalesGroup, data = data)

# Boxplots for two-group visualisation
boxplot(TV ~ SalesGroup, data = data,
        main = "TV Advertising by High and Low Sales Groups",
        xlab = "Sales Group",
        ylab = "TV Advertising")

boxplot(Radio ~ SalesGroup, data = data,
        main = "Radio Advertising by High and Low Sales Groups",
        xlab = "Sales Group",
        ylab = "Radio Advertising")

boxplot(Newspaper ~ SalesGroup, data = data,
        main = "Newspaper Advertising by High and Low Sales Groups",
        xlab = "Sales Group",
        ylab = "Newspaper Advertising")


# Section 7b: Four-group sales split for ANOVA
q <- quantile(data$Sales, probs = c(0.25, 0.50, 0.75))

data$Sales_split4 <- cut(
  data$Sales,
  breaks = c(-Inf, q[1], q[2], q[3], Inf),
  labels = c("Low", "Medium", "High", "Extreme"),
  include.lowest = TRUE
)

table(data$Sales_split4)

aov_tv <- aov(TV ~ Sales_split4, data = data)
summary(aov_tv)

aov_radio <- aov(Radio ~ Sales_split4, data = data)
summary(aov_radio)

aov_news <- aov(Newspaper ~ Sales_split4, data = data)
summary(aov_news)

TukeyHSD(aov_tv)
TukeyHSD(aov_radio)

# Boxplots for four-group visualisation
boxplot(TV ~ Sales_split4, data = data,
        main = "TV Advertising across Sales Groups",
        xlab = "Sales Group",
        ylab = "TV Advertising")

boxplot(Radio ~ Sales_split4, data = data,
        main = "Radio Advertising across Sales Groups",
        xlab = "Sales Group",
        ylab = "Radio Advertising")

boxplot(Newspaper ~ Sales_split4, data = data,
        main = "Newspaper Advertising across Sales Groups",
        xlab = "Sales Group",
        ylab = "Newspaper Advertising")

# Section 8: Principal Component Analysis
pca_model <- prcomp(data[, c("TV", "Radio", "Newspaper")], scale. = TRUE)
summary(pca_model)

# Hierarchical clustering
dist_matrix <- dist(scale(data[, c("TV", "Radio", "Newspaper")]))
hc <- hclust(dist_matrix, method = "ward.D2")
plot(hc, main = "Hierarchical Clustering Dendrogram")