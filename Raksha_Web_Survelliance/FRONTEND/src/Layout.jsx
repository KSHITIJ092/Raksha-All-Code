import React from 'react';
import { FaDatabase, FaExclamationTriangle, FaHome, FaAmbulance , FaUserShield ,FaMapMarker} from 'react-icons/fa';
import { Link, Outlet } from 'react-router-dom';
import './App.css'; // Add general styles if needed

const Layout = () => {
  return (
    <div className="dashboard">
      {/* Sidebar */}
      <aside className="sidebar">
        <h2>RAKSHA</h2>
        <nav>
          <ul>
            <li><Link to="/"><FaHome /> Dashboard</Link></li>
            <li><Link to="/database"><FaDatabase /> Database</Link></li>
            <li><Link to="/emergency-alerts"><FaExclamationTriangle /> SOS Alerts</Link></li>
            <li><Link to="/emergency-services"><FaUserShield />Law Enforcement</Link></li>
            <li><Link to="/emergency-services"><FaAmbulance />Medical Services</Link></li>
            <li><Link to="/map"><FaMapMarker />Map Analytics</Link></li>
          </ul>
        </nav>
      </aside>

      {/* Main Content Area */}
      <main className="content">
        <Outlet /> {/* This is where routed page content will appear */}
      </main>
    </div>
  );
};

export default Layout;
