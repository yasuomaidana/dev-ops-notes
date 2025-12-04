# Quick AI models overview

## GANS

Stands for Generative Adversarial Networks (GANs).

A GAN is a type of machine learning model that uses two neural networks, a generator and a discriminator, to create new
data that is similar to the data it was trained on. The generator creates new data, and the discriminator tries to tell
the difference between the real data and the fake data created by the generator. The two networks are trained together
in a zero-sum game, where the generator tries to fool the discriminator and the discriminator tries to correctly
identify the fake data. This process allows the generator to create increasingly realistic data over time.

![GAN model](../assets/GAN.png)

## Transformers

A transformer is a deep learning model that uses a self-attention mechanism to assign different weights to different
parts of an input sequence. This allows the model to pay more attention to the most important parts of the sequence,
which can lead to better performance on a variety of natural language processing tasks, such as machine translation,
text summarization, and question answering.

![Transformer model](../assets/transformers.png)

## Tokenization

Tokenization is the process of breaking down a text into smaller units called tokens. These tokens can be as small as characters or as long as words. For example, the sentence "I love NLP" can be tokenized into the words "I", "love", and "NLP". Tokenization is a fundamental step in many Natural Language Processing (NLP) tasks, as it allows the model to see the text as a sequence of discrete items.

There are several types of tokenization, including:
- **Word tokenization:** Splits a text into individual words.
- **Character tokenization:** Splits a text into individual characters.
- **Subword tokenization:** Splits a text into units that are smaller than words but larger than characters. This is useful for handling rare words and for reducing the size of the vocabulary.

## Word2vec

Word2vec is a popular technique for learning word embeddings, which are numerical representations of words. It was developed by a team of researchers at Google led by Tomas Mikolov. Word2vec uses a shallow, two-layer neural network to learn the relationships between words in a large corpus of text.

There are two main architectures for Word2vec:
- **Continuous Bag-of-Words (CBOW):** Predicts a word from its surrounding context.
- **Skip-gram:** Predicts the surrounding context from a word.

The learned word embeddings can be used for a variety of NLP tasks, such as machine translation, sentiment analysis, and question answering.

## BERT

BERT (Bidirectional Encoder Representations from Transformers) is a powerful language representation model developed by Google. It is based on the Transformer architecture and is pre-trained on a large corpus of text. BERT is able to learn deep bidirectional representations of words, which means that it can understand the context of a word from both the left and the right.

BERT can be fine-tuned for a variety of NLP tasks, such as:
- **Question answering:** Answering questions about a given text.
- **Sentiment analysis:** Determining the sentiment of a text.
- **Text classification:** Classifying a text into one of several categories.

## Natural Language Processing (NLP)

Natural Language Processing (NLP) is a field of artificial intelligence (AI) that focuses on enabling computers to understand, interpret, and generate human language. It is a multidisciplinary field that combines computer science, linguistics, and machine learning.

NLP has a wide range of applications, including:
- **Machine translation:** Translating text from one language to another.
- **Text summarization:** Summarizing a long text into a shorter one.
- **Sentiment analysis:** Determining the sentiment of a text.
- **Question answering:** Answering questions about a given text.
- **Chatbots:** Creating chatbots that can interact with humans in a natural way.

## Application in business functions

1. Marketing and customer engagement
   * Email marketing campaigns
   * Dynamic web content
2. Enhance
   * Engagement
   * Conversion rates (personalized content)
3. Operations and logistics
   * Forecast demand trends
   * Simulate supply chain scenarios
   * Recommend adjustments
4. Enables business to:
   * Make informed decisions 
   * Reduce costs
   * Improve services
5. Technical refinement of documents
6. Mimic writing styles
   * Tone
   * Style
   * Audience engagement
   * Adapt

## Types of learning

- Supervised learning
  - Learns from labeled training data to predict outcomes for new inputs
  - Common tasks: classification, regression
  - Example algorithms: linear/logistic regression, decision trees, support vector machines, neural networks

- Unsupervised learning
  - Identifies structure or patterns in unlabeled data
  - Common tasks: clustering, dimensionality reduction, association
  - Example algorithms: K-means, hierarchical clustering, PCA, autoencoders

- Reinforcement learning
  - Learns policies by trial and error via feedback (rewards)
  - Common tasks: control, sequential decision-making
  - Example algorithms: Q-learning, policy gradients, actor-critic methods

## Algorithms and techniques

- Traditional algorithms: linear regression, decision trees, random forests, gradient boosting
- Deep learning: multilayer neural networks, CNNs, RNNs, transformers
- Ensemble methods: bagging, boosting, stacking

## Data handling and processing

- Preprocessing: normalization/standardization, encoding categorical features, imputing missing values
- Feature engineering: selection, extraction, dimensionality reduction
- Data splitting and validation: train/validation/test, cross-validation, stratified sampling

## Performance evaluation

- Classification metrics: accuracy, precision, recall, F1-score, ROC AUC
- Regression metrics: RMSE, MAE, R²
- Validation methods: confusion matrix, cross-validation, calibration, holdout testing

## Application areas

- Finance: algorithmic trading, credit scoring, fraud detection
- Healthcare: predictive diagnostics, patient risk stratification
- Autonomous systems: navigation, perception, control
- Marketing and retail: recommendation systems, customer segmentation, demand forecasting