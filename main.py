import argparse
import os

import openai
from dotenv import load_dotenv
from openai import AzureOpenAI, OpenAI

from src.similarity_finder import process_files

load_dotenv()


def is_valid_folder(parser: argparse.ArgumentParser, path: str) -> str:
    if not os.path.isdir(path):
        parser.error(f"The folder '{path}' does not exist or is not a directory.")
    return path


def is_positive_number(parser: argparse.ArgumentParser, value: str) -> int:
    try:
        ivalue = int(value)
        if ivalue <= 0:
            parser.error(f"Expected a positive integer for --k, got {value} instead.")
        return ivalue
    except ValueError:
        parser.error(f"Expected a positive integer for --k, got {value} instead.")


def is_valid_output_path(parser: argparse.ArgumentParser, path: str) -> str:
    if path:
        output_dir = os.path.dirname(path)
        if output_dir and not os.path.isdir(output_dir):
            parser.error(f"The output directory '{output_dir}' does not exist.")
        if output_dir and not os.access(output_dir, os.W_OK):
            parser.error(f"The output directory '{output_dir}' is not writable.")
        return path
    else:
        parser.error("Output path cannot be empty.")


def process_folder(folder_path: str, k: int, output_path: str) -> None:
    openai_api_key = os.getenv("OPENAI_API_KEY")
    if os.getenv("AZURE_OPENAI_ENDPOINT"):
        azure_openai_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
        azure_openai_version = os.getenv("AZURE_OPENAI_API_VERSION")
        azure_openai_model = os.getenv("AZURE_MODEL_NAME")
        client = AzureOpenAI(
            api_key=openai_api_key,
            azure_endpoint=azure_openai_endpoint,
            api_version=azure_openai_version,
        )
        model = azure_openai_model
    else:
        client = OpenAI(api_key=openai_api_key)
        model = "gpt-4-turbo-preview"
    process_files(client, folder_path, k, output_path, model)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Process a folder with optional parameters and save output to a specified path."
    )

    # Add --folder (-f) argument
    parser.add_argument(
        "-f",
        "--folder",
        type=lambda x: is_valid_folder(parser, x),
        help="Path to the folder to process",
        required=True,
    )

    # Add --k argument
    parser.add_argument(
        "--k",
        type=lambda x: is_positive_number(parser, x),
        help="A positive integer value, defaults to 5",
        default=5,
    )

    # Add --output (-o) argument
    parser.add_argument(
        "-o",
        "--output",
        type=lambda x: is_valid_output_path(parser, x),
        help="Output path with output name",
        required=True,
    )

    args = parser.parse_args()

    process_folder(args.folder, args.k, args.output)
