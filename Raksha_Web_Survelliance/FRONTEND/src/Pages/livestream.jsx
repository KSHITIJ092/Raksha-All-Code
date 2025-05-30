import React, { useEffect, useRef } from 'react';
import io from 'socket.io-client';

const LiveVideoStream = () => {
  const videoRefs = useRef({}); // To hold references to video elements
  const mediaSources = useRef({}); // To store MediaSource objects for each camera
  const sourceBuffers = useRef({}); // To store SourceBuffer objects for each camera
  const queues = useRef({}); // To queue video data for each camera

  useEffect(() => {
    // Initialize the socket connection
    const socket = io('http://localhost:3000');
    const cameras=['camera1', 'camera2'];
    cameras.forEach((cameraId) => {
      // Create video element for each camera
      const video = document.createElement("video");
      video.id = `stream-${cameraId}`;
      video.autoplay = true;
      video.controls = true;
      document.getElementById("streams").appendChild(video);
  
      // Store video reference
      videoRefs.current[cameraId] = video;
  
      // Create a new MediaSource for each camera
      const mediaSource = new MediaSource();
      mediaSources.current[cameraId] = mediaSource;
      queues.current[cameraId] = [];
  
      // Set video source to MediaSource URL
      video.src = URL.createObjectURL(mediaSource);
  
      // Initialize the MediaSource and handle the 'sourceopen' event
      mediaSource.addEventListener("sourceopen", () => {
        console.log(`MediaSource opened for ${cameraId}`);
        const mimeType = 'video/webm; codecs="vp9"'; // Use vp9 codec
  
        if (MediaSource.isTypeSupported(mimeType)) {
          const sourceBuffer = mediaSource.addSourceBuffer(mimeType);
          sourceBuffers.current[cameraId] = sourceBuffer;
  
          // Handle the 'updateend' event for appending video data
          sourceBuffer.addEventListener("updateend", () => {
            if (
              queues.current[cameraId].length > 0 &&
              !sourceBuffer.updating
            ) {
              const nextChunk = queues.current[cameraId].shift();
              try {
                sourceBuffer.appendBuffer(nextChunk);
              } catch (err) {
                console.error(
                  `Error appending buffer for ${cameraId} in updateend:`,
                  err
                );
              }
            }
          });
        } else {
          console.error(`MIME type ${mimeType} is not supported.`);
        }
      });
    });
  
    // Listen for video chunks from the server
    cameras.forEach((cameraId) => {
      socket.on(`display-stream-${cameraId}`, (data) => {
        if (data instanceof ArrayBuffer) {
          const mediaSource = mediaSources.current[cameraId];
          const sourceBuffer = sourceBuffers.current[cameraId];
  
          if (mediaSource && mediaSource.readyState === "open" && sourceBuffer) {
            try {
              if (!sourceBuffer.updating) {
                sourceBuffer.appendBuffer(data);
              } else {
                queues.current[cameraId].push(data);
              }
            } catch (err) {
              console.error(`Error appending buffer for ${cameraId}:`, err);
            }
          } else {
            console.warn(
              `MediaSource or SourceBuffer is not available for ${cameraId}. Data will be dropped.`
            );
          }
        } else {
          console.error(`Invalid data received for ${cameraId}`);
        }
      });
    });
  
    return () => {
      socket.disconnect();
      // Cleanup created videos and MediaSources
      cameras.forEach((cameraId) => {
        if (videoRefs.current[cameraId]) {
          videoRefs.current[cameraId].remove();
          delete videoRefs.current[cameraId];
        }
        if (mediaSources.current[cameraId]) {
          try {
            if (sourceBuffers.current[cameraId]) {
              mediaSources.current[cameraId].removeSourceBuffer(
                sourceBuffers.current[cameraId]
              );
              delete sourceBuffers.current[cameraId];
            }
            mediaSources.current[cameraId].endOfStream();
          } catch (err) {
            console.error(`Error cleaning up MediaSource for ${cameraId}:`, err);
          }
          delete mediaSources.current[cameraId];
        }
      });
    };
  }, []);
  
  return (
    <div>
      <h1>Live Video Streams</h1>
      <div id="streams"></div>
    </div>
  );

};

export default LiveVideoStream;