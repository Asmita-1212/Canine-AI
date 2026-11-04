
import joblib
import pandas as pd

from pathlib import Path


# Project paths
BASE_DIR = Path(__file__).resolve().parent

MODEL_PATH = BASE_DIR / "models" / "calibrated_random_forest.joblib"
FEATURE_PATH = BASE_DIR / "models" / "feature_columns.joblib"


class CanineDiseasePredictor:

    def __init__(self):

        # Load the existing trained model
        self.model = joblib.load(MODEL_PATH)

        # Load the original 77 feature columns
        self.feature_columns = joblib.load(FEATURE_PATH)

        # Original multi-value dataset columns
        self.multi_columns = [
            "main_problem",
            "body_area",
            "hair_loss_pattern",
            "skin_look"
        ]

        # Original single-value dataset columns
        self.single_columns = [
            "itch_level",
            "smell",
            "coat_feel",
            "ears",
            "paw_licking",
            "fleas",
            "onset",
            "spread",
            "others_affected",
            "general_health",
            "age_group",
            "season"
        ]

        self.all_columns = (
            self.multi_columns + self.single_columns
        )

    def preprocess(self, answers):

        # Create one row with all original input fields
        row = {}

        for column in self.all_columns:

            value = answers.get(column)

            # Missing or unanswered information
            if value is None or value == () or value == "":
                row[column] = "not_recorded"

            # Multi-value questions
            elif column in self.multi_columns:

                if isinstance(value, (list, tuple, set)):
                    row[column] = "|".join(map(str, value))
                else:
                    row[column] = str(value)

            else:
                row[column] = str(value)

        input_df = pd.DataFrame([row])

        # Encode multi-value fields
        encoded_parts = []

        for column in self.multi_columns:

            encoded = (
                input_df[column]
                .str.get_dummies(sep="|")
                .add_prefix(column + "_")
            )

            encoded_parts.append(encoded)

        # Encode single-value categorical fields
        single_encoded = pd.get_dummies(
            input_df[self.single_columns],
            columns=self.single_columns
        )

        encoded_parts.append(single_encoded)

        # Combine encoded features
        final_df = pd.concat(
            encoded_parts,
            axis=1
        )

        # Match the exact training feature structure
        final_df = final_df.reindex(
            columns=self.feature_columns,
            fill_value=0
        )

        return final_df

    
    def predict(self, answers):

        # Preprocess questionnaire answers
        input_data = self.preprocess(answers)

        # Predict disease
        prediction = self.model.predict(input_data)[0]

        # Get probability scores
        probabilities = self.model.predict_proba(input_data)[0]

        # Find confidence of the predicted disease
        predicted_index = list(self.model.classes_).index(prediction)

        confidence = round(
            float(probabilities[predicted_index]) * 100,
            2
        )

        return {
            "predicted_disease": prediction,
            "confidence": confidence,
            "message": "AI-generated prediction. Veterinary confirmation is recommended."
        }


# Create reusable predictor instance
predictor = CanineDiseasePredictor()


def predict_disease(answers):

    return predictor.predict(answers)
