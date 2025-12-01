# Quick AI models overview

## GANS

Stands for Generative Adversarial Networks (GANs).

A GAN is a type of machine learning model that uses two neural networks, a generator and a discriminator, to create new
data that is similar to the data it was trained on. The generator creates new data, and the discriminator tries to tell
the difference between the real data and the fake data created by the generator. The two networks are trained together
in a zero-sum game, where the generator tries to fool the discriminator and the discriminator tries to correctly
identify the fake data. This process allows the generator to create increasingly realistic data over time.

![GAN model](./assets/GAN.png)

## Transformers

A transformer is a deep learning model that uses a self-attention mechanism to assign different weights to different
parts of an input sequence. This allows the model to pay more attention to the most important parts of the sequence,
which can lead to better performance on a variety of natural language processing tasks, such as machine translation,
text summarization, and question answering.

![Transformer model](./assets/transformers.png)