import os
from flask import Flask, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

app = Flask(__name__)

# Connection parameters from Environment Variables
db_user = os.environ.get("DB_USER", "postgres")
db_pass = os.environ.get("DB_PASSWORD") # Injected from Secret Manager
db_name = os.environ.get("DB_NAME", "app_db")
db_host = os.environ.get("DB_HOST") # Private IP of Cloud SQL

# Construct Connection URI
# Format: postgresql+pg8000://user:pass@host:port/name
app.config['SQLALCHEMY_DATABASE_URI'] = f"postgresql+pg8000://{db_user}:{db_pass}@{db_host}:5432/{db_name}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

@app.route('/health')
def health_check():
    try:
        # Simple query to verify DB connectivity
        db.session.execute(text('SELECT 1'))
        return jsonify({"status": "healthy", "database": "connected"}), 200
    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 500

@app.route('/api/data')
def get_data():
    # Example logic to fetch from a hypothetical table
    return jsonify({"message": "Successfully connected to Private Cloud SQL!"})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host='0.0.0.0', port=port)