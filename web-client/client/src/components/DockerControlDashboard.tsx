import React, { useState, useEffect } from 'react';
import { Play, Stop, RefreshCw } from 'lucide-react';

interface ServiceStatus {
  name: string;
  status: 'running' | 'stopped' | 'loading';
  ports: string[];
  healthcheck?: string;
}

export function DockerControlDashboard() {
  const [services, setServices] = useState<ServiceStatus[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchStatus = async () => {
    try {
      const response = await fetch('/api/docker/status');
      const data = await response.json();
      setServices(data.services);
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
        setTimeout(fetchStatus, 2000); // Check status after 2s
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
        setTimeout(fetchStatus, 2000); // Check status after 2s
      }
    } catch (error) {
      console.error('Failed to stop services:', error);
    } finally {
      setLoading(false);
    }
  };

  // Initial status fetch
  useEffect(() => {
    fetchStatus();
    // Set up periodic refresh
    const interval = setInterval(fetchStatus, 10000); // Refresh every 10s
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="bg-white p-6 rounded-lg shadow-lg">
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
        {services.map((service) => (
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
        ))}
      </div>
    </div>
  );
}
