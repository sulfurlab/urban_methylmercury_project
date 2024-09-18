import pandas as pd 
from sklearn.linear_model import Lasso
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

# Read the data
file_path = 'data.csv'  # Replace with your data file path
data = pd.read_csv(file_path)

# Select numerical columns for analysis (exclude categorical data)
numeric_data = data[['km', 'hgcA', 'MeHg_THg', 'MeHg', 'Hg', 'Nitrite', 'Nitrate', 'Ammonium', 'DOC', 'Sulfate']]

# Prepare the data
X = numeric_data.drop(columns=['km'])  # Input features (remove the target variable 'km')
y = numeric_data['km']  # Target variable 'km'

# Data standardization (Lasso is sensitive to the scale of input data)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Initialize the Lasso regression model with a proper regularization parameter (alpha)
lasso_model = Lasso(alpha=0.01)

# Train the model
lasso_model.fit(X_scaled, y)

# Get feature coefficients
lasso_coefficients = lasso_model.coef_

# Create a dataframe to display feature importance
lasso_df = pd.DataFrame({
    'Feature': X.columns,
    'Coefficient': lasso_coefficients
}).sort_values(by='Coefficient', ascending=False)

# Print the result
print(lasso_df)
