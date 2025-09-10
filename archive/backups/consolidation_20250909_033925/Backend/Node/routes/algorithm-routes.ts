import { Router } from "express";
import { z } from "zod";
import { PricePredictorService } from "../services/pricePredictor";
import { ProjectedScoreService } from "../services/projectedScore";
import { DataImporter } from "../utils/dataImporter";
import { ExcelConverter } from "../utils/excelConverter";

const router = Router();

// Initialize services
const pricePredictorService = new PricePredictorService();
const projectedScoreService = new ProjectedScoreService();
const dataImporter = new DataImporter();
const excelConverter = new ExcelConverter();

// Validation schemas
const pricePredictorSchema = z.object({
  playerId: z.number().int().positive(),
  projectedScores: z.array(z.number().int().min(0).max(300)).min(1).max(5)
});

const projectedScoreSchema = z.object({
  playerId: z.number().int().positive(),
  round: z.number().int().positive(),
  opponent: z.string().optional(),
  venue: z.string().optional()
});

const batchProjectedScoreSchema = z.object({
  players: z.array(projectedScoreSchema).min(1).max(50)
});

/**
 * Price Predictor Algorithm
 * POST /api/algorithms/price-predictor
 */
router.post("/price-predictor", async (req, res) => {
  try {
    const input = pricePredictorSchema.parse(req.body);
    
    const result = await pricePredictorService.calculatePricePrediction(input);
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error("Price predictor error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

/**
 * Get Player Scoring Form for Price Predictor
 * GET /api/algorithms/price-predictor/form/:playerId
 */
router.get("/price-predictor/form/:playerId", async (req, res) => {
  try {
    const playerId = parseInt(req.params.playerId);
    
    if (isNaN(playerId)) {
      return res.status(400).json({
        success: false,
        error: "Invalid player ID"
      });
    }
    
    const form = await pricePredictorService.getPlayerScoringForm(playerId);
    
    res.json({
      success: true,
      data: form
    });
  } catch (error) {
    console.error("Player form error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

/**
 * Calculate Magic Number for Round
 * GET /api/algorithms/price-predictor/magic-number/:round
 */
router.get("/price-predictor/magic-number/:round", async (req, res) => {
  try {
    const round = parseInt(req.params.round);
    
    if (isNaN(round)) {
      return res.status(400).json({
        success: false,
        error: "Invalid round number"
      });
    }
    
    const magicNumber = await pricePredictorService.calculateMagicNumber(round);
    
    res.json({
      success: true,
      data: {
        round,
        magicNumber
      }
    });
  } catch (error) {
    console.error("Magic number error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

/**
 * Projected Score Algorithm
 * POST /api/algorithms/projected-score
 */
router.post("/projected-score", async (req, res) => {
  try {
    const input = projectedScoreSchema.parse(req.body);
    
    const result = await projectedScoreService.calculateProjectedScore(input);
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error("Projected score error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

/**
 * Batch Projected Score Calculations
 * POST /api/algorithms/projected-score/batch
 */
router.post("/projected-score/batch", async (req, res) => {
  try {
    const input = batchProjectedScoreSchema.parse(req.body);
    
    const results = await projectedScoreService.calculateBatchProjections(input.players);
    
    res.json({
      success: true,
      data: results
    });
  } catch (error) {
    console.error("Batch projected score error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

/**
 * Convert Excel and Import Data
 * POST /api/algorithms/convert-excel
 */
router.post("/convert-excel", async (req, res) => {
  try {
    // Find Excel files
    const excelFiles = excelConverter.findExcelFiles();
    
    if (excelFiles.length === 0) {
      return res.json({
        success: false,
        error: "No Excel files found. Please upload .xlsx or .xls files first."
      });
    }

    const results = {
      success: true,
      converted: [] as string[],
      imported: [] as string[],
      errors: [] as string[]
    };

    // Convert each Excel file
    for (const excelFile of excelFiles) {
      console.log(`Converting Excel file: ${excelFile}`);
      
      const conversionResult = await excelConverter.convertAndImport(excelFile);
      results.converted.push(...conversionResult.converted);
      results.errors.push(...conversionResult.errors);
      
      if (!conversionResult.success) {
        results.success = false;
      }
    }

    // Import the converted CSV files
    const importResult = await dataImporter.autoImportData();
    results.imported.push(...importResult.imported);
    results.errors.push(...importResult.errors);
    
    if (!importResult.success) {
      results.success = false;
    }

    res.json({
      success: results.success,
      data: {
        excelFiles: excelFiles.map(f => f.split('/').pop()),
        converted: results.converted,
        imported: results.imported,
        errors: results.errors,
        message: results.success ? 
          `Successfully converted ${excelFiles.length} Excel file(s) and imported ${results.imported.length} datasets` :
          `Conversion completed with ${results.errors.length} errors`
      }
    });

  } catch (error) {
    console.error("Excel conversion error:", error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : "Conversion failed"
    });
  }
});

/**
 * Import Data from Files
 * POST /api/algorithms/import
 */
router.post("/import", async (req, res) => {
  try {
    const result = await dataImporter.autoImportData();
    
    res.json({
      success: result.success,
      data: {
        imported: result.imported,
        errors: result.errors,
        message: result.success ? 
          `Successfully imported ${result.imported.length} files` :
          `Import completed with ${result.errors.length} errors`
      }
    });
  } catch (error) {
    console.error("Data import error:", error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : "Import failed"
    });
  }
});

/**
 * Get Import Status
 * GET /api/algorithms/import/status
 */
router.get("/import/status", async (req, res) => {
  try {
    const status = await dataImporter.getImportStatus();
    
    res.json({
      success: true,
      data: status
    });
  } catch (error) {
    console.error("Import status error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to get import status"
    });
  }
});

/**
 * Get Algorithm Status and Requirements
 * GET /api/algorithms/status
 */
router.get("/status", async (req, res) => {
  try {
    // Get current data counts
    const importStatus = await dataImporter.getImportStatus();
    
    const status = {
      pricePredictor: {
        available: importStatus.playerRoundScores > 0 && importStatus.priceHistory > 0,
        dataCount: {
          roundScores: importStatus.playerRoundScores,
          priceHistory: importStatus.priceHistory
        },
        requirements: {
          playerRoundScores: "Individual round-by-round player scores",
          priceHistory: "Historical price tracking data",
          systemParameters: "Magic number and price formula parameters"
        }
      },
      projectedScore: {
        available: importStatus.playerRoundScores > 0,
        dataCount: {
          roundScores: importStatus.playerRoundScores,
          opponentHistory: importStatus.opponentHistory,
          venueHistory: importStatus.venueHistory,
          fixtures: importStatus.fixtures
        },
        requirements: {
          recentForm: "Last 3 and 5 game averages",
          opponentHistory: "Head-to-head performance records",
          venueHistory: "Venue-specific performance data",
          fixtures: "Upcoming game information"
        }
      },
      dataIntegrity: {
        status: "Ready for authentic AFL Fantasy data",
        magicNumber: 9650,
        totalRecords: Object.values(importStatus).reduce((sum, count) => sum + count, 0)
      }
    };
    
    res.json({
      success: true,
      data: status
    });
  } catch (error) {
    console.error("Status check error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to check algorithm status"
    });
  }
});

export default router;