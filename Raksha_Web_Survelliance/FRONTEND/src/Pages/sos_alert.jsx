import React, { useEffect, useRef, useState } from "react";
import { io } from "socket.io-client";
import { useNavigate } from "react-router-dom";
import {
  Card,
  CardContent,
  Typography,
  Button,
  Grid,
  Box,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableRow,
  Paper,
} from "@mui/material";
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import OSM from "ol/source/OSM";
import { fromLonLat } from "ol/proj";
import { Feature } from "ol";
import { Point } from "ol/geom";
import { Vector as VectorLayer } from "ol/layer";
import { Vector as VectorSource } from "ol/source";
import { Icon, Style } from "ol/style";
import "ol/ol.css";

const allAlerts = [
  "Harrasment or Eve Teasing",
  "Stalking or Chasing",
  "Groping",
  "Snatching",
  "Travelling Alone",
  "Domestic Violence",
];

const socket = io("http://192.168.93.176:3000");

const SOSAlertPage = () => {
  const [alerts, setAlerts] = useState(() => JSON.parse(localStorage.getItem("sosAlerts")) || []);
  const [selectedLocation, setSelectedLocation] = useState(null);
  const [status, setStatus] = useState(null);
  const mapRef = useRef(null);
  const mapInstance = useRef(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Listen to socket event and handle received alert data
    socket.on("alert-userDetails", async (data) => {
      try {
        if (!data || !data.latitude || !data.longitude || !data.threatType) {
          console.warn("Incomplete data received:", data);
          return;
        }

        const { username, status } = data;
        setStatus(status);

        const eventId = `EV${Math.floor(Math.random() * 1000)}`;
        const policeId = Math.random() > 0.5 ? "OPR001" : "OP2002";
        const priorityIndex = allAlerts.indexOf(data.threatType);
        const priority = priorityIndex !== -1 ? priorityIndex + 1 : "Low";

        const location = await convertLatLongToAddress(data.latitude, data.longitude);
        const currentTime = new Date().toLocaleString();

        const alertData = {
          ...data,
          eventId,
          policeId,
          priority: `P${priority}`,
          priorityIndex,
          location,
          time: currentTime,
        };

        setAlerts((prevAlerts) => {
          const updatedAlerts = [...prevAlerts, alertData];
          localStorage.setItem("sosAlerts", JSON.stringify(updatedAlerts));
          return updatedAlerts;
        });
      } catch (error) {
        console.error("Error processing alert data:", error);
      }
    });

    socket.on("alert-update", (data) => {
      const { username, status } = data;
      setStatus(status);
    });

    return () => {
      socket.off("alert-userDetails");
    };
  }, []);

  const initializeMap = (latitude, longitude) => {
    const coordinates = fromLonLat([longitude, latitude]);

    if (!mapInstance.current) {
      mapInstance.current = new Map({
        target: mapRef.current,
        layers: [new TileLayer({ source: new OSM() })],
        view: new View({
          center: coordinates,
          zoom: 15,
        }),
      });
    } else {
      mapInstance.current.getView().setCenter(coordinates);
      mapInstance.current.getView().setZoom(15);
    }

    const marker = new Feature({
      geometry: new Point(coordinates),
    });

    marker.setStyle(
      new Style({
        image: new Icon({
          src: "https://upload.wikimedia.org/wikipedia/commons/e/ec/RedDot.svg",
          scale: 1,
        }),
      })
    );

    const vectorLayer = new VectorLayer({
      source: new VectorSource({
        features: [marker],
      }),
    });

    mapInstance.current.getLayers().forEach((layer) => {
      if (layer instanceof VectorLayer) {
        mapInstance.current.removeLayer(layer);
      }
    });

    mapInstance.current.addLayer(vectorLayer);
  };

  const handleTrackLocation = (latitude, longitude) => {
    setSelectedLocation({ latitude, longitude });
    setTimeout(() => {
      initializeMap(latitude, longitude);
    }, 0);
  };

  const convertLatLongToAddress = async (lat, lon) => {
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=json`
      );
      const data = await response.json();
      return data.display_name || "Unknown location";
    } catch (error) {
      console.error("Error converting lat/lon to address:", error);
      return "Unknown location";
    }
  };

  return (
    <Box sx={{ marginLeft: "20px", padding: "10px", fontFamily: "Arial, sans-serif", color: "white" }}>
      <Typography variant="h4" gutterBottom color="error">
        SOS Alerts
      </Typography>
      <Grid container spacing={2}>
        <Grid item xs={12} md={6}>
          {alerts.length === 0 ? (
            <Typography variant="body1">No alerts received yet.</Typography>
          ) : (
            alerts.map((alert, index) => (
              <Card
                key={index}
                sx={{
                  marginBottom: "15px",
                  backgroundColor: "#333",
                  borderRadius: "10px",
                  boxShadow: "0px 4px 6px rgba(0, 0, 0, 0.1)",
                  color: "#fff",
                }}
              >
                <CardContent>
                  <Grid container spacing={2}>
                    <Grid item xs={6}>
                      <Typography variant="h6" gutterBottom>
                        Distress Info
                      </Typography>
                      <TableContainer component={Paper}>
                        <Table size="small">
                          <TableBody>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>Name</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>{alert.details?.name || "Unknown"}</TableCell>
                            </TableRow>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>Mobile</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>{alert.details?.mobileNo || "N/A"}</TableCell>
                            </TableRow>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>Gender</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>{alert.details?.gender || "N/A"}</TableCell>
                            </TableRow>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>Home Address</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>{alert.details?.address || "N/A"}</TableCell>
                            </TableRow>
                          </TableBody>
                        </Table>
                      </TableContainer>
                    </Grid>

                    <Grid item xs={6}>
                      <Typography variant="h6" gutterBottom>
                        Event Details
                      </Typography>
                      <TableContainer component={Paper}>
                        <Table size="small">
                          <TableBody>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>Co - Ord ID</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>OPR001</TableCell>
                            </TableRow>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>Event ID</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>EID202</TableCell>
                            </TableRow>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>Time</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>{"8:00 PM" || "N/A"}</TableCell>
                            </TableRow>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>Priority</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>{"P3" || "N/A"}</TableCell>
                            </TableRow>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>Threat Type</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>{"Groping" || "N/A"}</TableCell>
                            </TableRow>
                            <TableRow>
                              <TableCell sx={{ color: "white" }}><strong>CFS STATUS</strong></TableCell>
                              <TableCell sx={{ color: "white" }}>{"unresolved" || "N/A"}</TableCell>
                            </TableRow>
                          </TableBody>
                        </Table>
                      </TableContainer>
                    </Grid>
                  </Grid>

                  <Box sx={{ marginTop: "8px" }}>
                    <Button
                      variant="contained"
                      sx={{
                        backgroundColor: "#007BFF",
                        color: "#fff",
                        "&:hover": { backgroundColor: "#0056b3" },
                      }}
                      onClick={() => handleTrackLocation(alert.latitude, alert.longitude)}
                    >
                      Track Location
                    </Button>
                  </Box>
                </CardContent>
              </Card>
            ))
          )}
        </Grid>

        <Grid item xs={12} md={6}>
          <div ref={mapRef} style={{ width: "100%", height: "400px" }} />
        </Grid>
      </Grid>
    </Box>
  );
};

export default SOSAlertPage;
