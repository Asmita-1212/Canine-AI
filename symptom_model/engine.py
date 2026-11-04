
from question_bank_v2 import (
    QUESTIONS,
    BY_ID,
    QID,
    selected,
    clean_answer
)


class QuestionnaireEngine:

    def __init__(self, max_questions=10):

        if max_questions < 1:
            raise ValueError("max_questions must be at least 1")

        self.answers = {}
        self.asked_questions = []
        self.max_questions = max_questions

    # Check whether a question's conditions are satisfied
    def is_allowed(self, question_id):

        question = BY_ID[question_id]
        condition = question.get("ask_if")

        if not condition:
            return True

        dependent_question, allowed_values = condition

        if dependent_question not in self.answers:
            return False

        previous_answer = self.answers[dependent_question]

        if previous_answer is None:
            return False

        previous_values = selected(
            dependent_question,
            previous_answer
        )

        return bool(previous_values.intersection(allowed_values))

    # Prevent duplicate questions for the same model field
    def already_covered(self, question_id):

        model_field = BY_ID[question_id]["model_field"]

        for asked_id in self.asked_questions:

            asked_field = BY_ID[asked_id]["model_field"]

            if model_field == asked_field:
                return True

        return False

    # Get eligible questions
    def remaining_questions(self):

        remaining = []

        for question_id in QID:

            if question_id in self.asked_questions:
                continue

            if self.already_covered(question_id):
                continue

            if not self.is_allowed(question_id):
                continue

            remaining.append(question_id)

        return remaining

    # Assign priority to candidate questions
    def question_score(self, question_id):

        question = BY_ID[question_id]
        model_field = question["model_field"]

        first_answer = self.answers.get("main_problem")

        symptoms = (
            selected("main_problem", first_answer)
            if first_answer is not None
            else set()
        )

        priorities = {
            "main_problem": 100,
            "skin_look": 95,
            "hair_loss_pattern": 80,
            "body_area": 75,
            "itch_level": 70,
            "others_affected": 55,
            "onset": 50,
            "spread": 45,
            "coat_feel": 40,
            "paw_licking": 40,
            "smell": 40,
            "ears": 35,
            "fleas": 30,
            "age_group": 30,
            "season": 25,
            "general_health": 20
        }

        score = priorities.get(model_field, 10)

        # Symptom-based question priorities
        if model_field == "itch_level" and "itching" in symptoms:
            score += 40

        if model_field == "hair_loss_pattern" and "hair_loss" in symptoms:
            score += 50

        if model_field == "paw_licking" and "itching" in symptoms:
            score += 35

        if model_field == "fleas" and "itching" in symptoms:
            score += 30

        if model_field == "ears" and "itching" in symptoms:
            score += 25

        if model_field == "spread" and symptoms.intersection(
            {"bumps_pus", "wet_sore", "hair_loss"}
        ):
            score += 35

        if model_field == "smell" and symptoms.intersection(
            {"smell_greasy", "bumps_pus", "wet_sore"}
        ):
            score += 35

        # Give safety question high priority
        if (
            model_field == "general_health"
            and len(self.asked_questions) >= 3
        ):
            score += 1000

        # Select alternative wording when relevant
        if question_id == "hair_loss_detail" and "hair_loss" in symptoms:
            score += 25

        if question_id == "skin_look_detail" and symptoms.intersection(
            {"bumps_pus", "wet_sore", "flaky_crusty"}
        ):
            score += 20

        if question_id == "itch_level_detail" and "itching" in symptoms:
            score += 20

        return score

    # Select the next question dynamically
    def next_question(self):

        if len(self.asked_questions) >= self.max_questions:
            return None

        remaining = self.remaining_questions()

        if not remaining:
            return None

        if not self.asked_questions:
            return "main_problem"

        return max(
            remaining,
            key=self.question_score
        )

    # Validate and store an answer
    def submit_answer(self, question_id, raw_answer):

        if question_id not in BY_ID:
            raise ValueError("Invalid question ID")

        expected_question = self.next_question()

        if expected_question is None:
            raise ValueError("Questionnaire is already completed")

        if question_id != expected_question:
            raise ValueError(
                f"Expected question: {expected_question}"
            )

        cleaned = clean_answer(question_id, raw_answer)

        self.answers[question_id] = cleaned
        self.asked_questions.append(question_id)

        return self.next_question()

    # Get question details
    def get_question(self, question_id):

        if question_id is None:
            return None

        return BY_ID[question_id]

    # Return collected answers
    def get_answers(self):

        return self.answers.copy()

    # Convert answers to original model input fields
    def get_model_answers(self):

        model_answers = {}

        for question_id, answer in self.answers.items():

            model_field = BY_ID[question_id]["model_field"]

            model_answers[model_field] = answer

        return model_answers

    # Check completion
    def is_completed(self):

        return self.next_question() is None

    # Reset session
    def reset(self):

        self.answers = {}
        self.asked_questions = []
