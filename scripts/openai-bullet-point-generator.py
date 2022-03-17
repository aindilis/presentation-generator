import os
import openai
openai.organization = ""
openai.api_key = ""

print(openai.Completion.create(
    engine="curie",
    prompt="Make bullet points about the following:\n\nThere is more relevant information than I able to summarize contained in this presentation, so I recommend rewatching the video and occassionally pausing it as needed. This talk covers some systems integration and software applications that make use of Ontology to a degree.\n\n- Key points:\n - 1.",
    max_tokens=200,
    temperature=0.5,
))

