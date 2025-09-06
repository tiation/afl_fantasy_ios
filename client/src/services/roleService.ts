import { apiRequest } from '@/lib/queryClient';

/**
 * Fetch data from the Role Change Detector tool
 */
export async function fetchRoleChanges() {
  const response = await apiRequest('GET', '/api/role-tools/role-change');
  return await response.json();
}

/**
 * Fetch data from the CBA Trend Analyzer tool
 */
export async function fetchCBATrends() {
  const response = await apiRequest('GET', '/api/role-tools/cba-trends');
  return await response.json();
}

/**
 * Fetch data from the Positional Impact Scoring tool
 */
export async function fetchPositionalImpact() {
  const response = await apiRequest('GET', '/api/role-tools/positional-impact');
  return await response.json();
}

/**
 * Fetch data from the Possession Type Profiler tool
 */
export async function fetchPossessionProfile() {
  const response = await apiRequest('GET', '/api/role-tools/possession-profile');
  return await response.json();
}