from dotenv import load_dotenv
from crewai import Crew, Agent, Task
import json

from pydantic import BaseModel
from typing import List

from llm_config import build_gemini_llm

load_dotenv()

the_one_llm = build_gemini_llm()

class UnitModel(BaseModel):
    unit_title: str
    concepts: List[str]

class ConceptOutputModel(BaseModel):
    units: List[UnitModel]

concept_developer = Agent(
    role="""AI Concept and Example Generator""",

    goal="""
            For each unit, produce a rich set of short, engaging “concepts” — factual reminders, analogies, 
            micro-explanations, and examples that bring the unit’s objectives to life.
            """,

    backstory="""
            You are a creative educator who knows how to explain things simply. You turn abstract ideas into 
            relatable insights and connect with learners using friendly language. Your micro-lessons are like 
            conversations — short, motivating, and full of vivid examples that make complex topics easy to remember.
            """,
    
    verbose=False,
    llm=the_one_llm
)


concept_generation_task = Task(
    description="""
        
    Using as input the learning topic and unit with its description and objectives listed above, generate a set of
    short, engaging, and pedagogically sound “concepts.” Each concept should provide
    a clear micro-explanation, factual reminder, relatable example, or analogy that
    helps the learner understand or recall the key ideas of that unit.
    Ensure all content stays strictly within the conceptual scope of the provided
    topic and unit. Keep tone friendly, motivational, and accessible to
    Beginner to Intermediate learners. Use simple, conversational language and avoid
    unnecessary technicalities or references to setup steps, installations, or tools.
    Concepts should feel like quick teaching moments suitable for mobile microlearning.

    Topic information: {topic}
    Unit information: {unit_data}
    """,
    expected_output="""
        Return ONLY valid JSON with the following structure:
    {
      "units": [
      {
       "unit_title": "string",
       "concepts": ["string", "string", ...]
       },
      {
       "unit_title": "string",
       "concepts": ["string", "string", ...]
       }
       ]
    }

    Requirements:
    - Generate between 30 and 40 concepts for the given unit.
    - Each concept is under 50 words.
    - Use short, clear, and natural phrasing.
    - Include a variety of forms (mini-examples, analogies, factual statements, or clarifications).
    - Maintain logical and stylistic consistency with the provided unit’s objectives.
    - Avoid redundant or overly generic phrasing.
    - Language and tone should reflect any preferences found in `additional_context`.
    """,
    agent=concept_developer,
    output_json=ConceptOutputModel,
    output_file="outputs/concept_generation_{item_name}.json",
)



def pretty_print_json(data):
    print(json.dumps(data, indent=4, sort_keys=True))


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

# Second crew: Create content and questions
content_crew = Crew(agents=[concept_developer], tasks=[concept_generation_task], verbose=True)
results = content_crew.kickoff_for_each(inputs=input_list)

print(input_list)
