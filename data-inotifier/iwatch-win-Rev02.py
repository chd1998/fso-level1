import sys
import time
import logging
from watchdog.observers import Observer
from watchdog.events import LoggingEventHandler
import fire

def pysync(syncSrc,syncDest):
    logging.basicConfig(level=logging.INFO,format='%(asctime)s - %(message)s',datefmt='%Y-%m-%d %H:%M:%S')
    event_handler = LoggingEventHandler()
    observer = Observer()
    observer.schedule(event_handler, syncSrc, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

if __name__ == '__main__':
    fire.Fire(pysync)