import React, { useEffect, useState } from "react";
import io from "socket.io-client";

const CameraApp = () => {
  const [image, setImage] = useState(null);  // State to store the received image
  const [socket, setSocket] = useState(null); // Socket state

  useEffect(() => {
    // Connect to the Socket.io server
    const socketConnection = io("http://192.168.93.176:3000");  // Replace with your server IP

    setSocket(socketConnection);

    // Listen for the receiveImage event
    socketConnection.on("receiveImage", (data) => {
      const { image } = data;
      setImage(`data:image/jpeg;base64,${image}`);  // Assuming the image is sent in base64 format
    });

    return () => {
      socketConnection.disconnect();  // Clean up socket connection on component unmount
    };
  }, []);

  const handleCapture = () => {
    // This is just a placeholder for the actual image capturing logic
    const capturedImage = ""; // You should capture the image in Base64 format here
    const imageName = "captured_image.jpg";  // Example image name

    // Emit the image to the server
    if (socket) {
      socket.emit("sendImage", { image: capturedImage, name: imageName });
    }
  };

  return (
    <div>
      <h1>React Camera App</h1>
      <button onClick={handleCapture}>Capture & Send Image</button>

      <h3>Received Image:</h3>
      {image ? (
        <img src={image} alt="Received" style={{ width: "300px", height: "auto" }} />
      ) : (
        <p>No proof received yet.</p>
      )}
    </div>
  );
};

export default CameraApp;
