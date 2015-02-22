# Building Data Products Project: A Demonstrator for the Entropy Triangle

The Entropy Triangle is an exploratory analysis *for classifier evaluation*. Instead of trusting in classification accuracy which is highly unreliable it suggests considering the entropies involved in the **confusion matrix** of a particular classifier on a particular dataset.

## The balance equation 

Suppose you have a dataset on which you train a classifier to obtain a confusion matrix (in our examples, by 10-fold cross-validation) to estimate the performance of the classifier in unseen data. 

Consider the reference classes $X$ and the predicted classes $Y$ and the confusion matrix of the classifier $N_{XY}$. 

The confusion matrix can be transformed into  joint (count) distribution $P_{XY}$ whose marginals are discrete (count) distributions over $P_X$ $P_Y$. Note that distribution $P_X$ is the distribution of reference labels in the dataset, while $P_Y$ is, in some sense, build by the classifier.

If the dataset was balanced, then $P_X$ would be the uniform discrete distribution $U_X$, with maximum entropy $H_{U_X}=\log{|X|}$, where $|X|$ is the number of classes in $X$. Likewise, if the output was balanced, then $P_Y = U_Y$ with $H_{U_Y}=\log{|Y|}$. In any other case, we can measure the difference between the entropies as $\Delta H_{P_X} = H_{U_X} - H_{P_X}$  and $ $\Delta H_{P_Y}= H_{U_Y} - H_{P_Y}$, and add them $\Delta H_{P_{XY}}=  \Delta H_{P_X} + \Delta H_{P_Y}$.

We can relate these differences to the Mutual Information and to the conditional entropies as per the following diagram:
![Venn diagram of entropies of a joint discrete distribution][entropies]

[entropies]: https://github.com/FJValverde/BDPproject/figure5a.png "Entropies of a joint discrete distribution"
