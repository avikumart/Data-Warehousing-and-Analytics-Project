import pandas as pd
import numpy as np
import mlflow
import mlflow.sklearn
from sklearn.model_selection import StratifiedKFold
from sklearn.model_selection import cross_val_score
from mlpipeline import (
    create_preprocessor, get_models, create_pipeline, get_metrics, get_feature_importances, CONTINUOUS_FEATURES
)
from dataloader import load_data, split_data

# --- Configuration ---
DATA_FILE = 'data/health_lifestyle_dataset.csv' # Assuming 'data' is a sibling directory
TARGET_COLUMN = 'disease_risk'
MLFLOW_EXPERIMENT_NAME = "Disease_Risk_Classification_SMOTE"
RANDOM_STATE = 42

def train_and_evaluate_models(
    X_train: pd.DataFrame, 
    X_test: pd.DataFrame, 
    y_train: pd.Series, 
    y_test: pd.Series, 
    preprocessor,
    selected_model_name: str = None
) -> dict:
    """
    Trains and evaluates models using cross-validation and test set metrics,
    logging all results to MLflow. Can be limited to a single selected model.
    """
    all_models = get_models()
    results = {}
    
    # Filter models if a specific one is selected
    if selected_model_name and selected_model_name in all_models:
        models_to_train = {selected_model_name: all_models[selected_model_name]}
        print(f"\nStarting training for selected model: {selected_model_name}...")
    elif selected_model_name:
        print(f"\nError: Model '{selected_model_name}' not found. Training all models.")
        models_to_train = all_models
    else:
        print("\nStarting training for all models...")
        models_to_train = all_models

    # Log parameters common to all runs (outside the model loop)
    mlflow.log_param("test_size", 0.2)
    mlflow.log_param("random_state", RANDOM_STATE)
    mlflow.log_param("resampling_method", "SMOTE")
    mlflow.log_param("numerical_scaling", "StandardScaler")
    mlflow.log_param("categorical_encoding", "OneHotEncoder")
    
    for name, model in models_to_train.items():
        with mlflow.start_run(run_name=name) as run:
            print(f"\n--- {name} ---")
            
            # 1. Setup Pipeline with Preprocessor and SMOTE
            pipeline = create_pipeline(name, model, preprocessor)
            
            # 2. K-Fold Cross-Validation on Training Set
            cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=RANDOM_STATE)
            cv_scores = cross_val_score(pipeline, X_train, y_train, cv=cv, scoring='f1', n_jobs=-1)
            cv_mean_f1 = np.mean(cv_scores)
            print(f"5-Fold CV F1-Score (Train): {cv_mean_f1:.4f}")
            mlflow.log_metric("cv_mean_f1_score", cv_mean_f1)
            
            # 3. Train on full training set
            pipeline.fit(X_train, y_train)
            
            # 4. Predict on Test Set
            y_pred = pipeline.predict(X_test)
            
            # Determine probability for ROC AUC calculation
            if hasattr(pipeline.named_steps['classifier'], "predict_proba"):
                y_prob = pipeline.predict_proba(X_test)[:, 1]
            # SVC is trained with probability=True in model_pipeline.py
            else: 
                y_prob = pipeline.predict_proba(X_test)[:, 1] 

            # 5. Calculate Metrics
            metrics = get_metrics(y_test, y_pred, y_prob)
            results[name] = metrics
            
            for metric_name, value in metrics.items():
                mlflow.log_metric(f"test_{metric_name.lower().replace(' ', '_')}", value)
                print(f"Test {metric_name}: {value:.4f}")

            # 6. Log Model and Feature Importance
            mlflow.sklearn.log_model(pipeline, "model")
            
            importance_df = get_feature_importances(pipeline, name)
            if not importance_df.empty:
                # Log the top 10 feature importances/coefficients
                top_10 = importance_df.head(10).to_string()
                mlflow.log_text(top_10, "feature_importance/top_10_features.txt")
                
    return results

def compare_results(results: dict):
    """
    Compiles and compares all model results, identifying the best model by Recall.
    """
    results_df = pd.DataFrame(results).T
    print("\nFinal Model Comparison:")
    print(results_df)

    # Identify best model based on Recall (Sensitivity)
    best_model = results_df['Recall'].idxmax()
    print(f"\nBased on Recall (Sensitivity), the best model is: {best_model}")
    mlflow.log_text(f"Best model based on Recall: {best_model}", "model_comparison/best_model.txt")
    
    # Log the final comparison table
    mlflow.log_text(results_df.to_string(), "model_comparison/all_metrics.txt")


if __name__ == '__main__':
    # --- MLflow Setup ---
    mlflow.set_experiment(MLFLOW_EXPERIMENT_NAME)
    
    # --- User Configuration ---
    # To run only a specific model, change 'None' to one of the model names:
    # "Logistic Regression", "Random Forest", "XGBoost", or "SVC"
    MODEL_TO_RUN = "Logistic Regression" 
    # MODEL_TO_RUN = None # To run all models (default)
    
    try:
        # 1. Load Data
        df = load_data(DATA_FILE)
        if df.empty:
            raise RuntimeError("Data loading failed.")
            
        # 2. Split Data
        X_train, X_test, y_train, y_test = split_data(df, TARGET_COLUMN)
        
        # 3. Create Preprocessor
        preprocessor = create_preprocessor()
        
        # 4. Train and Evaluate only the selected model (or all if None)
        all_results = train_and_evaluate_models(
            X_train, X_test, y_train, y_test, preprocessor, selected_model_name=MODEL_TO_RUN
        )

        # 5. Final Comparison (Logged in a final, separate run for overview)
        # This summary run will only include results from the model(s) that were trained.
        if all_results:
            with mlflow.start_run(run_name="Comparison_Summary", nested=True):
                 compare_results(all_results)
        else:
            print("No models were successfully trained or evaluated.")
             
    except Exception as e:
        print(f"An error occurred: {e}")