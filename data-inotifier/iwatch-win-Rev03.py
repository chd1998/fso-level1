import sys
import time
import logging
from watchdog.observers import Observer
from watchdog.events import LoggingEventHandler

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S')
    syncSrc = sys.argv[1] if len(sys.argv) > 1 else '.'
    syncDest = sys.argv[2] if len(sys.argv) > 1 else exit(1)
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