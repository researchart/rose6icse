**Exploring users' desired and present values from the reviews of Bangladeshi agriculture mobile applications**

We manually classified 1522 user reviews from Bangladeshi agriculture mobile apps to explore users' desired values and the values that are present in the existing apps.

**Dataset**

**File name:** All\_Reviews\_of\_Bangladeshi\_Agriculture\_Mobile\_Apps\_and\_Users\_Values.csv

**Language**

Majority of the reviews are written in Bengali and the rest are in English. To use the dataset, one should be able to read both Bengali and English.

**Explanation of creating the dataset**

At first, we collected 35 Bangladeshi agriculture apps from Google Play. From these 35 apps, 6 apps have no reviews. From the rest of the 29 apps, all the user reviews were crawled through a web crawler named ‘WebHarvy’. A total of 3991 user reviews were crawled. We did not crawl the identity of the reviewers due to privacy reason. The database of 3991 reviews was checked manually if there are any irrelevant and meaningless reviews. We found 119 irrelevant and meaningless reviews and removed those reviews manually. We looking for some constructive reviews which can direct us towards new values rather than compliments only. Therefore, we removed the common reviews that mention one word only such as ‘good’, ‘excellent’, ‘amazing’, ‘nice’, ‘wow’, ‘great’, ‘awesome’, ‘helpful’ and ‘important’, and the combination of these words. The reviews related to the words ‘love’ and ‘like’ such as “Loving it so much” or “I like it” were also removed. After removing these kind of reviews, we created a new database of 1522 reviews which we analysed to identify users’ desired values and the values that are present in the apps. We found several reviews which are exactly similar, for example, reviews 191-195. In those cases, we checked manually if the reviews came from the same reviewer but we found different reviewers from those reviews. Therefore, we did not delete those reviews as different reviewers can also think the same.
For the convenience of the users of this dataset, I kept all the 3991 reviews. From row 3 to row 1524, users will find the 1522 reviews with which we moved forward to relate with human values and from row 1525 to row 3993, users will find only the reviews which we did not use for this study.

**Details of the dataset**

In the dataset, the 1522 reviews were manually categorized into ‘Praise’, ‘Criticise’, ‘Problem faced’, ‘Suggestions’, ‘Expectations’ and ‘Queries’ for the convenience of relating each review with values. Then, each review was manually classified with ‘Present individual value items’, ‘Present main value categories’, ‘Desired individual value items’ and ‘Desired main value categories’. The terms ‘Present’ and ‘Desired’ have been used when a value is already reflected in the apps and when users expect a value from the apps, respectively. The previous categorization helped us understand if values are present or desired in the apps. For example, a review that is under the category ‘Praise’, it is related to ‘Present values’ and for other categories (‘Criticism’, ‘Problem faced’, ‘Suggestions’, ‘Expectations’ and ‘Queries’), it is related to ‘Desired values’. After that, to relate each review with specific present/ desired individual value items and main value categories, we analyzed the reviews again according to the Schwartz circular value structure and coded the reviews. We named the values as ‘Missing values’ that are desired by the users but not present in the apps.

**Columns information**

**App name:** Name of the Bangladeshi agriculture apps.

**Review:** Reviews provided by the users.

**Praise:** If users admire the apps (y= yes, n= no). For each ‘y’, we have mentioned why do we think it is ‘yes’. Particularly, we have mentioned the portions of the reviews that can be related to ‘Praise’.

**Criticise:** If users criticise the apps or unhappy with the apps (y= yes, n= no). For each ‘y’, we have mentioned why do we think it is ‘yes’. Particularly, we have mentioned the portions of the reviews that can be related to ‘Criticism’.

**Problem faced:** If users provide reviews mentioning problems they faced with the apps (y= yes, n= no). For each ‘y’, we have mentioned why do we think it is ‘yes’. Particularly, we have mentioned the portions of the reviews that can be related to ‘Problem faced’.

**Suggestions:** If users give suggestions to improve the apps and the way of improving it (y= yes, n= no). For each ‘y’, we have mentioned why do we think it is ‘yes’. Particularly, we have mentioned the portions of the reviews that can be related to ‘Suggestions’.

**Expectations:** If users provide comments mentioning their expectations (y= yes, n= no). For each ‘y’, we have mentioned why do we think it is ‘yes’. Particularly, we have mentioned the portions of the reviews that can be related to ‘Expectations’.

**Queries:** If users ask something about the apps (y= yes, n= no). For each ‘y’, we have mentioned why do we think it is ‘yes’. Particularly, we have mentioned the portions of the reviews that can be related to ‘Queries’.

**Present individual value items:** We explored users’ individual value items from the reviews that are present in the apps. We followed the 58 individual values from Schwartz theory of basic human values to relate with the reviews (y= yes, n= no). For each ‘y’, we have mentioned the corresponding individual value names (according to the Schwartz theory of basic human values) after analysing the review. There can be more than one values for each ‘y’.

**Present main value categories:** We explored users’ main value categories from the reviews that are present in the apps. We followed the 10 main value categories from Schwartz theory of basic human values to relate with the reviews (y= yes, n= no). For each ‘y’, we have mentioned the corresponding main value categories (according to the Schwartz theory of basic human values) depends on the present individual value items. There can be more than one values for each ‘y’.

**Desired individual value items:** We explored users’ desired individual value items from the reviews. We followed the 58 individual values from Schwartz theory of basic human values to relate with the reviews (y= yes, n= no). For each ‘y’, we have mentioned the corresponding individual value names (according to the Schwartz theory of basic human values) after analysing the review. There can be more than one values for each ‘y’.

**Desired main value categories:** We explored users’ desired main value categories from the reviews. We followed the 10 main value categories from Schwartz theory of basic human values to relate with the reviews (y= yes, n= no). For each ‘y’, we have mentioned the corresponding main value categories (according to the Schwartz theory of basic human values) depends on the desired individual value items. There can be more than one values for each ‘y’.

**How to use the dataset**

The dataset can be opened with a text editor, or Microsoft Excel supporting csv format, or Google spreadsheet, or it can be imported to a database.

**How to reproduce the results**

1. Bangladeshi agriculture app users’ present individual value items are found where ‘y’ is written in the column named ‘Present individual value items’. From these column, percentage of individual value presence can also be shown by using a pie chart or bar chart or table.
2. Bangladeshi agriculture app users’ present main value categories are found where ‘y’ is written in the column named ‘Present main value categories’. From these column, percentage of main value presence can also be shown by using a pie chart or bar chart or table.
3. Bangladeshi agriculture app users’ desired individual value items are found where ‘y’ is written in the column named ‘Desired individual value items’. From these column, percentage of desired individual values can also be shown by using a pie chart or bar chart or table.
4. Bangladeshi agriculture app users’ desired main value categories are found where ‘y’ is written in the column named ‘Desired individual value items’. From these column, percentage of desired main values can also be shown by using a pie chart or bar chart or table.
5. The ‘missing desired values’ can be found where ‘n’ is written in the column ‘Present individual value items’ and ‘y’ is written in the column ‘Desired individual value items’. The ratio can also be shown by using a pie chart or bar chart or table.

**Reference**

Shalom H Schwartz. 2012. An overview of the Schwartz theory of basic values. Online readings in Psychology and Culture 2, 1(2012), 11.
