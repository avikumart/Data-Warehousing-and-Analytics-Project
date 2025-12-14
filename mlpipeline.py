import numpy as np
from sklearn.model_selection import StratifiedKFold, cross_val_score
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from xgboost import XGBClassifier
from imblearn.over_sampling import SMOTE
from imblearn.pipeline import Pipeline as ImbPipeline
from sklearn.metrics import accuracy_score, recall_score, f1_score, roc_auc_score
import pandas as pd

# --- Feature Definitions ---
CONTINUOUS_FEATURES = [
    'age', 'bmi', 'daily_steps', 'sleep_hours', 'water_intake_l', 
    'calories_consumed', 'resting_hr', 'systolic_bp', 'diastolic_bp', 'cholesterol', 'family_history', 'smoker', 'alcohol'
]
CATEGORICAL_FEATURES = ['gender']
RANDOM_STATE = 42

def create_preprocessor() -> ColumnTransformer:
    """
    Creates a ColumnTransformer for data preprocessing (scaling and encoding).
    """
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', StandardScaler(), CONTINUOUS_FEATURES), # Scale numerical features
            ('cat', OneHotEncoder(drop='if_binary', handle_unknown='ignore'), CATEGORICAL_FEATURES) # Encode gender
        ],
        remainder='passthrough'
    )
    return preprocessor

def get_models() -> dict:
    """
    Returns a dictionary of un-pipelined models.
    """
    models = {
        "Logistic Regression": LogisticRegression(max_iter=1000, random_state=RANDOM_STATE),
        "Random Forest": RandomForestClassifier(random_state=RANDOM_STATE),
        "XGBoost": XGBClassifier(random_state=RANDOM_STATE, eval_metric='logloss', use_label_encoder=False),
        "SVC": SVC(random_state=RANDOM_STATE, probability=True),
    }
    return models

def create_pipeline(model_name: str, model, preprocessor: ColumnTransformer) -> ImbPipeline:
    """
    Creates an imbalanced-learn pipeline for a given model, including preprocessing
    and SMOTE for oversampling.
    """
    smote = SMOTE(random_state=RANDOM_STATE)
    
    # Order: Preprocess -> SMOTE (on train set only) -> Model
    pipeline = ImbPipeline(steps=[
        ('preprocessor', preprocessor),
        ('smote', smote),
        ('classifier', model)
    ])
    return pipeline

def get_metrics(y_true: pd.Series, y_pred: np.ndarray, y_prob: np.ndarray) -> dict:
    """
    Calculates and returns standard classification metrics.
    """
    return {
        "Accuracy": accuracy_score(y_true, y_pred),
        "Recall": recall_score(y_true, y_pred),
        "F1 Score": f1_score(y_true, y_pred),
        "ROC AUC": roc_auc_score(y_true, y_prob),
    }

def get_feature_importances(pipeline: ImbPipeline, model_name: str) -> pd.DataFrame:
    """
    Extracts and formats feature importance/coefficients for a fitted model.
    """
    classifier = pipeline.named_steps['classifier']
    preprocessor = pipeline.named_steps['preprocessor']
    
    # Get the feature names from the preprocessor's transformers
    feature_names = CONTINUOUS_FEATURES + list(preprocessor.transformers_[1][1].get_feature_names_out(CATEGORICAL_FEATURES))
    
    if model_name == "Logistic Regression":
        coefficients = classifier.coef_[0]
        feature_importance_df = pd.DataFrame({'Feature': feature_names, 'Coefficient': coefficients})
        feature_importance_df['Importance'] = feature_importance_df['Coefficient'].abs()
        
    elif model_name in ["Random Forest", "XGBoost"]:
        importances = classifier.feature_importances_
        feature_importance_df = pd.DataFrame({'Feature': feature_names, 'Importance': importances})
        
    elif model_name == "SVC":
        # SVC coefficients are not easily interpretable as importance, so we return an empty frame
        # for a direct comparison table, as per the original notebook's intent.
        feature_importance_df = pd.DataFrame()
        
    else:
        feature_importance_df = pd.DataFrame()

    if not feature_importance_df.empty:
        feature_importance_df = feature_importance_df.sort_values(by='Importance', ascending=False)
        
    return feature_importance_df