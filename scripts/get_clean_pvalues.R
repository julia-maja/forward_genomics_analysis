library(dplyr)

results <- read.table("myOutput.txt", header=TRUE)
# filter out rows that have zero variance
results <- results %>% filter(PerfectMatchMargin != 0 | GLS_Pvalue != -1)
# multiple testing correction for p-values
results$GLS_FDR <- p.adjust(results$GLS_Pvalue, method="BH")
results <- results %>% arrange(GLS_Pvalue)

write.table(
    results,
    file="myOutput_with_FDR.txt",
    sep="\t",
    quote=FALSE,
    row.names=FALSE
)
