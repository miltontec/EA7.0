//+------------------------------------------------------------------+
//| AdaptiveVotingExample.mq5 - Ejemplo de Integración               |
//| Muestra cómo usar el AdaptiveVotingSystem en tu EA               |
//+------------------------------------------------------------------+
#property copyright "Advanced Trading System 2025"
#property version   "1.00"
#property strict

#include "AdaptiveVotingSystem.mqh"

// Instancia global del sistema
AdaptiveVotingSystem g_votingSystem;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    Print("═══════════════════════════════════════════════════════════════");
    Print("  EJEMPLO DE INTEGRACIÓN - ADAPTIVE VOTING SYSTEM v4.0");
    Print("═══════════════════════════════════════════════════════════════");

    // Inicializar el sistema
    if(!g_votingSystem.Initialize(_Symbol, PERIOD_CURRENT)) {
        Print("❌ ERROR: No se pudo inicializar AdaptiveVotingSystem");
        return INIT_FAILED;
    }

    Print("✅ Sistema inicializado correctamente");
    Print("═══════════════════════════════════════════════════════════════\n");

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("\n═══════════════════════════════════════════════════════════════");
    Print("  FINALIZANDO SISTEMA");
    Print("═══════════════════════════════════════════════════════════════");

    // El sistema guardará automáticamente en el destructor
    Print("✓ Datos guardados automáticamente");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    // Este es solo un ejemplo - en tu EA real, esto se ejecutaría
    // cuando tengas señales de tus 5 indicadores

    static datetime lastBar = 0;
    datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);

    // Solo procesar en nueva barra
    if(currentBar == lastBar) return;
    lastBar = currentBar;

    //------------------------------------------------------------------
    // PASO 1: Obtener señales de tus 5 indicadores
    //------------------------------------------------------------------
    // En tu EA real, estos valores vendrían de tus indicadores reales
    // signals[i]: 1=BUY, -1=SELL, 0=NEUTRAL
    // confidences[i]: 0.0-1.0 (confianza de la señal)

    int signals[5];
    double confidences[5];

    // EJEMPLO: Generar señales dummy (reemplazar con tus indicadores reales)
    signals[0] = GetSRLevelsSignal();           // SR_Levels
    signals[1] = GetMLNeuralSignal();           // ML_Neural
    signals[2] = GetMomentumSignal();           // Momentum
    signals[3] = GetRSIDivergenceSignal();      // RSI_Divergence
    signals[4] = GetVolumeProfileSignal();      // Volume_Profile

    confidences[0] = GetSRLevelsConfidence();
    confidences[1] = GetMLNeuralConfidence();
    confidences[2] = GetMomentumConfidence();
    confidences[3] = GetRSIDivergenceConfidence();
    confidences[4] = GetVolumeProfileConfidence();

    //------------------------------------------------------------------
    // PASO 2: Generar pesos dinámicos basados en contexto actual
    //------------------------------------------------------------------
    DynamicWeight weights[];

    if(!g_votingSystem.GenerateVotingWeights(weights)) {
        Print("⚠ WARNING: No se pudieron generar pesos");
        return;
    }

    // Mostrar pesos calculados (opcional, para debug)
    Print("\n┌─ PESOS DINÁMICOS ────────────────────────────────────────────┐");
    for(int i = 0; i < 5; i++) {
        if(weights[i].isActive) {
            Print("│ ", weights[i].indicatorName, ": ", DoubleToString(weights[i].finalWeight, 3));
            Print("│   ", weights[i].reasoning);
        } else {
            Print("│ ", weights[i].indicatorName, ": FILTRADO");
        }
    }
    Print("└───────────────────────────────────────────────────────────────┘");

    //------------------------------------------------------------------
    // PASO 3: Ejecutar votación con pesos dinámicos
    //------------------------------------------------------------------
    VotingResult result = g_votingSystem.ExecuteVoting(signals, confidences, weights);

    Print("\n┌─ RESULTADO DE VOTACIÓN ──────────────────────────────────────┐");
    Print("│ Dirección: ", result.finalDirection > 0 ? "BUY" : (result.finalDirection < 0 ? "SELL" : "NEUTRAL"));
    Print("│ Confianza: ", DoubleToString(result.confidence * 100, 1), "%");
    Print("│ Consenso: ", result.hasConsensus ? "SÍ" : "NO");
    Print("│ Indicadores activos: ", result.activeIndicators, "/", result.totalIndicators);
    Print("│ Top Indicador: ", result.topIndicatorName, " (peso: ", DoubleToString(result.topIndicatorWeight, 3), ")");
    Print("│ Razón: ", result.decisionReason);
    Print("└───────────────────────────────────────────────────────────────┘\n");

    //------------------------------------------------------------------
    // PASO 4: Si hay consenso, ejecutar trade
    //------------------------------------------------------------------
    if(result.hasConsensus && result.confidence > 0.70) {
        // Aquí ejecutarías tu trade
        Print("🎯 SEÑAL DE TRADING CONFIRMADA!");
        Print("   → Ejecutar ", result.finalDirection > 0 ? "BUY" : "SELL",
              " con confianza ", DoubleToString(result.confidence * 100, 1), "%");

        // EJEMPLO: Simular ejecución de trade
        // En tu EA real, aquí llamarías a tu función de ejecución
        // ExecuteTrade(result.finalDirection, result.confidence);

        // Para este ejemplo, simularemos el cierre del trade después de algunas barras
        SimulateTradeAndLearn(result);
    } else {
        Print("⏸ Sin consenso suficiente - Esperando mejor setup");
    }
}

//+------------------------------------------------------------------+
//| Simular trade y aprendizaje (solo para ejemplo)                 |
//+------------------------------------------------------------------+
void SimulateTradeAndLearn(VotingResult &votingResult) {
    // En tu EA real, esto se ejecutaría cuando el trade cierre

    // EJEMPLO: Simular resultado (50% probabilidad de ganar)
    bool won = (MathRand() % 100) > 50;
    double profit = won ? 150.0 : -100.0;
    int barsToClose = 5 + (MathRand() % 10);  // 5-15 barras

    Print("\n┌─ RESULTADO DEL TRADE (SIMULADO) ─────────────────────────────┐");
    Print("│ Resultado: ", won ? "✓ GANADOR" : "✗ PERDEDOR");
    Print("│ Profit: $", DoubleToString(profit, 2));
    Print("│ Barras hasta cierre: ", barsToClose);
    Print("└───────────────────────────────────────────────────────────────┘");

    //------------------------------------------------------------------
    // PASO 5: Aprender del resultado (CRÍTICO!)
    //------------------------------------------------------------------
    // Esto actualiza las estadísticas contextuales de cada indicador
    g_votingSystem.LearnFromTrade(votingResult, won, profit, barsToClose);

    Print("✅ Sistema actualizado con nuevo aprendizaje\n");
}

//+------------------------------------------------------------------+
//| Funciones dummy de indicadores (REEMPLAZAR CON TUS REALES)      |
//+------------------------------------------------------------------+

int GetSRLevelsSignal() {
    // EJEMPLO: Reemplazar con tu lógica real de S/R
    double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double support = price - 100 * _Point;
    double resistance = price + 100 * _Point;

    if(price < support + 20 * _Point) return 1;  // BUY cerca de soporte
    if(price > resistance - 20 * _Point) return -1;  // SELL cerca de resistencia
    return 0;
}

double GetSRLevelsConfidence() {
    // EJEMPLO: Confianza basada en distancia a nivel
    return 0.60 + (MathRand() % 30) / 100.0;  // 0.60-0.90
}

int GetMLNeuralSignal() {
    // EJEMPLO: Señal de red neuronal (reemplazar con tu modelo real)
    return (MathRand() % 3) - 1;  // -1, 0, o 1
}

double GetMLNeuralConfidence() {
    return 0.50 + (MathRand() % 40) / 100.0;  // 0.50-0.90
}

int GetMomentumSignal() {
    // EJEMPLO: Basado en MAs
    double ma20 = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE);
    double ma50 = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE);

    double ma20_val[], ma50_val[];
    ArraySetAsSeries(ma20_val, true);
    ArraySetAsSeries(ma50_val, true);

    if(CopyBuffer(ma20, 0, 0, 1, ma20_val) > 0 && CopyBuffer(ma50, 0, 0, 1, ma50_val) > 0) {
        if(ma20_val[0] > ma50_val[0]) return 1;
        if(ma20_val[0] < ma50_val[0]) return -1;
    }

    return 0;
}

double GetMomentumConfidence() {
    return 0.55 + (MathRand() % 35) / 100.0;
}

int GetRSIDivergenceSignal() {
    // EJEMPLO: RSI simple
    int rsiHandle = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    double rsi[];
    ArraySetAsSeries(rsi, true);

    if(CopyBuffer(rsiHandle, 0, 0, 1, rsi) > 0) {
        if(rsi[0] < 30) return 1;   // Sobreventa -> BUY
        if(rsi[0] > 70) return -1;  // Sobrecompra -> SELL
    }

    IndicatorRelease(rsiHandle);
    return 0;
}

double GetRSIDivergenceConfidence() {
    return 0.50 + (MathRand() % 40) / 100.0;
}

int GetVolumeProfileSignal() {
    // EJEMPLO: Basado en volumen tick
    long volume = iVolume(_Symbol, PERIOD_CURRENT, 0);
    long avgVolume = 1000;  // Simplificado

    if(volume > avgVolume * 1.5) {
        // Alto volumen - seguir tendencia
        double ma20 = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE);
        double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double ma[];
        ArraySetAsSeries(ma, true);

        if(CopyBuffer(ma20, 0, 0, 1, ma) > 0) {
            return (price > ma[0]) ? 1 : -1;
        }
    }

    return 0;
}

double GetVolumeProfileConfidence() {
    return 0.45 + (MathRand() % 45) / 100.0;
}

//+------------------------------------------------------------------+
//| Timer function para reportes periódicos                          |
//+------------------------------------------------------------------+
void OnTimer() {
    // Cada hora, mostrar reporte de performance
    g_votingSystem.PrintPerformanceReport();

    // Opcional: Exportar a CSV
    // g_votingSystem.ExportToCSV();
}
//+------------------------------------------------------------------+
