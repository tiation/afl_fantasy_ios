import axios from 'axios'
import type { WeatherForecast } from '../types'
import { logger } from '../lib/logger'

const API_KEY = process.env.WEATHER_API_KEY
const API_BASE = 'https://api.weatherapi.com/v1'

/**
 * WeatherAPI Integration
 * 
 * Provides weather forecasts for AFL venues using WeatherAPI.com
 */
class WeatherAPI {
  private static instance: WeatherAPI
  
  private constructor() {}
  
  public static getInstance(): WeatherAPI {
    if (!WeatherAPI.instance) {
      WeatherAPI.instance = new WeatherAPI()
    }
    return WeatherAPI.instance
  }

  /**
   * Get weather forecast for a specific location
   */
  public async getForecast(
    latitude: number,
    longitude: number,
    days: number = 3
  ): Promise<WeatherForecast | null> {
    try {
      const response = await axios.get(`${API_BASE}/forecast.json`, {
        params: {
          key: API_KEY,
          q: `${latitude},${longitude}`,
          days,
          aqi: 'no'
        }
      })

      const current = response.data.current
      const forecast = response.data.forecast.forecastday[0]

      return {
        temperature: current.temp_c,
        rainProbability: forecast.day.daily_chance_of_rain,
        windSpeed: current.wind_kph,
        windDirection: current.wind_dir,
        conditions: current.condition.text
      }
    } catch (error) {
      logger.error('Error fetching weather forecast', error)
      return null
    }
  }
  
  /**
   * Get historical weather data
   */
  public async getHistoricalWeather(
    latitude: number,
    longitude: number,
    date: string // YYYY-MM-DD
  ): Promise<WeatherForecast | null> {
    try {
      const response = await axios.get(`${API_BASE}/history.json`, {
        params: {
          key: API_KEY,
          q: `${latitude},${longitude}`,
          dt: date
        }
      })

      const day = response.data.forecast.forecastday[0].day

      return {
        temperature: day.avgtemp_c,
        rainProbability: day.daily_chance_of_rain,
        windSpeed: day.maxwind_kph,
        windDirection: 'N/A', // Not available in historical data
        conditions: day.condition.text
      }
    } catch (error) {
      logger.error('Error fetching historical weather', error)
      return null
    }
  }

  /**
   * Check if severe weather conditions are expected
   */
  public async checkSevereWeather(
    latitude: number,
    longitude: number
  ): Promise<{
    isSevere: boolean
    warnings: string[]
  }> {
    try {
      const forecast = await this.getForecast(latitude, longitude)
      if (!forecast) return { isSevere: false, warnings: [] }

      const warnings: string[] = []

      if (forecast.windSpeed > 40) {
        warnings.push('Strong winds may affect gameplay')
      }
      if (forecast.rainProbability > 80) {
        warnings.push('High chance of heavy rain')
      }
      if (forecast.temperature > 35) {
        warnings.push('Extreme heat conditions expected')
      }

      return {
        isSevere: warnings.length > 0,
        warnings
      }
    } catch (error) {
      logger.error('Error checking severe weather', error)
      return { isSevere: false, warnings: [] }
    }
  }
}

export const weatherApi = WeatherAPI.getInstance()
