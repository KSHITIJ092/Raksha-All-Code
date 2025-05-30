import React, { useEffect, useState } from "react";
import { io } from "socket.io-client"; // Import the io function
import "./dashboard.css";
import Video1 from "../assets/Videos/Video_1.mp4";
import Video2 from "../assets/Videos/Video_2.mp4";
import Video4 from "../assets/Videos/Video_4.mp4";
import Video6 from "../assets/Videos/Video_6.mp4";
import Video7 from "../assets/Videos/Video_7.mp4";
import Video8 from "../assets/Videos/Video_8.mp4";
import Video9 from "../assets/Videos/redalert.mp4";

const socket = io("http://192.168.93.176:3000");

const Dashboard = () => {
  const [activeFrames, setActiveFrames] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [matungaCases, setMatungaCases] = useState(99);
  const [zonesData, setZonesData] = useState([
    { id: "Video_1", location: "Kurla", Rate: "( 120 cases / year )", color: "Red" },
    { id: "Video_2", location: "Andheri", Rate: "( 102 cases / year )", color: "Red" },
    { id: "Video_4", location: "King Circle", Rate: "( 100 cases / year )", color: "Red" },
    { id: "Video_6", location: "Mulund", Rate: "( 30 cases / year )", color: "Yellow" },
    { id: "Video_7", location: "Parel", Rate: "( 30 cases / year )", color: "Yellow" },
    { id: "Video_8", location: "Sion", Rate: "( 29 cases / year )", color: "Yellow" },
    { id: "Video_9", location: "Airoli Sec-2" },
    { id: "Video_1", location: "Ghatkopar", Rate: "( 80 cases / year )", color: "Orange" },
    { id: "Video_8", location: "Dadar", Rate: "( 70 cases / year )", color: "Orange" },
    { id: "Video_7", location: "Worli", Rate: "( 20 cases / year )", color: "Yellow" },
    { id: "Video_8", location: "Bandra", Rate: "( 50 cases / year )", color: "Orange" },
    { id: "Video_2", location: "Matunga", Rate: "( 98 cases / year )", color: "Orange" },
  ]);

  useEffect(() => {
    const handleAlert = (data) => {
      setMatungaCases((prevCount) => prevCount + 1); // Increment Matunga cases
    };

    socket.on("alert-userDetails", handleAlert);

    return () => {
      socket.off("alert-userDetails", handleAlert); // Clean up listener
    };
  }, []);

  useEffect(() => {
    // Update Matunga's zone dynamically
    setZonesData((prevZones) =>
      prevZones.map((zone) => {
        if (zone.location === "Matunga") {
          if (matungaCases >= 101) {
            return {
              ...zone,
              Rate: `( ${matungaCases} cases / year )`,
              color: "Red",
            };
          } else {
            return {
              ...zone,
              Rate: `( ${matungaCases} cases / year )`,
              color: "Orange",
            };
          }
        }
        return zone;
      })
    );
  }, [matungaCases]);

  const videoPaths = {
    Video_1: Video1,
    Video_2: Video2,
    Video_4: Video4,
    Video_6: Video6,
    Video_7: Video7,
    Video_8: Video8,
    Video_9: Video9,
  };

  const actions = ["Detected", "Not Detected"];
  const alertTypes = ["Red", "Orange", "Yellow"];
  const weapons = ["Rope", "Knife", "Gun", "Firearm", "Sharp Object"];
  const gestures = ["Pushing", "Beating", "Assault", "Running", "Snatching Chain"];
  const counts = [1, 2, 3];

  const getRandomElement = (arr) => arr[Math.floor(Math.random() * arr.length)];

  const filteredZones = zonesData.filter((zone) =>
    zone.location.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const redZones = filteredZones.filter((zone) => zone.color === "Red");
  const orangeZones = filteredZones.filter((zone) => zone.color === "Orange");
  const yellowZones = filteredZones.filter((zone) => zone.color === "Yellow");

  const handleVideoSelect = (zone) => {
    if (activeFrames.find((frame) => frame.id === zone.id)) return; // Prevent duplicates

    const randomizedDetails = {
      actionType: getRandomElement(actions),
      alertType: getRandomElement(alertTypes),
      weapon: getRandomElement(weapons),
      gesture: getRandomElement(gestures),
      count: getRandomElement(counts),
    };

    setActiveFrames((prevFrames) => [...prevFrames, { ...zone, ...randomizedDetails }]);
  };

  return (
    <div className="dashboard-container">
      <div className="column-layout">

        {/* Hotspot Zones Section */}
        <section className="hotspot-zones">
          <h2>Hotspot Zones</h2>
          <input
            type="text"
            placeholder="Search zones..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="search-bar"
          />
          <table className="hotspot-table">
            <thead>
              <tr>
                <th style={{ backgroundColor: "#FF0000", color: "#fff" }}>
                  Red Zones {redZones.length}
                </th>
                <th style={{ backgroundColor: "#FFA500", color: "#fff" }}>
                  Orange Zones {orangeZones.length}
                </th>
                <th style={{ backgroundColor: "#FFFF00", color: "#000" }}>
                  Yellow Zones {yellowZones.length}
                </th>
                <th style={{ backgroundColor: "#D3D3D3", color: "#000" }}>
                  All Frames {redZones.length + orangeZones.length + yellowZones.length}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                {/* Red Zones */}
                <td>
                  <div className="zone-list">
                    {redZones.map((zone) => (
                      <div
                        key={zone.id}
                        className="zone-item"
                        onClick={() => handleVideoSelect(zone)}
                      >
                        {zone.location + " " + zone.Rate}
                      </div>
                    ))}
                  </div>
                </td>
                {/* Orange Zones */}
                <td>
                  <div className="zone-list">
                    {orangeZones.map((zone) => (
                      <div
                        key={zone.id}
                        className="zone-item"
                        onClick={() => handleVideoSelect(zone)}
                      >
                        {zone.location + " " + zone.Rate}
                      </div>
                    ))}
                  </div>
                </td>
                {/* Yellow Zones */}
                <td>
                  <div className="zone-list">
                    {yellowZones.map((zone) => (
                      <div
                        key={zone.id}
                        className="zone-item"
                        onClick={() => handleVideoSelect(zone)}
                      >
                        {zone.location + " " + zone.Rate}
                      </div>
                    ))}
                  </div>
                </td>
                {/* All Frames */}
                <td>
                  <div className="zone-list">
                    {filteredZones.map((zone) => (
                      <div
                        key={zone.id}
                        className="zone-item all-frame-item"
                        onClick={() => handleVideoSelect(zone)}
                      >
                        {zone.location + " " + zone.Rate}
                      </div>
                    ))}
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </section>

        {/* Active Attacks Section */}
        <section className="camera-feed">
          <h2>Active Attacks</h2>
          <div className="frames-grid">
            {activeFrames.map((frame) => (
              <div
                key={frame.id}
                className="frame-item"
                style={{
                  border: "5px solid",
                  position: "relative",
                }}
              >
                {/* Static Details Overlay */}
                <div className="details-overlay">
                  <div className="detail">Area Name: {frame.location}</div>
                  <div className="detail">Unusual Activity: {frame.actionType}</div>
                  <div className="detail">Alert Type: {frame.alertType}</div>
                  <div className="detail">Weapon Detected: {frame.weapon}</div>
                  <div className="detail">Gesture: {frame.gesture}</div>
                  <div className="detail">Count: {frame.count}</div>
                </div>
                <video
                  src={videoPaths[frame.id]}
                  autoPlay
                  loop
                  muted
                  className="frame-video"
                />
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
};

export default Dashboard;
