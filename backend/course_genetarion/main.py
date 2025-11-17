#!/usr/bin/env python
import sys
import json
from datetime import datetime
from course_genetarion.crew import Alexandria

def run():
    user_prompt = input("Enter what you want to learn about: ").strip()
    inputs = {
        "topic": user_prompt,
    }
    try:
        result = Alexandria().crew().kickoff(inputs=inputs)
        with open("outputs/final_result.json", "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print("\nExecution completed. Results stored in 'outputs/final_result.json'.")
    except Exception as e:
        print(f"An error occurred while running the crew: {e}")

if __name__ == "__main__":
    run()
