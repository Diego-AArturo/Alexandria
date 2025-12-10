from dotenv import load_dotenv
load_dotenv()
from crewai import Crew, Agent, Task
import json

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
    verbose=False
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
    verbose=False
)

# Agent: Concept_Developer
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
    verbose=False
)

# Agent: Question_Engineer
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
    verbose=False
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
                """,
    agent=topic_extractor,
    output_file="outputs/topic_extraction.json"
    
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
    - Produce between 1 and 3 units total.
    - Each unit_title must be short, descriptive, and conceptual.
    - Each description must be exactly one concise sentence explaining the core idea.
    - Objectives must be simple, action-oriented outcomes strictly aligned to the unit.
    - Maintain clarity, simplicity, and natural phrasing.
    - Adapt tone or language if indicated in additional_context.
    
    """,
    agent=unit_architect,
    output_file="outputs/unit_generation.json"

)

# Task: concept_generation_task
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
    Unit information: {unit}
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
    - Generate between 25 and 40 concepts for the given unit.
    - Each concept is under 50 words.
    - Use short, clear, and natural phrasing.
    - Include a variety of forms (mini-examples, analogies, factual statements, or clarifications).
    - Maintain logical and stylistic consistency with the provided unit’s objectives.
    - Avoid redundant or overly generic phrasing.
    - Language and tone should reflect any preferences found in `additional_context`.
    """,
    agent=concept_developer,
    output_file="outputs/concept_generation.json",
)

# Task: question_generation_task
question_generation_task = Task(
    description="""
    Using as input the learning topic (from topic_extraction_task) and the given {unit} with its
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
        - Include at least 40 questions, and only use the 3 allowed types.
        - Keep stems and explanations under 40 words.
        - For fill_in_blank:
            - The "options" array must list the missing words.
            - The "answer" field must contain the correct words as a single comma-separated string (e.g., "species,breeds").
    """,
    agent=question_engineer,
    output_file="outputs/question_generation.json",
    context=[topic_extraction_task, unit_generation_task]
)


user_prompt = input("Enter what you want to learn about: ").strip()
inputs = {
        "topic": user_prompt
}

# First crew: Generate names
names_crew = Crew(agents=[topic_extractor, unit_architect], tasks=[topic_extraction_task, unit_generation_task])
names_result = names_crew.kickoff(inputs=inputs)


#Parse units into list format
units_json = "C:/Users/Geronimo/Desktop/Voxl/Alex/Alexandria/backend/src/course_generation/outputs/unit_generation.json"

with open(units_json, "r", encoding="utf-8") as f:
    units_data = json.load(f)

#Open topic file
topic_json = "C:/Users/Geronimo/Desktop/Voxl/Alex/Alexandria/backend/src/course_generation/outputs/topic_extraction.json"

with open(topic_json, "r", encoding="utf-8") as f:
    topic_data = json.load(f)

i = 0
unit_list = [
    {
        "unit_title": u["unit_title"],
        "description": u["description"],
        "objectives": u["objectives"],
        "unit_index": i + 1
    }
    for u in units_data["units"]
]

print(unit_list)


inputs_list = [
    {"topic": topic_data, "unit": unit_list[n]} 
    for n in range(len(unit_list))]

# Second crew: Create content and questions
content_crew = Crew(agents=[concept_developer], tasks=[concept_generation_task])
results = content_crew.kickoff_for_each(inputs=inputs_list)