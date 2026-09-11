from fastapi import FastAPI
from FlagEmbedding import FlagModel
from sentence_transformers import SentenceTransformer

app = FastAPI()

model1 = "BAAI/bge-large-en-v1.5"
bge = FlagModel(model1, use_fp16=True)

model2 = "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"
sbert = SentenceTransformer(model2)


@app.post("/similarity/bge")
def similarity(pairs: list[list[str]]):
    scores = []
    for c1, c2 in pairs:
        emb = bge.encode([c1, c2])
        value = float(emb[0] @ emb[1])
        scores.append(value)
    return scores

@app.post("/similarity/sbert")
def similarity(pairs: list[list[str]]):
    scores = []
    for c1, c2 in pairs:
        emb = sbert.encode([c1, c2])
        value = float(sbert.similarity(emb[0:1], emb[1:2]))
        scores.append(value)
    return scores

@app.get("/models")
def models():
    return [ model1, model2 ]

