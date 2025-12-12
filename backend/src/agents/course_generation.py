from __future__ import annotations

import json
from typing import Any, Dict, List

from dotenv import load_dotenv
from crewai import Crew, Agent, Task
from crewai.tasks.task_output import TaskOutput
from pydantic import BaseModel
from loguru import logger

try:
    from llm_config import build_gemini_llm
    from execution_limits import agent_limits, crew_limits
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.agents.llm_config import build_gemini_llm  # type: ignore
    from src.agents.execution_limits import agent_limits, crew_limits  # type: ignore

try:
    from utils.json_utils import extract_json_dict
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.utils.json_utils import extract_json_dict  # type: ignore

load_dotenv()

the_one_llm = build_gemini_llm(max_tokens=1000)

class Topic(BaseModel):
    learning_topic: str
    user_level: str
    additional_context: str
    teachability: bool
    language: str

class DescriptionUnit(BaseModel):
    unit_title: str
    description: str
    objectives: List[str]


class Units(BaseModel):
    learning_topic: str
    user_level: str
    units: List[DescriptionUnit]
    

# Agent: Topic_Extractor
topic_extractor = Agent(
    role="""AI Learning Intent Analyst""",

    goal="""
            Interpret a learner’s written message to extract the main topic they wish to study, estimate their 
            knowledge level, and capture motivation or contextual clues that guide course generation.
            """,

    backstory="""
            You specialize in understanding natural language prompts from learners. You can read between the lines 
            to detect not just what users want to learn but also how prepared and motivated they are. Your analyses 
            define the foundation for course design, ensuring that each subsequent step of generation is accurate and 
            aligned with the learner’s intent.
            """,
    verbose=False,
    llm=the_one_llm,
    **agent_limits()
)

# Agent: Unit_Architect
unit_architect = Agent(
    role="""Educational Designer for Microlearning Units expert in the given topic""",
    
    goal="""
            Transform a learner’s intent into a structured learning roadmap composed of concise, 
            conceptual units suitable for 5-minute mobile lessons.""",
    
    backstory="""
            You are an experienced curriculum designer who has mastered breaking complex topics into digestible,
            interactive learning blocks. You understand how people learn best in short bursts and create sequences 
            that gradually build understanding while keeping engagement high. Your clarity and structure make learning
            smooth and approachable for every level.""",
    verbose=False,
    llm=the_one_llm,
    **agent_limits()
)


# Task: topic_extraction_task
topic_extraction_task = Task(
    description="""             
                Analyze the learner’s input message to accurately identify what they want to learn and how prepared they 
                are. Use natural language understanding to infer not only the main subject or skill but also the 
                learner’s level, motivation, tone, and any contextual details that could influence course design.  
                Ensure the output provides a clear, concise foundation for the next agent to design the course 
                structure.

                Input Message: {topic} 
                """,
    expected_output="""
                An object containing: 
                - learning_topic: The main subject or skill the learner wants to study (concise and clear).
                - user_level: inferred from wording.   
                - additional_context: A brief summary including any motivation, tone, or language clues from the prompt.
                - teachability: true if the prompt can generate an educational course, false otherwise.
                - language: Language in which the prompt was written.\n    No extra text outside the JSON object.
                
                Return ONLY a valid JSON object with the following fields and no additional text, no explanations, 
                no brackets outside the JSON:

                {
                    "learning_topic": "...",
                    "user_level": "Beginner | Intermediate | Advanced",
                    "additional_context": "...",
                    "teachability": true or false,
                    "language": "English | Spanish | French | Portuguese | Italian | Geman | Other"
                }

                The JSON must contain these exact fields, with no extra fields, no markdown, no comments, and no text outside the JSON.
                
                IMPORTANT:
                - Return ONLY valid JSON.
                - Do NOT include trailing commas.
                - Do NOT include comments.
                - Do NOT include text before or after the JSON.

                FINAL CHECK BEFORE RESPONDING:
                - Validate the JSON syntax.
                - Remove any trailing commas.
                - Ensure all brackets and quotes are properly closed.
                - If the JSON is invalid, fix it silently and return ONLY the corrected JSON.
                
                """,
    agent=topic_extractor,
    output_file="outputs/topic_extraction.json",
    llm=the_one_llm
    
)

# Task: unit_generation_task
unit_generation_task = Task(
    description="""
                Transform the learner information provided as context into a
                structured roadmap of concise, conceptual units for a 5-minute-per-lesson
                mobile microlearning course. Use only these input fields:
                - learning_topic
                - user_level (Beginner | Intermediate | Advanced)
                - additional_context (motivation, tone, language)

                Create units that emphasize conceptual understanding and lightweight
                interactivity (quizzes, mental checks). Avoid all content related to
                installations, environment setup, terminal commands, tooling, or anything
                procedural unless it is absolutely essential to the conceptual explanation.
                Each unit must represent one clear, focused idea suitable for microlearning.    
                """,        
    expected_output="""
                    DO NOT use markdown, DO NOT use triple backticks, DO NOT write ```json, and DO NOT wrap the output in any code block. 
                    Return ONLY a raw JSON object, with no text before or after it. Return ONLY valid JSON following EXACTLY this structure:
                    {
                    "learning_topic": "string",
                    "user_level": "string",
                    "units": [
                        {
                        "unit_title": "string",
                        "description": "string",
                        "objectives": ["string", "string"]
                        }
                    ]
                    }

                    STRICT FORMAT RULES:
                    - The JSON object must contain ONLY these keys:
                        - "learning_topic"
                        - "user_level"
                        - "units"
                    - "units" must be an array of unit objects.
                    - Each unit object MUST contain ONLY:
                        - "unit_title"
                        - "description"
                        - "objectives"
                    - "objectives" must be an array of 2 to 4 short strings.
                    - DO NOT include any additional fields, metadata, numbering, IDs, or comments.
                    - DO NOT use markdown, bullet points, code blocks,file type references such as ```json, or any text outside the JSON.

                    CONTENT RULES:
                    - Echo the exact learning_topic and user_level provided as input (normalized to Beginner, Intermediate, or Advanced).
                    - Produce between 7 and 10 units total.
                    - Each unit_title must be short, descriptive, and conceptual.
                    - Each description must be exactly one concise sentence explaining the core idea.
                    - Objectives must be simple, action-oriented outcomes strictly aligned to the unit.
                    - Maintain clarity, simplicity, and natural phrasing.
                    - Adapt tone or language if indicated in additional_context.

                    IMPORTANT:
                    - Return ONLY valid JSON.
                    - Do NOT include trailing commas.
                    - Do NOT include comments.
                    - Do NOT include text before or after the JSON.

                    FINAL CHECK BEFORE RESPONDING:
                    - Validate the JSON syntax.
                    - Remove any trailing commas.
                    - Ensure all brackets and quotes are properly closed.
                    - If the JSON is invalid, fix it silently and return ONLY the corrected JSON.
                    
                    """,
    agent=unit_architect,
    output_file="outputs/unit_generation.json",
    llm=the_one_llm

)



# user_prompt = input("Enter what you want to learn about: ").strip()
# inputs = {
#         "topic": user_prompt
# }

def create_course_generation_crew() -> Crew:
    """Factory to build the course generation crew with both agents."""
    return Crew(
        agents=[topic_extractor, unit_architect],
        tasks=[topic_extraction_task, unit_generation_task],
        **crew_limits()
    )


def _task_output_to_dict(task_output: TaskOutput) -> Dict[str, Any]:
    if task_output.json_dict:
        return task_output.json_dict
    if task_output.pydantic:
        return task_output.pydantic.model_dump()
    parsed = extract_json_dict(task_output.raw)
    if parsed:
        logger.warning("Course crew: recovered JSON from raw output after format violation")
        return parsed
    return {"raw": task_output.raw}


def run_course_generation(user_prompt: str) -> tuple[Dict[str, Any], Dict[str, Any]]:
    """Execute the course crew and return topic+unit structures."""
    logger.info("Course crew: building agents for prompt snippet=%r", user_prompt[:60])
    crew = create_course_generation_crew()
    inputs = {"topic": user_prompt.strip()}
    logger.info("Course crew: kicking off tasks")
    result = crew.kickoff(inputs=inputs)

    if len(result.tasks_output) < 2:
        logger.error("Course crew: expected 2 outputs but received %s", len(result.tasks_output))
        raise ValueError("Course generation expected two task outputs.")

    topic_output = _task_output_to_dict(result.tasks_output[0])
    units_output = _task_output_to_dict(result.tasks_output[1])
    logger.info(
        "Course crew: topic extracted (teachability=%s) and %s units generated",
        topic_output.get("teachability"),
        len(units_output.get("units", [])),
    )
    return topic_output, units_output


# if __name__ == "__main__":
#     prompt = input("Enter what you want to learn about: ").strip()
#     topic_payload, units_payload = run_course_generation(prompt)
#     print(json.dumps({"topic": topic_payload, "units": units_payload}, indent=2, ensure_ascii=False))
