import os

from dotenv import load_dotenv
from crewai import LLM

# Google Gemini uses the OpenAI-compatible endpoint.
# DEFAULT_GEMINI_BASE_URL = "https://generativelanguage.googleapis.com/v1beta/openai/"
# DEFAULT_GEMINI_MODEL = "gemini-robotics-er-1.5-preview"
MODEL = "ollama/hf.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF:Q4_K_M"
BASE_URL = "http://ollama:11434"

def build_gemini_llm(max_tokens: float, temperature: float = 0.0) -> LLM:
    """Create a LLM instance configured via environment variables.
    args:
        max_tokens (float): Maximum tokens for the LLM response.
        temperature (float): Sampling temperature for the LLM.
    returns:
        LLM: Configured LLM instance.
    """
    load_dotenv()
    # api_key = os.getenv("GEMINI_API_KEY")
    # if not api_key:
    #     raise ValueError("GEMINI_API_KEY is not set. Please add it to your environment.")

    model = os.getenv("MODEL", MODEL)
    base_url = os.getenv("BASE_URL", BASE_URL)

    return LLM(
        model=model,
        # api_key=api_key,
        base_url=base_url,
        temperature=temperature,
        max_tokens=max_tokens,
    )
