from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import MinMaxScaler
import numpy as np
import pyodbc
import traceback

app = Flask(__name__)
# Enhanced CORS configuration
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

# Load room + apartment data from your SQL Server
def load_room_data():
    try:
        conn = pyodbc.connect(
            'DRIVER={SQL SERVER};'
            'SERVER=.;'
            'DATABASE=StudentHousing.App;'
            'Trusted_Connection=yes;'
        )
        query = '''
        SELECT 
            A.Id, A.Title, A.Address, A.Gender, A.Space, A.Description, 
            A.PriceMonthly AS Price, R.TotalBeds AS No_Beds, A.Images AS Image1,
            A.UniversityName
        FROM Apartments A
        JOIN Rooms R ON A.Id = R.ApartmentId
        '''
        df = pd.read_sql(query, conn)
        conn.close()
        return df
    except Exception as e:
        print("❌ Error loading room data:")
        traceback.print_exc()
        return pd.DataFrame()

# ✅ Return available universities
@app.route('/universities', methods=['GET'])
def get_universities():
    try:
        room_data = load_room_data()
        if room_data.empty:
            return jsonify({"error": "No data available"}), 500
        universities = sorted(room_data['UniversityName'].dropna().unique())
        return jsonify(universities)
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

# ✅ Recommend best-matching rooms
@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        data = request.get_json()
        print("📥 Received request:", data)

        min_price = data.get("min_price", 0)
        max_price = data.get("max_price", float('inf'))
        gender = data.get("gender", "Any")
        room_size = data.get("room_size", 1)
        university = data.get("university", "").strip().lower()

        room_data = load_room_data()
        if room_data.empty:
            return jsonify({"error": "No room data available"}), 500

        # 🔹 Filter by selected university
        if university:
            room_data = room_data[room_data['UniversityName'].str.lower().str.contains(university)]

        # 🔹 Filter strictly by gender
        if gender.lower() in ['male', 'female']:
            room_data = room_data[room_data['Gender'].str.lower() == gender.lower()]

        # 🔹 Filter by price range
        filtered = room_data[
            (room_data['Price'] >= min_price - 2000) &
            (room_data['Price'] <= max_price + 2000)
        ].copy()

        if filtered.empty:
            return jsonify([])

        # 🔹 Encode gender
        def encode_gender(g): return 1 if g.lower() == "female" else 0
        filtered['Gender_Num'] = filtered['Gender'].apply(encode_gender)

        # 🔹 Scale and compute similarity
        features = filtered[['Price', 'No_Beds', 'Gender_Num']]
        scaler = MinMaxScaler()
        features_scaled = scaler.fit_transform(features)

        user_gender = encode_gender(gender)
        user_vector = np.array([[ (min_price + max_price) / 2, int(room_size), user_gender ]])
        user_vector_scaled = scaler.transform(user_vector)

        similarities = cosine_similarity(user_vector_scaled, features_scaled)[0]
        filtered['similarity'] = similarities

        # 🔹 Drop duplicate apartments
        filtered = filtered.drop_duplicates(subset=['Title', 'Address'])

        # 🔹 Sort by similarity
        top_rooms = filtered.sort_values(by='similarity', ascending=False).head(5).copy()
        top_rooms['match_percent'] = (top_rooms['similarity'].rank(ascending=False, method='first') / 5 * 100).astype(int)

        result = top_rooms[[
            'Id', 'Title', 'UniversityName', 'Price', 'Gender',
            'No_Beds', 'Address', 'Description', 'Image1', 'match_percent'
        ]].to_dict(orient='records')

        return jsonify(result)

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Fixed host and port configuration
    app.run(host='0.0.0.0', port=5000, debug=True)