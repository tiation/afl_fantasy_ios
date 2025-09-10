import React, { useState, useEffect } from 'react';
import { Play, Stop, RefreshCw, CircleDollarSign, Shield, Sparkles, ArrowUpDown } from 'lucide-react';

interface ServiceStatus {
  name: string;
  status: 'running' | 'stopped' | 'loading';
  ports: string[];
  healthcheck?: string;
}

function DockerControlDashboard() {
  const [services, setServices] = useState<ServiceStatus[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchStatus = async () => {
    try {
      const response = await fetch('/api/docker/status');
      const data = await response.json();
      setServices(data.services || []);
    } catch (error) {
      console.error('Failed to fetch Docker status:', error);
    }
  };

  const runAllServices = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/docker/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          profiles: ['default', 'dev', 'monitoring']
        })
      });
      const data = await response.json();
      if (data.success) {
        setTimeout(fetchStatus, 2000);
      }
    } catch (error) {
      console.error('Failed to start services:', error);
    } finally {
      setLoading(false);
    }
  };

  const stopAllServices = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/docker/stop', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      const data = await response.json();
      if (data.success) {
        setTimeout(fetchStatus, 2000);
      }
    } catch (error) {
      console.error('Failed to stop services:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStatus();
    const interval = setInterval(fetchStatus, 10000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="bg-white p-6 rounded-lg shadow-lg mb-6">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold">Docker Services</h2>
        <div className="flex gap-2">
          <button
            onClick={runAllServices}
            disabled={loading}
            className={`flex items-center px-4 py-2 rounded-md ${
              loading
                ? 'bg-gray-300 cursor-not-allowed'
                : 'bg-green-500 hover:bg-green-600 text-white'
            }`}
          >
            <Play className="w-4 h-4 mr-2" />
            Run Now
          </button>
          <button
            onClick={stopAllServices}
            disabled={loading}
            className={`flex items-center px-4 py-2 rounded-md ${
              loading
                ? 'bg-gray-300 cursor-not-allowed'
                : 'bg-red-500 hover:bg-red-600 text-white'
            }`}
          >
            <Stop className="w-4 h-4 mr-2" />
            Stop All
          </button>
          <button
            onClick={fetchStatus}
            disabled={loading}
            className={`flex items-center px-4 py-2 rounded-md ${
              loading
                ? 'bg-gray-300 cursor-not-allowed'
                : 'bg-blue-500 hover:bg-blue-600 text-white'
            }`}
          >
            <RefreshCw className="w-4 h-4 mr-2" />
            Refresh
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {services.length === 0 ? (
          <div className="col-span-full text-center py-8 text-gray-500">
            No Docker services found. Use "Run Now" to start services.
          </div>
        ) : (
          services.map((service) => (
            <div
              key={service.name}
              className={`p-4 rounded-lg ${
                service.status === 'running'
                  ? 'bg-green-50 border border-green-200'
                  : service.status === 'loading'
                  ? 'bg-yellow-50 border border-yellow-200'
                  : 'bg-red-50 border border-red-200'
              }`}
            >
              <div className="flex items-center justify-between">
                <h3 className="font-semibold">{service.name}</h3>
                <span
                  className={`px-2 py-1 rounded text-xs font-medium ${
                    service.status === 'running'
                      ? 'bg-green-100 text-green-800'
                      : service.status === 'loading'
                      ? 'bg-yellow-100 text-yellow-800'
                      : 'bg-red-100 text-red-800'
                  }`}
                >
                  {service.status}
                </span>
              </div>

              {service.ports.length > 0 && (
                <div className="mt-2 text-sm text-gray-600">
                  <span className="font-medium">Ports:</span>{' '}
                  {service.ports.join(', ')}
                </div>
              )}

              {service.healthcheck && (
                <div className="mt-1 text-sm text-gray-600">
                  <span className="font-medium">Health:</span>{' '}
                  {service.healthcheck}
                </div>
              )}
            </div>
          ))
        )}
      </div>
    </div>
  );
}

function PlaceholderTool({ name, description }: { name: string; description: string }) {
  return (
    <div className="bg-white p-6 rounded-lg shadow text-center">
      <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <Sparkles className="w-8 h-8 text-gray-400" />
      </div>
      <h3 className="text-lg font-semibold mb-2">{name}</h3>
      <p className="text-gray-600 mb-4">{description}</p>
      <span className="inline-block px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full">
        Coming Soon
      </span>
    </div>
  );
}

export default function WorkingDashboard() {
  const [activeSection, setActiveSection] = useState('docker');

  const sections = [
    { id: 'docker', name: 'Docker Control', icon: Play },
    { id: 'trades', name: 'Trade Analysis', icon: ArrowUpDown },
    { id: 'cash', name: 'Cash Tools', icon: CircleDollarSign },
    { id: 'risk', name: 'Risk Analysis', icon: Shield },
    { id: 'ai', name: 'AI Tools', icon: Sparkles }
  ];

  return (
    <div className="min-h-screen bg-gray-50" style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1 className="text-3xl font-bold mb-6 text-center">🏆 AFL Fantasy Coach Dashboard</h1>

      {/* Navigation */}
      <div className="flex flex-wrap gap-2 mb-6 justify-center">
        {sections.map(section => {
          const IconComponent = section.icon;
          return (
            <button
              key={section.id}
              onClick={() => setActiveSection(section.id)}
              className={`flex items-center px-4 py-2 rounded-lg font-medium transition-colors ${
                activeSection === section.id
                  ? 'bg-blue-500 text-white'
                  : 'bg-white text-gray-700 hover:bg-gray-100 border'
              }`}
            >
              <IconComponent className="w-4 h-4 mr-2" />
              {section.name}
            </button>
          );
        })}
      </div>

      {/* Content */}
      <div>
        {activeSection === 'docker' && (
          <div>
            <DockerControlDashboard />
            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-xl font-semibold mb-4">Welcome to AFL Fantasy Coach!</h3>
              <p className="text-gray-600 mb-4">
                This is your comprehensive AFL Fantasy management platform. Use the Docker controls above to start 
                all the backend services, then explore the various analysis tools using the navigation tabs.
              </p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="p-4 bg-blue-50 rounded-lg">
                  <h4 className="font-semibold text-blue-800">Getting Started</h4>
                  <p className="text-sm text-blue-600 mt-1">
                    Click "Run Now" to start all Docker services, then use the tools above to analyze your team.
                  </p>
                </div>
                <div className="p-4 bg-green-50 rounded-lg">
                  <h4 className="font-semibold text-green-800">Features</h4>
                  <p className="text-sm text-green-600 mt-1">
                    Trade analysis, cash generation tracking, risk assessment, and AI-powered insights.
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeSection === 'trades' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <PlaceholderTool
              name="Trade Calculator"
              description="Calculate comprehensive trade scores and analyze player swaps"
            />
            <PlaceholderTool
              name="One Up One Down"
              description="Find optimal trade combinations for maximum value"
            />
          </div>
        )}

        {activeSection === 'cash' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <PlaceholderTool
              name="Cash Generation Tracker"
              description="Track projected cash generation for players over time"
            />
            <PlaceholderTool
              name="Rookie Price Curves"
              description="Model rookie price trajectories and identify breakeven points"
            />
          </div>
        )}

        {activeSection === 'risk' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <PlaceholderTool
              name="Tag Watch Monitor"
              description="Monitor players at risk of being tagged by opponents"
            />
            <PlaceholderTool
              name="Injury Risk Tracker"
              description="Track injury risks and late withdrawal patterns"
            />
          </div>
        )}

        {activeSection === 'ai' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <PlaceholderTool
              name="AI Captain Advisor"
              description="Get AI-powered captain selection recommendations"
            />
            <PlaceholderTool
              name="Team Structure Analyzer"
              description="Analyze team balance and structure with AI insights"
            />
          </div>
        )}
      </div>
    </div>
  );
}
