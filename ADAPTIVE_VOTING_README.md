# 🧠 Adaptive Voting System v4.0 - Documentación Completa

## 📋 Tabla de Contenidos
1. [Visión General](#visión-general)
2. [Características Principales](#características-principales)
3. [Arquitectura del Sistema](#arquitectura-del-sistema)
4. [Cómo Funciona](#cómo-funciona)
5. [Guía de Integración](#guía-de-integración)
6. [API Completa](#api-completa)
7. [Métricas y Reportes](#métricas-y-reportes)
8. [Casos de Uso](#casos-de-uso)
9. [Preguntas Frecuentes](#preguntas-frecuentes)

---

## 🎯 Visión General

El **Adaptive Voting System v4.0** es un sistema de votación inteligente que aprende continuamente de cada trade y especializa automáticamente cada indicador en su área óptima de rendimiento.

### ✨ Problema que Resuelve

Los sistemas de trading tradicionales usan pesos fijos para todos los indicadores, ignorando que:
- **Un indicador puede ser excelente en ciertos contextos y malo en otros**
- **El mercado cambia constantemente** (sesiones, volatilidad, tendencias)
- **No todos los indicadores deben tener el mismo peso todo el tiempo**

### 🚀 Solución

Este sistema:
1. **Aprende tras cada trade** qué indicador funcionó bien en qué contexto
2. **Especializa cada indicador** en las condiciones donde es experto
3. **Asigna pesos dinámicos** según el contexto actual del mercado
4. **Se re-evalúa automáticamente** cada N trades para adaptarse a cambios del mercado

---

## 🌟 Características Principales

### 1. **Aprendizaje Contextual Profundo**

El sistema rastrea el rendimiento de cada indicador en **60 contextos diferentes**:

- **3 Sesiones**: Asia (00:00-08:00 GMT) | Londres (08:00-16:00 GMT) | NY (13:00-22:00 GMT)
- **2 Niveles de Volatilidad**: Baja (ATR < percentil 40) | Alta (ATR ≥ percentil 40)
- **2 Direcciones**: Alcista | Bajista
- **3 Regímenes**: Tendencia (ADX > 25) | Rango (ADX < 20) | Transición (ADX 20-25)

**Total**: 5 indicadores × 3 sesiones × 2 volatilidades × 2 direcciones = **60 micro-cerebros**

### 2. **Sistema de Especialización Automático**

Cada indicador es evaluado en 5 niveles de expertise:

| Nivel | Requisitos | Beneficio |
|-------|-----------|-----------|
| **MASTER** | WR > 65%, ≥100 trades, Sharpe > 1.5 | +30% peso bonus |
| **EXPERT** | WR 58-65%, ≥50 trades, Sharpe > 1.0 | +20% peso bonus |
| **COMPETENT** | WR 52-58%, ≥30 trades | +10% peso bonus |
| **NOVICE** | WR 45-52%, <30 trades | Peso base |
| **NONE** | <10 trades | -50% peso penalty |

### 3. **Pesos Dinámicos Adaptativos**

El peso de cada indicador se calcula con la fórmula:

```
Peso Final = (Base + Bonuses - Penalties) × ContextMatch × Performance

Donde:
- Base: Peso global del indicador (0.15-0.25)
- Bonuses: Expertise + Trend + Streak (hasta +0.65)
- Penalties: Degradación + No confiable (hasta -0.50)
- ContextMatch: Qué tan bien match el contexto (0.3-1.0)
- Performance: Score de WR × Sharpe × Consistency (0-1)
```

### 4. **Re-evaluación Automática**

Cada **100 trades** (configurable), el sistema:
1. Analiza todos los contextos
2. Re-asigna especializaciones
3. Actualiza rankings globales
4. Detecta cambios en el mercado
5. Adapta estrategia

### 5. **Métricas Avanzadas**

Para cada indicador en cada contexto, se calculan:

**Métricas Básicas**:
- Win Rate (WR)
- Total Profit
- Trades ejecutados
- Rachas máximas

**Métricas Avanzadas**:
- **Sharpe Ratio**: Rendimiento ajustado por riesgo
- **Profit Factor**: Ganancia promedio / Pérdida promedio
- **Recovery Factor**: Profit total / Drawdown máximo
- **Consistency Score**: Medida de confiabilidad (0-1)
- **Performance Trend**: Mejorando (+1) / Estable (0) / Empeorando (-1)

**EMAs Dinámicos**:
- EMA del Win Rate (alpha=0.1): Responde rápido a cambios
- EMA del Profit (alpha=0.15): Suaviza volatilidad

---

## 🏗️ Arquitectura del Sistema

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────┐
│            AdaptiveVotingSystem (Clase Principal)           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐      ┌──────────────────┐           │
│  │ ContextDetector  │──────│ Performance      │           │
│  │                  │      │ Matrix 4D        │           │
│  │ - Sesión         │      │ [5][3][2][2]     │           │
│  │ - Volatilidad    │      │                  │           │
│  │ - Régimen        │      │ 60 contextos     │           │
│  │ - Dirección      │      │                  │           │
│  └──────────────────┘      └──────────────────┘           │
│           │                         │                      │
│           ▼                         ▼                      │
│  ┌─────────────────────────────────────────┐              │
│  │   Specialization Manager                │              │
│  │   - Asigna expertise levels             │              │
│  │   - Identifica mejores contextos        │              │
│  │   - Calcula rankings globales           │              │
│  └─────────────────────────────────────────┘              │
│           │                                                │
│           ▼                                                │
│  ┌─────────────────────────────────────────┐              │
│  │   Adaptive Weight Calculator            │              │
│  │   - Context matching                    │              │
│  │   - Bonuses y penalties                 │              │
│  │   - Normalización                       │              │
│  └─────────────────────────────────────────┘              │
│           │                                                │
│           ▼                                                │
│  ┌─────────────────────────────────────────┐              │
│  │   Voting Executor                       │              │
│  │   - Combina señales con pesos           │              │
│  │   - Calcula consenso                    │              │
│  │   - Genera resultado final              │              │
│  └─────────────────────────────────────────┘              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Datos

```
1. Tick Nuevo
   ↓
2. Obtener Señales de 5 Indicadores
   ↓
3. ContextDetector → Detecta contexto actual
   ↓
4. GenerateVotingWeights() → Calcula pesos dinámicos
   ↓
5. ExecuteVoting() → Combina señales con pesos
   ↓
6. ¿Hay consenso?
   SÍ → Ejecutar Trade
   NO → Esperar
   ↓
7. Cuando el Trade Cierra
   ↓
8. LearnFromTrade() → Actualiza estadísticas
   ↓
9. ¿Han pasado 100 trades?
   SÍ → ReevaluateSpecializations()
   ↓
10. Sistema actualizado y listo para siguiente señal
```

---

## 🔧 Cómo Funciona

### Fase 1: Detección de Contexto

```cpp
MarketContextSnapshot context = contextDetector.DetectCurrentContext();

// context contiene:
// - session: ASIA / LONDON / NY
// - volatility: LOW / HIGH
// - regime: TRENDING / RANGING / TRANSITION
// - direction: BULLISH / BEARISH
// - Métricas: ATR, Spread, Momentum, etc.
```

### Fase 2: Cálculo de Pesos Dinámicos

Para cada indicador, el sistema calcula:

```cpp
DynamicWeight weight;

// 1. Context Match: ¿Este indicador es bueno en este contexto?
weight.contextMatchScore =
    IsExpertInContext(indicator, context) ? 1.0 :
    GetExpertiseLevel(indicator, context) / 4.0;

// 2. Performance Score
weight.performanceScore =
    WinRate × 0.35 +
    SharpeScore × 0.25 +
    ConsistencyScore × 0.25 +
    ProfitFactorScore × 0.15;

// 3. Bonuses
weight.expertiseBonus =
    MASTER: +0.30 | EXPERT: +0.20 | COMPETENT: +0.10;

weight.trendBonus =
    Mejorando: +0.15 | Estable: +0.08;

weight.streakBonus =
    ≥3 wins: +0.15 | ≥2 wins: +0.08;

// 4. Penalties
weight.degradationPenalty =
    Empeorando fuerte: -0.25 | Empeorando: -0.12;

weight.unreliabilityPenalty =
    No confiable: -0.15;

// 5. Peso Final
weight.finalWeight =
    (base + bonuses - penalties) × contextMatch × performance;

// 6. Filtrar si es muy bajo
weight.isActive = (weight.finalWeight >= 0.08);
```

### Fase 3: Votación

```cpp
// Cada indicador vota con su señal y confianza
buyScore = Σ(signal[i] × confidence[i] × weight[i])  // para signals > 0
sellScore = Σ(|signal[i]| × confidence[i] × weight[i])  // para signals < 0

// Calcular ratios
totalScore = buyScore + sellScore;
buyRatio = buyScore / totalScore;
sellRatio = sellScore / totalScore;

// Decidir
if (buyRatio > consensusThreshold):  // default: 0.65
    return BUY
elif (sellRatio > consensusThreshold):
    return SELL
else:
    return NO_CONSENSUS
```

### Fase 4: Aprendizaje

Cuando el trade cierra:

```cpp
void LearnFromTrade(result, won, profit) {
    // Para cada indicador que participó
    for (indicator in activeIndicators) {
        // Actualizar métricas en contexto específico
        context = result.context;
        cell = performanceMatrix[indicator][context];

        cell.metrics.Update(won, profit);
        cell.UpdateExpertiseLevel();

        // Actualizar EMAs
        cell.metrics.emaWinRate =
            0.1 × (won ? 1.0 : 0.0) + 0.9 × emaWinRate;

        cell.metrics.emaProfit =
            0.15 × profit + 0.85 × emaProfit;

        // Detectar tendencia de performance
        if (emaWinRate > historicalWR + 0.05):
            performanceTrend = +1.0;  // Mejorando
        elif (emaWinRate < historicalWR - 0.05):
            performanceTrend = -1.0;  // Empeorando
    }
}
```

### Fase 5: Re-evaluación (cada 100 trades)

```cpp
void ReevaluateSpecializations() {
    // 1. Analizar todos los contextos
    for (cada contexto de los 60) {
        // Encontrar mejor indicador en este contexto
        bestIndicator = GetBestPerformer(context);

        // Actualizar especialización
        if (expertise >= EXPERT):
            specialization[indicator].AddExpertContext(context);
    }

    // 2. Calcular rankings globales
    for (indicator in indicators) {
        globalScore =
            WR × 0.4 + SharpeScore × 0.3 + ProfitFactorScore × 0.3;

        // Ordenar y asignar ranks 1-5
    }

    // 3. Mostrar reporte
    PrintPerformanceReport();
}
```

---

## 📘 Guía de Integración

### Paso 1: Incluir el Sistema

```cpp
#include "AdaptiveVotingSystem.mqh"

// Crear instancia global
AdaptiveVotingSystem g_votingSystem;
```

### Paso 2: Inicializar en OnInit()

```cpp
int OnInit() {
    if (!g_votingSystem.Initialize(_Symbol, PERIOD_CURRENT)) {
        Print("ERROR: No se pudo inicializar voting system");
        return INIT_FAILED;
    }

    return INIT_SUCCEEDED;
}
```

### Paso 3: Generar Señales de tus Indicadores

```cpp
void OnTick() {
    // Obtener señales de tus 5 indicadores
    int signals[5];
    double confidences[5];

    // Indicador 0: S/R Levels
    signals[0] = GetSRLevelsSignal();        // 1, 0, o -1
    confidences[0] = GetSRLevelsConfidence(); // 0.0 - 1.0

    // Indicador 1: ML Neural
    signals[1] = GetMLNeuralSignal();
    confidences[1] = GetMLNeuralConfidence();

    // ... (resto de indicadores)
}
```

### Paso 4: Generar Pesos y Votar

```cpp
void OnTick() {
    // ... (después de obtener señales)

    // Generar pesos dinámicos
    DynamicWeight weights[];
    g_votingSystem.GenerateVotingWeights(weights);

    // Ejecutar votación
    VotingResult result = g_votingSystem.ExecuteVoting(
        signals,
        confidences,
        weights
    );

    // Verificar consenso
    if (result.hasConsensus && result.confidence > 0.70) {
        // Ejecutar trade
        ExecuteTrade(result.finalDirection);
    }
}
```

### Paso 5: Aprender del Resultado (CRÍTICO!)

```cpp
void OnTradeClose(VotingResult originalResult) {
    // Cuando el trade cierra, notificar al sistema

    bool won = (tradeProfit > 0);
    double profit = tradeProfit;
    int barsToClose = CalculateBarsToClose();

    // ¡ESTO ES CRÍTICO! Sin esto, el sistema no aprende
    g_votingSystem.LearnFromTrade(
        originalResult,  // Resultado original de la votación
        won,             // true si ganó
        profit,          // Profit/loss en $
        barsToClose      // Opcional: barras hasta cierre
    );
}
```

### Paso 6: Reportes y Monitoreo

```cpp
void OnTimer() {
    // Mostrar reporte completo cada hora
    g_votingSystem.PrintPerformanceReport();

    // Exportar a CSV para análisis externo
    g_votingSystem.ExportToCSV();
}
```

---

## 🔌 API Completa

### Clase: AdaptiveVotingSystem

#### Constructor y Destructor

```cpp
AdaptiveVotingSystem()
~AdaptiveVotingSystem()  // Auto-guarda datos
```

#### Métodos Públicos

```cpp
// Inicialización
bool Initialize(
    string symbol = "",              // Símbolo (default: _Symbol)
    ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT
);

// Generar pesos dinámicos
bool GenerateVotingWeights(
    DynamicWeight &weights[]         // OUT: Array de pesos calculados
);

// Ejecutar votación
VotingResult ExecuteVoting(
    int signals[],                   // Señales: 1=BUY, -1=SELL, 0=NEUTRAL
    double confidences[],            // Confianzas: 0.0-1.0
    DynamicWeight &weights[]         // Pesos previamente calculados
);

// Aprender de trade (¡LLAMAR SIEMPRE!)
void LearnFromTrade(
    VotingResult &votingResult,      // Resultado original de votación
    bool won,                        // true si ganó
    double profit,                   // Profit/loss en $
    int barsToClose = 0              // Opcional: barras hasta cierre
);

// Re-evaluar especializaciones manualmente
void ReevaluateSpecializations();

// Reportes
void PrintPerformanceReport();
bool ExportToCSV(string filename = "");

// Persistencia (auto, pero puedes forzar)
void SavePerformanceData();
void LoadPerformanceData();
```

#### Configuración

```cpp
// Cambiar configuración (antes de Initialize)
void SetMinSamplesForReliability(int samples);  // Default: 20
void SetTradesUntilReeval(int trades);          // Default: 100
void SetMinWeightThreshold(double threshold);   // Default: 0.08
void SetConsensusThreshold(double threshold);   // Default: 0.65
```

---

## 📊 Métricas y Reportes

### Reporte de Performance Completo

```
╔═══════════════════════════════════════════════════════════════╗
║         📊 REPORTE DE PERFORMANCE - VOTING SYSTEM v4.0      ║
╚═══════════════════════════════════════════════════════════════╝

┌─ ESTADÍSTICAS GLOBALES ──────────────────────────────────────┐
│ Total de Trades del Sistema: 500
│ Tiempo Activo: 168 horas
│ Última Re-evaluación: 2025-01-15 14:30:00
│ Próxima Re-evaluación: 50 trades
└───────────────────────────────────────────────────────────────┘

┌─ PERFORMANCE POR INDICADOR (GLOBAL) ─────────────────────────┐
│ #1 ML_Neural
│    Trades: 450 | WR: 62.5% | Profit: $15,230.00 | Sharpe: 1.82
│    Streak: 5 | MaxDD: $2,100.00 | Expertise Zones: 18
│
│ #2 RSI_Divergence
│    Trades: 420 | WR: 58.3% | Profit: $12,890.00 | Sharpe: 1.45
│    Streak: 3 | MaxDD: $1,850.00 | Expertise Zones: 15
│
│ #3 Momentum
│    Trades: 380 | WR: 55.7% | Profit: $9,450.00 | Sharpe: 1.23
│    Streak: -2 | MaxDD: $2,300.00 | Expertise Zones: 12
│
│ #4 SR_Levels
│    Trades: 410 | WR: 54.2% | Profit: $8,120.00 | Sharpe: 1.10
│    Streak: 1 | MaxDD: $2,050.00 | Expertise Zones: 10
│
│ #5 Volume_Profile
│    Trades: 390 | WR: 51.8% | Profit: $5,890.00 | Sharpe: 0.95
│    Streak: 2 | MaxDD: $2,400.00 | Expertise Zones: 8
└───────────────────────────────────────────────────────────────┘

┌─ TOP CONTEXTOS POR INDICADOR ────────────────────────────────┐
│ ML_Neural:
│    Best Context: 2_1_1_0 (Score: 0.892)
│    Expertise: MASTER
│
│ RSI_Divergence:
│    Best Context: 1_0_0_1 (Score: 0.845)
│    Expertise: EXPERT
│
│ ... (resto de indicadores)
└───────────────────────────────────────────────────────────────┘

┌─ MATRIZ DE CONTEXTOS (Top Performers) ───────────────────────┐
│ ASIA_LOW_BEAR: #1 SR_Levels (0.782) | #2 RSI_Divergence (0.745)
│ ASIA_LOW_BULL: #1 ML_Neural (0.823) | #2 Momentum (0.791)
│ ASIA_HIGH_BEAR: #1 Volume_Profile (0.801) | #2 ML_Neural (0.768)
│ ... (todos los 60 contextos)
└───────────────────────────────────────────────────────────────┘

╚═══════════════════════════════════════════════════════════════╝
```

### Exportación a CSV

```csv
Indicator,Session,Volatility,Direction,Trades,WinRate,Profit,Sharpe,MaxDD,Expertise,PerformanceScore
ML_Neural,LONDON,HIGH,BULLISH,45,0.6889,2350.50,1.92,450.00,MASTER,0.892
SR_Levels,ASIA,LOW,BEARISH,38,0.6842,1890.25,1.78,320.00,EXPERT,0.865
...
```

---

## 💡 Casos de Uso

### Caso 1: Indicador que Solo Funciona en Sesión NY

```
Resultado del Aprendizaje:
- SR_Levels tiene WR 45% en ASIA
- SR_Levels tiene WR 68% en NY (MASTER level)

Acción del Sistema:
- En sesión ASIA: peso de SR_Levels = 0.10 (filtrado o muy bajo)
- En sesión NY: peso de SR_Levels = 0.35 (máximo peso + bonuses)
```

### Caso 2: Indicador Degradándose

```
Situación:
- ML_Neural tenía WR 65% hace 100 trades
- Ahora tiene EMA_WR 58% (trend = -1.0, empeorando)

Acción del Sistema:
- Aplicar degradationPenalty = -0.25
- Reducir peso final de 0.30 a 0.15
- Alerta: "ML_Neural está degradándose en contexto LONDON_HIGH_BULL"
- En próxima re-evaluación: bajar de MASTER a EXPERT
```

### Caso 3: Alta Volatilidad Inesperada

```
Situación:
- ATR sube a percentil 85 (volatilidad extrema)
- Contexto cambia de LOW_VOL a HIGH_VOL

Acción del Sistema:
- Re-calcular pesos para nuevo contexto
- Momentum (experto en HIGH_VOL) sube de peso 0.18 a 0.32
- SR_Levels (malo en HIGH_VOL) baja de peso 0.22 a 0.12
- Sistema adapta automáticamente sin intervención manual
```

### Caso 4: Exploración de Nuevo Contexto

```
Situación:
- Un contexto raro tiene solo 8 trades de muestra
- expertiseLevel = NONE

Acción del Sistema:
- 95% de veces: usar indicadores con datos confiables
- 5% de veces: permitir "exploración" para recopilar datos
- Una vez alcance 20 trades: empezar a confiar en los datos
- A los 50 trades: si WR > 58%, promover a EXPERT
```

---

## ❓ Preguntas Frecuentes

### ¿Cuántos trades necesito para que el sistema funcione bien?

- **Mínimo**: 100 trades para ver primeros patrones
- **Recomendado**: 500+ trades para aprendizaje robusto
- **Óptimo**: 1000+ trades para especialización completa

### ¿Con qué frecuencia se re-evalúa?

Por defecto, cada **100 trades**. Puedes cambiarlo:

```cpp
g_votingSystem.SetTradesUntilReeval(50);  // Más frecuente
g_votingSystem.SetTradesUntilReeval(200); // Menos frecuente
```

### ¿Qué pasa si un indicador nunca vota en ciertos contextos?

El sistema maneja esto elegantemente:
- Contextos sin datos mantienen `expertiseLevel = NONE`
- Peso aplicado es muy bajo (0.05-0.10)
- En práctica, el indicador es "filtrado" en ese contexto
- El sistema prioriza indicadores con datos confiables

### ¿Puedo cambiar el umbral de consenso?

Sí:

```cpp
g_votingSystem.SetConsensusThreshold(0.70);  // Más estricto (70%)
g_votingSystem.SetConsensusThreshold(0.60);  // Más permisivo (60%)
```

### ¿Los datos se guardan automáticamente?

Sí, cada **50 trades** (configurable) y al cerrar el EA. Archivo: `AdaptiveVoting_EURUSD.bin`

### ¿Puedo usar más de 5 indicadores?

Sí, pero requiere modificar el código:

```cpp
// En AdaptiveVotingSystem.mqh, cambiar:
#define MAX_INDICATORS 7  // Aumentar a 7

// Actualizar matriz:
ContextualPerformanceCell m_performanceMatrix[7][3][2][2];
IndicatorSpecialization m_specializations[7];
```

### ¿Funciona en todos los timeframes?

Sí, el sistema se adapta automáticamente al timeframe especificado en `Initialize()`.

### ¿Qué pasa si el mercado cambia radicalmente?

El sistema se adapta:
1. Los **EMAs** detectan cambios rápidamente (alpha = 0.1-0.15)
2. La **re-evaluación periódica** reorganiza especializaciones
3. Los **bonuses/penalties** responden a tendencias de performance
4. Los indicadores que degradan pierden peso automáticamente

---

## 🎓 Mejores Prácticas

### ✅ DO (Hacer)

1. **Siempre llamar LearnFromTrade()** cuando un trade cierra
2. **Esperar al menos 200 trades** antes de confiar completamente en el sistema
3. **Monitorear reportes** cada 100 trades
4. **Exportar a CSV** periódicamente para análisis externo
5. **Usar señales de calidad** de tus indicadores (garbage in = garbage out)
6. **Mantener configuración estable** durante aprendizaje inicial

### ❌ DON'T (No hacer)

1. **No cambiar constantemente** los umbrales de configuración
2. **No ignorar** las alertas de degradación
3. **No ejecutar trades** sin consenso suficiente (confidence < 0.65)
4. **No hacer backtesting** sin primero entrenar en forward testing
5. **No mezclar** datos de diferentes símbolos
6. **No re-inicializar** el sistema frecuentemente (pierdes aprendizaje)

---

## 🚀 Próximos Pasos

1. **Integrar** el sistema en tu EA
2. **Ejecutar** 500+ trades en demo
3. **Analizar** reportes y CSV exports
4. **Ajustar** configuración basada en resultados
5. **Escalar** a live trading cuando WR > 55%

---

## 📞 Soporte

Si tienes preguntas o encuentras bugs:
1. Revisa esta documentación completa
2. Verifica el archivo de ejemplo: `AdaptiveVotingExample.mq5`
3. Analiza los logs del sistema (muy detallados)

---

## 📄 Licencia

Advanced Trading System 2025 - Todos los derechos reservados

---

**¡Feliz Trading!** 🎯📈
