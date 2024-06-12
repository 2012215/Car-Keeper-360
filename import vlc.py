import cv2
import numpy as np
from PIL import Image
import os
import time
import base64
from flask import Flask, request, jsonify, make_response, send_file, Response
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

recognizer = cv2.face.LBPHFaceRecognizer_create()
recognizer.read('trainer.yml')
cascadePath = 'haarcascade_frontalface_default.xml'
faceCascade = cv2.CascadeClassifier(cascadePath)
names = ['None','Anas','Fauji']
cam = cv2.VideoCapture(0)
cam.set(3, 640)  # set video width
cam.set(4, 480)

@app.route('/capture_image', methods=['POST'])
def capture_image():
    data = request.get_json()
    user_id = data.get('userId')

    if not user_id:
        return make_response(jsonify({'message': 'Missing user ID'}), 400)

    user_directory = f"dataset/User.{user_id}"
    if not os.path.exists(user_directory):
        os.makedirs(user_directory)

    print(f"\n Initializing face capture for User ID: {user_id}")
    count = 0

    cam = cv2.VideoCapture(0)
    cam.set(3, 640)
    cam.set(4, 480)

    if not cam.isOpened():
        print("Error: Could not open the camera.")
        return make_response(jsonify({'message': 'Could not open the camera'}), 500)

    try:
        while count < 30:
            ret, img = cam.read()
            if not ret or img is None:
                print("Error: Unable to capture image")
                return make_response(jsonify({'message': 'Unable to capture image'}), 500)

            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            faces = faceCascade.detectMultiScale(gray, 1.3, 5)

            for (x, y, w, h) in faces:
                cv2.rectangle(img, (x, y), (x + w, y + h), (255, 0, 0), 2)
                count += 1
                cv2.imwrite(f"{user_directory}/User.{user_id}.{count}.jpg", gray[y:y+h, x:x+w])
                cv2.imshow('image', img)

            k = cv2.waitKey(100) & 0xff
            if k == 27:  # ESC key to stop
                break

    except cv2.error as e:
        print(f"Error during face capture: {e}")
        return make_response(jsonify({'message': 'An error occurred during image capture'}), 500)

    finally:
        cam.release()
        cv2.destroyAllWindows()

    return jsonify({'message': f'Image capture complete for User ID: {user_id}!'})

@app.route('/train_images', methods=['GET'])
def train_images():
    path = 'dataset'
    recognizer = cv2.face.LBPHFaceRecognizer_create()
    detector = cv2.CascadeClassifier("haarcascade_frontalface_default.xml")

    def getImagesAndLabels(path):
        imagePaths = []
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith("jpg"):
                    imagePaths.append(os.path.join(root, file))
        
        faceSamples = []
        ids = []
        for imagePath in imagePaths:
            try:
                PIL_img = Image.open(imagePath).convert('L')  # grayscale
                img_numpy = np.array(PIL_img, 'uint8')
                id = int(os.path.split(imagePath)[-1].split(".")[1])
                faces = detector.detectMultiScale(img_numpy)
                for (x, y, w, h) in faces:
                    faceSamples.append(img_numpy[y:y+h, x:x+w])
                    ids.append(id)
            except Exception as e:
                print(f"Error processing image {imagePath}: {e}")
        return faceSamples, ids

    print("\nTraining faces...")
    faces, ids = getImagesAndLabels(path)
    if len(faces) == 0:
        return jsonify({'message': 'No faces found to train.'}), 400
    
    recognizer.train(faces, np.array(ids))
    recognizer.write('trainer.yml')
    print(f"\n{len(np.unique(ids))} faces trained.")
    return jsonify({'message': f'{len(np.unique(ids))} faces trained successfully!'})

@app.route('/process_frame', methods=['POST'])
def process_frame():
    data = request.get_json()
    image_data = base64.b64decode(data['image'])
    np_data = np.frombuffer(image_data, np.uint8)
    frame = cv2.imdecode(np_data, cv2.IMREAD_COLOR)
    
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = faceCascade.detectMultiScale(
        gray,
        scaleFactor=1.2,
        minNeighbors=5,
        minSize=(int(0.1 * frame.shape[1]), int(0.1 * frame.shape[0])),
    )
    
    if len(faces) == 0:
        print("No faces detected.")
    else:
        print(f"Detected {len(faces)} face(s).")
    
    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
        id, confidence = recognizer.predict(gray[y:y + h, x:x + w])
        if confidence < 100:
            id = names[id]
            confidence = f"  {round(100 - confidence)}%"
        else:
            id = "unknown"
            confidence = f"  {round(100 - confidence)}%"

        cv2.putText(frame, str(id), (x + 5, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
        cv2.putText(frame, str(confidence), (x + 5, y + h - 5), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 0), 1)

    _, buffer = cv2.imencode('.jpg', frame)
    frame_base64 = base64.b64encode(buffer).decode('utf-8')
    
    return jsonify({'image': frame_base64})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
