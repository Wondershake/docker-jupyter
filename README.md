Docker Image: Wondershake Jupyter
=================================

This docker image is an all-in-one Jupyter Notebook on Alpine Linux 3.6.

[wondershake/jupyter - Docker Hub](https://hub.docker.com/r/wondershake/jupyter/)

# Usage
## Jupyter Notebook

Execute following command:

```bash
docker run --name jupyter -p 8888:8888 wondershake/jupyter
```

and you can access Jupyter Notebook as http://localhost:8888/

## Console

You can enter console with bash.

```bash
docker exec -ti jupyter bash -l
```

## Google Cloud SDK

To initialize `gcloud`:

```bash
docker exec -ti jupyter bash -lc "gcloud init"
```

# Components

Programming Languages:

* Perl 5
* Python 3.6
* Python 2.7

Python Packages:

* [PyYAML](http://pyyaml.org/)

Data Processing:

* [matplotlib](https://matplotlib.org/)
* [NumPy](http://www.numpy.org/)
* [pandas](https://pandas.pydata.org/)
* [SciPy](https://www.scipy.org/)

Machine Learning:

* [scikit-learn](http://scikit-learn.org/stable/)

Natural Language Processing:

* [JapaneseTokenizers](https://github.com/Kensuke-Mitsuzawa/JapaneseTokenizers)
* [MeCab](http://taku910.github.io/mecab/) ([en](https://github.com/jordwest/mecab-docs-en))
* [JUMAN](http://nlp.ist.i.kyoto-u.ac.jp/EN/index.php?JUMAN)
* [JUMAN++](http://nlp.ist.i.kyoto-u.ac.jp/EN/index.php?JUMAN++)
* [KyTea](http://www.phontron.com/kytea/)
* [NEologd](https://github.com/neologd/mecab-ipadic-neologd)
* [neologdn](https://github.com/ikegami-yukino/neologdn) ([normalization document](https://github.com/neologd/mecab-ipadic-neologd/wiki/Regexp.ja#python-written-by-hideaki-t--overlast))

Jupyter Notebook:

* [jupyter](http://jupyter.org/)
* [IPython Kernel](https://github.com/ipython/ipykernel)

Google Cloud:

* [Cloud SDK](https://cloud.google.com/sdk/) (`gcloud`)
