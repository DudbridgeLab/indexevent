### Please use Siyang Cai's [ColliderBias](https://github.com/SiyangCai/ColliderBias) package for our most up-to-date methods.
[https://github.com/SiyangCai/ColliderBias](https://github.com/SiyangCai/ColliderBias)

This package is retained for compatibility with Dudbridge et al (2019).  The current version is 0.2.0 in which the default correction for weak instruments has been changed to CWLS (corrected weighted least squares) from Cai et al (2022).

# INDEXEVENT
`INDEXEVENT` is a package for adjusting association statistics for index event bias.

To install within R:

`devtools::install_github("DudbridgeLab/indexevent")`


To see a toy example: 

`help(testData)`


For more details on usage:

`help(indexevent)`



This software has been tested in R 3.3.1 under Windows 7, and R 3.4.1 under CentOS Linux.  For most applications it will run on a standard desktop PC.


## Citations
> Cai S, Hartley A, Mahmoud O, Tilling K, Dudbridge F Adjusting for collider bias in genetic association studies using instrumental variable methods. **Genetic Epidemiol** 46:303-316 (2022) [https://doi.org/10.1002/gepi.22455](https://doi.org/10.1002/gepi.22455)
> 
> Dudbridge, F., Allen, R.J., Sheehan, N.A. _et al._ Adjustment for index event bias in genome-wide association studies of subsequent events. **Nat Commun** 10:1561 (2019). [https://doi.org/10.1038/s41467-019-09381-w](https://doi.org/10.1038/s41467-019-09381-w)
