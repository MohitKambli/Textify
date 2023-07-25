from flask import Flask, request
from flask_cors import CORS
import pytesseract
from PIL import Image

app = Flask(__name__)
CORS(app)

def fetch_text(image) :
	return pytesseract.image_to_string(image)

@app.route('/process', methods=['POST'])
def get_image():
    image = request.files["image"]
    print('Image (I am here): ', image)
    text = fetch_text(Image.open(image))
    print('Text: ', text)
    return text

if __name__ == '__main__':
    app.run(port=7020)
