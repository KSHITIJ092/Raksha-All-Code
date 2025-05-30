import React, { useEffect } from "react";
import "ol/ol.css";
import Papa from "papaparse";
import Map from "ol/Map";
import View from "ol/View";
import { Tile as TileLayer, Vector as VectorLayer } from "ol/layer";
import { OSM } from "ol/source";
import { Vector as VectorSource } from "ol/source";
import { Circle as CircleGeom, Point } from "ol/geom";
import { Feature } from "ol";
import { Style, Fill, Stroke, Text } from "ol/style";
import { fromLonLat } from "ol/proj";

const CrimeDataMap = () => {
  useEffect(() => {
    // Create the map
    const map = new Map({
      target: "map-container",
      layers: [
        new TileLayer({
          source: new OSM(), // OpenStreetMap as the base layer
        }),
      ],
      view: new View({
        center: fromLonLat([72.8777, 19.0760]), // Center of India
        zoom: 13,
      }),
    });

    // Function to assign colors based on intensity
    const getColorForIntensity = (intensity) => {
      if (intensity === "High") {
        return "rgba(255, 0, 0, 0.6)";
      } else if (intensity === "Medium") {
        return "rgba(255, 165, 0, 0.6)";
      } else {
        return "rgba(0, 255, 0, 0.6)";
      }
    };

    // Parse the CSV file
    Papa.parse("/local_crime_data_20241026_020944.csv", {
      download: true,
      header: true,
      skipEmptyLines: true,
      dynamicTyping: true,
      complete: (results) => {
        const data = results.data; // Parsed CSV data

        const vectorSource = new VectorSource();

        data.forEach((row) => {
          const { Incident_Type, Latitude, Longitude, Date, Time, Intensity } = row;

          // Convert latitude and longitude to map projection
          const coords = fromLonLat([Longitude, Latitude]);

          // Create a circle geometry
          const circle = new CircleGeom(coords, 100); // Radius in meters (e.g., 100 km)

          // Create a circle feature
          const circleFeature = new Feature(circle);

          // Create a label feature
          const labelFeature = new Feature(new Point(coords));

          // Style the circle
          circleFeature.setStyle(
            new Style({
              stroke: new Stroke({
                color: getColorForIntensity(Intensity),
                width: 2,
              }),
              fill: new Fill({
                color: getColorForIntensity(Intensity).replace("0.6", "0.2"),
              }),
            })
          );

          // Style the label with intensity text
          labelFeature.setStyle(
            new Style({
              text: new Text({
                text: `${Incident_Type}`, // Display Intensity value
                font: "bold 12px Arial",
                fill: new Fill({ color: "#000" }), // Black text color
                backgroundFill: new Fill({ color: "rgba(255, 255, 255, 0.8)" }), // White background
                padding: [3, 3, 3, 3],
                offsetY: -20, // Offset the label above the circle
              }),
            })
          );

          // Add the circle and label features to the vector source
          vectorSource.addFeature(circleFeature);
          vectorSource.addFeature(labelFeature);
        });

        // Create a vector layer for the crime data
        const vectorLayer = new VectorLayer({
          source: vectorSource,
        });

        // Add the vector layer to the map
        map.addLayer(vectorLayer);
      },
    });
  }, []);

  return <div id="map-container" style={{ width: "100vw", height: "100vh" }} />;
};

export default CrimeDataMap;
