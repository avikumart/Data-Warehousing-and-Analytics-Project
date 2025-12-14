import pandas as pd
from sklearn.model_selection import train_test_split

def load_data(file_path: str) -> pd.DataFrame:
    """
    Loads the dataset from a CSV file.
    """
    try:
        df = pd.read_csv(file_path)
    except FileNotFoundError:
        print(f"Error: File not found at {file_path}")
        return pd.DataFrame()

    # Drop 'id' as it carries no predictive value
    if 'id' in df.columns:
        df = df.drop('id', axis=1)
        
    # Remove duplicates (though none were found in the notebook)
    initial_rows = len(df)
    df = df.drop_duplicates()
    print(f"Duplicates removed: {initial_rows - len(df)}")
    
    return df

def split_data(df: pd.DataFrame, target: str, test_size: float = 0.2, random_state: int = 42):
    """
    Splits the data into training and testing sets, stratifying by the target.
    """
    if df.empty:
        raise ValueError("DataFrame is empty. Check data loading.")
        
    X = df.drop(columns=[target])
    y = df[target]

    # Split into Training (80%) and Testing (20%) sets
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_state, stratify=y
    )
    
    return X_train, X_test, y_train, y_test

if __name__ == '__main__':
    # Example usage for testing
    DATA_FILE = '../data/health_lifestyle_dataset.csv' # Adjust path as needed
    TARGET_COLUMN = 'disease_risk'
    
    df = load_data(DATA_FILE)
    if not df.empty:
        X_train, X_test, y_train, y_test = split_data(df, TARGET_COLUMN)
        print(f"X_train shape: {X_train.shape}")
        print(f"X_test shape: {X_test.shape}")
        print(f"Class distribution in y_train:\n{y_train.value_counts(normalize=True)}")