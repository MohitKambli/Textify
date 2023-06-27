from flask import Flask, request
import pytesseract
from PIL import Image

def fetch_text(image) :
	pytesseract.pytesseract.tesseract_cmd = r'https://www.pythonanywhere.com/api/v0/user/MohitKambli/files/path/home/MohitKambli/mysite/Tesseract-OCR/tesseract.exe'
	return pytesseract.image_to_string(image)

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def get_image():
    image = request.files["image"]
    print(image)
    text = fetch_text(Image.open(image))
    print(text)
    return text

if __name__ == '__main__':
    app.run(port=7010)