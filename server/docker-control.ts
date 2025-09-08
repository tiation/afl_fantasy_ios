import { Router } from 'express';
import { exec } from 'child_process';
import { promisify } from 'util';
import { log } from './vite';

const execAsync = promisify(exec);
const router = Router();

interface DockerService {
  name: string;
  status: 'running' | 'stopped' | 'loading';
  ports: string[];
  healthcheck?: string;
}

async function getDockerServices(): Promise<DockerService[]> {
  try {
const { stdout } = await execAsync('docker compose -f docker-compose.unified.yml ps --format json');
    const services = JSON.parse(stdout);
    
    return services.map((svc: any) => ({
      name: svc.Name,
      status: svc.State === 'running' ? 'running' : 'stopped',
      ports: svc.Publishers?.map((p: any) => `${p.PublishedPort}:${p.TargetPort}`) || [],
      healthcheck: svc.Health
    }));
  } catch (error) {
    log(`Error getting Docker services: ${error}`);
    return [];
  }
}

// Get status of all services
router.get('/status', async (req, res) => {
  try {
    const services = await getDockerServices();
    res.json({ services });
  } catch (error) {
    log(`Error in /status: ${error}`);
    res.status(500).json({ error: 'Failed to get Docker status' });
  }
});

// Start services with specified profiles
router.post('/start', async (req, res) => {
  try {
    const { profiles = ['default'] } = req.body;
    const profileArgs = profiles.map(p => `--profile ${p}`).join(' ');
    
    await execAsync(`docker compose ${profileArgs} up -d`);
    
    // Wait a bit for services to start
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    const services = await getDockerServices();
    res.json({ success: true, services });
  } catch (error) {
    log(`Error in /start: ${error}`);
    res.status(500).json({ error: 'Failed to start Docker services' });
  }
});

// Stop all services
router.post('/stop', async (req, res) => {
  try {
    await execAsync('docker compose down');
    res.json({ success: true });
  } catch (error) {
    log(`Error in /stop: ${error}`);
    res.status(500).json({ error: 'Failed to stop Docker services' });
  }
});

// Restart a specific service
router.post('/restart/:service', async (req, res) => {
  try {
    const { service } = req.params;
    await execAsync(`docker compose restart ${service}`);
    
    // Wait a bit for service to restart
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    const services = await getDockerServices();
    res.json({ success: true, services });
  } catch (error) {
    log(`Error in /restart: ${error}`);
    res.status(500).json({ error: 'Failed to restart service' });
  }
});

export function registerDockerControlRoutes(app: any) {
  app.use('/api/docker', router);
  log('Docker control API registered');
}
