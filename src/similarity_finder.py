import json
import os
import re
from pathlib import Path
from typing import Union

import numpy as np
import openai
import pandas as pd
from InstructorEmbedding import INSTRUCTOR
from openai import AzureOpenAI, OpenAI
from qdrant_client import QdrantClient
from qdrant_client.models import (
    Distance,
    PointStruct,
    VectorParams,
)
from tqdm import tqdm

os.environ["TOKENIZERS_PARALLELISM"] = "true"
SUPPORTED_FILE_EXTENSIONS = {
    "c": (r"/\*.*?\*/", r"//.*"),
    "cpp": (r"/\*.*?\*/", r"//.*"),
    "sh": (r"#.*",),
}


def remove_comments(code: str, extension: str) -> str:
    patterns = SUPPORTED_FILE_EXTENSIONS.get(extension, ())
    for pattern in patterns:
        code = re.sub(pattern, "", code, flags=re.DOTALL)
    return code


def load_embedding_model(model_name: str) -> object:
    if model_name == "hkunlp/instructor-xl":
        model = INSTRUCTOR(model_name)
        return model


def get_embeddings(content_list: list, model: object) -> list:
    if isinstance(model, INSTRUCTOR):
        instruction = "Represent the code for similarity search:"
        input = [[instruction, sentence] for sentence in content_list]
        embeddings = model.encode(input)
        embeddings = [np.array(e) for e in embeddings]
        return embeddings


def get_qdrant_client(
    vector_size: int, collection_name: str = "code_search"
) -> QdrantClient:
    client = QdrantClient(":memory:")
    client.recreate_collection(
        collection_name=collection_name,
        vectors_config=VectorParams(size=vector_size, distance=Distance.COSINE),
    )
    return client


def build_prompt_for_similar_scripts(similar_scripts: list[str]) -> str:
    prompts = []
    for i, script in enumerate(similar_scripts):
        prompt = f"""
        Name : Script {i + 1}:
        ```
        {script}
        ```
        """.strip()
        prompts.append(prompt.strip())
    return "\n".join(prompts)


def call_open_ai(
    client: Union["AzureOpenAI", "OpenAI"],
    script: str,
    similar_codes: list[str],
    model: str,
) -> openai.ChatCompletion:
    similar_scripts_prompt = build_prompt_for_similar_scripts(similar_codes)
    system_content = """
        You are specialized agent for detecting code plagiarism.
        You excels in identifying potential instances of code plagiarism by analyzing user-provided code snippets.
        You can adapt to various programming languages and styles, ensuring accurate detection across diverse coding practices.
        You need to maintain a supportive tone, guiding users on best practices for code citation and academic honesty in software development.
        You are highly accurate, you serves as a tool for assistance, not a definitive authority on the legality or ethicality of detected similarities.
    """
    system_content = f"""
        ORIGINAL script :
        ```
        {script}
        ```
        Script to evaluate original against :
        ```
        {similar_scripts_prompt}
        ```
    """
    user_prompt = """
    You task is to understand ORIGINAL script and than evaluate the this original script for potential plagiarism.
    The scripts you are evaluating are from a university assignment and they must have same logic and structure.
    However, discern between legitimate similarities and instances of plagiarism.
    JSON Response format against original script:
        ```
        "results" : [
            {{
                "script_name": "string", # Name of the script, e.g., Script 1, Script 2, etc.
                "plagiarism": "bool", # True if plagiarized, False otherwise. Be sure to provide a rationale for your decision.
                "reason": "string" # Rationale for decision, citing evidence
            }}
        ]
        ```
    """.strip()

    message_text = [
        {"role": "system", "content": system_content},
        {"role": "user", "content": f"{user_prompt}"},
    ]
    completion = client.chat.completions.create(
        model=model,
        messages=message_text,
        response_format={"type": "json_object"},
        stop=None,
    )
    return completion


def process_files(
    client: Union["AzureOpenAI", "OpenAI"],
    folder_path: str,
    k: int,
    output_path: str,
    model: str,
    embedding_model_name: str = "hkunlp/instructor-xl",
) -> None:
    # load contect of files
    file_contents = {}
    folder = Path(folder_path)
    for file_path in folder.glob("*"):
        if file_path.is_dir():
            continue
        if file_path.suffix[1:] in SUPPORTED_FILE_EXTENSIONS:
            with file_path.open(encoding="ISO-8859-1") as f:
                content = f.read()
                content = remove_comments(content, extension=file_path.suffix[1:])
                file_contents[file_path.name] = content

    # setup embedding pipeline
    embedding_model = load_embedding_model(embedding_model_name)
    embeddings = get_embeddings(list(file_contents.values())[:5], embedding_model)
    collection_name = "code_search"
    qdrant_client = get_qdrant_client(embeddings[0].shape[0], collection_name)

    # upload embeddings to qdrant
    files = list(file_contents.keys())
    idx = 1
    points = []
    for file, embedding in zip(files, embeddings):
        point = PointStruct(
            vector=embedding.tolist(),
            payload={"file": file},
            id=idx,
        )
        points.append(point)
        idx += 1

    qdrant_client.upsert(collection_name=collection_name, points=points)

    files = files[:1]
    pbar = tqdm(zip(files, embeddings), total=len(files))
    results_df = []
    for file, embedding in pbar:
        hits = qdrant_client.search(
            collection_name=collection_name,
            query_vector=embedding,
            limit=k,
        )
        file_hits = [hit.payload["file"] for hit in hits if hit.payload["file"] != file]

        file_hits_similarity = [
            hit.score for hit in hits if hit.payload["file"] != file
        ]
        description = f"File: {file}, Hits: {file_hits}"

        row = {
            "file": file,
            "hits": file_hits,
            "k": k,
        }
        pbar.set_description(description)
        for hit, sim_score in zip(file_hits, file_hits_similarity):
            response = call_open_ai(
                client, file_contents[file], [file_contents[hit]], model
            )
            try:
                response = json.loads(response.choices[0].message.content)
                results_df.append(
                    {
                        **row,
                        "code_similarity": sim_score,
                        "hit": hit,
                        "plagiarism": response["results"][0]["plagiarism"],
                        "reason": response["results"][0]["reason"],
                    }
                )
            except Exception as e:
                print(e)
                response = response.choices[0].message.content
                results_df.append(
                    {
                        **row,
                        "code_similarity": sim_score,
                        "hit": hit,
                        "plagiarism": None,
                        "reason": None,
                        "response": response,
                    }
                )
    df = pd.DataFrame(results_df)
    df.to_csv(output_path, index=False)
