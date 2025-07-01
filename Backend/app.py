from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image

# Load model
model = tf.keras.models.load_model("Backend/model/model_keras.h5")

# Class labels (as list)
classes = [
    "Apple___Apple_scab", "Apple___Black_rot", "Apple___Cedar_apple_rust", "Apple___healthy",
    "Cherry_(including_sour)___healthy", "Cherry_(including_sour)___Powdery_mildew",
    "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot", "Corn_(maize)___Common_rust_",
    "Corn_(maize)___healthy", "Corn_(maize)___Northern_Leaf_Blight", "Grape___Black_rot",
    "Grape___Esca_(Black_Measles)", "Grape___healthy", "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
    "Peach___Bacterial_spot", "Peach___healthy", "Pepper,_bell___Bacterial_spot", "Pepper,_bell___healthy",
    "Potato___Early_blight", "Potato___healthy", "Potato___Late_blight", "Strawberry___healthy",
    "Tomato___Bacterial_spot", "Tomato___Early_blight", "Tomato___healthy", "Tomato___Late_blight",
    "Tomato___Leaf_Mold", "Tomato___Septoria_leaf_spot", "Tomato___Spider_mites Two-spotted_spider_mite",
    "Tomato___Target_Spot", "Tomato___Tomato_mosaic_virus", "Tomato___Tomato_Yellow_Leaf_Curl_Virus"
]

app = Flask(__name__)

@app.route("/")
def index():
    return " Server is running! Use /predict to POST images."

@app.route("/predict", methods=["POST"])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    # Preprocess image
    image = Image.open(request.files['file']).convert('RGB')
    image = image.resize((300, 300))
    image_np = np.array(image) 
    image_np = np.expand_dims(image_np, axis=0)

    # Predict
    predictions = model.predict(image_np)[0]
    predicted_index = int(np.argmax(predictions))
    confidence = float(np.max(predictions))

    return jsonify({
        "class": classes[predicted_index],
        "confidence": round(confidence, 4)
    })

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
