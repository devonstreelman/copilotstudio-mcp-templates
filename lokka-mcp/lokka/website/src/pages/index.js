import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import React, { useState, useRef, useEffect } from "react";
import Link from '@docusaurus/Link';
import styles from "./styles.module.css";

function VideoPlayer() {
  const [showVideo, setShowVideo] = useState(false);
  const thumbnailRef = useRef(null);
  const [tiltStyle, setTiltStyle] = useState({});
  
  const playVideo = () => {
    setShowVideo(true);
  };

  useEffect(() => {
    const container = thumbnailRef.current;
    if (!container) return;

    const handleMouseMove = (e) => {
      if (showVideo) return;
      
      const rect = container.getBoundingClientRect();
      const x = e.clientX - rect.left; // x position within the element
      const y = e.clientY - rect.top;  // y position within the element
      
      // Calculate the tilt angle based on mouse position
      // The further from center, the more tilt (up to max degrees)
      const centerX = rect.width / 2;
      const centerY = rect.height / 2;
      
      const maxTiltDegrees = 5; // Maximum tilt in degrees
      const tiltX = ((y - centerY) / centerY) * -maxTiltDegrees;
      const tiltY = ((x - centerX) / centerX) * maxTiltDegrees;
      
      setTiltStyle({
        transform: `perspective(1000px) rotateX(${tiltX}deg) rotateY(${tiltY}deg)`,
        transition: 'transform 0.05s ease-out'
      });
    };
    
    const handleMouseLeave = () => {
      setTiltStyle({
        transform: 'perspective(1000px) rotateX(0deg) rotateY(0deg)',
        transition: 'transform 0.5s ease-out'
      });
    };

    container.addEventListener('mousemove', handleMouseMove);
    container.addEventListener('mouseleave', handleMouseLeave);

    return () => {
      container.removeEventListener('mousemove', handleMouseMove);
      container.removeEventListener('mouseleave', handleMouseLeave);
    };
  }, [showVideo]);
  
  return (
    <div className={styles.videoContainer}>
      {!showVideo ? (
        <div 
          ref={thumbnailRef}
          className={styles.thumbnailContainer} 
          onClick={playVideo}
          style={tiltStyle}
        >
          <img 
            className={styles.thumbnail} 
            src="/img/lokka-intro-video.png" 
            alt="Lokka Demo - Introducing Lokka" 
          />
          <div className={styles.playButtonContainer}>
            <div className={styles.playButtonOuter}>
              <div className={styles.playButtonInner}>
                <div className={styles.playIcon}></div>
              </div>
            </div>
          </div>
        </div>
      ) : (
        <iframe 
          className={styles.videoFrame}
          src="https://www.youtube.com/embed/f-ECqQSpLCM?autoplay=1"
          title="Lokka Demo - Introducing Lokka"
          frameBorder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
        ></iframe>
      )}
    </div>
  );
}

export default function Home() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title="Lokka"
      description="Lokka is an AI agent tool that brings the power of Microsoft Graph to AI agents like GitHub Copilot and Claude that run on your local desktop.">
      <main>
        <div className={styles.hero}>
          <div className={styles.container}>
            <div className={styles.heroContent}>
              <h1 className={styles.heroTitle}>Lokka</h1>
              <p className={styles.heroSubtitle}>Lokka is an AI agent tool that brings the power of Microsoft Graph to AI agents like GitHub Copilot and Claude. The best part is you can get started for free and it runs on your desktop.</p>
                <p className={styles.heroSubtitle}>Get a glimpse into the future of administering Microsoft 365 👇</p>
            </div>
            <VideoPlayer />
            <div className={styles.buttonContainer}>
              <Link
                className={styles.tryButton}
                to="/docs/install">
                Try Lokka
              </Link>
            </div>
          </div>
        </div>
      </main>
    </Layout>
  );
}
