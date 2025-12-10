import os

from dotenv import load_dotenv
from crewai import LLM

# Google Gemini uses the OpenAI-compatible endpoint.
DEFAULT_GEMINI_BASE_URL = "https://generativelanguage.googleapis.com/v1beta/openai/"
DEFAULT_GEMINI_MODEL = "gemini-2.5-flash"


def build_gemini_llm(temperature: float = 0.1) -> LLM:
    """Create a Gemini LLM instance configured via environment variables."""
    load_dotenv()
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY is not set. Please add it to your environment.")

    model = os.getenv("GEMINI_MODEL", DEFAULT_GEMINI_MODEL)
    base_url = os.getenv("GEMINI_BASE_URL", DEFAULT_GEMINI_BASE_URL)

    return LLM(
        model=model,
        api_key=api_key,
        base_url=base_url,
        temperature=temperature,
    )
