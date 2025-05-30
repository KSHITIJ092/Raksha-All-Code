import React, { useState, useEffect } from 'react';
import './Database.css';
import Video1 from '../assets/Videos/Video_1.mp4';
import Video2 from '../assets/Videos/Video_2.mp4';
import Video3 from '../assets/Videos/Chain_Snatching.mp4';
import Video4 from '../assets/Videos/Video_4.mp4';
import redalert from '../assets/Videos/redalert.mp4';
import Video6 from '../assets/Videos/Video_6.mp4';
import Video7 from '../assets/Videos/Video_7.mp4';
import Video8 from '../assets/Videos/Video_8.mp4';

import alertSoundFile from '../assets/Sounds/alert.mp3';

const Database = () => {
  const videos = [
    { id: 'Andheri', name: 'garam masala', src: Video1 },
    { id: 'juinagar sec 4', name: 'juinagar sec 4', src: Video2 },
    { id: 'turbhe naka', name: 'turbhe naka', src: Video3 },
    { id: 'Vashi Square', name: 'Vashi Square', src: Video4 },
    { id: 'Airoli Sec 2', name: 'Airoli Sec 2', src: redalert },
    { id: 'Nerul', name: 'Nerul Sector 5', src: Video7 },
    { id: 'Ulhasnagar East', name: 'Ulhasnagar East', src: Video6 },
    { id: 'Thane West', name: 'Thane West', src: Video7 },
    { id: 'Belapur North', name: 'Belapur North', src: Video8 },
  ];

  const [searchQuery, setSearchQuery] = useState('');
  const [borderColor, setBorderColor] = useState({});
  const [isAlertShown, setIsAlertShown] = useState(false);

  const playAlertSound = () => {
    const alertSound = new Audio(alertSoundFile);
    alertSound.play(); // Start playing immediately
    setTimeout(() => {
      alertSound.pause(); // Stop playing after 5 seconds
      alertSound.currentTime = 0; // Reset to the beginning
    }, 5000); // 5000ms = 5 seconds
  };

  const updateBorderColor = (videoId) => {
    const colorSequence = [
      { color: 'green', duration: 5000 },
      { color: 'lightyellow', duration: 10000 },
      { color: 'orange', duration: 3000 },
      { color: 'red', duration: 3000 },
    ];

    let colorIndex = 0;
    const interval = setInterval(() => {
      setBorderColor((prev) => ({
        ...prev,
        [videoId]: colorSequence[colorIndex].color,
      }));

      // Only trigger sound and alert if red border is for 'Airoli Sec 2'
      if (colorSequence[colorIndex].color === 'red' && videoId === 'Airoli Sec 2' && !isAlertShown) {
        setIsAlertShown(true);

        // Play the alert sound immediately
        playAlertSound();

        // Use setTimeout to show the alert after the sound has started playing
        setTimeout(() => {
          alert(`${videoId} - Red Alert Detected!`);
        }, 100); // Slight delay to ensure sound plays first
      }

      // Move to the next color
      colorIndex++;
      if (colorIndex >= colorSequence.length) {
        clearInterval(interval); // Clear interval after the last color
      }
    }, 6000); // Update color every 6000ms (6 seconds)
  };

  useEffect(() => {
    updateBorderColor('Airoli Sec 2');
    setBorderColor((prev) => ({
      ...prev,
      'Ulhasnagar East': 'yellow',
      'Nerul': 'orange',
    }));
  }, []);

  const filteredVideos = videos.filter(
    (video) =>
      video.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      video.id.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const isSingleResult = filteredVideos.length === 1;

  return (
    <div>
      <section className="video-section">
        <input
          type="text"
          className="search-box"
          placeholder="Search videos by name or location..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
        <div className={`video-grid ${isSingleResult ? 'centered-video' : ''}`}>
          {filteredVideos.map((video) => (
            <div key={video.id} className="video-card">
              <h3>{video.name}</h3>
              <video
                src={video.src}
                controls
                autoPlay
                muted
                loop
                className="video-element"
                style={{
                  border: `3px solid ${borderColor[video.id] || '#4caf50'}`,
                }}
              />
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};

export default Database;
