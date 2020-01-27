# Human Values in Software Engineering Publications (2015-2018)

This dataset is our manual classification of human values in Software Engineering Publications (2015 - 2018) as a complement to our publication.
The dataset can be obtained in the following link: https://figshare.com/s/7a8c55799584d8783cd6

## Dataset
File name: `prevalence-human-values-in-se-publication.csv`

This file contains the title and the URL to the 1350 publications from top SE venues (ICSE, FSE, TOSEM, and TSE) between 2015 - 2018 with our human values manual classification. In the classification, we used Schwartz's theory of basic values (see reference below).

In this dataset, we provided the classification result from two different raters.
Each rater provided whether a publication is directly relevant to human values or not. If the publication was relevant, the rater provided a value category and up to three value items in which the publication is relevant.
For the result of the paper, we used the classification agreed by both raters.

### Columns information

- `paperId`:  Identifier of the paper
- `Venue`: the venue of the paper (ICSE, FSE, TOSEM, TSE)
- `Track`: the track of the paper (ICSE-SEIP and ICSE-SEIS, Main Track)
- `Year`: the publication year of the paper
- `Title`: the title of the paper
- `URL`: the URL to the paper
- `FirstRaterRelevance`: the relevance of the paper to human values classified by the first rater (Directly Relevant or Not Relevant)
- `FirstRaterValueCategory`: the human values category of the paper classified by the first rater
- `FirstRaterValue(1-3)`: one or more human value item of the paper classified by the first rater
- `SecondRaterRelevance`: the relevance of the paper to human values classified by the second rater (Directly Relevant or Not Relevant)
- `SecondRaterValueCategory`: the human values category of the paper classified by the second rater
- `SecondRaterValue(1-3)`: one or more human value item of the paper classified by the second rater

### Reference

Schwartz, S. H. (2012). An Overview of the Schwartz Theory of Basic Values. Online Readings in Psychology and Culture, 2(1), 12–13. https://doi.org/10.9707/2307-0919.1116
