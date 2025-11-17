from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task
from crewai.agents.agent_builder.base_agent import BaseAgent
from typing import List

@CrewBase
class Alexandria():
    agents: List[BaseAgent]
    tasks: List[Task]

    @agent
    def topic_extractor(self) -> Agent:
        return Agent(config=self.agents_config['Topic_Extractor'], verbose=True)

    @agent
    def unit_architect(self) -> Agent:
        return Agent(config=self.agents_config['Unit_Architect'], verbose=True)

    @agent
    def concept_developer(self) -> Agent:
        return Agent(config=self.agents_config['Concept_Developer'], verbose=True)

    @agent
    def question_engineer(self) -> Agent:
        return Agent(config=self.agents_config['Question_Engineer'], verbose=True)

    @task
    def topic_extraction_task(self) -> Task:
        return Task(config=self.tasks_config['topic_extraction_task'], output_file='outputs/topic_extraction.json')

    @task
    def unit_generation_task(self) -> Task:
        return Task(config=self.tasks_config['unit_generation_task'], output_file='outputs/unit_generation.json')

    @task
    def concept_generation_task(self) -> Task:
        return Task(config=self.tasks_config['concept_generation_task'], output_file='outputs/concept_generation.json')

    @task
    def question_generation_task(self) -> Task:
        return Task(config=self.tasks_config['question_generation_task'], output_file='outputs/question_generation.json')

    @crew
    def crew(self) -> Crew:
        return Crew(
            agents=self.agents,
            tasks=self.tasks,
            process=Process.sequential,
            verbose=True
        )
