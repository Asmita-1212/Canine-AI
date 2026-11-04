
# CanineAI - Expanded Adaptive Question Bank
# 20 candidate prompts mapped to 16 existing model fields.

QUESTIONS = [

    # -------------------------------------------------
    # 1. CORE QUESTIONS
    # -------------------------------------------------

    {
        "id": "main_problem",
        "model_field": "main_problem",
        "category": "core",
        "text": "What skin problems have you noticed in your dog?",
        "multi": True,
        "options": [
            ("itching", "Itching or scratching"),
            ("hair_loss", "Hair loss"),
            ("bumps_pus", "Bumps or pus"),
            ("smell_greasy", "Bad smell or greasy skin"),
            ("wet_sore", "Wet or open sores"),
            ("flaky_crusty", "Flaky or crusty skin")
        ]
    },

    {
        "id": "itch_level",
        "model_field": "itch_level",
        "category": "core",
        "text": "How severe is your dog's itching?",
        "multi": False,
        "ask_if": ("main_problem", ["itching"]),
        "options": [
            ("none", "No itching"),
            ("mild", "Mild"),
            ("moderate", "Moderate"),
            ("severe", "Severe")
        ]
    },

    {
        "id": "body_area",
        "model_field": "body_area",
        "category": "core",
        "text": "Which parts of your dog's body are affected?",
        "multi": True,
        "options": [
            ("face", "Face"),
            ("ears", "Ears"),
            ("paws", "Paws"),
            ("belly_groin", "Belly or groin"),
            ("back_tail_base", "Back or tail base"),
            ("legs", "Legs"),
            ("neck", "Neck"),
            ("whole_body", "Whole body")
        ]
    },

    {
        "id": "hair_loss_pattern",
        "model_field": "hair_loss_pattern",
        "category": "core",
        "text": "What does the hair loss look like?",
        "multi": True,
        "ask_if": ("main_problem", ["hair_loss"]),
        "options": [
            ("none", "No hair loss"),
            ("round_patches", "Round patches"),
            ("patchy_irregular", "Irregular patches"),
            ("around_eyes_face", "Around eyes or face"),
            ("all_over_thinning", "General thinning")
        ]
    },

    {
        "id": "skin_look",
        "model_field": "skin_look",
        "category": "core",
        "text": "How does the affected skin look?",
        "multi": True,
        "options": [
            ("normal", "Normal"),
            ("red", "Red or inflamed"),
            ("red_bumps_pus", "Red bumps or pus"),
            ("dry_scaly", "Dry or scaly"),
            ("crusty_scabby", "Crusty or scabby"),
            ("dark_thick", "Dark or thickened"),
            ("wet_oozing", "Wet or oozing")
        ]
    },

    # -------------------------------------------------
    # 2. CONDITIONAL QUESTIONS
    # -------------------------------------------------

    {
        "id": "fleas",
        "model_field": "fleas",
        "category": "conditional",
        "text": "Have you noticed fleas on your dog?",
        "multi": False,
        "ask_if": ("main_problem", ["itching"]),
        "options": [
            ("no", "No"),
            ("yes", "Yes")
        ]
    },

    {
        "id": "paw_licking",
        "model_field": "paw_licking",
        "category": "conditional",
        "text": "Does your dog frequently lick or chew its paws?",
        "multi": False,
        "ask_if": ("main_problem", ["itching"]),
        "options": [
            ("no", "No"),
            ("sometimes", "Sometimes"),
            ("constantly", "Constantly")
        ]
    },

    {
        "id": "ears",
        "model_field": "ears",
        "category": "conditional",
        "text": "Have you noticed any problems with your dog's ears?",
        "multi": False,
        "ask_if": ("main_problem", ["itching"]),
        "options": [
            ("normal", "Normal"),
            ("red_itchy", "Red or itchy"),
            ("smelly_discharge", "Bad smell or discharge")
        ]
    },

    {
        "id": "smell",
        "model_field": "smell",
        "category": "conditional",
        "text": "Is there an unusual smell from the skin?",
        "multi": False,
        "ask_if": ("main_problem", ["smell_greasy", "bumps_pus", "wet_sore"]),
        "options": [
            ("none", "No unusual smell"),
            ("mild", "Mild smell"),
            ("strong_musty", "Strong or musty smell")
        ]
    },

    {
        "id": "spread",
        "model_field": "spread",
        "category": "conditional",
        "text": "Is the affected skin area spreading?",
        "multi": False,
        "ask_if": ("main_problem", ["bumps_pus", "wet_sore", "hair_loss"]),
        "options": [
            ("no", "No"),
            ("slowly", "Slowly"),
            ("fast", "Rapidly")
        ]
    },

    # -------------------------------------------------
    # 3. SUPPORTING QUESTIONS
    # -------------------------------------------------

    {
        "id": "onset",
        "model_field": "onset",
        "category": "supporting",
        "text": "When did the skin problem start?",
        "multi": False,
        "options": [
            ("sudden_days", "Suddenly, within a few days"),
            ("gradual_weeks", "Gradually, over a few weeks"),
            ("months_recurring", "Several months ago or recurring")
        ]
    },

    {
        "id": "others_affected",
        "model_field": "others_affected",
        "category": "supporting",
        "text": "Are other pets or people experiencing similar symptoms?",
        "multi": False,
        "options": [
            ("no", "No"),
            ("other_pets", "Other pets"),
            ("humans", "Humans"),
            ("both", "Both pets and humans")
        ]
    },

    {
        "id": "general_health",
        "model_field": "general_health",
        "category": "safety",
        "text": "How is your dog's general health?",
        "multi": False,
        "options": [
            ("normal", "Normal and active"),
            ("tired_or_off_food", "Tired, weak or eating less")
        ]
    },

    {
        "id": "coat_feel",
        "model_field": "coat_feel",
        "category": "supporting",
        "text": "How does your dog's coat feel?",
        "multi": False,
        "options": [
            ("normal", "Normal"),
            ("greasy", "Greasy or oily"),
            ("dry_flaky", "Dry or flaky")
        ]
    },

    {
        "id": "age_group",
        "model_field": "age_group",
        "category": "supporting",
        "text": "What is your dog's age group?",
        "multi": False,
        "options": [
            ("puppy", "Puppy"),
            ("adult", "Adult"),
            ("senior", "Senior")
        ]
    },

    {
        "id": "season",
        "model_field": "season",
        "category": "supporting",
        "text": "During which season are the symptoms most noticeable?",
        "multi": False,
        "options": [
            ("summer_monsoon", "Summer or monsoon"),
            ("winter", "Winter"),
            ("all_year", "Throughout the year")
        ]
    },

    # -------------------------------------------------
    # 4. ALTERNATIVE QUESTION PROMPTS
    # These map to existing model fields.
    # The engine must not ask both versions.
    # -------------------------------------------------

    {
        "id": "skin_look_detail",
        "model_field": "skin_look",
        "variant_of": "skin_look",
        "category": "clarification",
        "text": "Can you describe the visible changes on your dog's skin?",
        "multi": True,
        "options": [
            ("normal", "No visible changes"),
            ("red", "Redness"),
            ("red_bumps_pus", "Raised bumps or pus"),
            ("dry_scaly", "Dry or scaly patches"),
            ("crusty_scabby", "Crusts or scabs"),
            ("dark_thick", "Dark or thickened skin"),
            ("wet_oozing", "Moist or oozing areas")
        ]
    },

    {
        "id": "hair_loss_detail",
        "model_field": "hair_loss_pattern",
        "variant_of": "hair_loss_pattern",
        "category": "clarification",
        "text": "How is the hair loss distributed across your dog's body?",
        "multi": True,
        "ask_if": ("main_problem", ["hair_loss"]),
        "options": [
            ("none", "No hair loss"),
            ("round_patches", "Circular bald patches"),
            ("patchy_irregular", "Uneven bald patches"),
            ("around_eyes_face", "Mostly around the face or eyes"),
            ("all_over_thinning", "Thinning across the body")
        ]
    },

    {
        "id": "body_area_detail",
        "model_field": "body_area",
        "variant_of": "body_area",
        "category": "clarification",
        "text": "Where did you first notice the skin problem?",
        "multi": True,
        "options": [
            ("face", "Face"),
            ("ears", "Ears"),
            ("paws", "Paws"),
            ("belly_groin", "Belly or groin"),
            ("back_tail_base", "Back or tail base"),
            ("legs", "Legs"),
            ("neck", "Neck"),
            ("whole_body", "Whole body")
        ]
    },

    {
        "id": "itch_level_detail",
        "model_field": "itch_level",
        "variant_of": "itch_level",
        "category": "clarification",
        "text": "How often does your dog scratch or rub its skin?",
        "multi": False,
        "ask_if": ("main_problem", ["itching"]),
        "options": [
            ("none", "Never"),
            ("mild", "Occasionally"),
            ("moderate", "Frequently"),
            ("severe", "Almost constantly")
        ]
    }
]


# -------------------------------------------------
# QUESTION BANK UTILITIES
# -------------------------------------------------

BY_ID = {q["id"]: q for q in QUESTIONS}

QID = [q["id"] for q in QUESTIONS]

MODEL_FIELDS = list(dict.fromkeys(
    q["model_field"] for q in QUESTIONS
))

def selected(question_id, answer):

    if answer is None:
        return set()

    if isinstance(answer, (list, tuple, set)):
        return set(answer)

    return {answer}


def clean_answer(question_id, raw_answer):

    question = BY_ID[question_id]
    valid_values = {
        value for value, label in question["options"]
    }

    if raw_answer is None:
        return None

    if question["multi"]:

        if isinstance(raw_answer, str):
            raw_answer = [
                item.strip() for item in raw_answer.split(",")
            ]

        if not isinstance(raw_answer, (list, tuple, set)):
            raise ValueError("Please provide multiple-choice answers.")

        cleaned = tuple(dict.fromkeys(raw_answer))

        if not cleaned:
            raise ValueError("Please select at least one answer.")

        if not set(cleaned).issubset(valid_values):
            raise ValueError("Invalid option selected.")

        return cleaned

    if isinstance(raw_answer, (list, tuple, set)):
        raise ValueError("Please select only one answer.")

    if raw_answer not in valid_values:
        raise ValueError("Invalid option selected.")

    return raw_answer


# Check which questions are alternative versions
def get_model_question_groups():

    groups = {}

    for question in QUESTIONS:
        field = question["model_field"]
        groups.setdefault(field, []).append(question["id"])

    return groups
