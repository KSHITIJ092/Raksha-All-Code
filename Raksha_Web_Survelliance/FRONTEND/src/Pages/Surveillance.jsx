import React, { useState, useEffect } from "react";
import { io } from "socket.io-client";
import "./Surveillance.css";

const Surveillance = () => {
  const [activeTab, setActiveTab] = useState("ambulance");
  const [searchQuery, setSearchQuery] = useState("");
  const [ambulanceData, setAmbulanceData] = useState([]);
  const [policeData, setPoliceData] = useState([]);

  useEffect(() => {
    // Locations for Matunga, Dadar, and Mulund
    const locations = [
      { name: "Matunga Ambulance", latitude: 19.0268, longitude: 72.8561 },
      { name: "Dadar Ambulance", latitude: 19.0175, longitude: 72.8493 },
      { name: "Mulund Ambulance", latitude: 19.1730, longitude: 72.9571 },
      { name: "King Circle Ambulance", latitude: 19.0755, longitude: 72.8777 },
      { name: "Emergency Ambulance Dharavi", latitude: 19.0402, longitude: 72.8573 },
      { name: "Rapid Response Ambulance Shivaji Park", latitude: 19.0266, longitude: 72.8412 },
      { name: "City Care Ambulance Mahim", latitude: 19.0474, longitude: 72.8380 },
      { name: "Matunga Police Chowki", latitude: 19.0268, longitude: 72.8561 },
      { name: "Dadar Police Chowki", latitude: 19.0175, longitude: 72.8493 },
      { name: "Mulund Police Chowki", latitude: 19.1730, longitude: 72.9571 },
      { name: "Shivaji Park Police Chowki", latitude: 19.0265, longitude: 72.8377 },
      { name: "Dharavi Police Chowki", latitude: 19.0402, longitude: 72.8573 },
      { name: "King Circle Police Chowki", latitude: 19.0266, longitude: 72.8412 },
      { name: "Mahim Police Chowki", latitude: 19.0474, longitude: 72.8380 },
    ];

    const generateData = (prefix, filterType) =>
      locations
        .filter((location) => location.name.includes(filterType))
        .map((location, index) => ({
          id: `${prefix}${(index + 1).toString().padStart(3, "0")}`,
          location: location.name,
          status: "Available",
          contact: `98${(index + 1).toString().padStart(8, "0")}`,
          latitude: location.latitude,
          longitude: location.longitude,
        }));

    setAmbulanceData(generateData("MH O5 0", "Ambulance"));
    setPoliceData(generateData("MH O5 0", "Police Chowki"));

    const socket = io("http://192.168.93.176:3000");

    socket.on("alert-userDetails", (data) => {
      console.log("Received SOS Alert:", data);
      handleSOSAlert(data);
    });

    return () => {
      socket.disconnect();
    };
  }, []);

  const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const toRadians = (degree) => (degree * Math.PI) / 180;
    const R = 6371; // Earth's radius in km
    const dLat = toRadians(lat2 - lat1);
    const dLon = toRadians(lon2 - lon1);

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; // Distance in kilometers
  };

  const handleSOSAlert = (alert) => {
    const { latitude, longitude } = alert;

    // Find the nearest ambulance
    let nearestAmbulance = null;
    let minAmbulanceDistance = Infinity;

    setAmbulanceData((prevAmbulances) => {
      prevAmbulances.forEach((ambulance) => {
        if (ambulance.status === "Available") {
          const distance = calculateDistance(
            latitude,
            longitude,
            ambulance.latitude,
            ambulance.longitude
          );
          if (distance < minAmbulanceDistance) {
            minAmbulanceDistance = distance;
            nearestAmbulance = ambulance;
          }
        }
      });

      if (nearestAmbulance) {
        return prevAmbulances.map((item) =>
          item.id === nearestAmbulance.id
            ? { ...item, status: "Busy" }
            : item
        );
      }

      return prevAmbulances;
    });

    // Find the nearest police vehicle
    let nearestPolice = null;
    let minPoliceDistance = Infinity;

    setPoliceData((prevPolice) => {
      prevPolice.forEach((police) => {
        if (police.status === "Available") {
          const distance = calculateDistance(
            latitude,
            longitude,
            police.latitude,
            police.longitude
          );
          if (distance < minPoliceDistance) {
            minPoliceDistance = distance;
            nearestPolice = police;
          }
        }
      });

      if (nearestPolice) {
        return prevPolice.map((item) =>
          item.id === nearestPolice.id
            ? { ...item, status: "Busy" }
            : item
        );
      }

      return prevPolice;
    });

    console.log(
      `Assigned Ambulance: ${nearestAmbulance?.id}, Police: ${nearestPolice?.id}`
    );
  };

  const handleAssign = (id, type) => {
    if (type === "ambulance") {
      setAmbulanceData((prev) =>
        prev.map((item) =>
          item.id === id
            ? { ...item, status: item.status === "Available" ? "Busy" : "Available" }
            : item
        )
      );
    } else {
      setPoliceData((prev) =>
        prev.map((item) =>
          item.id === id
            ? { ...item, status: item.status === "Available" ? "Busy" : "Available" }
            : item
        )
      );
    }
  };

  const filterData = (data) =>
    searchQuery
      ? data.filter((item) =>
        item.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.location.toLowerCase().includes(searchQuery.toLowerCase())
      )
      : data;

  const sortedData = (data) => {
    const busyItems = data.filter((item) => item.status === "Busy");
    const availableItems = data.filter((item) => item.status === "Available");
    return [...busyItems, ...availableItems];
  };

  const dataToDisplay =
    activeTab === "ambulance" ? sortedData(filterData(ambulanceData)) : sortedData(filterData(policeData));

  return (
    <div className="surveillance-container">
      <div className="navbar">
        <button
          className={`tab ${activeTab === "ambulance" ? "active" : ""}`}
          onClick={() => setActiveTab("ambulance")}
        >
          Ambulance
        </button>
        <button
          className={`tab ${activeTab === "police" ? "active" : ""}`}
          onClick={() => setActiveTab("police")}
        >
          Police Vehicle
        </button>
        <input
          type="text"
          className="search-bar"
          placeholder="Search by ID or Location"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>
      <div className="content">
        <div className="table-container">
          <h2
            style={{
              color: activeTab === "ambulance" ? "red" : "blue",
              paddingBottom: "15px",
            }}
          >
            {activeTab === "ambulance" ? "Ambulance Data" : "Police Vehicle Data"}
          </h2>
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Location</th>
                <th>Status</th>
                <th>Contact</th>
                <th>Assign</th>
              </tr>
            </thead>
            <tbody>
              {dataToDisplay.map((item) => (
                <tr
                  key={item.id}
                  className={item.status === "Busy" ? "row-busy" : ""}
                >
                  <td>{item.id}</td>
                  <td>{item.location}</td>
                  <td>{item.status}</td>
                  <td>{item.contact}</td>
                  <td>
                    <button
                      className={`assign-btn ${item.status === "Busy" ? "disabled" : ""}`}
                      disabled={item.status === "Busy"}
                      onClick={() => handleAssign(item.id, activeTab)}
                    >
                      {item.status === "Busy" ? "Busy" : "Assign"}
                    </button>
                  </td>
                </tr>
              ))}
              {dataToDisplay.length === 0 && (
                <tr>
                  <td colSpan="5">No results found</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Surveillance;
