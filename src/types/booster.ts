/**
 * Code Quality Booster types.
 * Implements AdaBoost-inspired iterative code quality analysis.
 */

import { Finding, Verdict, StaticAnalysisSummary } from './skill';

/** Analysis passes in the boosting process */
export enum BoostingPass {
  STATIC_ANALYSIS = 'static',
  AI_SEMANTIC = 'ai-semantic',
  DEEP_SPECIALIZED = 'deep-specialized',
}

/** Specializations available in Pass 3 */
export enum DeepSpecialization {
  SECURITY = 'security',
  PERFORMANCE = 'performance',
  LOGGING = 'logging',
  AI_SMELL = 'ai-smell',
}

/** Reasons for stopping the boosting loop */
export enum ConvergenceReason {
  MAX_PASSES_REACHED = 'max-passes',
  QUALITY_THRESHOLD = 'quality-achieved',
  DIMINISHING_RETURNS = 'diminishing-returns',
  TIMEOUT = 'timeout',
  NO_NEW_FINDINGS = 'no-new-findings',
}

/** AI-generated code smell types */
export enum AiSmellType {
  EXCESSIVE_DUPLICATION = 'excessive-duplication',
  HALLUCINATED_API = 'hallucinated-api',
  OVER_ENGINEERING = 'over-engineering',
  SHALLOW_ERROR_HANDLING = 'shallow-error-handling',
  MISSING_EDGE_CASES = 'missing-edge-cases',
  VERBOSE_BUT_SHALLOW = 'verbose-but-shallow',
}

/** Performance issue types */
export enum PerformanceIssueType {
  N_PLUS_ONE = 'n-plus-one',
  BLOCKING_IO = 'blocking-io',
  MEMORY_LEAK = 'memory-leak',
  INEFFICIENT_LOOP = 'inefficient-loop',
  EXCESSIVE_ALLOCATION = 'excessive-allocation',
  SYNCHRONIZATION_BOTTLENECK = 'synchronization-bottleneck',
}

/** Log quality issue types */
export enum LogIssueType {
  MISSING_STRUCTURED_LOG = 'missing-structured-log',
  SENSITIVE_DATA_EXPOSURE = 'sensitive-data-exposure',
  WRONG_LOG_LEVEL = 'wrong-log-level',
  MISSING_ERROR_LOG = 'missing-error-log',
  EXCEPTION_WITHOUT_STACKTRACE = 'exception-without-stacktrace',
}

/** Weight tracking for AdaBoost-style focusing */
export interface LineWeight {
  readonly lineNumber: number;
  readonly weight: number;
  readonly passesClean: number;
  readonly complexity: number;
}

/** Line range for focus regions */
export interface LineRange {
  readonly start: number;
  readonly end: number;
  readonly avgWeight: number;
}

/** A finding with boost metadata */
export interface BoostedFinding extends Finding {
  readonly detectedInPasses: readonly BoostingPass[];
  readonly baseWeight: number;
  readonly boostMultiplier: number;
  readonly finalScore: number;
  readonly confidence: number;
}

/** Result of a single boosting pass */
export interface PassResult {
  readonly pass: BoostingPass;
  readonly passNumber: number;
  readonly findings: readonly BoostedFinding[];
  readonly newFindings: number;
  readonly duration: number;
  readonly focusRegions: readonly LineRange[];
  readonly toolsUsed: readonly string[];
}

/** Self-healing fix suggestion */
export interface FixSuggestion {
  readonly finding: BoostedFinding;
  readonly suggestedCode: string;
  readonly confidence: number;
  readonly verified: boolean;
}

/** Convergence criteria configuration */
export interface ConvergenceCriteria {
  readonly maxPasses: number;
  readonly minNewFindingsRatio: number;
  readonly qualityThreshold: number;
  readonly diminishingReturns: number;
  readonly timeoutSeconds: number;
}

/** Default convergence settings */
export const DEFAULT_CONVERGENCE: ConvergenceCriteria = {
  maxPasses: 3,
  minNewFindingsRatio: 0.05,
  qualityThreshold: 85,
  diminishingReturns: 0.02,
  timeoutSeconds: 300,
} as const;

/** Weight adjustment constants */
export const WEIGHT_CONSTANTS = {
  ALPHA_INCREASE: 1.5,
  ALPHA_DECREASE: 0.5,
  COMPLEXITY_FACTOR: 0.1,
  METHOD_BOUNDARY_BOOST: 1.2,
  MULTI_PASS_BOOST_2: 1.5,
  MULTI_PASS_BOOST_3: 2.0,
} as const;

/** Boosting state tracked across iterations */
export interface BoostingState {
  readonly file: string;
  readonly passResults: readonly PassResult[];
  readonly weightMap: readonly LineWeight[];
  readonly convergenceReason?: ConvergenceReason;
  readonly qualityScore: number;
  readonly elapsedSeconds: number;
}

/** Extended static analysis summary with AI and deep check counts */
export interface ExtendedAnalysisSummary extends StaticAnalysisSummary {
  readonly aiReview: {
    readonly findings: number;
    readonly focusRegions: number;
  };
  readonly deepChecks: {
    readonly security: number;
    readonly performance: number;
    readonly logging: number;
    readonly aiSmell: number;
  };
}

/** Final aggregated result from Code Quality Booster */
export interface CodeQualityBoosterResult {
  readonly file: string;
  readonly scanDate: string;
  readonly finalScore: number;
  readonly verdict: Verdict;
  readonly convergence: ConvergenceReason;
  readonly totalPasses: number;
  readonly passResults: readonly PassResult[];
  readonly aggregatedFindings: readonly BoostedFinding[];
  readonly multiPassConfirmations: readonly BoostedFinding[];
  readonly fixSuggestions: readonly FixSuggestion[];
  readonly toolSummary: ExtendedAnalysisSummary;
  readonly boostingProgression: readonly BoostingProgressEntry[];
}

/** Entry in boosting progression table */
export interface BoostingProgressEntry {
  readonly pass: BoostingPass;
  readonly passNumber: number;
  readonly newFindings: number;
  readonly cumulative: number;
  readonly deltaPercent: number;
  readonly focusDescription: string;
}
