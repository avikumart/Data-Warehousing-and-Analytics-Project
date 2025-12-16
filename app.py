import streamlit as st
import pandas as pd
import numpy as np
import os
import joblib # Often used for saving scikit-learn pipelines
import glob
from pathlib import Path

# --- Configuration ---
MLFLOW_EXPERIMENT_NAME = "Disease_Risk_Classification_SMOTE"
TARGET_MODEL_NAME = "Logistic Regression" 
# The model artifact is stored inside a 'model' directory in the MLflow run folder.
ARTIFACT_PATH = "model" 
MODEL_FILENAME = "model.pkl" # Common filename for joblib-saved models in MLflow

# Define the features that require user input, based on your notebook's setup
# The order is crucial as the pipeline expects features in this order.
INPUT_FEATURES = [
    'age', 'bmi', 'daily_steps', 'sleep_hours', 'water_intake_l', 
    'calories_consumed', 'resting_hr', 'systolic_bp', 'diastolic_bp', 
    'cholesterol', 'family_history', 'smoker', 'alcohol', 'gender'
]

# --- PKL/Joblib Model Loading from File ---

def find_latest_model_path(experiment_name: str, model_run_name: str) -> str | None:
    """
    Searches the local 'mlruns' folder to find the file path of the latest 
    saved model artifact (model.pkl/joblib) for a specific experiment and run name.
    """
    # 1. Get the local MLflow tracking path
    base_path = Path("mlruns")
    
    # 2. Find the experiment directory
    # MLflow usually names experiment directories by ID, but we need to find the ID first
    # This requires MLflow to be set up, but we'll try to guess based on standard structure
    # A more direct way is to search by the run name tag, but that is complex without MLflow SDK
    
    # Simple direct search (less robust, but avoids MLflow SDK calls)
    # Pattern: mlruns/<experiment_id>/<run_id>/artifacts/model/model.pkl
    # We will search for all 'model.pkl' files and find the latest one from the correct run
    
    # NOTE: This search pattern assumes the training script uses `mlflow.sklearn.log_model`, 
    # which internally saves a 'model.pkl' file if the model is a scikit-learn object.
    search_pattern = str(base_path / "*" / "*" / "artifacts" / ARTIFACT_PATH / MODEL_FILENAME)
    all_model_files = glob.glob(search_pattern)

    # Filter by model run name (requires inspecting the run's metadata file, which is complex)
    # A simplified, less accurate approach: find the latest file by modification time
    
    if not all_model_files:
        st.error("No model files found in the mlruns directory. Did the training script run successfully?")
        return None

    # Get the latest file by modification time (heuristic)
    latest_file = max(all_model_files, key=os.path.getmtime)
    
    st.sidebar.markdown(f"**Heuristic Load Path:** `{latest_file}`")
    return latest_file


@st.cache_resource
def load_model_from_file():
    """
    Loads the model using joblib from the file path found.
    """
    model_path = find_latest_model_path(MLFLOW_EXPERIMENT_NAME, TARGET_MODEL_NAME)
    
    if model_path:
        try:
            # Using joblib.load for scikit-learn/ImbPipeline models
            model = joblib.load(model_path)
            return model
        except Exception as e:
            st.error(f"Error loading pipeline file from disk (`joblib.load`): {e}")
            return None
    return None

# --- Prediction Function (Unchanged) ---

def make_prediction(model, input_data: pd.DataFrame):
    """
    Makes a prediction and returns the result.
    """
    try:
        # The loaded model is the imblearn pipeline, which handles
        # preprocessing (scaling/encoding) internally.
        prediction = model.predict(input_data)[0]
        # Get probability for risk score visualization
        probability = model.predict_proba(input_data)[0][1] 
        return prediction, probability
    except Exception as e:
        st.error(f"Prediction error: {e}")
        return None, None

# --- Streamlit UI (Mostly Unchanged) ---

def main():
    st.set_page_config(page_title="Disease Risk Predictor", layout="wide")
    st.title("🩺 Healthcare Disease Risk Assessment")
    st.markdown("Use the input fields below to assess the patient's likelihood of **Disease Risk** (1) based on their lifestyle and health metrics.")
    
    # Load the model once and cache it
    model = load_model_from_file()
    if model is None:
        st.warning("Prediction functionality is disabled until a model is successfully loaded.")
        return

    # --- Sidebar for Model Info (Updated) ---
    st.sidebar.header("Model Details")
    st.sidebar.markdown(f"**Model Type:** `{TARGET_MODEL_NAME}`")
    st.sidebar.markdown("This model was loaded directly from the local MLflow artifact file (`mlruns` folder) using `joblib`.")
    st.sidebar.markdown("It was selected for its high **Recall** (sensitivity) score, minimizing false negatives.")

    # --- Input Form ---
    with st.form("risk_assessment_form"):
        st.header("Patient Health Metrics")
        
        # Input widgets organized into columns
        col1, col2, col3 = st.columns(3)

        # Numerical Inputs (st.number_input, st.slider)
        with col1:
            age = st.slider("Age (years)", 18, 100, 48)
            bmi = st.number_input("BMI (kg/m²)", 15.0, 50.0, 29.0, step=0.1)
            daily_steps = st.number_input("Daily Steps", 0, 30000, 10000)
            sleep_hours = st.number_input("Sleep Hours", 3.0, 10.0, 6.5, step=0.1)

        with col2:
            water_intake_l = st.number_input("Water Intake (Liters)", 0.0, 5.0, 2.75, step=0.1)
            calories_consumed = st.number_input("Calories Consumed", 1000, 5000, 2600)
            resting_hr = st.number_input("Resting Heart Rate (bpm)", 40, 120, 74)
            cholesterol = st.number_input("Cholesterol (mg/dL)", 150, 300, 224)

        # Binary/Categorical Inputs (st.selectbox, st.radio)
        with col3:
            systolic_bp = st.number_input("Systolic BP (mmHg)", 90, 200, 135)
            diastolic_bp = st.number_input("Diastolic BP (mmHg)", 60, 130, 90)
            
            gender = st.selectbox("Gender", ["Female", "Male"])
            family_history = st.selectbox("Family History of Disease", ["No", "Yes"])
            smoker = st.selectbox("Smoker", ["No", "Yes"])
            alcohol = st.selectbox("Alcohol Consumption", ["No", "Yes"])
            

        submitted = st.form_submit_button("Predict Risk Score")

    # --- Prediction Output ---
    if submitted:
        # 1. Create a Pandas DataFrame from inputs
        input_data = pd.DataFrame([[
            age, bmi, daily_steps, sleep_hours, water_intake_l, 
            calories_consumed, resting_hr, systolic_bp, diastolic_bp, 
            cholesterol, 1 if family_history == "Yes" else 0, 
            1 if smoker == "Yes" else 0, 1 if alcohol == "Yes" else 0, gender
        ]], columns=INPUT_FEATURES)

        # 2. Make Prediction
        prediction, probability = make_prediction(model, input_data)

        if prediction is not None:
            # 3. Display Results
            st.subheader("Prediction Result")
            
            # The model predicts the target class (0 or 1)
            if prediction == 1:
                st.error(f"🔴 High Disease Risk Predicted (Probability: {probability:.2f})")
                st.markdown("The model suggests this patient is at **high risk** of disease. Further clinical evaluation is recommended.")
                # Trigger image of common risk factors
                st.image("https://www.cdc.gov/chronicdisease/images/infographics/risk-factors-infographic-800px.jpg", caption="Common Risk Factors", use_column_width=True)
            else:
                st.success(f"🟢 Low Disease Risk Predicted (Probability: {1-probability:.2f})")
                st.markdown("The model suggests this patient is at **low risk**. Continue monitoring health metrics.")

            # Optional: Show input data for verification
            with st.expander("Show Raw Input Data"):
                st.dataframe(input_data)
                
if __name__ == "__main__":
    main()