import React from 'react';

const Popup = ({ message, onClose }) => {
  return (
    <div
      style={{
        position: 'fixed',
        top: '5%',
        left: '60%',
        transform: 'translate(-50%, 0)',
        background: 'linear-gradient(135deg, #008080, #005f5f)',
        color: 'white',
        padding: '20px',
        borderRadius: '8px',
        zIndex: 1000,
        width: '90%',
        maxWidth: '600px',
        boxShadow: '0 8px 20px rgba(0, 0, 0, 0.3)',
        animation: 'fadeIn 0.5s ease-in-out',
        fontFamily: 'Arial, sans-serif',
        textAlign: 'center',
      }}
    >
      <strong style={{ fontSize: '18px', display: 'block', marginBottom: '10px' }}>
        🚨 Alert:
      </strong>
      <span style={{ fontSize: '16px', lineHeight: '1.5' }}>{message}</span>
      <button
        onClick={onClose}
        style={{
          margin: '15px',
          padding: '10px 20px',
          background: 'black',
          color: 'white',
          border: 'none',
          borderRadius: '5px',
          cursor: 'pointer',
          fontSize: '14px',
          transition: 'background 0.3s ease',
        }}
        onMouseEnter={(e) => (e.target.style.background = '#444')}
        onMouseLeave={(e) => (e.target.style.background = 'black')}
      >
        Close
      </button>
    </div>
  );
};

export default Popup;
