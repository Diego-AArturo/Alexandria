from dotenv import load_dotenv
from crewai import Crew, Agent, Task
import json

from pydantic import BaseModel
from typing import List, Literal, Optional

from llm_config import build_gemini_llm

load_dotenv()

the_one_llm = build_gemini_llm()

class QuestionModel(BaseModel):
    type: Literal["multiple_choice", "true_false", "fill_in_blank"]
    stem: str
    options: Optional[List[str]] = None      # only for multiple_choice or fill_in_blank
    answer: str                               # for fill_in_blank: comma-separated words
    explanation_correct: str
    explanation_incorrect: str


class QuestionOutputModel(BaseModel):
    unit_title: str
    questions: List[QuestionModel]


question_engineer = Agent(
    role=       """AI Educational Question Designer""",

    goal=       """Generate a set of inquiry-driven, feedback-rich questions 
                for each unit that reinforce understanding through interaction and curiosity.
                """,

    backstory=  """
                You are a master of active learning. You design smart, accessible questions that 
                challenge learners just enough to keep them engaged while ensuring they always understand why 
                something is right or wrong. You blend pedagogy, clarity, and motivation — every question feels 
                like a friendly mini-challenge that teaches by doing.
                """,
    verbose=False,
    llm=the_one_llm
)


question_generation_task = Task(
    description="""
    Topic information: {topic}
    Unit information: {unit_data}
    
    Using both the topic information and unit information with its
    description and objectives, generate a complete set of
    short, pedagogically sound questions presented in microlearning format.
    Questions must be simple, mobile-friendly, concept-focused, and aligned with the unit’s objectives.
    Use only the three allowed question types:
    - multiple_choice
    - true_false
    - fill_in_blank
    Each question must reinforce understanding through immediate explanatory feedback.
    Follow the learner’s language preferences, tone, and user_level as indicated in additional_context.
    """,
    expected_output="""
        Return ONLY valid JSON in the following structure:

        {
          "unit_title": "string",
          "questions": [
            {
              "type": "multiple_choice | true_false | fill_in_blank",
              "stem": "short question text",
              "options": ["A", "B", "C", ...],   // only for multiple_choice or fill_in_blank
              "answer": "string",                // for fill_in_blank: comma-separated correct words
              "explanation_correct": "string",
              "explanation_incorrect": "string"
            }
          ]
        }
        STRICT RULES:
        - Output must ALWAYS start with { "units": [...] } as the root.
        - Each unit must contain:
            - unit_title
            - questions (array)
        - Each question may only contain the keys:
            - type
            - stem
            - options (only for multiple_choice or fill_in_blank)
            - answer
            - explanation_correct
            - explanation_incorrect
        - NO other keys are allowed (no id, no difficulty, no snippet, no metadata).
        - Include at least 30 questions, and only use the 3 allowed types.
        - Keep stems and explanations under 40 words.
        - For fill_in_blank:
            - The "options" array must list the missing words.
            - The "answer" field must contain the correct words as a single comma-separated string (e.g., "species,breeds").
    """,
    agent=question_engineer,
    output_file="outputs/question_generation_{item_name}.json",
    output_json=QuestionOutputModel,
    llm=the_one_llm
)




#Parse units into list format
units_json = "outputs/unit_generation.json"

with open(units_json, "r", encoding="utf-8") as f:
    units_data = json.load(f)

#Open topic file
topic_json = "outputs/topic_extraction.json"

with open(topic_json, "r", encoding="utf-8") as f:
    topic_data = json.load(f)





units_list = units_data["units"]

input_list = []

for i, unit in enumerate(units_list):
    input_list.append({
        "item_name": f"unit_{i+1}",
        "topic": topic_data["learning_topic"],
        "unit_data": unit
    })

# Second crew: Create questions
content_crew = Crew(agents=[question_engineer], tasks=[question_generation_task])
results = content_crew.kickoff_for_each(inputs=input_list)

print(input_list)
