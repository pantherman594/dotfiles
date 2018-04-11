#!/usr/bin/python3
import face_recognition
import cv2
import numpy
import os
import subprocess
import signal
import time
import calendar

should_train = False

# switch to face directory
os.chdir(os.path.expanduser("~"))
if not os.path.exists('.known_faces'):
    os.makedirs('.known_faces')
    should_train = True
os.chdir(".known_faces")

# Get a reference to webcam #0 (the default one)
video_capture = cv2.VideoCapture(0)

known_face_encodings = []
known_face_names = []
num_known_faces = 0

# 0.3 seems to catch me most of the time, and nobody else
threshold = 0.3
# if within train_threshold below threshold, train the image
train_threshold = 0.075

# threshold for testing picture similarity, if face is not found
similarity_threshold = 170000000

def calculateDistance(i1, i2):
    return numpy.sum((i1-i2)**2)

def train(frame):
    name = "./face_" + str(int(time.time())) + ".jpg"
    rgb_frame = frame[:, :, ::-1]
    face_locations = face_recognition.face_locations(rgb_frame)
    if len(face_locations) == 1:
        cv2.imwrite(name, frame)
        return name
    return ""

def load(image, name):
    global known_face_encodings, num_known_faces

    if name == "":
        return

    encodings = face_recognition.face_encodings(image)
    if len(encodings) != 1:
        os.remove(name)
        return
    encoding = encodings[0]

    known_face_encodings.append(encoding)
    known_face_names.append(name)
    num_known_faces += 1

    while num_known_faces > 100:
        ret, frame = video_capture.read()
        rgb_frame = frame[:, :, ::-1]
        face_locations = face_recognition.face_locations(rgb_frame)
        if len(face_locations) != 1:
            return
        face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)

        highest_distance = 0
        highest_distance_face = 0
        for face_encoding in face_encodings:
            distances = face_recognition.face_distance(known_face_encodings, face_encoding)

            for i, distance in enumerate(distances):
                if distance > highest_distance:
                    highest_distance = distance
                    highest_distance_face = i
        known_face_encodings.pop(highest_distance_face)
        os.remove(known_face_names.pop(highest_distance_face))
        num_known_faces -= 1


# Load all known faces if not in training mode
if not should_train:
    print("Loading faces...")
    for image_file in os.listdir('.'):
        if image_file[-4:] != ".jpg":
            continue
        image = face_recognition.load_image_file("./" + image_file)
        load(image, "./" + image_file)
    if num_known_faces == 0:
        print("No faces found.")
        should_train = True
    else:
        print("Ready.")

no_match_count = 0
frame_index = 0

last_known_appearance = None

while True:
    # Grab a single frame of video
    ret, frame = video_capture.read()

    # Resize frame of video to 1/4 size for faster face recognition processing
    #small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)

    # Convert the image from BGR color (which OpenCV uses) to RGB color (which face_recognition uses)
    rgb_frame = frame[:, :, ::-1]

    if should_train:
        print("Training...")
        load(rgb_frame, train(frame))
        should_train = False
        print("Ready.")
        continue

    # Only process every 30th frame of video to save time
    if frame_index == 0:
        monitor_off = subprocess.run("xset q | grep -q 'Monitor is Off'", shell=True).returncode == 0

        if monitor_off:
            video_capture.release()
            while monitor_off:
                time.sleep(1)
                monitor_off = subprocess.run("xset q | grep -q 'Monitor is Off'", shell=True).returncode == 0
            video_capture = cv2.VideoCapture(0)
            continue

        # Find all the faces and face encodings in the current frame of video
        face_locations = face_recognition.face_locations(rgb_frame)
        face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)

        match = False
        face = False
        for face_encoding in face_encodings:
            face = True
            total_distance = 0
            # See if the face is a match for the known face(s)
            distances = face_recognition.face_distance(known_face_encodings, face_encoding)

            for distance in distances:
                total_distance += distance

            avg_distance = total_distance / num_known_faces
            print('f' + str((threshold - avg_distance) / threshold))

            if avg_distance < threshold:
                match = True
                if avg_distance > threshold - train_threshold:
                    load(rgb_frame, train(frame))
                else:
                    last_known_appearance = rgb_frame
                break
        
        if (not face or no_match_count > 7) and not last_known_appearance is None:
            distance += calculateDistance(rgb_frame, last_known_appearance)
            print('s' + str((similarity_threshold - distance) / similarity_threshold))
            if distance < similarity_threshold:
                match = True

        if match:
            no_match_count = 0
            if face:
                p = subprocess.Popen(["ps", "-A", "-o", "pid,etime,comm"], stdout=subprocess.PIPE)
                out,err = p.communicate()
                for line in out.decode("utf-8").splitlines():
                    if 'i3lock' in line:
                        data = line.split(None, 3)
                        etime = data[1].split(':')
                        if len(etime) > 2 or int(etime[0]) > 0 or int(etime[1]) > 1:
                            os.kill(int(data[0]), signal.SIGTERM)
        else:
            no_match_count += 1
            print(no_match_count)

    frame_index = (frame_index + 1) % 30

    if no_match_count == 10:
        subprocess.run(["bash", "../.scripts/lock_actual.sh"])
        no_match_count += 1

    # Hit 'q' on the keyboard to quit!
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release handle to the webcam
video_capture.release()
