import socket
import cv2
from constants import SERVER_IP, SERVER_PORT

client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()

    if not ret:
        print("Error: failed to capture image")
        break

    frame = cv2.resize(frame, (600, 450))
    frame = cv2.flip(frame, 1)

    cv2.putText(
        frame,
        f"OpenCV version: {cv2.__version__}",
        (5, 15),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.5,
        (255, 255, 255),
        1,
    )

    image = cv2.resize(frame, (600, 450))

    _, encoded_image = cv2.imencode(".jpg", image)

    if len(encoded_image) <= 65507:
        client_socket.sendto(encoded_image, (SERVER_IP, SERVER_PORT))
    else:
        print("Frame too large, skipping")

    cv2.imshow("Image", image)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cv2.destroyAllWindows()

cap.release()
