# Print results of index event adjustment
#
# After regressing effects on the subsequent event on the effects on the index event, print out the regression coefficient
# and its confidence interval
#
print.indexevent = function(x) {
  print(paste("Coefficient",x$b))
  print(paste("Standard error",x$b.se))
  print(paste("95% CI",x$b.ci[1],x$b.ci[2]))
}
