import React, { useState, useEffect } from 'react';
import './App.css';
import Dashboard from './Pages/dashboard';
import Database from './Pages/database';
import LiveVideoStream from './Pages/livestream';
import SOSAlertPage from './Pages/sos_alert';
import CameraApp from './Pages/image';
import Layout from './Layout';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { io } from 'socket.io-client';
import axios from 'axios';
import Popup from './Popup';
import Surveillance from './Pages/Surveillance';
import CrimeDataVisualization from './Pages/map_analytics';

function App() {
  const [alerts, setAlerts] = useState([]);
  const [showPopup, setShowPopup] = useState(false);
  const [popupMessage, setPopupMessage] = useState('');

  // Function to fetch the place name using Nominatim API
  const fetchPlaceName = async (latitude, longitude) => {
    try {
      const response = await axios.get(
        `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latitude}&lon=${longitude}`
      );
      return response.data?.display_name || 'Unknown Location';
    } catch (error) {
      console.error('Error fetching location:', error);
      return 'Unknown Location';
    }
  };

  useEffect(() => {
    // Connect to the Socket.io server
    const socket = io('http://192.168.93.176:3000');

    socket.on('connect', () => {
      console.log('Connected to the server:', socket.id);
    });

    // Listen for incoming SOS alerts
    socket.on('alert-userDetails', async (data) => {
      console.log('Received alert:', data);

      // Fetch the location name
      const placeName = await fetchPlaceName(data.latitude, data.longitude);
      const alertMessage = `User: ${data.username || 'Unknown'}, Location: ${placeName}`;

      // Update alerts and show the popup
      setAlerts((prevAlerts) => [...prevAlerts, { ...data, placeName }]);
      setPopupMessage(alertMessage);
      setShowPopup(true);

      // Optionally store alerts in local storage
      localStorage.setItem('sosAlerts', JSON.stringify([...alerts, { ...data, placeName }]));
    });

    return () => {
      socket.disconnect(); // Cleanup on component unmount
    };
  }, [alerts]);

  const closePopup = () => {
    setShowPopup(false);
  };

  return (
    <Router>
      <div>
        {/* Global Popup */}
        {showPopup && <Popup message={popupMessage} onClose={closePopup} />}

        {/* Main Routes */}
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<Dashboard />} />
            <Route path="database" element={<Database />} />
            <Route path="live" element={<LiveVideoStream />} />
            <Route path="emergency-alerts" element={<SOSAlertPage />} />
            <Route path="img" element={<CameraApp />} />
            <Route path="emergency-services" element={<Surveillance />} />
            <Route path="map" element={<CrimeDataVisualization />} />
          </Route>
        </Routes>
      </div>
    </Router>
  );
}

export default App;
