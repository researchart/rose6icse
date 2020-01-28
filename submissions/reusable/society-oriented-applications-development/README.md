**Exploring users&#39; desired and present values from the reviews of Bangladeshi agriculture mobile applications**

We manually classified 1522 user reviews from Bangladeshi agriculture mobile apps to explore users&#39; desired values and the values that are present in the existing apps.

**Dataset**

**File name:** Reviews\_of\_Bangladeshi\_Agriculture\_Mobile\_Apps\_and\_Users\_Values.csv

**Explanation of creating the dataset**

At first, we collected 35 Bangladeshi agriculture apps from Google Play. From these 35 apps, 6 apps have no reviews. From the rest of the 29 apps, all the user reviews were crawled through a web crawler named `WebHarvy&#39;. A total of 3991 user reviews were crawled. We did not crawl the identity of the reviewers due to privacy reason. The database of 3991 reviews was checked manually if there are any irrelevant and meaningless reviews. We found 119 irrelevant and meaningless reviews and removed those reviews manually. We looking for some constructive reviews which can direct us towards new values rather than compliments only. Therefore, we removed the common reviews that mention one word only such as `good&#39;, `excellent&#39;, `amazing&#39;, `nice&#39;, `wow&#39;, `great&#39;, `awesome&#39;, `helpful&#39; and `important&#39;, and the combination of these words. The reviews related to the words `love&#39; and `like&#39; such as &quot;Loving it so much&quot; or &quot;I like it&quot; were also removed. After removing these kind of reviews, we created a new database of 1522 reviews which we analysed to identify users&#39; desired values and the values that are present in the apps.

**Details of the dataset**

In the dataset, the 1522 reviews were manually categorized into `Praise&#39;, `Criticise&#39;, `Problem faced&#39;, `Suggestions&#39;, `Expectations&#39; and `Queries&#39; for the convenience of relating each review with values. Then, we followed a human values theory, Schwartz theory of basic human values, to relate each review with values. The reviews were again classified into &quot;Present individual value items&quot;, &quot;Present main value categories&quot;, &quot;Desired individual value items&quot; and &quot;Desired main value categories&quot;.

**Columns information**

**App name:** Name of the Bangladeshi agriculture apps.

**Review:** Reviews provided by the users.

**Praise:** If users admire the apps (y= yes, n= no).

**Criticise:** If users criticise the apps or unhappy with the apps (y= yes, n= no).

**Problem faced:** If users provide reviews mentioning problems they faced with the apps (y= yes, n= no).

**Suggestions:** If users give suggestions to improve the apps and the way of improving it (y= yes, n= no).

**Expectations:** If users provide comments mentioning their expectations (y= yes, n= no).

**Queries:** If users ask something about the apps (y= yes, n= no).

**Present individual value items:** We explored users&#39; individual value items from the reviews that are present in the apps. We followed the 58 individual values from Schwartz theory of basic human values to relate with the reviews (y= yes, n= no).

**Present main value categories:** We explored users&#39; main value categories from the reviews that are present in the apps. We followed the 10 main value categories from Schwartz theory of basic human values to relate with the reviews (y= yes, n= no).

**Desired individual value items:** We explored users&#39; desired individual value items from the reviews. We followed the 58 individual values from Schwartz theory of basic human values to relate with the reviews (y= yes, n= no).

**Desired main value categories:** We explored users&#39; desired main value categories from the reviews. We followed the 10 main value categories from Schwartz theory of basic human values to relate with the reviews (y= yes, n= no).

**How to use the dataset**

The dataset can be opened with a text editor, or Microsoft Excel supporting csv format, or Google spreadsheet, or it can be imported to a database.

**How to reproduce the results**

1. Bangladeshi agriculture app users&#39; present individual value items are found where &quot;y&quot; is written in the column named &quot;Present individual value items&quot;. From these column, percentage of individual value presence can also be shown by using a pie chart or bar chart or table.
2. Bangladeshi agriculture app users&#39; present main value categories are found where &quot;y&quot; is written in the column named &quot;Present main value categories&quot;. From these column, percentage of main value presence can also be shown by using a pie chart or bar chart or table.
3. Bangladeshi agriculture app users&#39; desired individual value items are found where &quot;y&quot; is written in the column named &quot;Desired individual value items&quot;. From these column, percentage of desired individual values can also be shown by using a pie chart or bar chart or table.
4. Bangladeshi agriculture app users&#39; desired main value categories are found where &quot;y&quot; is written in the column named &quot;Desired individual value items&quot;. From these column, percentage of desired main values can also be shown by using a pie chart or bar chart or table.
5. The missing desired values can be found where &quot;n&quot; is written in the column &quot;Present individual value items&quot; and &quot;y&quot; is written in the column &quot;Desired individual value items&quot;. The ration can also be shown by using a pie chart or bar chart or table.

**Reference**

Shalom H Schwartz. 2012. An overview of the Schwartz theory of basic values. Online readings in Psychology and Culture 2, 1(2012), 11.