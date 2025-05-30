import React, { useEffect, useRef } from 'react';
import { FaMinus, FaPlus } from 'react-icons/fa';
// Import OpenLayers components
import 'ol/ol.css';
import { Map, View } from 'ol';
import { Tile as TileLayer } from 'ol/layer';
import { OSM } from 'ol/source';
import { fromLonLat } from 'ol/proj';

const mappage = () => {
  const mapContainer = useRef(null); // Reference to the map container
  const mapInstance = useRef(null); // Reference to the map instance

  useEffect(() => {
    // Initialize the map only once
    if (!mapInstance.current) {
      mapInstance.current = new Map({
        target: mapContainer.current, // Target the map container
        layers: [
          new TileLayer({
            source: new OSM(), // OpenStreetMap layer
          }),
        ],
        view: new View({
          center: fromLonLat([0, 0]), // Longitude and Latitude
          zoom: 2, // Initial zoom level
        }),
      });
    }
    return () => {
      mapInstance.current.setTarget(null); // Clean up on component unmount
    };
  }, []);

  return (
    <div>
      <h1>OpenLayers Map in React</h1>
      <div
        ref={mapContainer}
        style={{ width: '100%', height: '1000px' }} // Style for the map container
      ></div>
    </div>
  );
};

export default mappage;
