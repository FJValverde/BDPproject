Entropic Assessment of Multiclass Classifiers
========================================================
author: Francisco J Valverde
date: Sun Feb 22 13:00:40 2015


Problems with Classifier Evaluation
========================================================

In multiclass tasks it is often the case that the class distribution is deeply
*unbalanced*.

In this case, the usual assessment tools, like **Accuracy** are overly optimistic (*think of a classifier specializing in the majority class!*)

I am going to introduce one exploratory analysis tool, the **Entropy Triangle**  which suggest that **Mutual Information** helps understand this effect (and correct it!)

* F. J. Valverde-Albacete and C. Peláaez-Moreno. 100% classification accuracy considered harmful: the normalized information transfer factor explains the accuracy paradox. PLOS ONE, 2014.

Entropy Balance of a Joint Distribution
========================================================

Given two discrete R.V. $X$ and $Y$, the entropies related to them can be decomposed as:
<!-- We can write the following *balance equation*: -->
$$
\log |X| + \log |Y| = \Delta{H_{P_X \cdot P_Y}} + 2\cdot MI_{P_{XY}} + (H_{P_{X|Y}} + H_{P_{Y|X}})
$$
![The entropies in a distribution](figures/figure5a.png) 
<!-- where $MI_{P_{XY}}$ is the mutual information-->

The Entropy Triangle
========================================================

We represent the confusion matrices in normalized coordinates
$$
1 = \Delta{H'_{P_X \cdot P_Y}} + 2\cdot MI'_{P_{XY}} + VI'_{P_{XY}}
$$
in the Entropy Triangle, which is a  De Finetti diagram:
![Entropy Triangle](figures/figure6.png)

Example: different classifiers on unbalanced versions of Anderson's iris
========================================================



<!--  --> 
![plot of chunk unnamed-chunk-1](BDPProjectPitch-figure/unnamed-chunk-1-1.pdf) 
***

<!-- * Making your dataset more unbalanced: -->

* Using unbalanced datasets:

1. Improves classification Accuracy...! (For different families of classifiers!)
2. But decreases information transmitted in classification process.

* Take-home advice: always use balanced datasets to evaluate classifiers!

<!--
To assess a classifier on a dataset:

1. Obtain its confusion matrix
2. Work out the entropies 
in the balance equation
3. Represent them in the ET:
***
![plot of chunk unnamed-chunk-2](BDPProjectPitch-figure/unnamed-chunk-2-1.pdf) 
-->
