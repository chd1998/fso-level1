import numpy as np
import cv2


def change_res(width, height):
    cap.set(3, width)
    cap.set(4, height)


cap = cv2.VideoCapture(0)
change_res(1280, 720)

while (True):
    # Capture frame-by-frame
    ret, frame = cap.read()

    # Our operations on the frame come here
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    # Display the resulting frame

    cv2.imshow('Image from UVC Video --- press q to quit', gray)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# When everything done, release the capture
cap.release()
cv2.destroyAllWindows()
